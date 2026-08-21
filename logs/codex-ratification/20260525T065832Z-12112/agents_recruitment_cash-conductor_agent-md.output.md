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
session id: 019e5ded-9a11-7743-bf11-2280f129bda1
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

**Status:** Proposed.
**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R17 closed §8 sibling files + D1/bridge prereqs + §3 audit-row signatures (4-row chase lifecycle sequence). R19 fixes (today): split draft body out of decision_log payload into vault path (per ADR-002 vault/Postgres split), recent_edit schema R access cite correction, Stage 3 ESC code disambiguation. Awaits Q1 LOI + accounting + Open Banking commercial signups + Founder Decision D1 resolved + autosend bridge built (Concierge W10) + W7 build slice.
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
**Build complexity:** L (2 weeks) per ULTRAPLAN A4 line 540.
**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 257; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 182-187 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 257-262; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).

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

### Per-trigger auth requirements

- **Webhook (v1.0 primary path):** per-provider HMAC / bearer token verified at the ingress per `tools.yaml` capability declarations (matching the Scribe webhook auth pattern).
- **Cron (daily-sweep + weekly-report):** runs under `ifos_user` OS account (per Day-4 §6.5 tenant-provision script) via systemd-timer-style invocation; no inbound auth (process started by cron daemon with the right OS user identity). RLS isolation via `app.current_tenant` SET LOCAL per Day-4 §7.
- **Manual triggers (ifosctl below):** require operator OS account in the `ifos-operators` group; per-invocation `--tenant <slug>` is verified against the operator's tenant access list in `tenant_adapters` before execution. Founder + Hire #1 are the v1.0 ifosctl-authorized operators per master brief §8.2 line 604.
- **v1.1+ Brain UI:** session-cookie auth + per-tenant operator role check (deferred).

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

### Output 2 — Payment-chase drafts (yellow tier internal; Cash Conductor INITIATES the orange-tier customer send via Concierge approval bridge)

For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type per autosend-policy.yaml line 257) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.

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

Each draft writes to vault FIRST then produces TWO `decision_log` rows on the cash-conductor agent_name (per ADR-002 vault/Postgres split — narrative content in vault, structured audit metadata in Postgres):

0. Draft body written to `/vault/<tenant>/cash-conductor-drafts/<draft_id>.md` (chmod 0600); the YAML+body structure above lands as the canonical narrative source.
1. `phase='output'`, `output_type='chase_draft_generated'`, payload carries draft METADATA only: `{vault_path, body_sha256, voice_score, escalation_position, days_overdue, amount_due}`. The draft body itself is NOT in the payload — vault path is the authority.
2. `phase='action'`, `action_type='xero_reminder_draft_internal'` (yellow tier per autosend-policy.yaml lines 182-187), payload links to the draft via the vault path — this row records that Cash Conductor classified the draft as yellow-tier internal.

When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml line 257; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).

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

14 steps. Per ADR-003 §3 agent-bundle pattern + the review-agent-bundle Codex ratification skill §4 ("every output/action step MUST call hh_decision_*"): every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. Master brief §8.1 Change 2 mandates the three-call minimum per agent run (`trigger`, `output`, `action`); the per-step mandatory-write discipline is the agent-bundle contract extension.

```
0. Session start (webhook OR cron OR manual)
   → context.sh hydrates: tenant config + accounting-provider auth +
     Open Banking auth + voice corpus + tone rules
   → hh_decision_trigger("session_start", "<webhook|cron|manual>")

1. Provider auth refresh
   → accounting: Xero/QuickBooks/Sage OAuth refresh per provider
   → Open Banking: TrueLayer/Plaid UK 90-day token refresh (CRITICAL —
     gotcha per ULTRAPLAN A4 line 541); staged ESC_OPEN_BANKING_TOKEN_AGING:
     ≤30d info, ≤14d warn, ≤7d blocking (operator must re-authorise)
   → ESC_ACCOUNTING_AUTH or ESC_OPEN_BANKING_AUTH on auth failure
   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
     "accounting:<ok|fail>; open_banking:<ok|fail>; token_aging_stage:<info|warn|blocking|fresh>")

2. Event router (mode-dependent)
   → if mode=webhook: parse event_type → routes to Step 3-7 path
   → if mode=daily-sweep: routes to Step 4 (invoice ingest) → Step 5 (reconciliation) → Step 7 (chase generation pass) catch-up sequence; sweeps run the full reconciliation-first-then-chase pipeline
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
   → Stage 3 (single low-confidence exact-amount match): flag in weekly-report
     exception list; NO ESC fire (per §6 row distinguishing Stage 3 from
     Stage 4 — catalogue defines ESC_RECONCILIATION_AMBIGUOUS as multi-
     candidate, not low-confidence single). W4-polish backlog: register
     `ESC_RECONCILIATION_LOW_CONFIDENCE` OR widen catalogue trigger.
   → Stage 4 (fuzzy multi-candidate within tolerance): fire ESC_RECONCILIATION_AMBIGUOUS
     per catalogue (multiple candidates); queue for consultant review.
   → flag Stage 5 (unmatched) in weekly-report exception list
   → hh_decision_output("reconciliation_pass", "tenant:<slug>",
     "stage1_2:<N>; stage3:<N>; stage4:<N>; stage5:<N>")

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
     sent (read from `cash_conductor_invoices.last_chase_position` — v0.3
     schema-backed field per migration §3; NOT from decision_log payload)
   → if position=4: STOP — operator review (no auto-draft).
     hh_decision_output("chase_position_4_operator_review",
     "invoice:<id>", "age_days:<N>; prior_chases:3") — records the
     operator-review outcome explicitly per §4 mandatory-write discipline
   → else: proceed to Step 8

8. LLM chase-draft generation (per overdue invoice)
   → prompt = (invoice details + client context + position-N tone +
     voice corpus + tone rules)
   → output = email body + subject
   → voice classifier scores against tenant style (≥0.75 for position 1-2;
     ≥0.80 for position 3 per §3.2)
   → ESC_VOICE_DRIFT if classifier <threshold after 3 retries
   → hh_decision_output("chase_draft_generated", "invoice:<id>",
     "position:<N>; voice_score:<N>; words:<N>")

9. Chase-draft validation (Gate A specifics)
   → verify: invoice_number cited matches invoice_id
   → verify: amount_due cited matches accounting record
   → verify: client_contact_email matches active billing contact
   → verify: NOT paid in last 24h (re-query accounting)
   → ESC code mapping by failure class:
     - invoice_number / amount_due / paid-invoice-precondition mismatch →
       `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint failure)
     - client_contact_email / addressee mismatch (chase routed to wrong
       customer) → `ESC_ADDRESSEE_MISMATCH` (per catalogue §2.10 — explicitly
       blocking for Cash Conductor invoice/chase addressee resolution)
     `ESC_AUTOSEND_BLOCKED` is reserved for red-tier action attempts per
     catalogue line 41; Cash Conductor's chase pipeline is orange-tier.
   → hh_decision_output("chase_draft_validated", invoice_id, "passed")

10. Chase-draft queue to Concierge (opens orange-tier approval bridge)
    → POST internal API → Concierge agent receives draft
    → hh_decision_action("xero_reminder_draft_internal", "invoice:<id>",
      payload_hash, payload_preview) — tier=yellow internal-draft per
      autosend-policy.yaml line 182
    → hh_decision_action("xero_reminder_send_customer", "invoice:<id>",
      payload_hash, payload_preview) — tier=orange per autosend-policy.yaml
      line 257; Cash Conductor owns this action_type and OPENS the
      orange-approval-bridge; Concierge handles autosend-bridge call to
      operator (D1 path per Founder Decision)

11. (Operator approves via Concierge's bridge → Concierge transports the
    send → Cash Conductor receives webhook + records state mutation)
    → The orange-tier `xero_reminder_send_customer` action row was
      written by Cash Conductor at Step 10 (Cash Conductor owns this
      action_type per autosend-policy.yaml line 257; agent: cash-conductor).
      Concierge does NOT write its own action row for this — Concierge's
      role is approval-bridge + transport, not action-row authorship.
    → Concierge fires webhook back: chase_sent (transport completed)
    → Cash Conductor updates `cash_conductor_invoices.last_chase_position`
      and `last_chase_sent_at` (v0.3 schema-backed fields per migration §3)
    → hh_decision_output("cash_conductor_chase_sent_recorded",
      "invoice:<id>", "position:<N>; sent_at:<ISO>") — phase=output;
      green-tier internal status marker recording state mutation completion

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
    → hh_decision_action("cash_conductor_run_complete", "session:<session_id>",
      payload_hash, "run_mode:<mode>; matches:<N>; chases:<N>; report:<bool>")
      — hh_decision_action signature is (action_type, target, payload_hash,
      payload_preview) per agents/_shared/hook-helpers.sh contract
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
- Open Banking token ≥7 days from expiry (≤7d is blocking per ESC_OPEN_BANKING_TOKEN_AGING staged definition; ≤30d info + ≤14d warn are health-warning states that do NOT block Gate A, only signal upcoming reauth need)
- Accounting auth refresh succeeded in Step 1

Gate A failures fire either `ESC_AGENT_OUTPUT_SHAPE` (invoice/amount/paid-precondition miss; output-shape constraint) OR `ESC_ADDRESSEE_MISMATCH` (client_contact_email mismatch; blocking per catalogue §2.10 — explicit Cash Conductor invoice/chase addressee case). Draft stays in `/tmp` (auto-purged 24h); operator notified per the specific ESC route.

**Honesty note (per bilateral-disposition Cat-5):** Cash Conductor `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W7 build slice. The W7 build delivers `agents/recruitment/cash-conductor/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.

### Gate B — Outcome threshold (FD-tier closer metric)

Per ULTRAPLAN A4 line 539 verbatim: **"tenant DSO at month-3 ≥ 12 days lower than month-0 baseline"**.

DSO = Days Sales Outstanding = (Accounts Receivable / Total Credit Sales) × Number of Days.

Measured monthly via the weekly report's §2 trend. Month-0 baseline established at first pilot LOI signing (before Cash Conductor active). Month-3 target = month-0 minus 12 days.

This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).

---

## §6 — Escalation codes

Cash Conductor uses these ESC codes from `agents/_shared/escalation-codes.md`:

| Code | Trigger | Severity | Routing |
|---|---|---|---|
| `ESC_ACCOUNTING_AUTH` | Xero/QuickBooks/Sage OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
| `ESC_ACCOUNTING_WRITE_FAIL` | Accounting 4xx/5xx on reconciliation write | warn | operator_chat_id |
| `ESC_OPEN_BANKING_AUTH` | TrueLayer/Plaid UK auth fails after 2 retries | **blocking** | operator + ifos_oncall |
| `ESC_OPEN_BANKING_TOKEN_AGING` | Open Banking PSD2 consent approaching 90-day expiry (staged) | info ≤30d / warn ≤14d / **blocking** ≤7d (per catalogue §2.7) | operator_chat_id (info+warn); + ifos_oncall_chat_id at blocking stage |
| `ESC_RECONCILIATION_AMBIGUOUS` | Stage 4 fuzzy multi-candidate match within tolerance (per catalogue §2.10 — bank-feed payment line cannot match a single Xero invoice; multiple candidates) | warn | operator_chat_id |
| (Stage 3 low-confidence single-match review queue) | Stage 3 single low-confidence exact-amount match queued for consultant review — NOT ESC_RECONCILIATION_AMBIGUOUS (catalogue defines ambiguity as multi-candidate, not low-confidence single). v0.3 W4-polish backlog: add ESC_RECONCILIATION_LOW_CONFIDENCE for single-match-low-confidence case OR widen ESC_RECONCILIATION_AMBIGUOUS catalogue trigger. | flagged in weekly report exception list (no ESC fire at v0.3) | (weekly report aggregation) |
| `ESC_AUTOSEND_RACE` | Payment received between chase-draft and chase-send window | warn | operator_chat_id |
| `ESC_VOICE_DRIFT` | Chase voice classifier below threshold after 3 retries | warn | operator_chat_id |
| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in chase body | **blocking** | operator + ifos_oncall |
| `ESC_AGENT_OUTPUT_SHAPE` | Gate A miss on invoice_number / amount_due / paid-invoice-precondition (NOT addressee mismatch — that uses ESC_ADDRESSEE_MISMATCH) | warn | operator_chat_id |
| `ESC_ADDRESSEE_MISMATCH` | Gate A miss on client_contact_email / addressee resolution (per catalogue §2.10 Cash Conductor case) | **blocking** | operator + ifos_oncall |
| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
| `ESC_AUTOSEND_ORANGE_PENDING` | Chase draft awaiting consultant approval — heartbeat at ≥50% of declared timeout (per catalogue §2.9 trigger) | info | operator_chat_id (gentle reminder; no oncall CC) |

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
- **NOTE: Cash Conductor does NOT read `recent_edit`.** Per v0.3 supplement §2a access grants (line 723), Cash Conductor has W-only access — it WRITES recent_edit rows when consultants edit its chase drafts post-send, but does NOT READ them. Voice continuity for Cash Conductor relies on the tenant voice_corpus + tone_rule reads above. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries (LLM step internal to chase-draft generation; classifier scoring distinct from sample retrieval). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked by the canary (which has R access) for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.

Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.

---

## §8 — Build dependencies (W7-8 prerequisites)

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
| Concierge agent.md ratified Accepted (for chase-send routing contract; full Concierge production-build at W10-13, but Cash Conductor only depends on the Concierge agent.md contract being Accepted, not the full bundle being In Force) | Post-Concierge agent.md re-ratification | ⏸ |
| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
| `validate.sh` Gate A logic | Build at W7 start (~1 day; complex due to 4 validators) | ⏸ |
| `context.sh` hydration | Build at W7 start (~0.5 day) | ⏸ |
| `cycle.sh` orchestration (14-step) | Build at W7 start (~3 days; most complex of v1.0 agents) | ⏸ |
| `tools.yaml` MCP capability declarations (xero_oauth, quickbooks_oauth, sage_oauth, open_banking_truelayer / plaid, telegram_notify) | Build at W7 start (~1 day) | ⏸ |
| `cleanup.sh` post-run state purge (transient OAuth tokens; provider rate-limit caches) | Build at W7 start (~0.5 day) | ⏸ |
| 3 fixtures with golden outputs | Build at W7 start (~1 day) | ⏸ |
| **Founder Decision D1 (autosend orange-tier path) RESOLVED** — blocking for Cash Conductor's xero_reminder_send_customer action_type | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` D1 (currently Proposed) | ⏸ |
| **Autosend bridge implementation** (per D1 outcome) — Concierge W10 build delivers; blocking for orange-tier send writes | Concierge W10 build slice (~2 days for D1-A; less for D1-B/C) | ⏸ |
| Fallback: if D1 + bridge not ready by W7-8, Cash Conductor v1.0 downgrades to drafts-only (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` writes until D1 resolves + bridge ships) | v1.0 contingency | n/a |

**ADR-005 framing:** ADR-005 (Week-3 Diagnostic acceleration) notes Cash Conductor is unaffected by Bullhorn slips because it has zero Bullhorn dependency. v0.3 supplement: Cash Conductor pull-forward (from W7-8 to W4-5) is NOT explicitly authorised by ADR-005 §5.1 (that section number doesn't exist; earlier draft mis-cited). Pull-forward would require a separate ADR (e.g. ADR-007 if/when needed); accounting + Open Banking commercial signups remain founder-action gates regardless of timing.

---

## §9 — Status + open questions

**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start.

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
I’ll verify the cited project files directly before deciding, focusing on the agent-bundle structure, schema/action types, ESC catalogue, and the specific line citations that the artefact relies on.
exec
/bin/zsh -lc "test -f agents/recruitment/cash-conductor/agent.md && nl -ba agents/recruitment/cash-conductor/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Cash Conductor — the FD's evenings back
     2	
     3	**Status:** Proposed.
     4	**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R17 closed §8 sibling files + D1/bridge prereqs + §3 audit-row signatures (4-row chase lifecycle sequence). R19 fixes (today): split draft body out of decision_log payload into vault path (per ADR-002 vault/Postgres split), recent_edit schema R access cite correction, Stage 3 ESC code disambiguation. Awaits Q1 LOI + accounting + Open Banking commercial signups + Founder Decision D1 resolved + autosend bridge built (Concierge W10) + W7 build slice.
     5	**Date:** 2026-05-24.
     6	**Author:** Founder (Maddox) + Claude Code.
     7	**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
     8	**Build complexity:** L (2 weeks) per ULTRAPLAN A4 line 540.
     9	**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
    10	**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
    11	
    12	---
    13	
    14	## §1 — Output contract (one-paragraph screenshot)
    15	
    16	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    17	
    18	> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 257; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 182-187 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 257-262; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension).
    19	
    20	---
    21	
    22	## §2 — Invocation surface
    23	
    24	### Webhook (v1.0 primary path)
    25	
    26	```http
    27	POST https://<tenant>.ifos.app/agents/cash-conductor/webhook
    28	Authorization: Bearer <provider-shared-secret>
    29	Content-Type: application/json
    30	
    31	# Event types (per provider):
    32	# - Xero/QuickBooks/Sage: invoice.created, invoice.sent, invoice.viewed,
    33	#   invoice.paid, payment.received
    34	# - Open Banking (TrueLayer/Plaid UK): transaction.posted, balance.updated
    35	```
    36	
    37	Per-provider webhook auth handled in `tools.yaml`.
    38	
    39	### Cron (daily reconciliation sweep)
    40	
    41	```bash
    42	# 07:00 UTC daily — bank feed catch-up + invoice age scan
    43	0 7 * * * sudo -u ifos_user /usr/local/bin/ifos-cash-conductor.sh --tenant <slug> --mode daily-sweep
    44	```
    45	
    46	### Weekly report cron
    47	
    48	```bash
    49	# Monday 06:00 UTC — cash-flow report regeneration
    50	0 6 * * 1 sudo -u ifos_user /usr/local/bin/ifos-cash-conductor.sh --tenant <slug> --mode weekly-report
    51	```
    52	
    53	### Per-trigger auth requirements
    54	
    55	- **Webhook (v1.0 primary path):** per-provider HMAC / bearer token verified at the ingress per `tools.yaml` capability declarations (matching the Scribe webhook auth pattern).
    56	- **Cron (daily-sweep + weekly-report):** runs under `ifos_user` OS account (per Day-4 §6.5 tenant-provision script) via systemd-timer-style invocation; no inbound auth (process started by cron daemon with the right OS user identity). RLS isolation via `app.current_tenant` SET LOCAL per Day-4 §7.
    57	- **Manual triggers (ifosctl below):** require operator OS account in the `ifos-operators` group; per-invocation `--tenant <slug>` is verified against the operator's tenant access list in `tenant_adapters` before execution. Founder + Hire #1 are the v1.0 ifosctl-authorized operators per master brief §8.2 line 604.
    58	- **v1.1+ Brain UI:** session-cookie auth + per-tenant operator role check (deferred).
    59	
    60	### Manual triggers (v1.0)
    61	
    62	```bash
    63	ifosctl cash-conductor reconcile --tenant <slug> [--invoice <id>]
    64	ifosctl cash-conductor draft-chase --tenant <slug> --invoice <id>
    65	ifosctl cash-conductor weekly-report --tenant <slug>
    66	```
    67	
    68	### v1.1+ surfaces (deferred)
    69	
    70	- Brain UI cash-flow dashboard
    71	- Per-tenant Telegram daily summary
    72	- FD-mode end-of-month report (more detailed than weekly)
    73	
    74	---
    75	
    76	## §3 — Output shape
    77	
    78	Three outputs. All load-bearing.
    79	
    80	### Output 1 — Reconciliation rows (yellow tier)
    81	
    82	Per webhook event, Cash Conductor reconciles incoming bank deposits against the tenant's open invoice register. Match algorithm:
    83	
    84	| Stage | Match dimensions | Confidence |
    85	|---|---|---|
    86	| 1 | Exact amount + matching invoice reference in transaction memo | 0.98 |
    87	| 2 | Exact amount + matching payee name | 0.85 |
    88	| 3 | Exact amount + within-90-day-of-invoice-issue window | 0.70 |
    89	| 4 | Fuzzy amount (±0.5% rounding) + matching payee name | 0.65 |
    90	| 5 | Unmatched (queued for review) | <0.50 |
    91	
    92	Stages 1-2 auto-write reconciliation to accounting system (yellow tier; spot-check sampled). Stages 3-4 queue for consultant review. Stage 5 flagged in weekly report.
    93	
    94	Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'`, `tier='yellow'`, payload includes match confidence + match dimensions.
    95	
    96	### Output 2 — Payment-chase drafts (yellow tier internal; Cash Conductor INITIATES the orange-tier customer send via Concierge approval bridge)
    97	
    98	For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type per autosend-policy.yaml line 257) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
    99	
   100	Chase draft structure:
   101	
   102	```yaml
   103	draft_id: <uuid>
   104	invoice_id: <accounting-system-invoice-id>
   105	contact_email: <client-billing-contact-email>
   106	subject: "Friendly reminder — invoice <number> from <YYYY-MM-DD>"
   107	body_markdown: <voice-classified consultant-tone reminder>
   108	amount_due: <decimal>
   109	days_overdue: <int>
   110	prior_chases_sent: <int>
   111	escalation_ladder_position: 1-4 per §3.2 below
   112	expected_send_window: orange-tier approval expected within 24h
   113	```
   114	
   115	Each draft writes to vault FIRST then produces TWO `decision_log` rows on the cash-conductor agent_name (per ADR-002 vault/Postgres split — narrative content in vault, structured audit metadata in Postgres):
   116	
   117	0. Draft body written to `/vault/<tenant>/cash-conductor-drafts/<draft_id>.md` (chmod 0600); the YAML+body structure above lands as the canonical narrative source.
   118	1. `phase='output'`, `output_type='chase_draft_generated'`, payload carries draft METADATA only: `{vault_path, body_sha256, voice_score, escalation_position, days_overdue, amount_due}`. The draft body itself is NOT in the payload — vault path is the authority.
   119	2. `phase='action'`, `action_type='xero_reminder_draft_internal'` (yellow tier per autosend-policy.yaml lines 182-187), payload links to the draft via the vault path — this row records that Cash Conductor classified the draft as yellow-tier internal.
   120	
   121	When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml line 257; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).
   122	
   123	### §3.2 — Chase escalation ladder
   124	
   125	| Position | Trigger | Tone | Voice classifier minimum |
   126	|---|---|---|---|
   127	| 1 | 7 days overdue | "Friendly reminder, hope everything's OK on your end" | ≥0.75 |
   128	| 2 | 14 days overdue, position-1 sent | "Following up — please let us know if there's a query" | ≥0.75 |
   129	| 3 | 21 days overdue, position-2 sent | "Need to flag this; can we schedule a quick call?" | ≥0.80 (higher bar) |
   130	| 4 | 30 days overdue, position-3 sent | "Escalation to operator review" — drafts STOP; operator manual handle | n/a (not sent) |
   131	
   132	Position 4 is the kill-switch: Cash Conductor never auto-drafts beyond position 3. Operator decides next step manually.
   133	
   134	### Output 3 — Weekly cash-flow Markdown report
   135	
   136	Located at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md`. Generated Monday 06:00 UTC. Six sections:
   137	
   138	| # | Section | Content |
   139	|---|---|---|
   140	| 1 | **Week summary** | Receipts received + invoices issued + invoices paid + new chases sent |
   141	| 2 | **DSO trend** | Days-Sales-Outstanding metric this week vs prior-week vs month-0 baseline; Gate B tracking |
   142	| 3 | **Aged debtors** | Invoices outstanding bucketed (0-30 / 31-60 / 61-90 / 90+ days); per-client totals |
   143	| 4 | **Chase pipeline** | Active chase drafts by position 1-3; pending consultant approval; sent-but-no-response |
   144	| 5 | **Cash-flow forecast** | 4-week forward cash projection (open invoices + expected payments per historical conversion rate) |
   145	| 6 | **Exception list** | Reconciliation failures; bank-feed gaps; accounting-API failures; operator action items |
   146	
   147	---
   148	
   149	## §4 — Workflow
   150	
   151	14 steps. Per ADR-003 §3 agent-bundle pattern + the review-agent-bundle Codex ratification skill §4 ("every output/action step MUST call hh_decision_*"): every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. Master brief §8.1 Change 2 mandates the three-call minimum per agent run (`trigger`, `output`, `action`); the per-step mandatory-write discipline is the agent-bundle contract extension.
   152	
   153	```
   154	0. Session start (webhook OR cron OR manual)
   155	   → context.sh hydrates: tenant config + accounting-provider auth +
   156	     Open Banking auth + voice corpus + tone rules
   157	   → hh_decision_trigger("session_start", "<webhook|cron|manual>")
   158	
   159	1. Provider auth refresh
   160	   → accounting: Xero/QuickBooks/Sage OAuth refresh per provider
   161	   → Open Banking: TrueLayer/Plaid UK 90-day token refresh (CRITICAL —
   162	     gotcha per ULTRAPLAN A4 line 541); staged ESC_OPEN_BANKING_TOKEN_AGING:
   163	     ≤30d info, ≤14d warn, ≤7d blocking (operator must re-authorise)
   164	   → ESC_ACCOUNTING_AUTH or ESC_OPEN_BANKING_AUTH on auth failure
   165	   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
   166	     "accounting:<ok|fail>; open_banking:<ok|fail>; token_aging_stage:<info|warn|blocking|fresh>")
   167	
   168	2. Event router (mode-dependent)
   169	   → if mode=webhook: parse event_type → routes to Step 3-7 path
   170	   → if mode=daily-sweep: routes to Step 4 (invoice ingest) → Step 5 (reconciliation) → Step 7 (chase generation pass) catch-up sequence; sweeps run the full reconciliation-first-then-chase pipeline
   171	   → if mode=weekly-report: skip to Step 13
   172	
   173	3. Bank transaction ingest (mode=webhook from Open Banking)
   174	   → fetch latest transactions since last_ingested_at
   175	   → normalise schema (TrueLayer vs Plaid have different formats)
   176	   → store in Postgres table `cash_conductor_transactions` (RLS-isolated per
   177	     tenant per Day-4 §6.3 + tenancy-invariants T1-T3; W7 build slice creates
   178	     the table per ADR-002 vault/Postgres split — structured state in Postgres,
   179	     not vault markdown)
   180	   → hh_decision_output("transactions_ingested", "tenant:<slug>",
   181	     "<N> rows since <last_ingested_at>")
   182	
   183	4. Invoice register ingest (mode=webhook from accounting OR daily-sweep)
   184	   → accounting.list_open_invoices() per provider
   185	   → store in Postgres table `cash_conductor_invoices` (RLS-isolated;
   186	     W7 build slice creates per ADR-002 vault/Postgres split)
   187	   → hh_decision_output("invoices_ingested", "tenant:<slug>", "<N> rows")
   188	
   189	5. Reconciliation pass (5-stage match algorithm per §3 Output 1)
   190	   → for each transaction × open invoice: compute match confidence
   191	   → write Stage 1-2 matches to accounting (yellow tier) atomically
   192	   → Stage 3 (single low-confidence exact-amount match): flag in weekly-report
   193	     exception list; NO ESC fire (per §6 row distinguishing Stage 3 from
   194	     Stage 4 — catalogue defines ESC_RECONCILIATION_AMBIGUOUS as multi-
   195	     candidate, not low-confidence single). W4-polish backlog: register
   196	     `ESC_RECONCILIATION_LOW_CONFIDENCE` OR widen catalogue trigger.
   197	   → Stage 4 (fuzzy multi-candidate within tolerance): fire ESC_RECONCILIATION_AMBIGUOUS
   198	     per catalogue (multiple candidates); queue for consultant review.
   199	   → flag Stage 5 (unmatched) in weekly-report exception list
   200	   → hh_decision_output("reconciliation_pass", "tenant:<slug>",
   201	     "stage1_2:<N>; stage3:<N>; stage4:<N>; stage5:<N>")
   202	
   203	6. Reconciliation write (yellow tier; per match)
   204	   → accounting.write_payment_received(invoice_id, payment_id, amount, date)
   205	   → atomic transaction; rollback on 4xx/5xx
   206	   → on success: hh_decision_action("accounting_reconciliation_write",
   207	     "invoice:<id>", payload_hash, payload_preview)
   208	   → on failure: ESC_ACCOUNTING_WRITE_FAIL
   209	   → spot-check sampling per autosend-safety-policy.yaml yellow tier
   210	
   211	7. Chase generation pass (for overdue, unmatched invoices)
   212	   → query open invoices with age >7 days AND no Stage-1/2 reconciliation
   213	   → for each, determine chase position 1-4 based on age + prior chases
   214	     sent (read from `cash_conductor_invoices.last_chase_position` — v0.3
   215	     schema-backed field per migration §3; NOT from decision_log payload)
   216	   → if position=4: STOP — operator review (no auto-draft).
   217	     hh_decision_output("chase_position_4_operator_review",
   218	     "invoice:<id>", "age_days:<N>; prior_chases:3") — records the
   219	     operator-review outcome explicitly per §4 mandatory-write discipline
   220	   → else: proceed to Step 8
   221	
   222	8. LLM chase-draft generation (per overdue invoice)
   223	   → prompt = (invoice details + client context + position-N tone +
   224	     voice corpus + tone rules)
   225	   → output = email body + subject
   226	   → voice classifier scores against tenant style (≥0.75 for position 1-2;
   227	     ≥0.80 for position 3 per §3.2)
   228	   → ESC_VOICE_DRIFT if classifier <threshold after 3 retries
   229	   → hh_decision_output("chase_draft_generated", "invoice:<id>",
   230	     "position:<N>; voice_score:<N>; words:<N>")
   231	
   232	9. Chase-draft validation (Gate A specifics)
   233	   → verify: invoice_number cited matches invoice_id
   234	   → verify: amount_due cited matches accounting record
   235	   → verify: client_contact_email matches active billing contact
   236	   → verify: NOT paid in last 24h (re-query accounting)
   237	   → ESC code mapping by failure class:
   238	     - invoice_number / amount_due / paid-invoice-precondition mismatch →
   239	       `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint failure)
   240	     - client_contact_email / addressee mismatch (chase routed to wrong
   241	       customer) → `ESC_ADDRESSEE_MISMATCH` (per catalogue §2.10 — explicitly
   242	       blocking for Cash Conductor invoice/chase addressee resolution)
   243	     `ESC_AUTOSEND_BLOCKED` is reserved for red-tier action attempts per
   244	     catalogue line 41; Cash Conductor's chase pipeline is orange-tier.
   245	   → hh_decision_output("chase_draft_validated", invoice_id, "passed")
   246	
   247	10. Chase-draft queue to Concierge (opens orange-tier approval bridge)
   248	    → POST internal API → Concierge agent receives draft
   249	    → hh_decision_action("xero_reminder_draft_internal", "invoice:<id>",
   250	      payload_hash, payload_preview) — tier=yellow internal-draft per
   251	      autosend-policy.yaml line 182
   252	    → hh_decision_action("xero_reminder_send_customer", "invoice:<id>",
   253	      payload_hash, payload_preview) — tier=orange per autosend-policy.yaml
   254	      line 257; Cash Conductor owns this action_type and OPENS the
   255	      orange-approval-bridge; Concierge handles autosend-bridge call to
   256	      operator (D1 path per Founder Decision)
   257	
   258	11. (Operator approves via Concierge's bridge → Concierge transports the
   259	    send → Cash Conductor receives webhook + records state mutation)
   260	    → The orange-tier `xero_reminder_send_customer` action row was

exec
/bin/zsh -lc "rg --files | rg '("'^|/)(vertical-schema.yaml|autosend-safety-policy.yaml|escalation-codes.md|voice-loader.sh|hook-helpers.sh|ULTRAPLAN|master|v1.0-kill-criterion|ADR-002|ADR-003|ADR-005|2026-05-20-codex-round-1-founder-decisions)'"'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/voice-loader.sh
docs/verticals/recruitment/vertical-schema.yaml
docs/specs/ULTRAPLAN.md
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md
docs/decisions/v1.0-kill-criterion.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
legacy/v1/docs/phase-2-agent-suite/_shared/escalation-codes.md
legacy/v1/docs/phase-2-agent-suite/_shared/hook-helpers.sh

exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/agent.md | sed -n '260,620p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	    → The orange-tier `xero_reminder_send_customer` action row was
   261	      written by Cash Conductor at Step 10 (Cash Conductor owns this
   262	      action_type per autosend-policy.yaml line 257; agent: cash-conductor).
   263	      Concierge does NOT write its own action row for this — Concierge's
   264	      role is approval-bridge + transport, not action-row authorship.
   265	    → Concierge fires webhook back: chase_sent (transport completed)
   266	    → Cash Conductor updates `cash_conductor_invoices.last_chase_position`
   267	      and `last_chase_sent_at` (v0.3 schema-backed fields per migration §3)
   268	    → hh_decision_output("cash_conductor_chase_sent_recorded",
   269	      "invoice:<id>", "position:<N>; sent_at:<ISO>") — phase=output;
   270	      green-tier internal status marker recording state mutation completion
   271	
   272	12. (Mode=webhook only) Re-trigger eligibility check
   273	    → was this webhook also a "payment received" that just hit?
   274	    → re-run Step 5 to check if any chases-in-flight should be cancelled
   275	      (paid-since-draft-but-before-send race condition)
   276	    → if so: ESC_AUTOSEND_RACE → cancel chase draft (do NOT send)
   277	    → hh_decision_output("chase_cancellation_check", "invoice:<id>",
   278	      "cancelled:<bool>")
   279	
   280	13. Weekly report assembly (mode=weekly-report; runs Monday 06:00 UTC)
   281	    → query decision_log + accounting + bank feed for the 7-day window
   282	    → compute DSO metric (Gate B tracking)
   283	    → 6-section Markdown report per §3 Output 3
   284	    → write to /vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md
   285	    → hh_decision_output("weekly_report", report_path,
   286	      "dso_delta_days:<N>; sections:6")
   287	
   288	14. Session close
   289	    → update tenant_adapters.config.cash_conductor_last_run = now()
   290	    → hh_decision_action("cash_conductor_run_complete", "session:<session_id>",
   291	      payload_hash, "run_mode:<mode>; matches:<N>; chases:<N>; report:<bool>")
   292	      — hh_decision_action signature is (action_type, target, payload_hash,
   293	      payload_preview) per agents/_shared/hook-helpers.sh contract
   294	    → exit code 0
   295	```
   296	
   297	---
   298	
   299	## §5 — Gates
   300	
   301	### Gate A — validate.sh (hard-fail before action)
   302	
   303	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
   304	
   305	- **"chase email references correct invoice number AND correct amount AND correct contact"** (all three; AND not OR)
   306	- **"never proposes chase for an invoice that's been paid in last 24h"** (defence-in-depth re-query at draft time)
   307	- Voice classifier score ≥0.75 for position 1-2 chases; ≥0.80 for position 3
   308	- No PII outside firm boundary in chase body
   309	- Reconciliation match confidence ≥0.85 for auto-write (Stage 1-2 only)
   310	- Open Banking token ≥7 days from expiry (≤7d is blocking per ESC_OPEN_BANKING_TOKEN_AGING staged definition; ≤30d info + ≤14d warn are health-warning states that do NOT block Gate A, only signal upcoming reauth need)
   311	- Accounting auth refresh succeeded in Step 1
   312	
   313	Gate A failures fire either `ESC_AGENT_OUTPUT_SHAPE` (invoice/amount/paid-precondition miss; output-shape constraint) OR `ESC_ADDRESSEE_MISMATCH` (client_contact_email mismatch; blocking per catalogue §2.10 — explicit Cash Conductor invoice/chase addressee case). Draft stays in `/tmp` (auto-purged 24h); operator notified per the specific ESC route.
   314	
   315	**Honesty note (per bilateral-disposition Cat-5):** Cash Conductor `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W7 build slice. The W7 build delivers `agents/recruitment/cash-conductor/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   316	
   317	### Gate B — Outcome threshold (FD-tier closer metric)
   318	
   319	Per ULTRAPLAN A4 line 539 verbatim: **"tenant DSO at month-3 ≥ 12 days lower than month-0 baseline"**.
   320	
   321	DSO = Days Sales Outstanding = (Accounts Receivable / Total Credit Sales) × Number of Days.
   322	
   323	Measured monthly via the weekly report's §2 trend. Month-0 baseline established at first pilot LOI signing (before Cash Conductor active). Month-3 target = month-0 minus 12 days.
   324	
   325	This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
   326	
   327	---
   328	
   329	## §6 — Escalation codes
   330	
   331	Cash Conductor uses these ESC codes from `agents/_shared/escalation-codes.md`:
   332	
   333	| Code | Trigger | Severity | Routing |
   334	|---|---|---|---|
   335	| `ESC_ACCOUNTING_AUTH` | Xero/QuickBooks/Sage OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   336	| `ESC_ACCOUNTING_WRITE_FAIL` | Accounting 4xx/5xx on reconciliation write | warn | operator_chat_id |
   337	| `ESC_OPEN_BANKING_AUTH` | TrueLayer/Plaid UK auth fails after 2 retries | **blocking** | operator + ifos_oncall |
   338	| `ESC_OPEN_BANKING_TOKEN_AGING` | Open Banking PSD2 consent approaching 90-day expiry (staged) | info ≤30d / warn ≤14d / **blocking** ≤7d (per catalogue §2.7) | operator_chat_id (info+warn); + ifos_oncall_chat_id at blocking stage |
   339	| `ESC_RECONCILIATION_AMBIGUOUS` | Stage 4 fuzzy multi-candidate match within tolerance (per catalogue §2.10 — bank-feed payment line cannot match a single Xero invoice; multiple candidates) | warn | operator_chat_id |
   340	| (Stage 3 low-confidence single-match review queue) | Stage 3 single low-confidence exact-amount match queued for consultant review — NOT ESC_RECONCILIATION_AMBIGUOUS (catalogue defines ambiguity as multi-candidate, not low-confidence single). v0.3 W4-polish backlog: add ESC_RECONCILIATION_LOW_CONFIDENCE for single-match-low-confidence case OR widen ESC_RECONCILIATION_AMBIGUOUS catalogue trigger. | flagged in weekly report exception list (no ESC fire at v0.3) | (weekly report aggregation) |
   341	| `ESC_AUTOSEND_RACE` | Payment received between chase-draft and chase-send window | warn | operator_chat_id |
   342	| `ESC_VOICE_DRIFT` | Chase voice classifier below threshold after 3 retries | warn | operator_chat_id |
   343	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in chase body | **blocking** | operator + ifos_oncall |
   344	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A miss on invoice_number / amount_due / paid-invoice-precondition (NOT addressee mismatch — that uses ESC_ADDRESSEE_MISMATCH) | warn | operator_chat_id |
   345	| `ESC_ADDRESSEE_MISMATCH` | Gate A miss on client_contact_email / addressee resolution (per catalogue §2.10 Cash Conductor case) | **blocking** | operator + ifos_oncall |
   346	| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
   347	| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
   348	| `ESC_AUTOSEND_ORANGE_PENDING` | Chase draft awaiting consultant approval — heartbeat at ≥50% of declared timeout (per catalogue §2.9 trigger) | info | operator_chat_id (gentle reminder; no oncall CC) |
   349	
   350	Cash Conductor does NOT use:
   351	
   352	- Bullhorn-specific codes (no Bullhorn dependency)
   353	- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
   354	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Cash Conductor's Gate A misses are output-shape failures, not schema-field violations
   355	- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Cash Conductor fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
   356	
   357	---
   358	
   359	## §7 — Voice + tone constraints
   360	
   361	Step 8 (chase-draft generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   362	
   363	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
   364	  - No "Final demand" or legal-threatening language (escalation ladder caps at position 3; position 4 is operator-handled)
   365	  - No reference to the client's industry / sector pain points (chase is operational, not strategic)
   366	  - No mentions of late-payment fees unless tenant's terms explicitly state them
   367	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
   368	- **NOTE: Cash Conductor does NOT read `recent_edit`.** Per v0.3 supplement §2a access grants (line 723), Cash Conductor has W-only access — it WRITES recent_edit rows when consultants edit its chase drafts post-send, but does NOT READ them. Voice continuity for Cash Conductor relies on the tenant voice_corpus + tone_rule reads above. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries (LLM step internal to chase-draft generation; classifier scoring distinct from sample retrieval). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked by the canary (which has R access) for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
   369	
   370	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   371	
   372	---
   373	
   374	## §8 — Build dependencies (W7-8 prerequisites)
   375	
   376	Cash Conductor build cannot start until ALL of the following are confirmed:
   377	
   378	| Dependency | Source | Status |
   379	|---|---|---|
   380	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   381	| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
   382	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   383	| **Tenant's accounting choice confirmed** (Xero / QuickBooks / Sage) | Tenant onboarding | ⏸ |
   384	| **Accounting commercial signup** (developer access + sandbox) | Founder commercial | ⏸ |
   385	| **Open Banking commercial signup** (TrueLayer or Plaid UK) | Founder commercial; ~£100-300/mo | ⏸ |
   386	| Xero MCP connector | W7 build start (~2 days) | ⏸ |
   387	| QuickBooks MCP connector | W7 build start (~2 days) | ⏸ |
   388	| Sage MCP connector | W7 build start (~2 days; may defer if no pilot uses Sage v1.0) | ⏸ |
   389	| Open Banking MCP connector | W7 build start (~3 days; harder due to 90-day token rotation) | ⏸ |
   390	| Per-tenant accounting credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   391	| Per-tenant Open Banking credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   392	| Concierge agent.md ratified Accepted (for chase-send routing contract; full Concierge production-build at W10-13, but Cash Conductor only depends on the Concierge agent.md contract being Accepted, not the full bundle being In Force) | Post-Concierge agent.md re-ratification | ⏸ |
   393	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   394	| `validate.sh` Gate A logic | Build at W7 start (~1 day; complex due to 4 validators) | ⏸ |
   395	| `context.sh` hydration | Build at W7 start (~0.5 day) | ⏸ |
   396	| `cycle.sh` orchestration (14-step) | Build at W7 start (~3 days; most complex of v1.0 agents) | ⏸ |
   397	| `tools.yaml` MCP capability declarations (xero_oauth, quickbooks_oauth, sage_oauth, open_banking_truelayer / plaid, telegram_notify) | Build at W7 start (~1 day) | ⏸ |
   398	| `cleanup.sh` post-run state purge (transient OAuth tokens; provider rate-limit caches) | Build at W7 start (~0.5 day) | ⏸ |
   399	| 3 fixtures with golden outputs | Build at W7 start (~1 day) | ⏸ |
   400	| **Founder Decision D1 (autosend orange-tier path) RESOLVED** — blocking for Cash Conductor's xero_reminder_send_customer action_type | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` D1 (currently Proposed) | ⏸ |
   401	| **Autosend bridge implementation** (per D1 outcome) — Concierge W10 build delivers; blocking for orange-tier send writes | Concierge W10 build slice (~2 days for D1-A; less for D1-B/C) | ⏸ |
   402	| Fallback: if D1 + bridge not ready by W7-8, Cash Conductor v1.0 downgrades to drafts-only (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` writes until D1 resolves + bridge ships) | v1.0 contingency | n/a |
   403	
   404	**ADR-005 framing:** ADR-005 (Week-3 Diagnostic acceleration) notes Cash Conductor is unaffected by Bullhorn slips because it has zero Bullhorn dependency. v0.3 supplement: Cash Conductor pull-forward (from W7-8 to W4-5) is NOT explicitly authorised by ADR-005 §5.1 (that section number doesn't exist; earlier draft mis-cited). Pull-forward would require a separate ADR (e.g. ADR-007 if/when needed); accounting + Open Banking commercial signups remain founder-action gates regardless of timing.
   405	
   406	---
   407	
   408	## §9 — Status + open questions
   409	
   410	**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start.
   411	
   412	### Open questions for founder review
   413	
   414	| # | Question | Resolution path |
   415	|---|---|---|
   416	| Q1 | First-tenant accounting choice — Xero / QuickBooks / Sage? Affects which connector is W7-prio-1. | Tenant onboarding; depends on first pilot tenant's existing stack. |
   417	| Q2 | Open Banking provider — TrueLayer or Plaid UK? Both have UK coverage; TrueLayer slightly cheaper at low volume; Plaid has broader US-EU coverage for v1.1+ expansion. | Founder commercial. Recommend TrueLayer for v1.0 UK-only pilots. |
   418	| Q3 | Open Banking 90-day token rotation UX — when token nears expiry, operator must re-authenticate via tenant's bank login. How is this triggered? Telegram nudge? Brain UI dashboard? | Recommend: ESC_OPEN_BANKING_TOKEN_AGING fires Telegram nudge at 30/14/7 days; tenant-admin handles via Brain UI v1.1. |
   419	| Q4 | Chase escalation ladder — 4 positions proposed in §3.2. Founder confidence each position's timing + tone is right? | Founder review with first pilot tenant; varies by tenant's payment terms (net-30 vs net-14 vs net-60). |
   420	| Q5 | Reconciliation Stage 3-4 (fuzzy / ambiguous matches) — consultant review queue UX. Brain UI workflow? Telegram? | v1.0: weekly report exception list. v1.1: Brain UI per-row review queue. |
   421	| Q6 | DSO baseline establishment — month-0 baseline measured pre-deployment. How do we measure if accounting system data is incomplete or fragmented? | First pilot tenant: 30-day baseline measurement period BEFORE Cash Conductor goes live; documented in pilot LOI. |
   422	| Q7 | Hire #1 anchor — what specific Cash Conductor sub-tasks does Hire #1 take vs Claude Code? | Founder strategic decision; recommend Hire #1 owns Open Banking connector + ESC_OPEN_BANKING_TOKEN_AGING UX. Cash Conductor agent.md + cycle.sh stays with founder + Claude Code for consistency with other agents. |
   423	| Q8 | Sage connector — defer if no v1.0 pilot uses Sage? Saves ~2 days. Risk: blocks future Sage-using pilots. | Recommend defer to v1.1; document in W7 build start review. |
   424	
   425	### Gotchas (carried forward from ULTRAPLAN A4 line 541)
   426	
   427	1. **Open Banking auth is a 90-day token; rotation logic is non-trivial.** Plan for the rotation UX up-front; ESC_OPEN_BANKING_TOKEN_AGING staged at 30/14/7 days from expiry; document tenant-admin re-auth procedure.
   428	2. **Bank feed reconciliation against invoice register is the hard logic.** Start with exact-amount matches (Stage 1-2); expand to fuzzy (Stage 3-4) as confidence builds.
   429	3. **5 stages of match algorithm** is intentionally conservative for v1.0 to avoid false-positive reconciliation writes (which corrupt the tenant's accounting books).
   430	4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
   431	
   432	---
   433	
   434	## §10 — When this document ratifies
   435	
   436	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   437	
   438	Status flips Proposed → Accepted when:
   439	- Codex Round 4 Phase 2 ratifies
   440	- Founder approves §9 Q1 + Q2 + Q4 + Q7 + Q8
   441	- Q3 UX flow approved (operator re-auth path)
   442	
   443	Status flips Accepted → In Force when:
   444	- W7-8 build slice produces all 5 sibling bundle files + 3 fixtures
   445	- First production webhook processed end-to-end against migration-test tenant
   446	- 30-day month-0 baseline measured for first pilot
   447	- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
   448	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   449	
   450	Until then: this document is a forward-looking scaffold.
   451	
   452	*End of Cash Conductor agent.md draft.*

codex
The local artefact has the required §1-§10 shape and is clearly marked as a pre-build scaffold, so I’m narrowing the review to hard blockers: fabricated/drifted citations, invented schema/action fields, and boundary violations.
exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '520,545p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   520	- **CortexOS primitives required:** None per call (stateless between calls)
   521	- **MCP tools required:** Bullhorn (write), Fathom (read), Fireflies (read)
   522	- **Shared modules required:** Voice loader (for tone-detection of tacit notes), decision log writer
   523	- **External APIs:** Fathom webhook, Fireflies webhook, Bullhorn for write-back
   524	- **Gate A:** every transcript produces at least 3 structured-field extractions AND 1 tacit-note; tacit-notes have a confidence score ≥ 0.6
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
/bin/zsh -lc "rg --files docs | rg -i 'master|brief|operational|hygiene|autosend'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/decisions/autosend-approval-bridge-spec.md
docs/decisions/autosend-safety-policy.md
docs/runbooks/operational-hygiene-protocol.md
docs/runbooks/pii-purge-operational-pattern.md
docs/build-brief/00-MASTER-BRIEF.md
docs/_supplementary/planning-phase-brief.md

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc 'rg --files agents/_shared | sort' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/README.md
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/hook-helpers.sh
agents/_shared/tests/test-hook-helpers.sh
agents/_shared/tests/test-voice-loader.sh
agents/_shared/voice-loader.sh

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '260,520p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '160,275p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   160	  bullhorn_field_backfill:
   161	    tier: yellow
   162	    agent: janitor
   163	    sample_rate: 10
   164	    reason: "Fills missing canonical schema fields from Companies House or LinkedIn enrichment; reversible PATCH; high-volume; source provenance logged in payload"
   165	    irreversible: false
   166	
   167	  bullhorn_note_attach:
   168	    tier: yellow
   169	    agent: janitor
   170	    sample_rate: 20
   171	    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
   172	    irreversible: false
   173	
   174	  bullhorn_note_append_summary:
   175	    tier: yellow
   176	    agent: scribe
   177	    sample_rate: 20
   178	    reason: "Appends to candidate record; consultant-only visibility; high-volume; format quality needs review"
   179	    irreversible: false
   180	
   181	  linkedin_connection_request:
   182	    tier: yellow
   183	    agent: sourcing-scout
   184	    sample_rate: 5
   185	    reason: "Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy"
   186	    irreversible: true
   187	
   188	  xero_reminder_draft_internal:
   189	    tier: yellow
   190	    agent: cash-conductor
   191	    sample_rate: 10
   192	    reason: "Generates reminder draft visible to consultant; not yet sent; format + tone needs review"
   193	    irreversible: false
   194	
   195	  bullhorn_note_draft_internal:
   196	    tier: yellow
   197	    agent: concierge
   198	    sample_rate: 10
   199	    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
   200	    irreversible: false
   201	
   202	  bullhorn_scribe_field_write:
   203	    tier: yellow
   204	    agent: scribe
   205	    sample_rate: 10
   206	    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
   207	    irreversible: false
   208	
   209	  accounting_reconciliation_write:
   210	    tier: yellow
   211	    agent: cash-conductor
   212	    sample_rate: 10
   213	    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
   214	    irreversible: false
   215	
   216	  concierge_email_draft:
   217	    tier: yellow
   218	    agent: concierge
   219	    sample_rate: 20
   220	    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
   221	    irreversible: false
   222	
   223	  # ───────────────────────────────────────────────────────────
   224	  # ORANGE — per-action human approval (10 action_types)
   225	  # ───────────────────────────────────────────────────────────
   226	
   227	  bullhorn_note_customer_visible:
   228	    tier: orange
   229	    agent: concierge
   230	    timeout: PT4H
   231	    reason: "CANONICAL ORANGE. Bullhorn Note with isExternal: true — customer-visible in their CRM; single send is irreversible (note in audit trail even if deleted)"
   232	    irreversible: true
   233	    canonical: true
   234	
   235	  gmail_outlook_send_to_candidate:
   236	    tier: orange
   237	    agent: concierge
   238	    timeout: PT4H
   239	    reason: "Outbound email to candidate; customer-facing; reputation effects"
   240	    irreversible: true
   241	
   242	  twilio_sms_send:
   243	    tier: orange
   244	    agent: concierge
   245	    timeout: PT30M
   246	    reason: "Outbound SMS; high-trust channel; cost-per-send; irreversible"
   247	    irreversible: true
   248	
   249	  calendar_invite_send:
   250	    tier: orange
   251	    agent: concierge
   252	    timeout: PT4H
   253	    reason: "Creates calendar event with attendee notification; visible to attendee"
   254	    irreversible: true
   255	
   256	  email_summary_to_customer:
   257	    tier: orange
   258	    agent: scribe
   259	    timeout: PT4H
   260	    reason: "Outbound email summarising call to customer; customer-facing; format-sensitive"
   261	    irreversible: true
   262	
   263	  xero_reminder_send_customer:
   264	    tier: orange
   265	    agent: cash-conductor
   266	    timeout: PT24H
   267	    reason: "Outbound payment reminder to customer; reputation + collection risk"
   268	    irreversible: true
   269	
   270	  diagnostic_email_send:
   271	    tier: orange
   272	    agent: diagnostic
   273	    timeout: PT4H
   274	    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
   275	    irreversible: true

 succeeded in 0ms:
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
   285	- **Payload fields:** `provider` (`xero` | `quickbooks` | `sage` | `freeagent`), `failure_type`, `last_attempt_at`
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
   297	- **Severity:** staged — info → warn → blocking as expiry approaches (per Cash Conductor agent.md §6)
   298	- **Trigger:** Open Banking PSD2 consent approaching 90-day expiry. Three stages:
   299	  - **≤30 days remaining:** info — non-urgent operator awareness; nightly health check emits this
   300	  - **≤14 days remaining:** warn — operator nudge to schedule reauth this week
   301	  - **≤7 days remaining:** blocking — Cash Conductor enters degraded mode (cached balance only; no fresh bank-feed reads); operator must complete SCA reauth before token expires
   302	- **Phase:** `gating_failed`
   303	- **Routing:** `operator_chat_id` (info + warn stages); ADD `ifos_oncall_chat_id` at blocking stage
   304	- **Payload fields:** `consent_expires_at`, `days_remaining`, `bank_provider`, `stage` (`info` | `warn` | `blocking`)
   305	- **Recovery:** founder schedules + completes Open Banking SCA reauth via tenant's bank login
   306	
   307	### 2.8 — Provider read/write failures (4 codes)
   308	Source: derived from v1.0 agent.md adapter call sites
   309	
   310	#### `ESC_BULLHORN_WRITE_FAIL`
   311	- **Severity:** warn
   312	- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
   313	- **Phase:** `gating_failed`
   314	- **Routing:** `operator_chat_id`
   315	- **Payload fields:** `endpoint`, `entity_type`, `entity_id`, `status_code`, `error_body_preview` (truncated 120 chars)
   316	
   317	#### `ESC_ACCOUNTING_WRITE_FAIL`
   318	- **Severity:** warn
   319	- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
   320	- **Phase:** `gating_failed`
   321	- **Routing:** `operator_chat_id`
   322	- **Payload fields:** `provider`, `endpoint`, `entity_type`, `status_code`, `error_body_preview`
   323	
   324	#### `ESC_PROVIDER_FETCH_FAIL`
   325	- **Severity:** warn
   326	- **Trigger:** Generic upstream provider read failure (Companies House, web-scraper, any non-Bullhorn-non-Accounting GET) after retry budget exhausted; distinct from rate-limit
   327	- **Phase:** `gating_failed`
   328	- **Routing:** `operator_chat_id`
   329	- **Payload fields:** `upstream` (e.g. `companies-house`, `web-scraper`, `linkedin-cache`), `endpoint`, `status_code`, `consecutive_failures`
   330	
   331	#### `ESC_SEND_FAIL`
   332	- **Severity:** warn — distinct from auth/rate-limit; the send itself failed at the protocol layer
   333	- **Trigger:** External send (Gmail / Outlook / Twilio / Telegram-to-customer) returned 5xx or transport error after retry budget
   334	- **Phase:** `gating_failed`
   335	- **Routing:** `operator_chat_id`
   336	- **Payload fields:** `channel` (`gmail` | `outlook` | `twilio` | `telegram`), `recipient_id_hash`, `error_class`, `attempts_made`
   337	
   338	### 2.9 — Auto-send orchestration (4 codes)
   339	Source: `docs/decisions/autosend-safety-policy.md` §5 extensions; runtime orchestration semantics
   340	
   341	#### `ESC_AUTOSEND_ORANGE_PENDING`
   342	- **Severity:** info — distinct from ESC_AUTOSEND_NEEDS_REVIEW (which is the initial queue event)
   343	- **Trigger:** Orange-tier action has been pending operator response for ≥50% of declared `timeout` (heartbeat reminder before bridge timeout)
   344	- **Phase:** `action`
   345	- **Routing:** `operator_chat_id` (gentle reminder; no oncall)
   346	- **Payload fields:** `original_decision_log_id`, `action_type`, `time_pending_seconds`, `timeout_seconds`, `time_remaining_seconds`
   347	
   348	#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
   349	- **Severity:** warn — orange action's approval window expired without response
   350	- **Trigger:** Orange-tier action exceeded its `timeout` (default PT4H) without operator approve/reject
   351	- **Phase:** `gating_failed`
   352	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (operator absent + commitment may need rerouting)
   353	- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
   354	- **Recovery:** action converts to manual reconciliation; operator handles offline
   355	
   356	#### `ESC_AUTOSEND_RACE`
   357	- **Severity:** warn — concurrency / state-change race
   358	- **Trigger:** A send is about to fire when the underlying state has changed in a way that should suppress it. Two canonical use cases:
   359	  - **Duplicate-payload race:** two agents attempted to send the same `payload_hash` within same tenant within `race_window_seconds` (default 60s); second attempt detected by `decision_log` UPSERT-conflict; second wins-suppressed (first sends; idempotency by payload_hash)
   360	  - **State-change race (Cash Conductor):** payment received between chase-draft and chase-send window; the invoice is no longer overdue when the orange-tier approval fires; chase cancelled (do NOT send) per Cash Conductor §4 Step 12
   361	- **Phase:** `gating_failed`
   362	- **Routing:** `operator_chat_id`
   363	- **Payload fields:** `race_class` (`duplicate_payload` | `state_change_cancellation`), `payload_hash`, class-specific: duplicate → `first_agent_name`, `second_agent_name`, `time_delta_ms`, `action_type`; state-change → `entity_id`, `state_before`, `state_after`, `time_delta_ms`
   364	- **Recovery:** duplicate → second suppressed; state-change → cancelled draft logged; no operator action required beyond informational review
   365	
   366	#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
   367	- **Severity:** info — quality sampling, not a failure
   368	- **Trigger:** Yellow-tier action was sampled per `sample_rate` (1-in-N) for post-hoc human review; sampling is informational + drives ongoing quality monitoring
   369	- **Phase:** `action`
   370	- **Routing:** `operator_chat_id`; sampled action is queued in `spot_check_queue_path` (`/vault/{tenant_slug}/spot-checks/`)
   371	- **Payload fields:** `action_type`, `original_decision_log_id`, `sample_rate`, `sampling_reason`, `target`, `payload_preview`
   372	- **Note:** Operator review of sampled rows is asynchronous (typically end-of-day batch); no SLA timer.
   373	
   374	### 2.10 — Agent workflow (10 codes)
   375	Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
   376	
   377	#### `ESC_GATE_B_MISS`
   378	- **Severity:** warn — post-send quality signal; not a hard failure
   379	- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
   380	- **Phase:** `gating_failed`
   381	- **Routing:** `operator_chat_id`
   382	- **Payload fields:** `agent_name`, `metric_name`, `actual_value`, `threshold`, `window`, `sample_size`
   383	- **Note:** Local Gate B is a leading metric for agent quality; consecutive misses inform per-agent quality review. Not tied to a kill-criterion trigger in v1.0 (per disagreement-doc Cat-3 disposition).
   384	
   385	#### `ESC_TONE_RULE_VIOLATION`
   386	- **Severity:** warn — voice/tone classifier flagged output as violating a tenant `tone_rule` row
   387	- **Trigger:** Output drafted by an agent matches a tenant-defined `tone_rule` violation pattern (e.g. tenant prohibits "absolutely" in customer-facing comms; output contained it)
   388	- **Phase:** `gating_failed`
   389	- **Routing:** `operator_chat_id`
   390	- **Payload fields:** `tone_rule_id`, `pattern_violated`, `output_snippet_redacted`, `agent_name`, `tenant_slug`
   391	- **Recovery:** agent re-drafts with violation removed; if persistent, escalates to tone_rule review
   392	
   393	#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
   394	- **Severity:** warn
   395	- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
   396	- **Phase:** `gating_failed`
   397	- **Routing:** `operator_chat_id`
   398	- **Payload fields:** `entity_type`, `field_name`, `extracted_value`, `confidence_score`, `source` (e.g. `companies-house`, `linkedin`, `cv-pdf`), `agent_name`
   399	
   400	#### `ESC_CANDIDATE_DATA_INCOMPLETE`
   401	- **Severity:** warn
   402	- **Trigger:** Sourcing Scout candidate record lacks ≥N required fields for a shortlist (e.g. no email AND no phone, OR no LinkedIn AND no CV)
   403	- **Phase:** `gating_failed`
   404	- **Routing:** `operator_chat_id`
   405	- **Payload fields:** `candidate_id`, `missing_fields` (list), `shortlist_id`, `brief_id`
   406	
   407	#### `ESC_ADDRESSEE_MISMATCH`
   408	- **Severity:** **blocking** — outbound send refused (whichever agent firing)
   409	- **Trigger:** Outbound recipient resolution failed — addressee does not match the entity whose lifecycle/event triggered the send. Two canonical use cases:
   410	  - **Cash Conductor:** chase/reminder/invoice addressee does not match Bullhorn placement client OR Xero contact (cross-system reconciliation failure between accounting + ATS)
   411	  - **Concierge:** lifecycle-event email recipient does not match the candidate_id whose state is changing (per ULTRAPLAN A6 line 566 verbatim "no candidates emailed under another's name")
   412	- **Phase:** `gating_failed`
   413	- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id`
   414	- **Payload fields:** `agent_name`, `mismatch_class` (one of `cash_conductor_xero_bullhorn` | `concierge_candidate_email` | future variant), plus class-specific fields: Cash Conductor → `bullhorn_client_id`, `xero_contact_id`, `xero_contact_name`, `bullhorn_client_name`, `invoice_id`, `mismatch_dimension` (e.g. `name`, `email`, `address`); Concierge → `expected_candidate_bullhorn_id`, `actual_recipient_email`, `event_type`
   415	- **Recovery:** operator reviews; either reconciles manually OR updates one system to match
   416	
   417	#### `ESC_RECONCILIATION_AMBIGUOUS`
   418	- **Severity:** warn — Cash Conductor cannot confidently match incoming payment to a specific invoice
   419	- **Trigger:** Bank-feed payment line cannot be matched to a single Xero invoice; multiple candidates within tolerance
   420	- **Phase:** `gating_failed`
   421	- **Routing:** `operator_chat_id`
   422	- **Payload fields:** `payment_id`, `amount`, `payee_name_raw`, `candidate_invoice_ids` (list), `match_basis` (e.g. `amount_only`, `payee_partial`)
   423	
   424	#### `ESC_DNC_FILTER_HIT`
   425	- **Severity:** **blocking** — outbound (email / SMS / call) refused
   426	- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
   427	- **Phase:** `gating_failed`
   428	- **Routing:** `operator_chat_id`
   429	- **Payload fields:** `recipient_id_hash`, `dnc_list_source`, `dnc_match_reason` (e.g. `explicit_opt_out`, `previous_complaint`, `gdpr_objection`), `action_type_attempted`
   430	
   431	#### `ESC_CONCIERGE_SLA_MISS`
   432	- **Severity:** warn — aggregated to Gate B (not a per-event block)
   433	- **Trigger:** Concierge SLA breached. Three canonical sla_types:
   434	  - `brief_ack`: inbound brief not acknowledged within 4h (default)
   435	  - `customer_reply`: customer reply not actioned within 24h (default)
   436	  - `draft_generation`: lifecycle event → draft generated >30 min (per ULTRAPLAN A6 line 566; aggregated to Gate B per Concierge §1 disposition rather than per-event hard fail)
   437	- **Phase:** `gating_failed`
   438	- **Routing:** `operator_chat_id`
   439	- **Payload fields:** `brief_id` or `candidate_bullhorn_id` or `lifecycle_event_id` (per sla_type), `sla_type` (one of the three above), `sla_threshold_seconds`, `actual_elapsed_seconds`, `tenant_slug`
   440	
   441	#### `ESC_SCRIBE_SLA_MISS`
   442	- **Severity:** warn
   443	- **Trigger:** Scribe SLA breached (default: call summary rendered within 30 min of call end; Bullhorn note attached within 1h)
   444	- **Phase:** `gating_failed`
   445	- **Routing:** `operator_chat_id`
   446	- **Payload fields:** `call_id`, `sla_type` (`summary_render` | `note_attach`), `sla_threshold_seconds`, `actual_elapsed_seconds`, `tenant_slug`
   447	
   448	#### `ESC_LIFECYCLE_STATE_UNKNOWN`
   449	- **Severity:** warn — agent cannot determine entity state for downstream action
   450	- **Trigger:** Lifecycle state is ambiguous or outside the agent's known taxonomy. Two canonical use cases:
   451	  - **Janitor:** placement record has ambiguous lifecycle markers (e.g. start_date present but no end_date AND no `active` flag AND no recent activity); Janitor cannot safely tag or update
   452	  - **Concierge:** Bullhorn state transition is outside the 12-event v1.0 taxonomy (acknowledgement / prep / debrief / placement / rejection / withdrawal / on-hold / start-confirm / 7d-checkin / 30d-checkin / 90d-checkin / nurture); handler logs + skips draft
   453	- **Phase:** `gating_failed`
   454	- **Routing:** `operator_chat_id`
   455	- **Payload fields:** `agent_name`, `entity_type` (`placement` | `candidate_lifecycle_event`), `entity_id`, `ambiguity_class` (Janitor: e.g. `missing_end_date`, `stale_activity`; Concierge: e.g. `unknown_transition`, `out_of_taxonomy`), plus class-specific fields
   456	
   457	---
   458	
   459	## §3 — Reserved codes (not-yet-wired)
   460	
   461	These names are reserved by design documents but no agent fires them in v1.0. Listed here to prevent collision; do not invent codes overlapping these names.
   462	
   463	| Code | Reserved by | Earliest agent |
   464	|---|---|---|
   465	| `ESC_JSL_RED_FLAG` | master brief §8.1 Change 3 line 588 | Supply Chain Auditor (v1.1 backlog) |
   466	| `ESC_BRIEF_AMBIGUITY` | master brief §8.1 Change 3 line 589 | Brief Decoder (v1.1 standalone; v1.0 Sourcing Scout subskill) |
   467	
   468	---
   469	
   470	## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
   471	
   472	`_shared/hook-helpers.sh` must:
   473	
   474	1. Implement `autosend_escalate <ESC_CODE> [<key=value>...]` — writes the `decision_log` row + dispatches Telegram per `common-notifications.json` routing
   475	2. Validate `<ESC_CODE>` is a name from §2 above; unknown codes raise `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` (meta-escalation)
   476	3. Resolve `phase` from this catalogue's `Phase:` line (table-driven, not freeform)
   477	4. Default `agent_name` to `${CTX_AGENT_NAME}` or `_renderer` (renderer-only sentinel)
   478	
   479	The catalogue is read at process start via `_shared/escalation-codes-table.sh` (machine-readable companion; deferred to Phase 3 or first use, whichever lands first). If absent, helpers fall back to permissive write (log row only; no Telegram) + emit a one-shot operational warning.
   480	
   481	---
   482	
   483	## §5 — Change protocol
   484	
   485	New codes added here BEFORE wiring into helpers + before any agent references them. Code names case-sensitive (`ESC_[A-Z][A-Z0-9_]*`).
   486	
   487	The Codex Day-7 ratification queue includes this catalogue (item #20 placeholder per `docs/decisions/2026-05-18-codex-ratification-manifest.md` §1). Updates after ratification = new commit + Codex re-review of the diff.
   488	
   489	*End of catalogue (52 active codes + 2 reserved).*

exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	#
     3	# IFOS voice-loader — implements the 3 hh_load_* helpers per master brief
     4	# §8.1 Change 1. Sourced by every agent's context.sh at session start; emits
     5	# voice corpus, tone rules, and recent edits into the agent's context bundle.
     6	#
     7	# Requires:
     8	#   - vertical-schema.v0.2-supplement.yaml schema migrated (Phase 4 SQL)
     9	#   - IFOS_DB_URL set + psql on PATH for live queries
    10	#   - Falls back to /vault/<tenant>/_voice/ markdown files if DB unavailable
    11	#
    12	# Helpers (3):
    13	#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
    14	#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
    15	#   hh_load_recent_edits   — query recent_edit for last N days
    16	#
    17	# Each helper writes its result to stdout as a single JSON document. Caller
    18	# (context.sh) typically pipes into `jq` to inject into context bundle.
    19	#
    20	# shellcheck shell=bash
    21	
    22	set -uo pipefail
    23	
    24	_VL_VERSION="0.1.0"
    25	_VL_HELPERS_PATH="${_VL_HELPERS_PATH:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/hook-helpers.sh}"
    26	
    27	# Try to source hook-helpers.sh so we can _hh_json_escape + _hh_emit_row
    28	# (helpers may not be loaded yet if voice-loader is called standalone).
    29	if [[ -z "${_HH_HELPERS_VERSION:-}" ]] && [[ -f "${_VL_HELPERS_PATH}" ]]; then
    30	  # shellcheck source=/dev/null
    31	  source "${_VL_HELPERS_PATH}"
    32	fi
    33	
    34	# Minimal fallback if hook-helpers.sh wasn't loadable (e.g. running standalone
    35	# in tests). Functions here mirror the helpers' behaviour with no DB writes.
    36	if ! declare -f _hh_json_escape >/dev/null 2>&1; then
    37	  _hh_json_escape() {
    38	    local input="$1"
    39	    input="${input//\\/\\\\}"
    40	    input="${input//\"/\\\"}"
    41	    input="${input//$'\n'/\\n}"
    42	    input="${input//$'\r'/\\r}"
    43	    input="${input//$'\t'/\\t}"
    44	    printf '%s' "${input}"
    45	  }
    46	fi
    47	
    48	# ────────────────────────────────────────────────────────────────────────
    49	# Internal: Postgres query helpers
    50	# ────────────────────────────────────────────────────────────────────────
    51	
    52	# Returns 0 if live DB mode is available, 1 if fallback should be used.
    53	_vl_db_available() {
    54	  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
    55	    return 0
    56	  fi
    57	  return 1
    58	}
    59	
    60	# _vl_psql_query <SQL> → stdout (rows), or empty on failure
    61	_vl_psql_query() {
    62	  local sql="$1"
    63	  local tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
    64	  local wrapped
    65	  wrapped="BEGIN;
    66	SET LOCAL app.current_tenant = '$(_hh_json_escape "${tenant}")';
    67	${sql}
    68	COMMIT;"
    69	  psql -v ON_ERROR_STOP=1 -q -t -A -F $'\t' "${IFOS_DB_URL}" <<<"${wrapped}" 2>/dev/null
    70	}
    71	
    72	# ────────────────────────────────────────────────────────────────────────
    73	# hh_load_tone_rules [<agent_name>]
    74	# ────────────────────────────────────────────────────────────────────────
    75	# Returns active tone_rule rows filtered to agent_name (or all rules if
    76	# agent_name absent). JSON shape:
    77	#   { "rules": [ { "rule_id":..., "rule_text":..., "severity":...,
    78	#                  "examples_positive":[...], "examples_negative":[...] }, ... ] }
    79	hh_load_tone_rules() {
    80	  local agent_name="${1:-${CTX_AGENT_NAME:-}}"
    81	
    82	  if _vl_db_available; then
    83	    local sql
    84	    if [[ -n "${agent_name}" ]]; then
    85	      sql="SELECT rule_id, rule_text, severity, COALESCE(examples_positive, '{}'), COALESCE(examples_negative, '{}')
    86	           FROM tone_rule
    87	           WHERE enabled = TRUE
    88	             AND (cardinality(applies_to_agents) = 0 OR '$(_hh_json_escape "${agent_name}")' = ANY(applies_to_agents))
    89	           ORDER BY severity DESC, rule_id ASC;"
    90	    else
    91	      sql="SELECT rule_id, rule_text, severity, COALESCE(examples_positive, '{}'), COALESCE(examples_negative, '{}')
    92	           FROM tone_rule
    93	           WHERE enabled = TRUE
    94	           ORDER BY severity DESC, rule_id ASC;"
    95	    fi
    96	    local rows
    97	    rows="$(_vl_psql_query "${sql}")"
    98	    _vl_render_tone_rules_json "${rows}"
    99	    return 0
   100	  fi
   101	
   102	  # Fallback: read /vault/<tenant>/_voice/tone-rules.yaml
   103	  local fallback_file="${IFOS_VAULT_ROOT:-/vault}/${CTX_TENANT_SLUG}/_voice/tone-rules.yaml"
   104	  if [[ -f "${fallback_file}" ]]; then
   105	    printf '{"rules":[],"source":"fallback","fallback_path":"%s","note":"DB unavailable; YAML fallback not yet parsed in v0.1 — caller should read file directly"}\n' \
   106	      "$(_hh_json_escape "${fallback_file}")"
   107	    return 0
   108	  fi
   109	  printf '{"rules":[],"source":"empty","reason":"db_unavailable_and_no_fallback_file"}\n'
   110	}
   111	
   112	# Internal: convert TSV rows from psql into JSON.
   113	_vl_render_tone_rules_json() {
   114	  local rows="$1"
   115	  if [[ -z "${rows}" ]]; then
   116	    printf '{"rules":[],"source":"db","count":0}\n'
   117	    return 0
   118	  fi
   119	  printf '{"rules":['
   120	  local first=1
   121	  while IFS=$'\t' read -r rule_id rule_text severity examples_pos examples_neg; do
   122	    [[ -z "${rule_id}" ]] && continue
   123	    if (( first )); then first=0; else printf ','; fi
   124	    printf '{"rule_id":"%s","rule_text":"%s","severity":"%s","examples_positive":"%s","examples_negative":"%s"}' \
   125	      "$(_hh_json_escape "${rule_id}")" \
   126	      "$(_hh_json_escape "${rule_text}")" \
   127	      "$(_hh_json_escape "${severity}")" \
   128	      "$(_hh_json_escape "${examples_pos}")" \
   129	      "$(_hh_json_escape "${examples_neg}")"
   130	  done <<<"${rows}"
   131	  printf '],"source":"db"}\n'
   132	}
   133	
   134	# ────────────────────────────────────────────────────────────────────────
   135	# hh_load_voice_samples <task_context> [<top_k>]
   136	# ────────────────────────────────────────────────────────────────────────
   137	# Runs pgvector ANN against voice_corpus_chunks for the active voice_corpus
   138	# pack. Requires task_context to be embedded externally and supplied as a
   139	# vector literal via IFOS_VL_QUERY_VECTOR env var (because shell can't
   140	# generate embeddings). Callers from Python/Node embed first, then exec
   141	# voice-loader with the literal vector pre-encoded.
   142	#
   143	# Falls back to /vault/<tenant>/_voice/style-guide.md when DB or query vector
   144	# unavailable (returns the style guide path; agent reads directly).
   145	#
   146	# Output JSON shape:
   147	#   { "samples": [ { "chunk_index": N, "text_chunk": "...",
   148	#                    "source_doc_ref": "...", "distance": 0.123 }, ... ],
   149	#     "voice_corpus_version": "v0.2-seed",
   150	#     "source": "db" | "fallback" }
   151	hh_load_voice_samples() {
   152	  local task_context="${1:-}"
   153	  local top_k="${2:-10}"
   154	
   155	  # Validate top_k
   156	  if ! [[ "${top_k}" =~ ^[0-9]+$ ]] || (( top_k <= 0 )) || (( top_k > 50 )); then
   157	    top_k=10
   158	  fi
   159	
   160	  if _vl_db_available && [[ -n "${IFOS_VL_QUERY_VECTOR:-}" ]]; then
   161	    # Live mode: run HNSW ANN query against active voice_corpus
   162	    local sql
   163	    sql="SELECT vcc.chunk_index, vcc.text_chunk, COALESCE(vcc.source_doc_ref, ''), (vcc.embedding <=> '${IFOS_VL_QUERY_VECTOR}'::vector) AS distance
   164	         FROM voice_corpus_chunks vcc
   165	         JOIN voice_corpus vc ON vc.id = vcc.voice_corpus_id
   166	         WHERE vc.is_active = TRUE
   167	         ORDER BY vcc.embedding <=> '${IFOS_VL_QUERY_VECTOR}'::vector
   168	         LIMIT ${top_k};"
   169	    local rows
   170	    rows="$(_vl_psql_query "${sql}")"
   171	    local version
   172	    version="$(_vl_psql_query "SELECT version FROM voice_corpus WHERE is_active = TRUE LIMIT 1;")"
   173	    _vl_render_voice_samples_json "${rows}" "${version:-unknown}" "db" "${task_context}"
   174	    return 0
   175	  fi
   176	
   177	  # Fallback: return style guide path
   178	  local style_guide="${IFOS_VAULT_ROOT:-/vault}/${CTX_TENANT_SLUG}/_voice/style-guide.md"
   179	  if [[ -f "${style_guide}" ]]; then
   180	    printf '{"samples":[],"voice_corpus_version":"fallback","source":"fallback","style_guide_path":"%s","task_context":"%s","reason":"%s"}\n' \
   181	      "$(_hh_json_escape "${style_guide}")" \
   182	      "$(_hh_json_escape "${task_context}")" \
   183	      "$([[ -z "${IFOS_VL_QUERY_VECTOR:-}" ]] && printf 'no_query_vector' || printf 'db_unavailable')"
   184	    return 0
   185	  fi
   186	  printf '{"samples":[],"voice_corpus_version":"empty","source":"empty","task_context":"%s","reason":"no_db_no_style_guide"}\n' \
   187	    "$(_hh_json_escape "${task_context}")"
   188	}
   189	
   190	# Internal: render psql TSV → JSON for voice samples.
   191	_vl_render_voice_samples_json() {
   192	  local rows="$1"
   193	  local version="$2"
   194	  local source="$3"
   195	  local task_context="$4"
   196	
   197	  if [[ -z "${rows}" ]]; then
   198	    printf '{"samples":[],"voice_corpus_version":"%s","source":"%s","task_context":"%s","count":0}\n' \
   199	      "$(_hh_json_escape "${version}")" \
   200	      "$(_hh_json_escape "${source}")" \
   201	      "$(_hh_json_escape "${task_context}")"
   202	    return 0
   203	  fi
   204	
   205	  printf '{"samples":['
   206	  local first=1
   207	  while IFS=$'\t' read -r chunk_index text_chunk source_doc_ref distance; do
   208	    [[ -z "${chunk_index}" ]] && continue
   209	    if (( first )); then first=0; else printf ','; fi
   210	    printf '{"chunk_index":%s,"text_chunk":"%s","source_doc_ref":"%s","distance":%s}' \
   211	      "${chunk_index}" \
   212	      "$(_hh_json_escape "${text_chunk}")" \
   213	      "$(_hh_json_escape "${source_doc_ref}")" \
   214	      "${distance}"
   215	  done <<<"${rows}"
   216	  printf '],"voice_corpus_version":"%s","source":"%s","task_context":"%s"}\n' \
   217	    "$(_hh_json_escape "${version}")" \
   218	    "$(_hh_json_escape "${source}")" \
   219	    "$(_hh_json_escape "${task_context}")"
   220	}

exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	#
     3	# IFOS hook-helpers — implements the 3 hh_decision_* contracts + 7 autosend_*
     4	# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
     5	#
     6	# Sourced by every rendered agent's .claude/hooks/validate.sh and
     7	# .claude/hooks/context.sh via the per-tenant `_shared/` symlink resolved at
     8	# render time (ADR-003 §3.3.3 Option γ).
     9	#
    10	# Live-mode writes:        Postgres decision_log via psql + IFOS_DB_URL
    11	# Offline-mode writes:     JSON-line append to $IFOS_DECISION_LOG_FALLBACK
    12	#                          (defaults to /vault/<tenant>/decision-log.jsonl)
    13	#
    14	# The dual-mode design means: agents in degraded mode (Hetzner unreachable)
    15	# still produce an audit trail; the trail replays into Postgres when
    16	# connectivity returns. See agents/_shared/README.md §"Degraded mode".
    17	#
    18	# Shellcheck-clean: this file passes `shellcheck -s bash -S style`.
    19	# Side-effects: appends to decision_log table OR fallback JSONL; never reads
    20	# raw PII into shell vars (payload_preview must be sanitised by caller).
    21	
    22	# shellcheck shell=bash
    23	
    24	set -uo pipefail
    25	
    26	# ────────────────────────────────────────────────────────────────────────
    27	# Internal: paths, table names, sanity guards
    28	# ────────────────────────────────────────────────────────────────────────
    29	
    30	_HH_HELPERS_VERSION="0.1.0"
    31	_HH_POLICY_FILE="${HH_POLICY_FILE:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/autosend-policy.yaml}"
    32	_HH_ESC_CATALOGUE="${HH_ESC_CATALOGUE:-${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/escalation-codes.md}"
    33	
    34	# Fallback file used when IFOS_DB_URL is unset OR psql is unavailable.
    35	# Resolved at first call to _hh_emit_row().
    36	_hh_resolve_fallback_path() {
    37	  if [[ -n "${IFOS_DECISION_LOG_FALLBACK:-}" ]]; then
    38	    printf '%s' "${IFOS_DECISION_LOG_FALLBACK}"
    39	    return 0
    40	  fi
    41	  local tenant="${CTX_TENANT_SLUG:-unknown}"
    42	  local vault_root="${IFOS_VAULT_ROOT:-/vault}"
    43	  printf '%s/%s/decision-log.jsonl' "${vault_root}" "${tenant}"
    44	}
    45	
    46	# JSON escape a single string for inclusion in a JSON value.
    47	# Use this when BUILDING a JSON document from plain text.
    48	_hh_json_escape() {
    49	  local input="$1"
    50	  input="${input//\\/\\\\}"
    51	  input="${input//\"/\\\"}"
    52	  input="${input//$'\n'/\\n}"
    53	  input="${input//$'\r'/\\r}"
    54	  input="${input//$'\t'/\\t}"
    55	  printf '%s' "${input}"
    56	}
    57	
    58	# SQL escape a string for inclusion in a single-quoted SQL string literal.
    59	# Use this when EMBEDDING values in psql SQL. Doubles single quotes;
    60	# leaves everything else (incl. backslashes, JSON internal " characters)
    61	# alone — Postgres standard_conforming_strings=on (default since 9.1)
    62	# treats backslash as literal.
    63	_hh_sql_escape() {
    64	  local input="$1"
    65	  printf '%s' "${input//\'/\'\'}"
    66	}
    67	
    68	# Current ISO-8601 UTC timestamp with millisecond precision where available.
    69	# GNU date supports %3N (3-digit nanoseconds → milliseconds). BSD date
    70	# (macOS default) does NOT error on the spec but outputs the literal
    71	# string "3N" instead, which Postgres rejects as invalid timestamptz.
    72	# Detect by checking that %3N produced exactly 3 digits.
    73	_hh_now_iso() {
    74	  local ms
    75	  ms=$(date -u +"%3N" 2>/dev/null)
    76	  if [[ "${ms}" =~ ^[0-9]{3}$ ]]; then
    77	    date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
    78	  else
    79	    date -u +"%Y-%m-%dT%H:%M:%SZ"
    80	  fi
    81	}
    82	
    83	# Validate that ESC code exists in the catalogue.
    84	# Returns 0 if known, 1 otherwise. Catalogue absent → permissive (return 0).
    85	_hh_validate_esc_code() {
    86	  local code="$1"
    87	  if [[ ! -f "${_HH_ESC_CATALOGUE}" ]]; then
    88	    return 0
    89	  fi
    90	  if grep -Fq "\`${code}\`" "${_HH_ESC_CATALOGUE}"; then
    91	    return 0
    92	  fi
    93	  return 1
    94	}
    95	
    96	# ────────────────────────────────────────────────────────────────────────
    97	# Core decision-log writer
    98	# ────────────────────────────────────────────────────────────────────────
    99	
   100	# _hh_emit_row <phase> <outcome> <reason> <payload_json>
   101	#
   102	# Writes one row to decision_log. Live mode (IFOS_DB_URL set + psql available):
   103	# INSERT via psql -v ON_ERROR_STOP=1. Offline mode: append JSON line to
   104	# fallback file. The two formats are reconcilable by the sync worker.
   105	_hh_emit_row() {
   106	  local phase="$1"
   107	  local outcome="${2:-}"
   108	  local reason="${3:-}"
   109	  local payload_json="${4:-{\}}"
   110	
   111	  local tenant agent created_at
   112	  tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   113	  agent="${CTX_AGENT_NAME:?CTX_AGENT_NAME unset}"
   114	  created_at="$(_hh_now_iso)"
   115	
   116	  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   117	    local sql
   118	    sql=$(cat <<EOF
   119	BEGIN;
   120	SET LOCAL app.current_tenant = '$(_hh_sql_escape "${tenant}")';
   121	INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload, created_at)
   122	VALUES (
   123	  '$(_hh_sql_escape "${tenant}")',
   124	  '$(_hh_sql_escape "${agent}")',
   125	  '$(_hh_sql_escape "${phase}")',
   126	  $([ -z "${outcome}" ] && echo "NULL" || printf "'%s'" "$(_hh_sql_escape "${outcome}")"),
   127	  $([ -z "${reason}" ] && echo "NULL" || printf "'%s'" "$(_hh_sql_escape "${reason}")"),
   128	  '$(_hh_sql_escape "${payload_json}")'::jsonb,
   129	  '${created_at}'::timestamptz
   130	);
   131	COMMIT;
   132	EOF
   133	)
   134	    local psql_err
   135	    psql_err=$(printf '%s\n' "${sql}" | psql -v ON_ERROR_STOP=1 -q "${IFOS_DB_URL}" 2>&1)
   136	    if [[ $? -eq 0 ]]; then
   137	      return 0
   138	    fi
   139	    # psql failed — fall through to fallback append + emit warning to stderr
   140	    printf 'hh_emit_row: psql write failed; appending to fallback\n' >&2
   141	    printf 'hh_emit_row: psql error: %s\n' "${psql_err}" >&2
   142	  fi
   143	
   144	  local fallback
   145	  fallback="$(_hh_resolve_fallback_path)"
   146	  mkdir -p "$(dirname "${fallback}")" 2>/dev/null || true
   147	
   148	  local row
   149	  row=$(printf '{"tenant_slug":"%s","agent_name":"%s","phase":"%s","outcome":%s,"reason":%s,"payload":%s,"created_at":"%s","_hh_version":"%s"}' \
   150	    "$(_hh_json_escape "${tenant}")" \
   151	    "$(_hh_json_escape "${agent}")" \
   152	    "$(_hh_json_escape "${phase}")" \
   153	    "$([ -z "${outcome}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${outcome}")")" \
   154	    "$([ -z "${reason}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${reason}")")" \
   155	    "${payload_json}" \
   156	    "${created_at}" \
   157	    "${_HH_HELPERS_VERSION}")
   158	
   159	  printf '%s\n' "${row}" >> "${fallback}"
   160	}
   161	
   162	# ────────────────────────────────────────────────────────────────────────
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

exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '220,420p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   256	}
   257	
   258	# ────────────────────────────────────────────────────────────────────────
   259	# 7 autosend_* helpers (autosend-safety-policy §4)
   260	# ────────────────────────────────────────────────────────────────────────
   261	
   262	# autosend_policy_lookup <action_type>
   263	# Prints the tier (green|yellow|orange|red) to stdout; returns 0 if found,
   264	# 1 if action_type missing from policy file.
   265	autosend_policy_lookup() {
   266	  local action_type="$1"
   267	  if [[ ! -f "${_HH_POLICY_FILE}" ]]; then
   268	    printf 'autosend_policy_lookup: policy file not found at %s\n' "${_HH_POLICY_FILE}" >&2
   269	    return 1
   270	  fi
   271	  # YAML lookup via awk — finds the action_type key, then reads tier:
   272	  # one line below. Safer than yq/python deps at agent runtime.
   273	  local tier
   274	  tier=$(awk -v key="${action_type}" '
   275	    $0 ~ "^  " key ":" { in_block = 1; next }
   276	    in_block && /^    tier: / { sub(/^    tier: /, ""); print; exit }
   277	    in_block && /^  [a-z]/ { in_block = 0 }
   278	  ' "${_HH_POLICY_FILE}")
   279	  if [[ -z "${tier}" ]]; then
   280	    return 1
   281	  fi
   282	  printf '%s' "${tier}"
   283	}
   284	
   285	# autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>
   286	# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
   287	# tenant override file at /vault/<tenant>/_config/autosend-overrides.yaml.
   288	# Tenants can ELEVATE only (green→yellow→orange→red); red is the floor.
   289	autosend_apply_tenant_override() {
   290	  local base_tier="$1"
   291	  local action_type="$2"
   292	  local tenant_slug="$3"
   293	
   294	  # Red is absolute — no override possible.
   295	  if [[ "${base_tier}" == "red" ]]; then
   296	    printf '%s' "red"
   297	    return 0
   298	  fi
   299	
   300	  local override_file="${IFOS_VAULT_ROOT:-/vault}/${tenant_slug}/_config/autosend-overrides.yaml"
   301	  if [[ ! -f "${override_file}" ]]; then
   302	    printf '%s' "${base_tier}"
   303	    return 0
   304	  fi
   305	
   306	  local override
   307	  override=$(awk -v key="${action_type}" '
   308	    $0 ~ "^  " key ":" { sub(/^  [^:]+: */, ""); print; exit }
   309	  ' "${override_file}")
   310	
   311	  if [[ -z "${override}" ]]; then
   312	    printf '%s' "${base_tier}"
   313	    return 0
   314	  fi
   315	
   316	  # Enforce elevation-only ordering.
   317	  local base_rank override_rank
   318	  case "${base_tier}" in green) base_rank=0;; yellow) base_rank=1;; orange) base_rank=2;; red) base_rank=3;; *) return 1;; esac
   319	  case "${override}" in green) override_rank=0;; yellow) override_rank=1;; orange) override_rank=2;; red) override_rank=3;; *) return 1;; esac
   320	
   321	  if (( override_rank < base_rank )); then
   322	    printf 'autosend_apply_tenant_override: refusing to demote %s → %s for %s/%s\n' \
   323	      "${base_tier}" "${override}" "${tenant_slug}" "${action_type}" >&2
   324	    return 1
   325	  fi
   326	  printf '%s' "${override}"
   327	}
   328	
   329	# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
   330	# Emits the standard autosend decision_log row with payload.tier set.
   331	autosend_emit_decision_log() {
   332	  local phase="$1"
   333	  local tier="$2"
   334	  local action_type="$3"
   335	  local target="$4"
   336	  local payload_hash="$5"
   337	  local payload_preview="$6"
   338	  local reason_or_status="${7:-}"
   339	
   340	  local payload
   341	  payload=$(printf '{"tier":"%s","action_type":"%s","target":"%s","payload_hash":"%s","payload_preview":"%s","approval_status":%s,"block_reason":%s,"policy_version_sha":"%s"}' \
   342	    "$(_hh_json_escape "${tier}")" \
   343	    "$(_hh_json_escape "${action_type}")" \
   344	    "$(_hh_json_escape "${target}")" \
   345	    "$(_hh_json_escape "${payload_hash}")" \
   346	    "$(_hh_json_escape "${payload_preview}")" \
   347	    "$([ -z "${reason_or_status}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${reason_or_status}")")" \
   348	    "$([ "${tier}" = "red" ] || [ "${tier}" = "fail-safe-red" ] && printf '"%s"' "$(_hh_json_escape "${reason_or_status}")" || echo "null")" \
   349	    "${HH_POLICY_VERSION_SHA:-unknown}")
   350	  _hh_emit_row "${phase}" "${tier}" "${reason_or_status}" "${payload}"
   351	}
   352	
   353	# autosend_escalate <ESC_CODE> [<key=value>...]
   354	# Writes the ESC row + dispatches Telegram via primitive-5 helper. Catalogue
   355	# lookup is permissive — unknown codes are emitted with phase='gating_failed'
   356	# + ESC_AUTOSEND_POLICY_LOOKUP_FAILED meta-escalation.
   357	autosend_escalate() {
   358	  local code="$1"
   359	  shift
   360	
   361	  if ! _hh_validate_esc_code "${code}"; then
   362	    printf 'autosend_escalate: unknown ESC code: %s\n' "${code}" >&2
   363	    local meta_payload
   364	    meta_payload=$(printf '{"unknown_code":"%s","helpers_version":"%s"}' \
   365	      "$(_hh_json_escape "${code}")" "${_HH_HELPERS_VERSION}")
   366	    _hh_emit_row "gating_failed" "fail-safe-red" "esc_code_unknown" "${meta_payload}"
   367	    return 1
   368	  fi
   369	
   370	  local escaped_code
   371	  escaped_code="$(_hh_json_escape "${code}")"
   372	  local payload="{\"escalation_code\":\"${escaped_code}\""
   373	  local arg
   374	  for arg in "$@"; do
   375	    if [[ "${arg}" == *"="* ]]; then
   376	      local k="${arg%%=*}"
   377	      local v="${arg#*=}"
   378	      payload+=",\"$(_hh_json_escape "${k}")\":\"$(_hh_json_escape "${v}")\""
   379	    fi
   380	  done
   381	  payload+="}"
   382	
   383	  _hh_emit_row "gating_failed" "${code}" "" "${payload}"
   384	
   385	  # Telegram dispatch is a separate primitive — for v0.1 the row is the
   386	  # signal. Dispatcher (autosend-syncer) reads recent gating_failed rows and
   387	  # routes to operator chat per common-notifications.json.
   388	}
   389	
   390	# autosend_should_sample <action_type> <tenant_slug>
   391	# Returns 0 if this invocation should produce a spot-check (1-in-N draw);
   392	# 1 otherwise. Sample rate read from autosend-policy.yaml (sample_rate field);
   393	# tenant override via tenant_adapters.config.sampling_rates.
   394	autosend_should_sample() {
   395	  local action_type="$1"
   396	  # tenant_slug reserved for future per-tenant rate override; currently unused
   397	  local rate
   398	  rate=$(awk -v key="${action_type}" '
   399	    $0 ~ "^  " key ":" { in_block = 1; next }
   400	    in_block && /^    sample_rate: / { sub(/^    sample_rate: /, ""); print; exit }
   401	    in_block && /^  [a-z]/ { in_block = 0 }
   402	  ' "${_HH_POLICY_FILE}")
   403	
   404	  if [[ -z "${rate}" || ! "${rate}" =~ ^[0-9]+$ || "${rate}" -le 0 ]]; then
   405	    return 1
   406	  fi
   407	
   408	  local draw
   409	  draw=$(( RANDOM % rate ))
   410	  if (( draw == 0 )); then
   411	    return 0
   412	  fi
   413	  return 1
   414	}
   415	
   416	# autosend_spot_check_enqueue <action_type> <target> <payload_hash> <payload_preview> <tenant_slug>
   417	# Writes spot-check artefact under /vault/<tenant>/spot-checks/ for operator
   418	# review. Idempotent on payload_hash — duplicate enqueues become single file.
   419	autosend_spot_check_enqueue() {
   420	  local action_type="$1"

exec
/bin/zsh -lc 'rg -n "D1|autosend|orange|Proposed" docs/decisions/2026-05-20-codex-round-1-founder-decisions.md' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '680,750p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '570,610p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

 succeeded in 0ms:
   680	    notes: Diagnostic runs against public footprint per Ultraplan §8.1 A1 line 489. No Bullhorn-entity reads or writes.
   681	
   682	  Janitor:
   683	    candidate: R+W   # full sweep + normalisation + dedup proposals
   684	    contractor: R+W  # status normalisation
   685	    client: R+W      # orphan-link sweep + normalisation
   686	    contact: R       # read-only (Concierge owns writes)
   687	    brief: R         # status drift sweep
   688	    placement: R     # orphan / stale-tag sweep
   689	    opportunity: none
   690	    timesheet: none
   691	
   692	  Scribe:
   693	    candidate: R+W   # field updates from call transcripts (salary expectation, willing to relocate, etc.)
   694	    contractor: R+W  # contractor calls same pattern
   695	    client: none     # Scribe reads candidate's link to client via brief but doesn't write to client
   696	    contact: none
   697	    brief: R         # write-context resolution
   698	    placement: R+W   # note links on placed-candidate calls
   699	    opportunity: none
   700	    timesheet: none
   701	
   702	  Cash_Conductor:
   703	    candidate: none  # No Bullhorn touch — Xero + Open Banking only
   704	    contractor: none
   705	    client: none
   706	    contact: none
   707	    brief: none
   708	    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
   709	    opportunity: none
   710	    timesheet: none
   711	
   712	  Sourcing_Scout:
   713	    candidate: R     # passive matching
   714	    contractor: R    # contractor pool
   715	    client: R        # target-firm context
   716	    contact: none    # thin v1.0
   717	    brief: R         # active brief context for matching
   718	    placement: none
   719	    opportunity: none
   720	    timesheet: none
   721	
   722	  Concierge:
   723	    candidate: R+W   # lifecycle state on every event
   724	    contractor: R+W  # lifecycle state, contractor-specific cadence
   725	    client: R        # relationship context
   726	    contact: R       # decision-maker resolution for orange-tier sends
   727	    brief: R         # linked-brief context
   728	    placement: R+W   # lifecycle stage maintenance (week_1, month_1, etc.)
   729	    opportunity: none
   730	    timesheet: none
   731	
   732	# ============================================================================
   733	# §4 — Bullhorn mapping
   734	# ============================================================================
   735	# Per-entity Bullhorn source + field-level mapping notes.
   736	# Verifies against real Bullhorn data at Week 3-4 Janitor build per bullhorn §4.1 Spec gap §4.1-A.
   737	# ============================================================================
   738	
   739	bullhorn_mapping:
   740	
   741	  candidate:
   742	    bullhorn_entity: Bullhorn.Candidate
   743	    primary_key: id
   744	    status_filter: status != 'contractor'
   745	    field_mapping_density: v0.1 covers 18 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn-integration-path.md §4.1 Spec gap §4.1-A.
   746	
   747	  contractor:
   748	    bullhorn_entity: Bullhorn.Candidate
   749	    primary_key: id
   750	    status_filter: status='contractor'

 succeeded in 0ms:
4:**Status:** Proposed
11:## D1 — Auto-send v1.0 tier enforcement (orange-tier behavior)
14:- `docs/decisions/autosend-safety-policy.md` §3 (defines 4 tiers + classifies 10 action_types as orange)
15:- `docs/decisions/autosend-safety-policy.md` §9 (says "v1.0 ships green + red only")
16:- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issues 1+2
18:**Codex's framing:** "v1.0 tier semantics are internally contradictory. Lines 41-68 define four tiers and line 43 says every governed action falls into exactly one tier at execution, but lines 474-481 say v1.0 ships green + red only while orange approval is handled outside the policy pipeline. ... Canonical orange actions are described as v1.0-mitigated, but orange is not implemented in v1.0."
20:**Real issue:** 10 action_types (including the canonical orange `bullhorn_note_customer_visible` — Concierge's primary outbound action) are classified as orange. v1.0 ships green+red only. In v1.0, those orange action_types must either:
22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
23:- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
24:- **D1-C: Ship orange-as-red default + manual override** — orange action_types refused by default in v1.0, but per-action manual approval via founder's Telegram bot allowed as escape hatch. Pragmatic; aligns with autosend §9 "orange handled outside the policy pipeline" wording. **Closest to current artefact wording but explicit about the manual surface.**
26:**Claude's recommendation (initial briefing, Day 8):** D1-C. v1.0 ships with orange-as-red default + documented manual approval path. Concierge demo pitch becomes "voice-classified drafts that the operator can approve in Telegram"; doesn't promise full auto-send-with-policy in v1.0. v1.1 implements full orange approval gate.
28:**Claude's recommendation (Day-11 update, post implementation-spec investigation):** **D1-B.** Investigation surfaced that the "~1 week extra" cost was overestimated — cortextOS Primitive 4 (`createApproval` + `updateApproval` in `packages/harness/cortextos/src/bus/approval.ts`) already implements the Telegram fan-out + button-press routing. IFOS-side work is a thin bridge: 2 file watchers + a small Postgres state table. Realistic effort: 2-3 days. See `docs/decisions/autosend-approval-bridge-spec.md` for the full implementation surface (10 acceptance criteria, 6 risks, 600 lines TypeScript scaffold + tests).
30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
32:**Alternative timing:** Insert as next IFOS Claude slice now (post-Diagnostic-build, ~Week 8). Marginal benefit: D1 becomes a closed item earlier; bridge gets stress-tested before Concierge needs it. Cost: 2-3 days inserted before Concierge.
34:**Cost of deferral:** Concierge W10 build risks slipping if bridge isn't ready. Concrete delay: ~3 days. Risk #2 (Bullhorn) is the bigger blocker for Concierge (auth path); D1 is downstream of that.
36:**D1 Concrete recommendation:** Schedule for Week 9 (default). Founder explicitly approves D1-B; bridge spec ratifies through Codex Round 2; bridge implementation slice authored Week 9.
44:- `docs/decisions/autosend-safety-policy.md` §10 ("Pilot-agreement liability language placeholder — counsel-reviewed")
45:- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issue 3
49:**Real issue:** v1.0 kill-criterion §3.4 names "external advisor" as a Week 1-2 must-fill. This is also the resolution path for autosend §10 pilot-agreement liability. Today = 2026-05-20 (Day 8 = Week 1 underway). No advisor identified.
68:**Codex's framing:** "`recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker."
142:| **D1** (autosend v1.0 tier) | This week | Concierge build scope (W10-13) |
147:**Recommended order:** D5 (quickest, unblocks Round 2) → D1 (Concierge planning) → D2 + D3 (legal bundle) → D4 (no-rush).
158:## D1 — Resolution (2026-05-XX)
160:Founder picks D1-C: ship orange-as-red default + manual override.
164:Implementation work: <commit reference or "in autosend §9 update commit">
167:OR open a follow-on ADR if the decision warrants more substantive recording (e.g., ADR-005 for D1; ADR-006 for D2 + D3 bundle).

exec
/bin/zsh -lc 'rg -n "cash_conductor|recent_edit|last_chase|transaction|invoice|accounting_reconciliation|xero_reminder|placement|client_contact|tone_rule|voice_corpus" docs/verticals/recruitment/vertical-schema.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
214:        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
218:      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.
223:      A company that hires through the recruitment agency. Master brief canonical vocabulary at §3.2 line 155 ("candidate, placement, brief") implicitly assumes client as the holder of briefs. Bullhorn calls this `ClientCorporation`.
429:  placement:
431:      A candidate placed into a client role. The commercial transaction unit — fees accrue per placement, lifecycle events (week-1, month-1, etc.) fire per placement per Product Spec §2.2 R7.
434:      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
450:        notes: Nullable for permanent placements; required for contract.
456:      placement_type:
465:        notes: GBP. For permanent placements typically % of candidate_salary_at_placement; for contract typically per-day margin.
471:      candidate_salary_at_placement:
491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
497:      A candidate-brief pairing in the submission/screening/interview/offer pipeline. Pre-placement state. v1.1+ exercised; v1.0 minimal.
587:    target: placement
589:    description: A candidate may have multiple placements over time (different clients, different roles). A placement has exactly one candidate.
591:      Despite "M:N" cardinality, practically 1:N from placement → candidate (each placement has one candidate; each candidate has 0..N placements). Modelled as M:N for query symmetry.
592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
594:  placement_for_brief:
595:    source: placement
598:    description: Each placement fills exactly one brief; a brief may have multiple placements over time (replacement hires, multiple seats).
654:  timesheet_for_placement:
656:    target: placement
658:    description: Each timesheet relates to one (contract) placement; a placement has 0..N timesheets over its duration.
677:    placement: none
688:    placement: R     # orphan / stale-tag sweep
698:    placement: R+W   # note links on placed-candidate calls
708:    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
718:    placement: none
728:    placement: R+W   # lifecycle stage maintenance (week_1, month_1, etc.)
771:  placement:
835:    revisit_trigger: If Concierge surfaces multi-contractor patterns where the same umbrella company serves multiple IFOS-tracked contractors (e.g., "all contractors at Acme Umbrella who terminate placements within 90 days"), promote umbrella_company to entity_type='umbrella_company' in v1.1.
844:  Q9_multi_client_contact:
861:    v0_1_decision: placement.lifecycle_stage enum is hardcoded to Product Spec §2.2 R7 values (pre_start, week_1, month_1, month_3, month_6, month_12, month_24, completed).
862:    revisit_trigger: Any Product Spec revision touching R7 nurture cadence (e.g., adding week_2 checkpoint, removing month_24, splitting month_12 into quarterly checkpoints) requires schema migration. Migration steps — (1) ALTER TABLE add new enum value(s) to entities.data JSONB validator; (2) backfill existing placement rows if semantic change (e.g., week_1 → week_1_check_in renaming); (3) Concierge nurture-event firing logic updated to match new cadence.

exec
/bin/zsh -lc "rg -n \"v0\\.3|recent_edit|Cash Conductor|Cash_Conductor|cash_conductor\" docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
702:  Cash_Conductor:

exec
/bin/zsh -lc "rg --files docs | rg -i 'schema|supplement|v0\\.2|v0\\.3|migration'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql
docs/_archive-build-pack/05-MIGRATION-MAP.md
docs/_supplementary/PRD-autonomous-agent.md
docs/_supplementary/build-plan-original.md
docs/_supplementary/README.md
docs/_supplementary/strategic-plan.md
docs/_supplementary/planning-phase-brief.md
docs/_supplementary/technical-strategy-v2.md
docs/_supplementary/execution-plan.md

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
     2	# ============================================================================
     3	# Status: Proposed (Codex Day-19 ratification queue addendum)
     4	# Date:   2026-05-24 (Day 19; post-Round-8 Cat-β unblock)
     5	# Author: Founder (Maddox) + Claude Code
     6	# Predecessor: docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
     7	#
     8	# Partially addresses Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor +
     9	# Concierge schema gaps) per docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md
    10	# Phase 4 Cat-β section. Closes the v0.3-scoped subset (14 entity JSONB keys + 2
    11	# auxiliary tables + 6 tenant_adapters.config keys + v0.2 entity-access amendments).
    12	# (v0.3-supplement-0.1 amendment Day-20: original 3 v0.3 keys + 2 Janitor keys
    13	# added closing Janitor R11 Finding 4 + blocked_recipients added closing
    14	# Sourcing Scout R8 Finding 1. blocked_recipients is pre-v0.3 origin
    15	# canonicalised here. Total: 6 declarations in §4.)
    16	# Residual Cat-β gaps require either (a) Scribe agent.md consistency-pass to align
    17	# its §3 narrative with canonical v0.1/v0.2/v0.3 field names (current_role vs
    18	# current_role_title; start_date_target vs brief.start_date; etc.) OR (b) a follow-on
    19	# v0.4-supplement that adds the remaining Scribe-referenced fields (seniority,
    20	# opportunity.sector, current_role_title). v0.4 work is queued for W4-polish slice;
    21	# v0.3 ratification does not block on it.
    22	#
    23	# Companion migrations: migrations/v0.2-to-v0.3.sql + migrations/v0.3-to-v0.2.sql
    24	#   Both files drafted at commit alongside this supplement.
    25	#
    26	# Field types: per `review-schema-change` skill §2 allowed types only —
    27	# string | integer | number | boolean | array | object | timestamp | date.
    28	# Enums expressed as `type: string` + `enum: [...]`. Lists as `type: array`
    29	# with `items.type`. SQL-level types (NUMERIC(15,2), TIMESTAMPTZ etc.) appear
    30	# only in the companion migration SQL, not here.
    31	#
    32	# Schema layering: entities.data is JSONB per Day-4 §6.3 generic primitive.
    33	# v0.3 entity-field additions are JSONB key shapes validated via the
    34	# validate_entities_data_v0_3 trigger function in v0.2-to-v0.3.sql §4.
    35	# No ALTER TABLE for the candidate / contact / brief / placement / opportunity
    36	# tables — they're already JSONB-shaped.
    37	# ============================================================================
    38	
    39	vertical: recruitment
    40	version: v0.3
    41	supplements: v0.2
    42	status: Proposed
    43	date: 2026-05-24
    44	author: founder (Maddox) + Claude Code; bilateral Cat-β unblock
    45	codex_ratification_queue_position: 44
    46	
    47	# ============================================================================
    48	# §1 — New entity.data JSONB key shapes (14 across 5 entities)
    49	# ============================================================================
    50	#
    51	# All additions land as JSONB keys on the existing entities.data column
    52	# (Day-4 §6.3 generic primitive layer). Validation lives in
    53	# validate_entities_data_v0_3() trigger function (migration §4).
    54	
    55	entity_field_additions:
    56	
    57	  candidate:
    58	    v0_3_new_keys:
    59	      employment_type:
    60	        type: string
    61	        enum: [perm, contract, contract_inside_ir35, contract_outside_ir35, day_rate, hybrid]
    62	        required: false
    63	        notes: |
    64	          Candidate's preferred engagement model (distinct from role type).
    65	          IR35 distinction matters for UK contractors. Extracted by Scribe
    66	          from call context.
    67	        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
    68	        v1_0_agent_access:
    69	          - Scribe: W
    70	          - Sourcing Scout: R
    71	
    72	      key_skills:
    73	        type: array
    74	        items:
    75	          type: string
    76	        max_items: 20
    77	        required: false
    78	        notes: |
    79	          Aggregated skill tags from CV + transcripts. Free-text strings;
    80	          W4 polish may add controlled-vocabulary clustering. Max 20 items
    81	          per candidate enforced by validate_entities_data_v0_3.
    82	        source: IFOS-derived (Scribe from CV/transcripts; Sourcing Scout from CV-Library + Reed search results)
    83	        v1_0_agent_access:
    84	          - Scribe: W
    85	          - Sourcing Scout: R+W
    86	
    87	      linkedin_url:
    88	        type: string
    89	        pattern: '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$'
    90	        required: false
    91	        notes: |
    92	          LinkedIn profile URL. Pattern enforced by trigger. Set by Sourcing
    93	          Scout from match; Janitor uses for dedup (stronger match signal
    94	          than name+email); Concierge reads for outreach context (NOT for
    95	          outbound — outreach via candidate.email or candidate.phone only).
    96	        source: IFOS-derived (Sourcing Scout from match; Janitor for dedup verification)
    97	        v1_0_agent_access:
    98	          - Sourcing Scout: R+W
    99	          - Janitor: R   # W only via dedup-merge action
   100	          - Concierge: R
   101	
   102	  contact:
   103	    v0_3_new_keys:
   104	      preferred_channel:
   105	        type: string
   106	        enum: [email, phone, sms, teams, slack, in_person, unknown]
   107	        default: unknown
   108	        required: false
   109	        notes: |
   110	          Contact's stated preference; extracted by Scribe from call context.
   111	          Concierge reads to route outbound lifecycle comms.
   112	        source: IFOS-derived (Scribe extraction)
   113	        v1_0_agent_access:
   114	          - Scribe: R+W
   115	          - Concierge: R
   116	
   117	      next_action_target_date:
   118	        type: date
   119	        required: false
   120	        notes: |
   121	          ISO-8601 date set by Scribe at call-end when "I'll follow up by X"
   122	          is in transcript. Concierge respects this when scheduling lifecycle
   123	          nurture.
   124	        source: IFOS-derived (Scribe extraction)
   125	        v1_0_agent_access:
   126	          - Scribe: R+W
   127	          - Concierge: R
   128	
   129	  brief:
   130	    v0_3_new_keys:
   131	      must_haves:
   132	        type: array
   133	        items:
   134	          type: string
   135	        max_items: 15
   136	        required: false
   137	        notes: |
   138	          Hard requirements; Sourcing Scout filters candidates against this
   139	          list. Free-text strings; max 15 items enforced by trigger.
   140	        source: IFOS-derived (Scribe extracts from briefing-call transcripts)
   141	        v1_0_agent_access:
   142	          - Scribe: R+W
   143	          - Sourcing Scout: R
   144	
   145	      nice_to_haves:
   146	        type: array
   147	        items:
   148	          type: string
   149	        required: false
   150	        notes: |
   151	          Soft preferences; Sourcing Scout uses for ranking, not hard filter.
   152	        source: IFOS-derived (Scribe extracts)
   153	        v1_0_agent_access:
   154	          - Scribe: R+W
   155	          - Sourcing Scout: R
   156	
   157	      deal_breakers:
   158	        type: array
   159	        items:
   160	          type: string
   161	        required: false
   162	        notes: |
   163	          Anti-requirements; Sourcing Scout EXCLUDES candidates matching any
   164	          item.
   165	        source: IFOS-derived (Scribe extracts)
   166	        v1_0_agent_access:
   167	          - Scribe: R+W
   168	          - Sourcing Scout: R
   169	
   170	  placement:
   171	    v0_3_new_keys:
   172	      placement_status:
   173	        type: string
   174	        enum: [pending_start, active, completed, terminated_early, on_hold, cancelled]
   175	        default: pending_start
   176	        required: false
   177	        notes: |
   178	          Lifecycle state tracking. Scribe sets 'active' at 7d check-in
   179	          confirming candidate started. Janitor flags ambiguous via
   180	          ESC_LIFECYCLE_STATE_UNKNOWN.
   181	        source: IFOS-derived (Scribe + Janitor)
   182	        v1_0_agent_access:
   183	          - Scribe: R+W
   184	          - Janitor: R+W
   185	          - Concierge: R
   186	
   187	      week_1_status_vault_path:
   188	        type: string
   189	        max_length: 200
   190	        pattern: '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$'
   191	        required: false
   192	        notes: |
   193	          POINTER ONLY (per ADR-002 vault/Postgres split). The 7d check-in
   194	          narrative itself lives in vault at `/vault/<tenant>/scribe-notes/
   195	          <call_id>-<ISO-date>.md` (canonical Scribe tacit-note pattern).
   196	          Pattern accepts call_ids + ISO dates (hyphens + underscores +
   197	          alphanumerics). This field stores the vault path; narrative does
   198	          NOT enter Postgres. Voice-classifier review at write time applies
   199	          to the vault file content; Concierge reads the vault file directly
   200	          via its path resolution.
   201	        source: IFOS-derived (Scribe extracts from 7d check-in call; writes
   202	          to vault then stores pointer here)
   203	        v1_0_agent_access:
   204	          - Scribe: R+W
   205	          - Concierge: R
   206	
   207	      satisfaction_signal:
   208	        type: string
   209	        enum: [positive, neutral, negative, unclear]
   210	        default: unclear
   211	        required: false
   212	        notes: |
   213	          Scribe's LLM-sentiment inference from 7d/30d/90d check-in call.
   214	          Concierge reads to adjust nurture tone.
   215	        source: IFOS-derived (Scribe LLM extraction)
   216	        v1_0_agent_access:
   217	          - Scribe: R+W
   218	          - Concierge: R
   219	
   220	  opportunity:

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	-- ============================================================================
     2	-- IFOS recruitment vertical schema — v0.2 → v0.3 migration
     3	-- ============================================================================
     4	-- Companion to: docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
     5	-- Authored:     2026-05-24 (Day 19; post-bilateral Cat-β unblock)
     6	-- Status:       DRAFTED; NOT executed against production Hetzner Postgres yet.
     7	--               Execute against migration-test tenant first via run-live-migration.sh.
     8	--
     9	-- Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
    10	-- Concierge). v0.3 additions:
    11	--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
    12	--     (both RLS-isolated per tenant_slug)
    13	--   - JSONB validation trigger updates for entities.data: validate new keys on
    14	--     candidate, contact, brief, placement, opportunity (14 fields across 5
    15	--     entity_types)
    16	--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
    17	--   - decision_log.payload extension is DEFERRED to a future W4-polish ADR
    18	--     + schema supplement (per ADR-006 Tier 2 + v0.3 supplement §5). v0.3
    19	--     does NOT extend the payload shape; the W4 ADR will add both the new
    20	--     payload key and its enforcement (CHECK constraint or trigger).
    21	--
    22	-- All v0.3 additions are STRICTLY ADDITIVE. Rollback path: companion
    23	-- v0.3-to-v0.2.sql.
    24	--
    25	-- Prerequisites:
    26	--   - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule +
    27	--     recent_edit tables exist; validate_voice_scores trigger active)
    28	--   - RLS policies + ifos_app grants from Day-4 §6.3 in place
    29	--   - migration-test tenant row exists in tenants table
    30	--
    31	-- Execution order: BEGIN; <each block>; COMMIT;   on success.
    32	--                  BEGIN; <each block>; ROLLBACK; on any error.
    33	-- ============================================================================
    34	
    35	BEGIN;
    36	
    37	-- ----------------------------------------------------------------------------
    38	-- §1 — Verify prerequisite v0.2 state
    39	-- ----------------------------------------------------------------------------
    40	
    41	DO $$
    42	BEGIN
    43	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus') THEN
    44	    RAISE EXCEPTION 'v0.2 voice_corpus table missing; run v0.1-to-v0.2.sql first';
    45	  END IF;
    46	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus_chunks') THEN
    47	    RAISE EXCEPTION 'v0.2 voice_corpus_chunks table missing; run v0.1-to-v0.2.sql first';
    48	  END IF;
    49	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'tone_rule') THEN
    50	    RAISE EXCEPTION 'v0.2 tone_rule table missing; run v0.1-to-v0.2.sql first';
    51	  END IF;
    52	  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
    53	    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
    54	  END IF;
    55	  RAISE NOTICE 'v0.2 prerequisites verified (4 tables: voice_corpus + voice_corpus_chunks + tone_rule + recent_edit)';
    56	END $$;
    57	
    58	-- ----------------------------------------------------------------------------
    59	-- §2 — Create cash_conductor_transactions table (RLS-isolated)
    60	-- ----------------------------------------------------------------------------
    61	
    62	CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
    63	  id                 BIGSERIAL PRIMARY KEY,
    64	  tenant_slug        TEXT NOT NULL,
    65	  transaction_id     TEXT NOT NULL,
    66	  posted_at          TIMESTAMPTZ NOT NULL,
    67	  amount             NUMERIC(15, 2) NOT NULL,
    68	  currency           TEXT NOT NULL DEFAULT 'GBP',
    69	  payee_name_raw     TEXT,
    70	  description        TEXT,
    71	  bank_provider      TEXT NOT NULL,
    72	  match_status       TEXT NOT NULL DEFAULT 'unmatched',
    73	  matched_invoice_id TEXT,
    74	  match_confidence   NUMERIC(3, 2),
    75	  match_dimensions   TEXT[],
    76	  ingested_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
    77	  raw_payload        JSONB,
    78	
    79	  CONSTRAINT cct_match_status_valid CHECK (
    80	    match_status IN ('unmatched', 'matched', 'ambiguous')
    81	  ),
    82	  CONSTRAINT cct_bank_provider_valid CHECK (
    83	    bank_provider IN ('truelayer', 'plaid_uk', 'open_banking_direct')
    84	  ),
    85	  CONSTRAINT cct_match_confidence_range CHECK (
    86	    match_confidence IS NULL OR (match_confidence >= 0.00 AND match_confidence <= 1.00)
    87	  ),
    88	  CONSTRAINT cct_tenant_transaction_unique UNIQUE (tenant_slug, bank_provider, transaction_id)
    89	);
    90	
    91	CREATE INDEX IF NOT EXISTS idx_cct_tenant_posted
    92	  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
    93	
    94	CREATE INDEX IF NOT EXISTS idx_cct_tenant_unmatched
    95	  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
    96	  WHERE match_status IN ('unmatched', 'ambiguous');
    97	
    98	-- RLS isolation per Day-4 §6.3 pattern
    99	ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
   100	ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
   101	
   102	CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
   103	  FOR ALL TO ifos_app
   104	  USING (tenant_slug = current_setting('app.current_tenant', true));
   105	
   106	GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
   107	GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
   108	
   109	-- ----------------------------------------------------------------------------
   110	-- §3 — Create cash_conductor_invoices table (RLS-isolated)
   111	-- ----------------------------------------------------------------------------
   112	
   113	CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
   114	  id                       BIGSERIAL PRIMARY KEY,
   115	  tenant_slug              TEXT NOT NULL,
   116	  invoice_id               TEXT NOT NULL,
   117	  accounting_provider      TEXT NOT NULL,
   118	  invoice_number           TEXT,
   119	  issued_at                TIMESTAMPTZ NOT NULL,
   120	  due_at                   TIMESTAMPTZ NOT NULL,
   121	  amount_total             NUMERIC(15, 2) NOT NULL,
   122	  amount_paid              NUMERIC(15, 2) NOT NULL DEFAULT 0,
   123	  currency                 TEXT NOT NULL DEFAULT 'GBP',
   124	  status                   TEXT NOT NULL DEFAULT 'open',
   125	  client_contact_id        TEXT,
   126	  client_billing_email     TEXT,
   127	  last_chase_position      INT NOT NULL DEFAULT 0,
   128	  last_chase_sent_at       TIMESTAMPTZ,
   129	  ingested_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
   130	  raw_payload              JSONB,
   131	
   132	  CONSTRAINT cci_status_valid CHECK (
   133	    status IN ('open', 'partial', 'paid', 'overdue', 'cancelled', 'voided')
   134	  ),
   135	  CONSTRAINT cci_provider_valid CHECK (
   136	    accounting_provider IN ('xero', 'quickbooks', 'sage')
   137	  ),
   138	  CONSTRAINT cci_chase_position_range CHECK (
   139	    last_chase_position >= 0 AND last_chase_position <= 4
   140	  ),
   141	  CONSTRAINT cci_amount_paid_non_negative CHECK (
   142	    amount_paid >= 0 AND amount_paid <= amount_total
   143	  ),
   144	  CONSTRAINT cci_tenant_provider_invoice_unique UNIQUE (tenant_slug, accounting_provider, invoice_id)
   145	);
   146	
   147	CREATE INDEX IF NOT EXISTS idx_cci_tenant_due
   148	  ON cash_conductor_invoices (tenant_slug, due_at);
   149	
   150	CREATE INDEX IF NOT EXISTS idx_cci_tenant_overdue
   151	  ON cash_conductor_invoices (tenant_slug, status, due_at)
   152	  WHERE status IN ('open', 'partial', 'overdue');
   153	
   154	CREATE INDEX IF NOT EXISTS idx_cci_tenant_chase
   155	  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
   156	  WHERE last_chase_position BETWEEN 1 AND 3;
   157	
   158	ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
   159	ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
   160	
   161	CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
   162	  FOR ALL TO ifos_app
   163	  USING (tenant_slug = current_setting('app.current_tenant', true));
   164	
   165	GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
   166	GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
   167	
   168	-- ----------------------------------------------------------------------------
   169	-- §4 — Replace JSONB validation function for entities.data (adds v0.3 keys)
   170	-- ----------------------------------------------------------------------------
   171	--
   172	-- The v0.2 migration installed validate_voice_scores trigger which validates
   173	-- the 6 voice-score keys. v0.3 extends validation to cover the 14 new keys
   174	-- for candidate, contact, brief, placement, opportunity. We replace the
   175	-- function in place (CREATE OR REPLACE) so the v0.2 voice-score checks remain.
   176	
   177	CREATE OR REPLACE FUNCTION validate_entities_data_v0_3()
   178	RETURNS TRIGGER AS $$
   179	DECLARE
   180	  d JSONB := NEW.data;
   181	  et TEXT := NEW.entity_type;
   182	  arr_item JSONB;
   183	BEGIN
   184	  -- v0.2 voice-score keys (forwarded; preserves v0.2 [0.0, 1.0] range check)
   185	  IF d ? 'voice_classifier_score' THEN
   186	    IF jsonb_typeof(d->'voice_classifier_score') NOT IN ('number', 'null') THEN
   187	      RAISE EXCEPTION 'voice_classifier_score must be number or null';
   188	    END IF;
   189	    IF d->'voice_classifier_score' != 'null'::jsonb THEN
   190	      IF (d->>'voice_classifier_score')::numeric < 0.0
   191	         OR (d->>'voice_classifier_score')::numeric > 1.0 THEN
   192	        RAISE EXCEPTION 'voice_classifier_score out of [0.0, 1.0] range: %', d->>'voice_classifier_score';
   193	      END IF;
   194	    END IF;
   195	  END IF;
   196	
   197	  IF d ? 'voice_drift_at_close' THEN
   198	    IF jsonb_typeof(d->'voice_drift_at_close') NOT IN ('number', 'null') THEN
   199	      RAISE EXCEPTION 'voice_drift_at_close must be number or null';
   200	    END IF;
   201	    IF d->'voice_drift_at_close' != 'null'::jsonb THEN
   202	      IF (d->>'voice_drift_at_close')::numeric < 0.0
   203	         OR (d->>'voice_drift_at_close')::numeric > 1.0 THEN
   204	        RAISE EXCEPTION 'voice_drift_at_close out of [0.0, 1.0] range: %', d->>'voice_drift_at_close';
   205	      END IF;
   206	    END IF;
   207	  END IF;
   208	
   209	  -- v0.3 candidate fields
   210	  IF et = 'candidate' THEN
   211	    IF d ? 'employment_type' THEN
   212	      IF (d->>'employment_type') NOT IN (
   213	        'perm', 'contract', 'contract_inside_ir35', 'contract_outside_ir35', 'day_rate', 'hybrid'
   214	      ) THEN
   215	        RAISE EXCEPTION 'employment_type invalid: %', d->>'employment_type';
   216	      END IF;
   217	    END IF;
   218	
   219	    IF d ? 'key_skills' THEN
   220	      IF jsonb_typeof(d->'key_skills') != 'array' THEN
   221	        RAISE EXCEPTION 'key_skills must be array';
   222	      END IF;
   223	      IF jsonb_array_length(d->'key_skills') > 20 THEN
   224	        RAISE EXCEPTION 'key_skills max length 20 (got %)', jsonb_array_length(d->'key_skills');
   225	      END IF;
   226	      -- Every element must be a string
   227	      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'key_skills') LOOP
   228	        IF jsonb_typeof(arr_item) != 'string' THEN
   229	          RAISE EXCEPTION 'key_skills items must be strings; got %', jsonb_typeof(arr_item);
   230	        END IF;
   231	      END LOOP;
   232	    END IF;
   233	
   234	    IF d ? 'linkedin_url' THEN
   235	      IF jsonb_typeof(d->'linkedin_url') NOT IN ('string', 'null') THEN
   236	        RAISE EXCEPTION 'linkedin_url must be string or null';
   237	      END IF;
   238	      IF d->>'linkedin_url' IS NOT NULL
   239	         AND d->>'linkedin_url' !~ '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$' THEN
   240	        RAISE EXCEPTION 'linkedin_url does not match expected pattern: %', d->>'linkedin_url';
   241	      END IF;
   242	    END IF;
   243	  END IF;
   244	
   245	  -- v0.3 contact fields
   246	  IF et = 'contact' THEN
   247	    IF d ? 'preferred_channel' THEN
   248	      IF (d->>'preferred_channel') NOT IN (
   249	        'email', 'phone', 'sms', 'teams', 'slack', 'in_person', 'unknown'
   250	      ) THEN
   251	        RAISE EXCEPTION 'preferred_channel invalid: %', d->>'preferred_channel';
   252	      END IF;
   253	    END IF;
   254	
   255	    IF d ? 'next_action_target_date' THEN
   256	      IF jsonb_typeof(d->'next_action_target_date') NOT IN ('string', 'null') THEN
   257	        RAISE EXCEPTION 'next_action_target_date must be ISO-8601 date string or null';
   258	      END IF;
   259	      -- Validate ISO-8601 date format (YYYY-MM-DD) by cast
   260	      IF d->>'next_action_target_date' IS NOT NULL THEN

exec
/bin/zsh -lc 'rg -n "cash_conductor|Cash Conductor|recent_edit|last_chase|invoice|transaction|accounting|reconciliation|xero" docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:129:      - Cash Conductor (R — payment reminder tone)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:259:      recent_edit is the most privacy-sensitive entity in v0.2 because it stores raw agent output (potentially including names, salaries, etc. — anything the agent drafted). RLS isolation per tenant_slug is non-negotiable. Retention: indefinite for v1.0 (the SFT corpus needs longitudinal data); revisit at v1.1 if tenant pushes back. Per-message redaction is the operator's responsibility before approval.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:350:  recent_edit_drives_retraining:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:351:    source: recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:355:      The retraining queue: recent_edits with edit_distance > threshold accumulate as candidates for the next voice_corpus version's source corpus (and for v2.0 LoRA SFT pairs). M:N because one recent_edit may inform multiple future corpus versions (longitudinal SFT data); one corpus version draws from many edits.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1:# IFOS recruitment vertical schema v0.3 — Scribe + Cash Conductor + Concierge fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:8:# Partially addresses Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:289:#   - Cash Conductor contact: none → R (reads for invoice addressee resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:291:#   - Cash Conductor placement: none → R (reads for client linkage on invoice)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:292:#   - Cash Conductor timesheet: none → R (reads to verify billable hours
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:293:#     match invoiced amounts)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:306:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:308:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:322:  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:330:  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:402:  cash_conductor:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:403:    # NOTE: Cash Conductor has NO direct Bullhorn endpoint access per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:407:    # sync paths). Cash Conductor never calls Bullhorn endpoints directly.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:411:    contact: R             # IFOS-cached read; invoice addressee resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:413:    opportunity: R         # v0.3 NEW — IFOS-cached read; invoice-context (NOT a direct Bullhorn call; only cached rows)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:414:    placement: R           # IFOS-cached read; client linkage on invoice
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:415:    timesheet: R           # IFOS-cached read; verify billable hours match invoice (NOT a direct Bullhorn call)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:467:      - Cash Conductor (R) # v0.3 NEW — reads client billing details for invoices
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:471:      v0.3 grants R to Diagnostic + Scribe + Cash Conductor (each reads
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:480:      - Cash Conductor (R) # v0.3 NEW — reads for invoice addressee resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:486:      Diagnostic + Cash Conductor gain R for context.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:506:      - Cash Conductor (R) # v0.3 NEW — reads for invoice context
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:513:      timing), Diagnostic + Cash Conductor (reads for context).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:516:    v0_1_v1_0_agent_access: [Janitor (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:520:      - Cash Conductor (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:527:    v0_1_v1_0_agent_access: [Cash Conductor (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:531:      - Cash Conductor (R) # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:534:      v0.1 timesheet is Cash Conductor only. v0.3 grants R to Janitor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:566:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:575:    v0_2_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:576:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:584:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:      - Cash Conductor (W)       # v0.3 NEW — writes own chase-draft edits
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:596:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:602:# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:607:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:609:      Open Banking transactions are high-volume + time-series + don't model
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:611:      RLS isolation and indexes for date + match-status. Per Cash Conductor
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:617:      transaction_id: {type: string, required: true, source: Open Banking provider (TrueLayer / Plaid)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:624:      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched, source: IFOS-derived (Cash Conductor reconciliation algorithm)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:625:      matched_invoice_id: {type: string, required: false, source: IFOS-derived, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:626:      match_confidence: {type: number, required: false, source: IFOS-derived (Cash Conductor algorithm), notes: "range [0.00, 1.00]"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:645:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:647:      Open invoice register cached from accounting provider. Same auxiliary-
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:648:      table pattern as transactions. Per Cash Conductor §4 Step 4.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:653:      invoice_id: {type: string, required: true, source: Accounting provider (Xero/QuickBooks/Sage)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:654:      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage], source: IFOS-internal (per-tenant config)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:655:      invoice_number: {type: string, required: false, source: Accounting provider}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:659:      amount_paid: {type: number, required: true, default: 0, source: Accounting provider + IFOS-derived (Cash Conductor reconciliation updates)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:662:      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor links to Bullhorn placement.client_contact_id)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:664:      last_chase_position: {type: integer, required: true, default: 0, source: IFOS-derived (Cash Conductor escalation ladder), notes: 0-4 per Cash Conductor §3.2}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:665:      last_chase_sent_at: {type: timestamp, required: false, source: IFOS-derived}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:671:      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:680:      W4 polish, production use of cash_conductor_invoices is GATED by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:681:      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:682:      per §3 cash_conductor_transactions.retention). Migration-test tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:694:    cash_conductor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:703:    cash_conductor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:712:    cash_conductor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:715:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:718:    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:723:    cash_conductor: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:726:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:730:    cash_conductor: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:733:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:737:    cash_conductor: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:751:  cash_conductor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:754:    set_by: cash_conductor
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:755:    read_by: [cash_conductor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:757:      Cash Conductor cron sweep updates at session-close. Next run queries
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:758:      transactions/invoices since this timestamp.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:880:    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:889:      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:892:      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:907:      Smoke verification DO block confirms both cash_conductor_*
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:914:    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:970:  Q4_cash_conductor_transactions_retention:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:971:    question: Bank-feed transactions contain PII (payee_name_raw + description).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:977:         rows retained beyond 7 years for cross-period reconciliation).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:985:      cash_conductor_transactions table is GATED by an explicit per-tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1005:  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1027:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1028:    - Cash Conductor agent.md §4 Postgres-tables claim schema-backed
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:9:--   - Drops cash_conductor_transactions + cash_conductor_invoices tables (data lost)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:13:-- IRREVERSIBLE DATA LOSS: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:29:  SELECT count(*) INTO cct_rows FROM cash_conductor_transactions;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:30:  SELECT count(*) INTO cci_rows FROM cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:32:    RAISE NOTICE 'cash_conductor_transactions has % rows; cash_conductor_invoices has %', cct_rows, cci_rows;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:42:DROP TABLE IF EXISTS cash_conductor_transactions CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:43:DROP TABLE IF EXISTS cash_conductor_invoices CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:88:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:94:  RAISE NOTICE 'v0.3 → v0.2 rollback verified: cash_conductor tables dropped';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:9:-- Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:11:--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:27:--     recent_edit tables exist; validate_voice_scores trigger active)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:52:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:53:    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:  RAISE NOTICE 'v0.2 prerequisites verified (4 tables: voice_corpus + voice_corpus_chunks + tone_rule + recent_edit)';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:59:-- §2 — Create cash_conductor_transactions table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:62:CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:65:  transaction_id     TEXT NOT NULL,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:73:  matched_invoice_id TEXT,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:88:  CONSTRAINT cct_tenant_transaction_unique UNIQUE (tenant_slug, bank_provider, transaction_id)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:92:  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:95:  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:99:ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:100:ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:102:CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:106:GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:107:GRANT USAGE ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:110:-- §3 — Create cash_conductor_invoices table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:113:CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:116:  invoice_id               TEXT NOT NULL,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:117:  accounting_provider      TEXT NOT NULL,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:118:  invoice_number           TEXT,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:127:  last_chase_position      INT NOT NULL DEFAULT 0,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:128:  last_chase_sent_at       TIMESTAMPTZ,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:136:    accounting_provider IN ('xero', 'quickbooks', 'sage')
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:139:    last_chase_position >= 0 AND last_chase_position <= 4
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:144:  CONSTRAINT cci_tenant_provider_invoice_unique UNIQUE (tenant_slug, accounting_provider, invoice_id)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:148:  ON cash_conductor_invoices (tenant_slug, due_at);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:151:  ON cash_conductor_invoices (tenant_slug, status, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:155:  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:156:  WHERE last_chase_position BETWEEN 1 AND 3;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:158:ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:159:ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:161:CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:165:GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:166:GRANT USAGE ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:403:    'cash_conductor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:442:  IF c ? 'cash_conductor_last_run' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:443:    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:444:      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:502:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:504:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:508:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:510:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:513:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';

exec
/bin/zsh -lc 'rg -n "cash_conductor_run_complete|xero_reminder_draft_internal|xero_reminder_send_customer|accounting_reconciliation_write" agents/_shared/autosend-policy.yaml docs/decisions/autosend-safety-policy.md agents/_shared/hook-helpers.sh' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "test -f .codex/ratification/review-agent-bundle.md && nl -ba .codex/ratification/review-agent-bundle.md | sed -n '1,40p' || true" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "AgentMail|Composio|packages/harness/cortextos|kb-|brain system|stock KB" agents/recruitment/cash-conductor/agent.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/decisions/autosend-safety-policy.md:95:| Cash Conductor | `xero_reminder_draft_internal` | 1-in-10 | Generates reminder draft visible to consultant; not yet sent; format + tone needs review |
docs/decisions/autosend-safety-policy.md:107:| Cash Conductor | `xero_reminder_send_customer` | Outbound payment reminder to customer; reputation + collection risk |
docs/decisions/autosend-safety-policy.md:448:      "xero_reminder_send_customer": "PT24H"
agents/_shared/autosend-policy.yaml:107:  cash_conductor_run_complete:
agents/_shared/autosend-policy.yaml:188:  xero_reminder_draft_internal:
agents/_shared/autosend-policy.yaml:209:  accounting_reconciliation_write:
agents/_shared/autosend-policy.yaml:263:  xero_reminder_send_customer:

 exited 1 in 0ms:
 succeeded in 0ms:
     1	# Codex ratification skill — review-agent-bundle
     2	
     3	Type-specific checks for: agent.md output contracts at `agents/recruitment/<name>/agent.md` and (when present) the surrounding bundle files at `agents/recruitment/<name>/{tools.yaml,context.sh,validate.sh,cycle.sh,cleanup.sh}` + fixtures at `agents/recruitment/<name>/fixtures/*.yaml`.
     4	
     5	This skill ADDS to the top-level `SKILL.md`. Apply that first; everything below is incremental.
     6	
     7	**Distinction from review-architecture-decision:** agent.md files are NOT architecture-decision documents. They follow the ADR-003 v2 bundle pattern (6 files + 3 fixtures) and have their own structural requirements documented below. Do NOT REJECT an agent.md for missing Context/Decision/Consequences sections — those belong in ADRs (which live at `docs/decisions/ADR-*.md`).
     8	
     9	---
    10	
    11	## §1 — agent.md required-section structure (per ADR-003 + Diagnostic precedent)
    12	
    13	Every `agents/recruitment/<name>/agent.md` MUST have these 10 sections in order. Reject if any are missing OR materially out of order.
    14	
    15	| § | Section title | Purpose | Reject criteria |
    16	|---|---|---|---|
    17	| Header | (file metadata) | Status field; date; author; build wave; tier; build complexity | Missing Status field; status conflicts with content (e.g. "Accepted" but build dependencies still ⏸) |
    18	| §1 | Output contract | One-paragraph screenshot per master brief §1 Rule 1. Names WHAT the agent produces in a single paragraph, readable cold | Missing; >3 paragraphs; doesn't name vault write path; doesn't name Gate A + Gate B thresholds |
    19	| §2 | Invocation surface | CLI / webhook / cron / Brain UI / Telegram triggers; per-trigger auth requirements; v1.1+ deferred surfaces | Missing; lists surfaces not supported by master brief §8.2 (e.g. uses AgentMail before v1.1) |
    20	| §3 | Output shape | Specific to agent. Diagnostic: 12 sections. Janitor: day-30 report + Bullhorn writes. Cash Conductor: reconciliation rows + chase drafts + weekly report | Missing; doesn't name the artefact paths; doesn't name the decision_log audit-row signature for each output |
    21	| §4 | Workflow | n-step process. Each step must reference (a) the tools.yaml capability it depends on OR (b) a `_shared/` helper. Must integrate `hh_decision_*` calls at every step that produces output OR takes action | Missing; steps reference undocumented capabilities; steps that produce output/action don't call `hh_decision_*` |
    22	| §5 | Gates | Gate A: validate.sh hard-fail conditions. Gate B: outcome success threshold + measurement mechanism | Missing; Gate A conditions not testable; Gate B threshold not cited to ULTRAPLAN/master brief; Gate A weaker than §1 output contract |
    23	| §6 | Escalation codes | Subset of `agents/_shared/escalation-codes.md` relevant to this agent. Each cited code must exist in the catalogue OR be flagged for catalogue addition | Missing; cites invented ESC codes not in catalogue + not flagged for addition; ESC code repurposed beyond catalogue definition |
    24	| §7 | Voice + tone constraints | `_shared/voice-loader.sh` integration; per-tenant scope; voice classifier threshold per agent.md §5 | Missing for agents that produce text output; threshold drift from master brief §8.1 Change 1 |
    25	| §8 | Build dependencies | Prerequisites that must clear before W-X build slice can begin. Table with Status (✅ ⏸ ❌) per dep | Missing; doesn't name Bullhorn / accounting / LinkedIn commercial gates where applicable; doesn't cite Trigger 3 (Bullhorn-touching agents) or D1 (Concierge) where applicable |
    26	| §9 | Status + open questions | Numbered list of founder-review questions; each has a resolution path (founder review at next Sunday OR pilot tenant onboarding OR commercial conversation) | Missing; questions are vague (no resolution path); doesn't acknowledge gotchas from corresponding ULTRAPLAN §8.1 A-N spec |
    27	| §10 | When this document ratifies | Codex skill reference + status-flip criteria (Proposed → Accepted → In Force) | Missing; cites wrong Codex skill; doesn't name the W-X build-slice completion criteria for status-flip |
    28	
    29	---
    30	
    31	## §2 — Citation accuracy requirements
    32	
    33	agent.md files cite extensively. Every cited line/section MUST match the source.
    34	
    35	**Required citations:**
    36	
    37	1. **master brief §8.2 line N** for build wave (e.g. "W5 per master brief §8.2 line 596"). Verify the line range actually contains the row claimed.
    38	2. **ULTRAPLAN §8.1 A-N lines X-Y** for spec detail (Diagnostic = A1 lines 487+; Janitor = A2 lines 501+; Scribe = A3 lines 515+; Cash Conductor = A4 lines 529+; Sourcing Scout = A5 lines 543+; Concierge = A6 lines 557+). Verify the cited lines contain the cited content.
    39	3. **agents/_shared/escalation-codes.md** for every cited ESC code. Verify the code exists. Verify the trigger description matches.
    40	4. **autosend-safety-policy.yaml** for tier classifications. Verify the action_type exists in the policy + tier assignment matches.

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '90,120p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    90	    tier: green
    91	    agent: concierge
    92	    reason: "Internal run-complete status marker; the inbound-brief acknowledgement cycle wraps; no external comms"
    93	    irreversible: false
    94	
    95	  concierge_send_complete:
    96	    tier: green
    97	    agent: concierge
    98	    reason: "Status marker recorded AFTER an external send completes (the send itself was a different orange/yellow action_type with its own decision_log row); this row closes the workflow trace"
    99	    irreversible: false
   100	
   101	  concierge_approval_routed:
   102	    tier: green
   103	    agent: concierge
   104	    reason: "Internal audit row recorded by Concierge cycle.sh Step 11 when an approval is routed via the autosend-bridge (per Founder Decision D1 path A/B/C). Payload carries d1_path + bridge_target (approval_id or vault path). Not an external send; the actual send is a downstream orange-tier action_type with its own row."
   105	    irreversible: false
   106	
   107	  cash_conductor_run_complete:
   108	    tier: green
   109	    agent: cash-conductor
   110	    reason: "Internal run-complete status marker; no external comms"
   111	    irreversible: false
   112	
   113	  consultant_feedback:
   114	    tier: green
   115	    agent: all
   116	    reason: "Gate B feedback row written when consultant tags an agent's output (Diagnostic report booked/not-booked; Sourcing Scout candidate useful/not-useful; Scribe call-summary accurate/inaccurate; etc.) via Telegram (/<agent>-feedback <artefact-id> ...) or Brain UI button. agent_name=<firing-agent>; phase='action'; payload includes artefact_id + outcome + feedback_class. Internal-only; no external send."
   117	    irreversible: false
   118	
   119	  validate_gate_a_fail:
   120	    tier: green

codex
REJECTED

1. Autosend line citations are wrong. Lines 18, 119, 121, 249-254, and 260-262 cite `autosend-policy.yaml` lines 182-187 and 257-262 for `xero_reminder_draft_internal` / `xero_reminder_send_customer`, but the actual file has `xero_reminder_draft_internal` at lines 188-193 and `xero_reminder_send_customer` at lines 263-268; line 257 is `email_summary_to_customer`. Fix all cited autosend line anchors to the actual policy lines.

2. The chase-draft workflow omits the canonical vault write required by its own output shape. Lines 115-121 say draft body is written to `/vault/<tenant>/cash-conductor-drafts/<draft_id>.md` first and decision_log payloads carry only metadata, but §4 Step 8 lines 222-230 logs `chase_draft_generated` without writing the vault file, `vault_path`, or `body_sha256`. Add an explicit vault-write step before the `hh_decision_output("chase_draft_generated", ...)` call and make the audit metadata match §3.
tokens used
82,779
REJECTED

1. Autosend line citations are wrong. Lines 18, 119, 121, 249-254, and 260-262 cite `autosend-policy.yaml` lines 182-187 and 257-262 for `xero_reminder_draft_internal` / `xero_reminder_send_customer`, but the actual file has `xero_reminder_draft_internal` at lines 188-193 and `xero_reminder_send_customer` at lines 263-268; line 257 is `email_summary_to_customer`. Fix all cited autosend line anchors to the actual policy lines.

2. The chase-draft workflow omits the canonical vault write required by its own output shape. Lines 115-121 say draft body is written to `/vault/<tenant>/cash-conductor-drafts/<draft_id>.md` first and decision_log payloads carry only metadata, but §4 Step 8 lines 222-230 logs `chase_draft_generated` without writing the vault file, `vault_path`, or `body_sha256`. Add an explicit vault-write step before the `hh_decision_output("chase_draft_generated", ...)` call and make the audit metadata match §3.
