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
session id: 019e881e-5357-7f42-89b4-3b2cc0ead099
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

> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 263; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 188-193 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 263-268; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** if Founder Decision D1 is unresolved OR the Concierge autosend bridge has not shipped (both gated per §8), Cash Conductor v1.0 runs in **drafts-only** mode — it produces the yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT write the orange-tier `xero_reminder_send_customer` rows that open the send pipeline (per §8 fallback row).

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

For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type per autosend-policy.yaml line 263) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.

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
2. `phase='action'`, `action_type='xero_reminder_draft_internal'` (yellow tier per autosend-policy.yaml lines 188-193), payload links to the draft via the vault path — this row records that Cash Conductor classified the draft as yellow-tier internal.

When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml line 263; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).

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
   → write draft body to /vault/<tenant>/cash-conductor-drafts/<draft_id>.md
     (chmod 0600) FIRST — vault path is the authority per §3 Output 2 +
     ADR-002 vault/Postgres split; the body is NOT carried in the payload
   → hh_decision_output("chase_draft_generated", "invoice:<id>",
     "vault_path:<path>; body_sha256:<hash>; escalation_position:<N>; voice_score:<N>; days_overdue:<N>; amount_due:<N>")
     — payload carries METADATA only, matching §3 line 118

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
      autosend-policy.yaml line 188
    → hh_decision_action("xero_reminder_send_customer", "invoice:<id>",
      payload_hash, payload_preview) — tier=orange per autosend-policy.yaml
      line 263; Cash Conductor owns this action_type and OPENS the
      orange-approval-bridge; Concierge handles autosend-bridge call to
      operator (D1 path per Founder Decision)

11. (Operator approves via Concierge's bridge → Concierge transports the
    send → Cash Conductor receives webhook + records state mutation)
    → The orange-tier `xero_reminder_send_customer` action row was
      written by Cash Conductor at Step 10 (Cash Conductor owns this
      action_type per autosend-policy.yaml line 263; agent: cash-conductor).
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
- **NOTE: Cash Conductor does NOT read `recent_edit`.** Per v0.3 supplement §2a access grants (line 729; recent_edit block at lines 721-731), Cash Conductor has W-only access — it WRITES recent_edit rows when consultants edit its chase drafts post-send, but does NOT READ them. Voice continuity for Cash Conductor relies on the tenant voice_corpus + tone_rule reads above. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries (LLM step internal to chase-draft generation; classifier scoring distinct from sample retrieval). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked by the canary (which has R access) for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.

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
I’ll verify the cited source lines and catalogue entries against the repo, then apply the agent-bundle checks directly to `agents/recruitment/cash-conductor/agent.md`.
exec
/bin/zsh -lc "rg --files docs agents packages | rg 'master|ULTRAPLAN|escalation-codes|autosend|voice-loader|vertical-schema|v0.2|ADR-005|codex-round-1-founder-decisions|cash-conductor/agent.md'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/voice-loader.sh
agents/_shared/tests/test-voice-loader.sh
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql
agents/recruitment/cash-conductor/agent.md
packages/utilities/autosend-bridge-telegram/src/index.ts
packages/utilities/autosend-bridge-telegram/src/message-format.ts
packages/utilities/autosend-bridge-telegram/src/bridge.ts
packages/utilities/autosend-bridge-telegram/src/types.ts
packages/utilities/autosend-bridge-telegram/src/errors.ts
packages/utilities/autosend-bridge-telegram/vitest.config.ts
packages/utilities/autosend-bridge-telegram/tsconfig.json
packages/utilities/autosend-bridge-telegram/tsup.config.ts
packages/utilities/autosend-bridge-telegram/package.json
packages/utilities/autosend-bridge-telegram/README.md
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts
packages/utilities/autosend-bridge-telegram/tests/test-helpers.ts
packages/utilities/autosend-bridge-telegram/tests/message-format.test.ts
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md
docs/decisions/autosend-approval-bridge-spec.md
docs/decisions/autosend-safety-policy.md
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/specs/ULTRAPLAN.md

exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
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
    18	> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 263; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 188-193 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 263-268; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** if Founder Decision D1 is unresolved OR the Concierge autosend bridge has not shipped (both gated per §8), Cash Conductor v1.0 runs in **drafts-only** mode — it produces the yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT write the orange-tier `xero_reminder_send_customer` rows that open the send pipeline (per §8 fallback row).
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
    98	For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type per autosend-policy.yaml line 263) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
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
   119	2. `phase='action'`, `action_type='xero_reminder_draft_internal'` (yellow tier per autosend-policy.yaml lines 188-193), payload links to the draft via the vault path — this row records that Cash Conductor classified the draft as yellow-tier internal.
   120	
   121	When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml line 263; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).
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
   229	   → write draft body to /vault/<tenant>/cash-conductor-drafts/<draft_id>.md
   230	     (chmod 0600) FIRST — vault path is the authority per §3 Output 2 +
   231	     ADR-002 vault/Postgres split; the body is NOT carried in the payload
   232	   → hh_decision_output("chase_draft_generated", "invoice:<id>",
   233	     "vault_path:<path>; body_sha256:<hash>; escalation_position:<N>; voice_score:<N>; days_overdue:<N>; amount_due:<N>")
   234	     — payload carries METADATA only, matching §3 line 118
   235	
   236	9. Chase-draft validation (Gate A specifics)
   237	   → verify: invoice_number cited matches invoice_id
   238	   → verify: amount_due cited matches accounting record
   239	   → verify: client_contact_email matches active billing contact
   240	   → verify: NOT paid in last 24h (re-query accounting)
   241	   → ESC code mapping by failure class:
   242	     - invoice_number / amount_due / paid-invoice-precondition mismatch →
   243	       `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint failure)
   244	     - client_contact_email / addressee mismatch (chase routed to wrong
   245	       customer) → `ESC_ADDRESSEE_MISMATCH` (per catalogue §2.10 — explicitly
   246	       blocking for Cash Conductor invoice/chase addressee resolution)
   247	     `ESC_AUTOSEND_BLOCKED` is reserved for red-tier action attempts per
   248	     catalogue line 41; Cash Conductor's chase pipeline is orange-tier.
   249	   → hh_decision_output("chase_draft_validated", invoice_id, "passed")
   250	
   251	10. Chase-draft queue to Concierge (opens orange-tier approval bridge)
   252	    → POST internal API → Concierge agent receives draft
   253	    → hh_decision_action("xero_reminder_draft_internal", "invoice:<id>",
   254	      payload_hash, payload_preview) — tier=yellow internal-draft per
   255	      autosend-policy.yaml line 188
   256	    → hh_decision_action("xero_reminder_send_customer", "invoice:<id>",
   257	      payload_hash, payload_preview) — tier=orange per autosend-policy.yaml
   258	      line 263; Cash Conductor owns this action_type and OPENS the
   259	      orange-approval-bridge; Concierge handles autosend-bridge call to
   260	      operator (D1 path per Founder Decision)

exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/agent.md | sed -n '261,560p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   261	
   262	11. (Operator approves via Concierge's bridge → Concierge transports the
   263	    send → Cash Conductor receives webhook + records state mutation)
   264	    → The orange-tier `xero_reminder_send_customer` action row was
   265	      written by Cash Conductor at Step 10 (Cash Conductor owns this
   266	      action_type per autosend-policy.yaml line 263; agent: cash-conductor).
   267	      Concierge does NOT write its own action row for this — Concierge's
   268	      role is approval-bridge + transport, not action-row authorship.
   269	    → Concierge fires webhook back: chase_sent (transport completed)
   270	    → Cash Conductor updates `cash_conductor_invoices.last_chase_position`
   271	      and `last_chase_sent_at` (v0.3 schema-backed fields per migration §3)
   272	    → hh_decision_output("cash_conductor_chase_sent_recorded",
   273	      "invoice:<id>", "position:<N>; sent_at:<ISO>") — phase=output;
   274	      green-tier internal status marker recording state mutation completion
   275	
   276	12. (Mode=webhook only) Re-trigger eligibility check
   277	    → was this webhook also a "payment received" that just hit?
   278	    → re-run Step 5 to check if any chases-in-flight should be cancelled
   279	      (paid-since-draft-but-before-send race condition)
   280	    → if so: ESC_AUTOSEND_RACE → cancel chase draft (do NOT send)
   281	    → hh_decision_output("chase_cancellation_check", "invoice:<id>",
   282	      "cancelled:<bool>")
   283	
   284	13. Weekly report assembly (mode=weekly-report; runs Monday 06:00 UTC)
   285	    → query decision_log + accounting + bank feed for the 7-day window
   286	    → compute DSO metric (Gate B tracking)
   287	    → 6-section Markdown report per §3 Output 3
   288	    → write to /vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md
   289	    → hh_decision_output("weekly_report", report_path,
   290	      "dso_delta_days:<N>; sections:6")
   291	
   292	14. Session close
   293	    → update tenant_adapters.config.cash_conductor_last_run = now()
   294	    → hh_decision_action("cash_conductor_run_complete", "session:<session_id>",
   295	      payload_hash, "run_mode:<mode>; matches:<N>; chases:<N>; report:<bool>")
   296	      — hh_decision_action signature is (action_type, target, payload_hash,
   297	      payload_preview) per agents/_shared/hook-helpers.sh contract
   298	    → exit code 0
   299	```
   300	
   301	---
   302	
   303	## §5 — Gates
   304	
   305	### Gate A — validate.sh (hard-fail before action)
   306	
   307	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
   308	
   309	- **"chase email references correct invoice number AND correct amount AND correct contact"** (all three; AND not OR)
   310	- **"never proposes chase for an invoice that's been paid in last 24h"** (defence-in-depth re-query at draft time)
   311	- Voice classifier score ≥0.75 for position 1-2 chases; ≥0.80 for position 3
   312	- No PII outside firm boundary in chase body
   313	- Reconciliation match confidence ≥0.85 for auto-write (Stage 1-2 only)
   314	- Open Banking token ≥7 days from expiry (≤7d is blocking per ESC_OPEN_BANKING_TOKEN_AGING staged definition; ≤30d info + ≤14d warn are health-warning states that do NOT block Gate A, only signal upcoming reauth need)
   315	- Accounting auth refresh succeeded in Step 1
   316	
   317	Gate A failures fire either `ESC_AGENT_OUTPUT_SHAPE` (invoice/amount/paid-precondition miss; output-shape constraint) OR `ESC_ADDRESSEE_MISMATCH` (client_contact_email mismatch; blocking per catalogue §2.10 — explicit Cash Conductor invoice/chase addressee case). Draft stays in `/tmp` (auto-purged 24h); operator notified per the specific ESC route.
   318	
   319	**Honesty note (per bilateral-disposition Cat-5):** Cash Conductor `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W7 build slice. The W7 build delivers `agents/recruitment/cash-conductor/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   320	
   321	### Gate B — Outcome threshold (FD-tier closer metric)
   322	
   323	Per ULTRAPLAN A4 line 539 verbatim: **"tenant DSO at month-3 ≥ 12 days lower than month-0 baseline"**.
   324	
   325	DSO = Days Sales Outstanding = (Accounts Receivable / Total Credit Sales) × Number of Days.
   326	
   327	Measured monthly via the weekly report's §2 trend. Month-0 baseline established at first pilot LOI signing (before Cash Conductor active). Month-3 target = month-0 minus 12 days.
   328	
   329	This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
   330	
   331	---
   332	
   333	## §6 — Escalation codes
   334	
   335	Cash Conductor uses these ESC codes from `agents/_shared/escalation-codes.md`:
   336	
   337	| Code | Trigger | Severity | Routing |
   338	|---|---|---|---|
   339	| `ESC_ACCOUNTING_AUTH` | Xero/QuickBooks/Sage OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   340	| `ESC_ACCOUNTING_WRITE_FAIL` | Accounting 4xx/5xx on reconciliation write | warn | operator_chat_id |
   341	| `ESC_OPEN_BANKING_AUTH` | TrueLayer/Plaid UK auth fails after 2 retries | **blocking** | operator + ifos_oncall |
   342	| `ESC_OPEN_BANKING_TOKEN_AGING` | Open Banking PSD2 consent approaching 90-day expiry (staged) | info ≤30d / warn ≤14d / **blocking** ≤7d (per catalogue §2.7) | operator_chat_id (info+warn); + ifos_oncall_chat_id at blocking stage |
   343	| `ESC_RECONCILIATION_AMBIGUOUS` | Stage 4 fuzzy multi-candidate match within tolerance (per catalogue §2.10 — bank-feed payment line cannot match a single Xero invoice; multiple candidates) | warn | operator_chat_id |
   344	| (Stage 3 low-confidence single-match review queue) | Stage 3 single low-confidence exact-amount match queued for consultant review — NOT ESC_RECONCILIATION_AMBIGUOUS (catalogue defines ambiguity as multi-candidate, not low-confidence single). v0.3 W4-polish backlog: add ESC_RECONCILIATION_LOW_CONFIDENCE for single-match-low-confidence case OR widen ESC_RECONCILIATION_AMBIGUOUS catalogue trigger. | flagged in weekly report exception list (no ESC fire at v0.3) | (weekly report aggregation) |
   345	| `ESC_AUTOSEND_RACE` | Payment received between chase-draft and chase-send window | warn | operator_chat_id |
   346	| `ESC_VOICE_DRIFT` | Chase voice classifier below threshold after 3 retries | warn | operator_chat_id |
   347	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in chase body | **blocking** | operator + ifos_oncall |
   348	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A miss on invoice_number / amount_due / paid-invoice-precondition (NOT addressee mismatch — that uses ESC_ADDRESSEE_MISMATCH) | warn | operator_chat_id |
   349	| `ESC_ADDRESSEE_MISMATCH` | Gate A miss on client_contact_email / addressee resolution (per catalogue §2.10 Cash Conductor case) | **blocking** | operator + ifos_oncall |
   350	| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
   351	| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
   352	| `ESC_AUTOSEND_ORANGE_PENDING` | Chase draft awaiting consultant approval — heartbeat at ≥50% of declared timeout (per catalogue §2.9 trigger) | info | operator_chat_id (gentle reminder; no oncall CC) |
   353	
   354	Cash Conductor does NOT use:
   355	
   356	- Bullhorn-specific codes (no Bullhorn dependency)
   357	- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
   358	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Cash Conductor's Gate A misses are output-shape failures, not schema-field violations
   359	- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Cash Conductor fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
   360	
   361	---
   362	
   363	## §7 — Voice + tone constraints
   364	
   365	Step 8 (chase-draft generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   366	
   367	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
   368	  - No "Final demand" or legal-threatening language (escalation ladder caps at position 3; position 4 is operator-handled)
   369	  - No reference to the client's industry / sector pain points (chase is operational, not strategic)
   370	  - No mentions of late-payment fees unless tenant's terms explicitly state them
   371	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
   372	- **NOTE: Cash Conductor does NOT read `recent_edit`.** Per v0.3 supplement §2a access grants (line 729; recent_edit block at lines 721-731), Cash Conductor has W-only access — it WRITES recent_edit rows when consultants edit its chase drafts post-send, but does NOT READ them. Voice continuity for Cash Conductor relies on the tenant voice_corpus + tone_rule reads above. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries (LLM step internal to chase-draft generation; classifier scoring distinct from sample retrieval). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked by the canary (which has R access) for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
   373	
   374	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   375	
   376	---
   377	
   378	## §8 — Build dependencies (W7-8 prerequisites)
   379	
   380	Cash Conductor build cannot start until ALL of the following are confirmed:
   381	
   382	| Dependency | Source | Status |
   383	|---|---|---|
   384	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   385	| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
   386	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   387	| **Tenant's accounting choice confirmed** (Xero / QuickBooks / Sage) | Tenant onboarding | ⏸ |
   388	| **Accounting commercial signup** (developer access + sandbox) | Founder commercial | ⏸ |
   389	| **Open Banking commercial signup** (TrueLayer or Plaid UK) | Founder commercial; ~£100-300/mo | ⏸ |
   390	| Xero MCP connector | W7 build start (~2 days) | ⏸ |
   391	| QuickBooks MCP connector | W7 build start (~2 days) | ⏸ |
   392	| Sage MCP connector | W7 build start (~2 days; may defer if no pilot uses Sage v1.0) | ⏸ |
   393	| Open Banking MCP connector | W7 build start (~3 days; harder due to 90-day token rotation) | ⏸ |
   394	| Per-tenant accounting credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   395	| Per-tenant Open Banking credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   396	| Concierge agent.md ratified Accepted (for chase-send routing contract; full Concierge production-build at W10-13, but Cash Conductor only depends on the Concierge agent.md contract being Accepted, not the full bundle being In Force) | Post-Concierge agent.md re-ratification | ⏸ |
   397	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   398	| `validate.sh` Gate A logic | Build at W7 start (~1 day; complex due to 4 validators) | ⏸ |
   399	| `context.sh` hydration | Build at W7 start (~0.5 day) | ⏸ |
   400	| `cycle.sh` orchestration (14-step) | Build at W7 start (~3 days; most complex of v1.0 agents) | ⏸ |
   401	| `tools.yaml` MCP capability declarations (xero_oauth, quickbooks_oauth, sage_oauth, open_banking_truelayer / plaid, telegram_notify) | Build at W7 start (~1 day) | ⏸ |
   402	| `cleanup.sh` post-run state purge (transient OAuth tokens; provider rate-limit caches) | Build at W7 start (~0.5 day) | ⏸ |
   403	| 3 fixtures with golden outputs | Build at W7 start (~1 day) | ⏸ |
   404	| **Founder Decision D1 (autosend orange-tier path) RESOLVED** — blocking for Cash Conductor's xero_reminder_send_customer action_type | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` D1 (currently Proposed) | ⏸ |
   405	| **Autosend bridge implementation** (per D1 outcome) — Concierge W10 build delivers; blocking for orange-tier send writes | Concierge W10 build slice (~2 days for D1-A; less for D1-B/C) | ⏸ |
   406	| Fallback: if D1 + bridge not ready by W7-8, Cash Conductor v1.0 downgrades to drafts-only (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` writes until D1 resolves + bridge ships) | v1.0 contingency | n/a |
   407	
   408	**ADR-005 framing:** ADR-005 (Week-3 Diagnostic acceleration) notes Cash Conductor is unaffected by Bullhorn slips because it has zero Bullhorn dependency. v0.3 supplement: Cash Conductor pull-forward (from W7-8 to W4-5) is NOT explicitly authorised by ADR-005 §5.1 (that section number doesn't exist; earlier draft mis-cited). Pull-forward would require a separate ADR (e.g. ADR-007 if/when needed); accounting + Open Banking commercial signups remain founder-action gates regardless of timing.
   409	
   410	---
   411	
   412	## §9 — Status + open questions
   413	
   414	**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start.
   415	
   416	### Open questions for founder review
   417	
   418	| # | Question | Resolution path |
   419	|---|---|---|
   420	| Q1 | First-tenant accounting choice — Xero / QuickBooks / Sage? Affects which connector is W7-prio-1. | Tenant onboarding; depends on first pilot tenant's existing stack. |
   421	| Q2 | Open Banking provider — TrueLayer or Plaid UK? Both have UK coverage; TrueLayer slightly cheaper at low volume; Plaid has broader US-EU coverage for v1.1+ expansion. | Founder commercial. Recommend TrueLayer for v1.0 UK-only pilots. |
   422	| Q3 | Open Banking 90-day token rotation UX — when token nears expiry, operator must re-authenticate via tenant's bank login. How is this triggered? Telegram nudge? Brain UI dashboard? | Recommend: ESC_OPEN_BANKING_TOKEN_AGING fires Telegram nudge at 30/14/7 days; tenant-admin handles via Brain UI v1.1. |
   423	| Q4 | Chase escalation ladder — 4 positions proposed in §3.2. Founder confidence each position's timing + tone is right? | Founder review with first pilot tenant; varies by tenant's payment terms (net-30 vs net-14 vs net-60). |
   424	| Q5 | Reconciliation Stage 3-4 (fuzzy / ambiguous matches) — consultant review queue UX. Brain UI workflow? Telegram? | v1.0: weekly report exception list. v1.1: Brain UI per-row review queue. |
   425	| Q6 | DSO baseline establishment — month-0 baseline measured pre-deployment. How do we measure if accounting system data is incomplete or fragmented? | First pilot tenant: 30-day baseline measurement period BEFORE Cash Conductor goes live; documented in pilot LOI. |
   426	| Q7 | Hire #1 anchor — what specific Cash Conductor sub-tasks does Hire #1 take vs Claude Code? | Founder strategic decision; recommend Hire #1 owns Open Banking connector + ESC_OPEN_BANKING_TOKEN_AGING UX. Cash Conductor agent.md + cycle.sh stays with founder + Claude Code for consistency with other agents. |
   427	| Q8 | Sage connector — defer if no v1.0 pilot uses Sage? Saves ~2 days. Risk: blocks future Sage-using pilots. | Recommend defer to v1.1; document in W7 build start review. |
   428	
   429	### Gotchas (carried forward from ULTRAPLAN A4 line 541)
   430	
   431	1. **Open Banking auth is a 90-day token; rotation logic is non-trivial.** Plan for the rotation UX up-front; ESC_OPEN_BANKING_TOKEN_AGING staged at 30/14/7 days from expiry; document tenant-admin re-auth procedure.
   432	2. **Bank feed reconciliation against invoice register is the hard logic.** Start with exact-amount matches (Stage 1-2); expand to fuzzy (Stage 3-4) as confidence builds.
   433	3. **5 stages of match algorithm** is intentionally conservative for v1.0 to avoid false-positive reconciliation writes (which corrupt the tenant's accounting books).
   434	4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
   435	
   436	---
   437	
   438	## §10 — When this document ratifies
   439	
   440	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies when Codex Round 4 Phase 2 (Day 20) returns RATIFIED verdict.
   441	
   442	Status flips Proposed → Accepted when:
   443	- Codex Round 4 Phase 2 ratifies
   444	- Founder approves §9 Q1 + Q2 + Q4 + Q7 + Q8
   445	- Q3 UX flow approved (operator re-auth path)
   446	
   447	Status flips Accepted → In Force when:
   448	- W7-8 build slice produces all 5 sibling bundle files + 3 fixtures
   449	- First production webhook processed end-to-end against migration-test tenant
   450	- 30-day month-0 baseline measured for first pilot
   451	- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
   452	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   453	
   454	Until then: this document is a forward-looking scaffold.
   455	
   456	*End of Cash Conductor agent.md draft.*

exec
/bin/zsh -lc "rg --files docs | rg -i 'master|brief|operational|kill|tenancy|Day-4|ADR-002|ADR-003'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/architecture/tenancy-invariants.md
docs/build-brief/00-MASTER-BRIEF.md
docs/decisions/v1.0-kill-criterion.md
docs/decisions/ADR-003-agent-bundle-renderer.md
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md
docs/_supplementary/planning-phase-brief.md
docs/runbooks/day-4-provisioning.md
docs/runbooks/operational-hygiene-protocol.md
docs/runbooks/pii-purge-operational-pattern.md

codex
The local artefact matches the pasted content, so I’m checking the source anchors now: master brief schedule, ULTRAPLAN A4, autosend tiers, ESC catalogue, schema supplement, and helper functions.
exec
/bin/zsh -lc "nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '580,610p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '180,275p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   180	
   181	  # ───────────────────────────────────────────────────────────
   182	  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
   183	  # ───────────────────────────────────────────────────────────
   184	
   185	  bullhorn_candidate_dedupe:
   186	    tier: yellow
   187	    agent: janitor
   188	    sample_rate: 10
   189	    reason: "Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review"
   190	    irreversible: false
   191	
   192	  bullhorn_field_backfill:
   193	    tier: yellow
   194	    agent: janitor
   195	    sample_rate: 10
   196	    reason: "Fills missing canonical schema fields from Companies House or LinkedIn enrichment; reversible PATCH; high-volume; source provenance logged in payload"
   197	    irreversible: false
   198	
   199	  bullhorn_note_attach:
   200	    tier: yellow
   201	    agent: janitor
   202	    sample_rate: 20
   203	    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
   204	    irreversible: false
   205	
   206	  bullhorn_note_append_summary:
   207	    tier: yellow
   208	    agent: scribe
   209	    sample_rate: 20
   210	    reason: "Appends to candidate record; consultant-only visibility; high-volume; format quality needs review"
   211	    irreversible: false
   212	
   213	  linkedin_connection_request:
   214	    tier: yellow
   215	    agent: sourcing-scout
   216	    sample_rate: 5
   217	    reason: "Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy"
   218	    irreversible: true
   219	
   220	  xero_reminder_draft_internal:
   221	    tier: yellow
   222	    agent: cash-conductor
   223	    sample_rate: 10
   224	    reason: "Generates reminder draft visible to consultant; not yet sent; format + tone needs review"
   225	    irreversible: false
   226	
   227	  bullhorn_note_draft_internal:
   228	    tier: yellow
   229	    agent: concierge
   230	    sample_rate: 10
   231	    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
   232	    irreversible: false
   233	
   234	  bullhorn_scribe_field_write:
   235	    tier: yellow
   236	    agent: scribe
   237	    sample_rate: 10
   238	    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
   239	    irreversible: false
   240	
   241	  accounting_reconciliation_write:
   242	    tier: yellow
   243	    agent: cash-conductor
   244	    sample_rate: 10
   245	    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
   246	    irreversible: false
   247	
   248	  concierge_email_draft:
   249	    tier: yellow
   250	    agent: concierge
   251	    sample_rate: 20
   252	    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
   253	    irreversible: false
   254	
   255	  # ───────────────────────────────────────────────────────────
   256	  # ORANGE — per-action human approval (10 action_types)
   257	  # ───────────────────────────────────────────────────────────
   258	
   259	  bullhorn_note_customer_visible:
   260	    tier: orange
   261	    agent: concierge
   262	    timeout: PT4H
   263	    reason: "CANONICAL ORANGE. Bullhorn Note with isExternal: true — customer-visible in their CRM; single send is irreversible (note in audit trail even if deleted)"
   264	    irreversible: true
   265	    canonical: true
   266	
   267	  gmail_outlook_send_to_candidate:
   268	    tier: orange
   269	    agent: concierge
   270	    timeout: PT4H
   271	    reason: "Outbound email to candidate; customer-facing; reputation effects"
   272	    irreversible: true
   273	
   274	  twilio_sms_send:
   275	    tier: orange

exec
/bin/zsh -lc "nl -ba agents/_shared/voice-loader.sh | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
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
   221	
   222	# ────────────────────────────────────────────────────────────────────────
   223	# hh_load_recent_edits [<lookback_days>] [<agent_name>]
   224	# ────────────────────────────────────────────────────────────────────────
   225	# Returns recent_edit rows from the last <lookback_days> for <agent_name>
   226	# (or all agents if not specified).
   227	#
   228	# Output JSON shape:
   229	#   { "edits": [ { "id": N, "action_type": "...", "edit_distance": N,
   230	#                  "resolution": "...", "tone_rules_triggered": [...],
   231	#                  "resolved_at": "..." }, ... ],
   232	#     "lookback_days": N, "source": "db" | "fallback" }
   233	hh_load_recent_edits() {
   234	  local lookback_days="${1:-30}"
   235	  local agent_name="${2:-${CTX_AGENT_NAME:-}}"
   236	
   237	  # Validate lookback_days
   238	  if ! [[ "${lookback_days}" =~ ^[0-9]+$ ]] || (( lookback_days <= 0 )) || (( lookback_days > 365 )); then
   239	    lookback_days=30
   240	  fi

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '274,340p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   274	  twilio_sms_send:
   275	    tier: orange
   276	    agent: concierge
   277	    timeout: PT30M
   278	    reason: "Outbound SMS; high-trust channel; cost-per-send; irreversible"
   279	    irreversible: true
   280	
   281	  calendar_invite_send:
   282	    tier: orange
   283	    agent: concierge
   284	    timeout: PT4H
   285	    reason: "Creates calendar event with attendee notification; visible to attendee"
   286	    irreversible: true
   287	
   288	  email_summary_to_customer:
   289	    tier: orange
   290	    agent: scribe
   291	    timeout: PT4H
   292	    reason: "Outbound email summarising call to customer; customer-facing; format-sensitive"
   293	    irreversible: true
   294	
   295	  xero_reminder_send_customer:
   296	    tier: orange
   297	    agent: cash-conductor
   298	    timeout: PT24H
   299	    reason: "Outbound payment reminder to customer; reputation + collection risk"
   300	    irreversible: true
   301	
   302	  diagnostic_email_send:
   303	    tier: orange
   304	    agent: diagnostic
   305	    timeout: PT4H
   306	    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
   307	    irreversible: true
   308	
   309	  diagnostic_calendar_invite:
   310	    tier: orange
   311	    agent: diagnostic
   312	    timeout: PT4H
   313	    reason: "Books intro call with prospect; reputation + scheduling friction"
   314	    irreversible: true
   315	
   316	  linkedin_inmail_send:
   317	    tier: orange
   318	    agent: sourcing-scout
   319	    timeout: PT4H
   320	    reason: "Outbound InMail (paid credit); cost-per-send; customer-facing"
   321	    irreversible: true
   322	
   323	  bullhorn_placement_terminate:
   324	    tier: orange
   325	    agent: janitor
   326	    timeout: PT4H
   327	    reason: "Marks placement as terminated; commercial/legal implications; reversible only via support ticket"
   328	    irreversible: false
   329	
   330	  # ───────────────────────────────────────────────────────────
   331	  # RED — blocked entirely; ESC_AUTOSEND_BLOCKED (8 action_types)
   332	  # ───────────────────────────────────────────────────────────
   333	
   334	  xero_payment_initiate:
   335	    tier: red
   336	    agent: all
   337	    block_reason: payment_action
   338	    reason: "Payment transfer; financial-bearing; never auto-send in v1.0"
   339	    irreversible: true
   340	

exec
/bin/zsh -lc 'rg -n "xero_reminder_send_customer|accounting_reconciliation_write|ESC_ACCOUNTING_AUTH|ESC_ACCOUNTING_WRITE_FAIL|ESC_OPEN_BANKING_AUTH|ESC_OPEN_BANKING_TOKEN_AGING|ESC_RECONCILIATION_AMBIGUOUS|ESC_AUTOSEND_RACE|ESC_GATE_B_MISS|ESC_ADDRESSEE_MISMATCH|ESC_AUTOSEND_ORANGE_PENDING" agents/_shared/escalation-codes.md agents/_shared/autosend-policy.yaml docs/verticals/recruitment -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/escalation-codes.md:280:#### `ESC_ACCOUNTING_AUTH`
agents/_shared/escalation-codes.md:288:#### `ESC_OPEN_BANKING_AUTH`
agents/_shared/escalation-codes.md:296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
agents/_shared/escalation-codes.md:317:#### `ESC_ACCOUNTING_WRITE_FAIL`
agents/_shared/escalation-codes.md:319:- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
agents/_shared/escalation-codes.md:341:#### `ESC_AUTOSEND_ORANGE_PENDING`
agents/_shared/escalation-codes.md:356:#### `ESC_AUTOSEND_RACE`
agents/_shared/escalation-codes.md:377:#### `ESC_GATE_B_MISS`
agents/_shared/escalation-codes.md:407:#### `ESC_ADDRESSEE_MISMATCH`
agents/_shared/escalation-codes.md:417:#### `ESC_RECONCILIATION_AMBIGUOUS`
agents/_shared/autosend-policy.yaml:172:    reason: "TrueLayer OAuth 2.0 refresh — idempotent token rotation against auth.truelayer.com; @ifos/open-banking connector handles concurrent-refresh dedup per-connection; PSD2 90-day consent expiry surfaces via ESC_OPEN_BANKING_TOKEN_AGING (separate aging signal, not this action_type)."
agents/_shared/autosend-policy.yaml:241:  accounting_reconciliation_write:
agents/_shared/autosend-policy.yaml:295:  xero_reminder_send_customer:

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '700,745p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc 'rg -n "cash_conductor|cash-conductor|last_chase|recent_edit|cash_conductor_transactions|cash_conductor_invoices|tenant_adapters" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
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
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 6 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:311:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:327:  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:335:  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:409:  cash_conductor:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:597:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:609:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:620:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:638:      matched_invoice_id: {type: string, required: false, source: IFOS-derived, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:658:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:677:      last_chase_position: {type: integer, required: true, default: 0, source: IFOS-derived (Cash Conductor escalation ladder), notes: 0-4 per Cash Conductor §3.2}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:678:      last_chase_sent_at: {type: timestamp, required: false, source: IFOS-derived}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:684:      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:693:      W4 polish, production use of cash_conductor_invoices is GATED by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:694:      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:695:      per §3 cash_conductor_transactions.retention). Migration-test tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:707:    cash_conductor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:716:    cash_conductor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:725:    cash_conductor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:728:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:736:    cash_conductor: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:739:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:743:    cash_conductor: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:746:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:750:    cash_conductor: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:755:# §4 — tenant_adapters.config keys (6 declarations: 5 v0.3-new + 1 pre-v0.3 canonicalised)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:758:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:759:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:762:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:764:  cash_conductor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:767:    set_by: cash_conductor
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:768:    read_by: [cash_conductor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:830:    read_by: [concierge, sourcing-scout, cash-conductor, janitor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:893:    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:902:      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:905:      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:916:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:918:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:920:      Smoke verification DO block confirms both cash_conductor_*
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:956:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:983:  Q4_cash_conductor_transactions_retention:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:991:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:998:      cash_conductor_transactions table is GATED by an explicit per-tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1003:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1040:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1042:    - Concierge tenant_adapters.config field refs valid
docs/verticals/recruitment/vertical-schema.yaml:702:  Cash_Conductor:
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:26:DROP TABLE IF EXISTS recent_edit          CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:6:-- side effects on existing recent_edit data).
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:15:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:18:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:19:  DROP CONSTRAINT IF EXISTS recent_edit_text_purged_consistency;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:21:DROP INDEX IF EXISTS recent_edit_text_purged_idx;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:23:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:11:--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:27:--     recent_edit tables exist; validate_voice_scores trigger active)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:52:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'recent_edit') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:53:    RAISE EXCEPTION 'v0.2 recent_edit table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:55:  RAISE NOTICE 'v0.2 prerequisites verified (4 tables: voice_corpus + voice_corpus_chunks + tone_rule + recent_edit)';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:59:-- §2 — Create cash_conductor_transactions table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:62:CREATE TABLE IF NOT EXISTS cash_conductor_transactions (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:93:  ON cash_conductor_transactions (tenant_slug, posted_at DESC);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:96:  ON cash_conductor_transactions (tenant_slug, match_status, posted_at DESC)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:100:ALTER TABLE cash_conductor_transactions ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:101:ALTER TABLE cash_conductor_transactions FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:105:DROP POLICY IF EXISTS cct_tenant_isolation ON cash_conductor_transactions;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:106:CREATE POLICY cct_tenant_isolation ON cash_conductor_transactions
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:110:GRANT SELECT, INSERT, UPDATE ON cash_conductor_transactions TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:111:GRANT USAGE, SELECT ON SEQUENCE cash_conductor_transactions_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:114:-- §3 — Create cash_conductor_invoices table (RLS-isolated)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:117:CREATE TABLE IF NOT EXISTS cash_conductor_invoices (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:131:  last_chase_position      INT NOT NULL DEFAULT 0,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:132:  last_chase_sent_at       TIMESTAMPTZ,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:144:    last_chase_position >= 0 AND last_chase_position <= 4
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:153:  ON cash_conductor_invoices (tenant_slug, due_at);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:156:  ON cash_conductor_invoices (tenant_slug, status, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:160:  ON cash_conductor_invoices (tenant_slug, last_chase_position, due_at)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:161:  WHERE last_chase_position BETWEEN 1 AND 3;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:163:ALTER TABLE cash_conductor_invoices ENABLE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:164:ALTER TABLE cash_conductor_invoices FORCE ROW LEVEL SECURITY;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:167:DROP POLICY IF EXISTS cci_tenant_isolation ON cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:168:CREATE POLICY cci_tenant_isolation ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:172:GRANT SELECT, INSERT, UPDATE ON cash_conductor_invoices TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:173:GRANT USAGE, SELECT ON SEQUENCE cash_conductor_invoices_id_seq TO ifos_app;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:191:DROP TRIGGER IF EXISTS set_updated_at_cct ON cash_conductor_transactions;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:193:  BEFORE UPDATE ON cash_conductor_transactions
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:197:DROP TRIGGER IF EXISTS set_updated_at_cci ON cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:199:  BEFORE UPDATE ON cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:419:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:426:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:440:    'cash_conductor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:453:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:479:  IF c ? 'cash_conductor_last_run' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:480:    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:481:      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:529:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:531:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:532:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:534:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:546:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:548:    RAISE EXCEPTION 'cash_conductor_transactions table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:552:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:554:    RAISE EXCEPTION 'cash_conductor_invoices table not created';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:557:  RAISE NOTICE 'v0.3 migration smoke passed: cash_conductor_transactions + cash_conductor_invoices present';
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:10:--   - 3 new tables: voice_corpus, tone_rule, recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:16:--     recent_edit_drives_retraining); also JSONB-backed in entity_links.metadata
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
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:180:GRANT SELECT, INSERT                 ON recent_edit         TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:185:GRANT USAGE, SELECT ON SEQUENCE recent_edit_id_seq         TO ifos_app;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:202:--   ALTER TABLE recent_edit OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:206:--   ALTER SEQUENCE recent_edit_id_seq OWNER TO postgres;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:318:-- SELECT relname FROM pg_class WHERE relname IN ('voice_corpus', 'voice_corpus_chunks', 'tone_rule', 'recent_edit');
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
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:9:--   - Drops cash_conductor_transactions + cash_conductor_invoices tables (data lost)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:11:--   - Restores v0.2 tenant_adapters.config validation trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:13:-- IRREVERSIBLE DATA LOSS: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:34:  IF to_regclass('public.cash_conductor_transactions') IS NOT NULL THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:35:    SELECT count(*) INTO cct_rows FROM cash_conductor_transactions;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:37:  IF to_regclass('public.cash_conductor_invoices') IS NOT NULL THEN
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:38:    SELECT count(*) INTO cci_rows FROM cash_conductor_invoices;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:41:    RAISE NOTICE 'cash_conductor_transactions has % rows; cash_conductor_invoices has %', cct_rows, cci_rows;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:51:DROP TABLE IF EXISTS cash_conductor_transactions CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:52:DROP TABLE IF EXISTS cash_conductor_invoices CASCADE;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:87:-- §4 — Restore v0.2 tenant_adapters validation (drop v0.3 trigger)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:91:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:93:-- v0.2 trigger (if it existed) — currently no v0.2 validate_tenant_adapters
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:95:-- tenant_adapters config validation trigger.
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:107:    WHERE table_name = 'cash_conductor_transactions';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:109:    WHERE table_name = 'cash_conductor_invoices';
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:113:  RAISE NOTICE 'v0.3 → v0.2 rollback verified: cash_conductor tables dropped';

 succeeded in 0ms:
   700	  voice_corpus:
   701	    # v0.2 auxiliary table — voice exemplar corpus (per-tenant)
   702	    # Per §2a amendment: v0.3 expands access to all 6 v1.0 agents that
   703	    # produce voice-classified output
   704	    diagnostic: R
   705	    janitor: R
   706	    scribe: R
   707	    cash_conductor: R
   708	    sourcing_scout: R
   709	    concierge: R
   710	  voice_corpus_chunks:
   711	    # v0.2 auxiliary table holding pgvector HNSW index over voice corpus chunks
   712	    # All v1.0 agents producing voice-classified output need R for ANN-match retrieval
   713	    diagnostic: R
   714	    janitor: R
   715	    scribe: R
   716	    cash_conductor: R
   717	    sourcing_scout: R
   718	    concierge: R
   719	  tone_rule:
   720	    # v0.2 auxiliary table — per-tenant tone constraints
   721	    # Per §2a amendment: v0.3 expands access to all 6 v1.0 agents
   722	    diagnostic: R
   723	    janitor: R
   724	    scribe: R
   725	    cash_conductor: R
   726	    sourcing_scout: R
   727	    concierge: R
   728	  recent_edit:
   729	    # v0.2 auxiliary table — consultant edits for retraining/drift detection
   730	    # Per §2a amendment: v0.3 expands access (Concierge R from v0.2;
   731	    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
   732	    # Scout add W to write own retraining edits; Diagnostic remains none)
   733	    diagnostic: none
   734	    janitor: R
   735	    scribe: W
   736	    cash_conductor: W
   737	    sourcing_scout: W
   738	    concierge: R
   739	  cash_conductor_transactions:
   740	    diagnostic: none
   741	    janitor: none
   742	    scribe: none
   743	    cash_conductor: R+W
   744	    sourcing_scout: none
   745	    concierge: none

codex
I’ve already found a hard citation drift in the autosend-policy references: the artefact repeatedly points `xero_reminder_send_customer` to line 263, but that line is a Bullhorn orange-tier reason; the Xero send action is later in the file. I’m checking whether there are additional blocking schema or catalogue issues before returning the verdict.
exec
/bin/zsh -lc 'rg -n "Composio|AgentMail|packages/harness/cortextos|cortextOS|stock KB|kb-" agents/recruitment/cash-conductor/agent.md' in /Users/madsadmin/code/CortexOS
 exited 1 in 0ms:
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '1,80p;150,175p;270,430p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "nl -ba docs/decisions/2026-05-20-codex-round-1-founder-decisions.md | sed -n '1,140p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Codex Round 1 — 5 founder decisions surfaced
     2	
     3	**Date:** 2026-05-20 (Day 8 evening)
     4	**Status:** Proposed
     5	**Context:** Codex ratification first run rejected 14 of 16 artefacts. 13 of 14 rejections were incorporated (Bucket 1 cosmetic + Bucket 2 drift + Bucket 3 structural fixes — same commit as this briefing). The remaining 5 items surfaced by Codex are genuine founder-domain product judgments, not Claude's call. This briefing surfaces them in one place for resolution.
     6	
     7	Each decision: source + Codex's framing + named options + Claude's recommendation + cost-of-delay.
     8	
     9	---
    10	
    11	## D1 — Auto-send v1.0 tier enforcement (orange-tier behavior)
    12	
    13	**Source artefacts:**
    14	- `docs/decisions/autosend-safety-policy.md` §3 (defines 4 tiers + classifies 10 action_types as orange)
    15	- `docs/decisions/autosend-safety-policy.md` §9 (says "v1.0 ships green + red only")
    16	- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issues 1+2
    17	
    18	**Codex's framing:** "v1.0 tier semantics are internally contradictory. Lines 41-68 define four tiers and line 43 says every governed action falls into exactly one tier at execution, but lines 474-481 say v1.0 ships green + red only while orange approval is handled outside the policy pipeline. ... Canonical orange actions are described as v1.0-mitigated, but orange is not implemented in v1.0."
    19	
    20	**Real issue:** 10 action_types (including the canonical orange `bullhorn_note_customer_visible` — Concierge's primary outbound action) are classified as orange. v1.0 ships green+red only. In v1.0, those orange action_types must either:
    21	
    22	- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
    23	- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
    24	- **D1-C: Ship orange-as-red default + manual override** — orange action_types refused by default in v1.0, but per-action manual approval via founder's Telegram bot allowed as escape hatch. Pragmatic; aligns with autosend §9 "orange handled outside the policy pipeline" wording. **Closest to current artefact wording but explicit about the manual surface.**
    25	
    26	**Claude's recommendation (initial briefing, Day 8):** D1-C. v1.0 ships with orange-as-red default + documented manual approval path. Concierge demo pitch becomes "voice-classified drafts that the operator can approve in Telegram"; doesn't promise full auto-send-with-policy in v1.0. v1.1 implements full orange approval gate.
    27	
    28	**Claude's recommendation (Day-11 update, post implementation-spec investigation):** **D1-B.** Investigation surfaced that the "~1 week extra" cost was overestimated — cortextOS Primitive 4 (`createApproval` + `updateApproval` in `packages/harness/cortextos/src/bus/approval.ts`) already implements the Telegram fan-out + button-press routing. IFOS-side work is a thin bridge: 2 file watchers + a small Postgres state table. Realistic effort: 2-3 days. See `docs/decisions/autosend-approval-bridge-spec.md` for the full implementation surface (10 acceptance criteria, 6 risks, 600 lines TypeScript scaffold + tests).
    29	
    30	**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
    31	
    32	**Alternative timing:** Insert as next IFOS Claude slice now (post-Diagnostic-build, ~Week 8). Marginal benefit: D1 becomes a closed item earlier; bridge gets stress-tested before Concierge needs it. Cost: 2-3 days inserted before Concierge.
    33	
    34	**Cost of deferral:** Concierge W10 build risks slipping if bridge isn't ready. Concrete delay: ~3 days. Risk #2 (Bullhorn) is the bigger blocker for Concierge (auth path); D1 is downstream of that.
    35	
    36	**D1 Concrete recommendation:** Schedule for Week 9 (default). Founder explicitly approves D1-B; bridge spec ratifies through Codex Round 2; bridge implementation slice authored Week 9.
    37	
    38	---
    39	
    40	## D2 — External advisor identification
    41	
    42	**Source artefacts:**
    43	- `docs/decisions/v1.0-kill-criterion.md` §3.4 ("Week 1-2 must-fill")
    44	- `docs/decisions/autosend-safety-policy.md` §10 ("Pilot-agreement liability language placeholder — counsel-reviewed")
    45	- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issue 3
    46	
    47	**Codex's framing:** "The legal placeholder is load-bearing for pilot readiness but unresolved. Lines 498-500 warn not to use the liability language as-is, and lines 578-584 leave jurisdiction, liability cap, dispute forum, insurance, and PII liability open. Fix by marking pilot LOI signing blocked until counsel-reviewed language replaces §10."
    48	
    49	**Real issue:** v1.0 kill-criterion §3.4 names "external advisor" as a Week 1-2 must-fill. This is also the resolution path for autosend §10 pilot-agreement liability. Today = 2026-05-20 (Day 8 = Week 1 underway). No advisor identified.
    50	
    51	**Options:**
    52	- **D2-A: Engage UK SaaS lawyer this week** (recommended advisors: a) Bowers Anderson, b) recommended-by-Jack contact, c) any-firm-that-handles-recruiter-SaaS). Expected cost: £500-2000 for LOI template + jurisdiction clauses + PII liability clauses. **Recommended.**
    53	- **D2-B: Defer to first pilot LOI signing window** — risky; if Q1 LOI lands before D2-A advisor is engaged, founder is choosing between (a) signing without legal cover, or (b) delaying LOI signing.
    54	- **D2-C: Use boilerplate UK SaaS LOI template** (off-the-shelf) without lawyer engagement. Cheap but high risk for kill-criterion §3.4 explicit external-advisor requirement.
    55	
    56	**Claude's recommendation:** D2-A. Engage this week. Cost is minor relative to pilot LOI risk; advisor naming is also a Risk #3 mitigation. Block any LOI signing until D2-A completes.
    57	
    58	**Cost of delay:** Trigger 1 fires 2026-06-03 if no LOI. If LOI lands but advisor isn't engaged, founder has to choose between violating kill-criterion §3.4 or delaying LOI past Trigger 1. Engage now to avoid the forced choice.
    59	
    60	---
    61	
    62	## D3 — v0.2 recent_edit PII retention
    63	
    64	**Source artefacts:**
    65	- `docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml` §6 Q13 (UK GDPR retention question)
    66	- Codex output `logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4
    67	
    68	**Codex's framing:** "`recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker."
    69	
    70	**Real issue:** `recent_edit.original_text` + `edited_text` are CAPPED at 8192 chars but otherwise stored verbatim. The agent's draft AND the consultant's edited version. Both can contain PII (candidate names, salaries, contact info). Indefinite retention for LoRA SFT training. UK GDPR Art. 5(1)(e) "data minimisation" arguably requires bounded retention.
    71	
    72	**Options:**
    73	- **D3-A: Indefinite retention (v0.2 current default)** — maximises LoRA SFT corpus. Highest GDPR risk.
    74	- **D3-B: 90-day text purge + indefinite metadata** — purge `original_text` + `edited_text` after 90 days; keep `edit_distance` + `resolution` + `tone_rules_triggered` (already aggregates) forever. **Loses some SFT corpus signal** but retains the "what rules fired" signal indefinitely.
    75	- **D3-C: Pilot-controlled retention** — each tenant's TOS specifies retention (default 90d, optional indefinite). Operationally complex but GDPR-compliant per-tenant.
    76	- **D3-D: Tied to D2** — defer until external advisor (D2-A) weighs in. Advisor likely recommends D3-B with redaction rules.
    77	
    78	**Claude's recommendation:** D3-D first (defer until D2 advisor engaged), then likely D3-B. Block first pilot LOI until D3 resolves (paired with D2).
    79	
    80	**Cost of delay:** Same as D2 — Trigger 1 fires 2026-06-03. If LOI lands before D3 resolves, founder ships v1.0 with D3-A indefinite retention, which is the worst legal posture. Bundle D2 + D3 resolution.
    81	
    82	---
    83	
    84	## D4 — Path B emergency credential policy
    85	
    86	**Source artefacts:**
    87	- `docs/runbooks/operational-hygiene-protocol.md` §2.2 (Path B — FORBIDDEN absent explicit waiver)
    88	- Codex output `logs/codex-ratification/manual-run/docs_runbooks_operational_hygiene_protocol_md.output.md` issue 2
    89	
    90	**Codex's framing:** "The document says Path B is forbidden but preserves a waiver that can still put credentials in chat. Fix by replacing Path B with a non-chat emergency alternative, or mark the waiver as no longer available."
    91	
    92	**Bucket 3 already tightened Path B language** (`fix(codex-round-1)` commit). Current state: Path B remains available as emergency escape hatch, with rotation-in-same-session-MANDATORY discipline + verification protocol. Future use counts as Risk #1 strike.
    93	
    94	This decision is whether to go further:
    95	
    96	- **D4-A: Keep current Path B with the Bucket 3 tightening** — emergency escape hatch with hard rotation discipline. **Recommended.** Day-4 LUKS-passphrase incident shows this can be done safely.
    97	- **D4-B: Remove Path B entirely** — replace with non-chat alternatives only (1Password CLI auto-fetch; SSH agent forwarding; manual founder execution outside chat). More disciplined but harder for genuine emergencies (e.g., LUKS unlock at boot when there's no other terminal).
    98	- **D4-C: Hybrid — Path B remains for LUKS-only emergencies** — narrow allowed scope to a specific named emergency type (LUKS unlock when no interactive shell). All other credential paths use Path A or Path D.
    99	
   100	**Claude's recommendation:** D4-A (current state after Bucket 3 tightening). Day-4 evidence: Path B used once, rotated correctly, no real damage. D4-B is principle-pure but operationally costly. Re-evaluate at pilot-scale.
   101	
   102	**Cost of delay:** Low; current Bucket 3 tightening is already in place. Decision can wait for next Path B incident.
   103	
   104	---
   105	
   106	## D5 — Decision-doc shape skill softening for Reference + In Force artefacts
   107	
   108	**Source artefact:** `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` §4
   109	
   110	**Real issue:** Codex Round 1 REJECTED `cortexos-primitive-status.md` (audit) and `operational-hygiene-protocol.md` (runbook) for lacking Decision + Consequences sections. The skill `.codex/ratification/review-architecture-decision.md` §1 requires these sections for all artefacts under this skill. But the skill ALSO allows Status=Reference and Status=In Force, which are legitimately non-decision artefacts. Contradiction in the skill itself.
   111	
   112	**Options:**
   113	- **D5-A: Soften the skill** — exempt Status=Reference + Status=In Force from the Decision/Consequences requirement. Re-run Round 2; both artefacts expected to RATIFY without further changes. **Recommended.**
   114	- **D5-B: Don't soften** — add Decision/Consequences sections to both artefacts (retrofitted ceremony). ~50 lines per artefact.
   115	- **D5-C: Hybrid** — soften for Reference only; keep enforcement for In Force (argue runbooks DO encode binding policy).
   116	
   117	**Claude's recommendation:** D5-A. The skill should reflect what the artefact types actually are; audits + runbooks legitimately don't have decisions.
   118	
   119	**Cost of delay:** Both artefacts remain marked REJECTED in manifest queue until D5 resolves. Neither blocks any current work (audit findings + runbook procedures are still binding regardless of Codex verdict).
   120	
   121	If D5-A or D5-C: skill update is a separate small commit. Re-ratification runs from same `bash scripts/run-codex-ratification.sh --cluster B` command.
   122	
   123	### ✅ D5 — RESOLVED 2026-05-22
   124	
   125	Founder accepted **D5-A**. Skill softening landed in `.codex/ratification/review-architecture-decision.md §1` plus new §1-Exemption clause. Reference + In Force status artefacts now exempt from Decision + Alternatives + Consequences requirements (Context + Status line still required for ALL).
   126	
   127	Round 2 expectations after this resolution:
   128	- `cortexos-primitive-status.md` (was REJECTED §1 issue 2) → expected RATIFY
   129	- `operational-hygiene-protocol.md` (was REJECTED §1 issue 1) → expected RATIFY
   130	- `architecture-cohesion-review.md` (Day-9; not yet ratified) → ratifiable under softened skill
   131	- `tenant-lifecycle.md` (Day-9; not yet ratified) → ratifiable under softened skill
   132	
   133	D5 unblocks Round 2 closure for 4 artefacts.
   134	
   135	---
   136	
   137	## §10 — Resolution timeline recommendation
   138	
   139	| Decision | Timing | Blocks what |
   140	|---|---|---|

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '400,430p;590,690p;746,772p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   400	    candidate: R+W         # call-summary field extraction (Bullhorn endpoint A3)
   401	    contractor: R+W        # call-summary field extraction (Bullhorn endpoint A3 — candidate entity)
   402	    client: R              # IFOS-cached read (Bullhorn endpoint A3 — ClientCorporation)
   403	    contact: R+W           # v0.3 CHANGED (was none); preferred_channel + next_action_target_date writes only (NOT decision_authority); via Bullhorn Note endpoint A3
   404	    brief: R+W             # v0.3 CHANGED (was R); must_haves + nice_to_haves + deal_breakers writes only; via Bullhorn JobOrder endpoint A3
   405	    opportunity: R+W       # v0.3 CHANGED (was none); 3 new prospecting-call fields written to IFOS-cached Postgres rows only (Bullhorn Opportunity endpoint NOT used at v1.0 per integration-path §4.1)
   406	    placement: R+W         # check-in field extraction (Bullhorn Placement endpoint A3)
   407	    timesheet: R           # IFOS-cached read; placement-context resolution (Bullhorn Timesheet endpoint NOT used at v1.0)
   408	
   409	  cash_conductor:
   410	    # NOTE: Cash Conductor has NO direct Bullhorn endpoint access per
   411	    # bullhorn-integration-path.md §1.2 A4 ("No direct Bullhorn"). All
   412	    # entity reads below are against IFOS-cached Postgres rows
   413	    # (populated by Janitor + Scribe + Concierge from their Bullhorn
   414	    # sync paths). Cash Conductor never calls Bullhorn endpoints directly.
   415	    candidate: none        # no Bullhorn dependency
   416	    contractor: none
   417	    client: R              # IFOS-cached read; client billing details
   418	    contact: R             # IFOS-cached read; invoice addressee resolution
   419	    brief: none
   420	    opportunity: R         # v0.3 NEW — IFOS-cached read; invoice-context (NOT a direct Bullhorn call; only cached rows)
   421	    placement: R           # IFOS-cached read; client linkage on invoice
   422	    timesheet: R           # IFOS-cached read; verify billable hours match invoice (NOT a direct Bullhorn call)
   423	    # (auxiliary-table access is documented in auxiliary_table_access_matrix below)
   424	
   425	  sourcing_scout:
   426	    # v0.3 EXPLICIT OVERRIDES — R20 reconciliation (2026-05-27): the original
   427	    # v0.3 draft upgraded candidate/contractor to R+W to allow writing
   428	    # proposed-candidate rows. That was REVERTED — Sourcing Scout stays R-only
   429	    # on Bullhorn-backed entities per bullhorn-integration-path §4.1 A5 +
   430	    # sourcing-scout/agent.md §6 ("Bullhorn read-only"). Proposed matches live
   590	    rationale: |
   591	      Janitor agent.md §7 calls hh_load_tone_rules filtered by
   592	      applies_to_agents containing 'janitor' for tacit-note narrative
   593	      voice-classification. Per Round-8 Cat-β finding for Janitor.
   594	      Diagnostic + Sourcing Scout also read tone_rules for their
   595	      voice-classified outputs (§12 opener, per-candidate rationale).
   596	
   597	  recent_edit:
   598	    v0_2_v1_0_agent_access: [voice-drift-canary (W), Concierge (R), LoRA (R)]
   599	    v0_3_v1_0_agent_access:
   600	      - voice-drift-canary (W)  # v0.2 unchanged
   601	      - Concierge (R)            # v0.2 unchanged
   602	      - LoRA (R)                 # v0.2 unchanged
   603	      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
   604	      - Scribe (W)               # v0.3 NEW — writes own edits for retraining
   605	      - Cash Conductor (W)       # v0.3 NEW — writes own chase-draft edits
   606	      - Sourcing Scout (W)       # v0.3 NEW — writes own rationale edits
   607	    rationale: |
   608	      v0.2 only granted W to voice-drift-canary. v0.3 expands W to Scribe,
   609	      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
   610	      for retraining queue). Janitor adds R for tacit-note harvest per
   611	      §4 Step 8. The v0.2 supplement file remains unchanged; this v0.3
   612	      supplement is the authoritative source for the expanded access list.
   613	
   614	# ============================================================================
   615	# §3 — Auxiliary Postgres tables (NOT entities) for Cash Conductor
   616	# ============================================================================
   617	
   618	auxiliary_tables:
   619	
   620	  cash_conductor_transactions:
   621	    rationale: |
   622	      Open Banking transactions are high-volume + time-series + don't model
   623	      as entity.data JSONB. v0.3 introduces a first-class table with
   624	      RLS isolation and indexes for date + match-status. Per Cash Conductor
   625	      §4 Step 3 + ADR-002 vault/Postgres split.
   626	    sql_definition_in: migrations/v0.2-to-v0.3.sql §2 (migration is authoritative; this section mirrors the SQL columns)
   627	    columns:
   628	      id: {type: integer, required: true, source: IFOS-internal, notes: BIGSERIAL primary key in SQL}
   629	      tenant_slug: {type: string, required: true, source: IFOS-internal, notes: RLS isolation key per Day-4 §6.3}
   630	      transaction_id: {type: string, required: true, source: Open Banking provider (TrueLayer / Plaid)}
   631	      posted_at: {type: timestamp, required: true, source: Open Banking provider}
   632	      amount: {type: number, required: true, source: Open Banking provider, notes: NUMERIC(15,2) GBP; negative for outgoing}
   633	      currency: {type: string, required: true, default: GBP, source: Open Banking provider}
   634	      payee_name_raw: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   635	      description: {type: string, required: false, source: Open Banking provider, pii: true, retention: Pseudonymized at year 7 per Q4 v0_3_default}
   636	      bank_provider: {type: string, required: true, enum: [truelayer, plaid_uk, open_banking_direct], source: IFOS-internal (per-tenant config)}
   637	      match_status: {type: string, required: true, enum: [unmatched, matched, ambiguous], default: unmatched, source: IFOS-derived (Cash Conductor reconciliation algorithm)}
   638	      matched_invoice_id: {type: string, required: false, source: IFOS-derived, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
   639	      match_confidence: {type: number, required: false, source: IFOS-derived (Cash Conductor algorithm), notes: "range [0.00, 1.00]"}
   640	      match_dimensions: {type: array, items: {type: string}, required: false, source: IFOS-derived}
   641	      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
   642	      raw_payload: {type: object, required: false, source: Open Banking provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific. Full Open Banking response cached for audit; pseudonymized at year 7"}
   643	    indexes:
   644	      - "(tenant_slug, posted_at DESC)"
   645	      - "(tenant_slug, match_status, posted_at DESC) WHERE match_status IN ('unmatched','ambiguous')"
   646	    retention: |
   647	      INTENT (W4-polish enforcement required): 7-year retention with
   648	      pseudonymization at year 7 for PII-bearing fields (payee_name_raw,
   649	      description, raw_payload). Aligned with Q4 v0_3_default. The
   650	      v0.2-to-v0.3 migration creates the table + indexes only; the
   651	      pseudonymization + purge implementation is a W4-polish slice (pg_cron
   652	      job or external scheduled job; not yet authored).
   653	    enforcement_gate: |
   654	      Production use of this table GATED until pseudonymization + purge
   655	      implementation lands as W4 polish. Per-tenant DPA addendum signed
   656	      by founder + tenant before go-live; migration-test tenant exempt.
   657	
   658	  cash_conductor_invoices:
   659	    rationale: |
   660	      Open invoice register cached from accounting provider. Same auxiliary-
   661	      table pattern as transactions. Per Cash Conductor §4 Step 4.
   662	    sql_definition_in: migrations/v0.2-to-v0.3.sql §3 (migration is authoritative)
   663	    columns:
   664	      id: {type: integer, required: true, source: IFOS-internal}
   665	      tenant_slug: {type: string, required: true, source: IFOS-internal}
   666	      invoice_id: {type: string, required: true, source: Accounting provider (Xero/QuickBooks/Sage)}
   667	      accounting_provider: {type: string, required: true, enum: [xero, quickbooks, sage], source: IFOS-internal (per-tenant config)}
   668	      invoice_number: {type: string, required: false, source: Accounting provider}
   669	      issued_at: {type: timestamp, required: true, source: Accounting provider}
   670	      due_at: {type: timestamp, required: true, source: Accounting provider}
   671	      amount_total: {type: number, required: true, source: Accounting provider, notes: NUMERIC(15,2) GBP}
   672	      amount_paid: {type: number, required: true, default: 0, source: Accounting provider + IFOS-derived (Cash Conductor reconciliation updates)}
   673	      currency: {type: string, required: true, default: GBP, source: Accounting provider}
   674	      status: {type: string, required: true, enum: [open, partial, paid, overdue, cancelled, voided], default: open, source: Accounting provider}
   675	      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor resolves the billing contact from cached Bullhorn client_contact rows via the placement→client→contact entity_links relationship; NOT from a denormalized placement.client_contact_id field, which the base schema does not declare)}
   676	      client_billing_email: {type: string, required: false, source: Accounting provider, pii: true}
   677	      last_chase_position: {type: integer, required: true, default: 0, source: IFOS-derived (Cash Conductor escalation ladder), notes: 0-4 per Cash Conductor §3.2}
   678	      last_chase_sent_at: {type: timestamp, required: false, source: IFOS-derived}
   679	      ingested_at: {type: timestamp, required: true, default: now(), source: IFOS-internal}
   680	      raw_payload: {type: object, required: false, source: Accounting provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific (Xero / QuickBooks / Sage). Full provider response cached for audit"}
   681	    indexes:
   682	      - "(tenant_slug, due_at)"
   683	      - "(tenant_slug, status, due_at) WHERE status IN ('open','partial','overdue')"
   684	      - "(tenant_slug, last_chase_position, due_at) WHERE last_chase_position BETWEEN 1 AND 3"
   685	    retention: |
   686	      INTENT (W4-polish enforcement required): 7-year retention with
   687	      pseudonymization at year 7 per Q4 v0_3_default. Cancelled/voided rows
   688	      90d. The v0.2-to-v0.3 migration creates the table + indexes only; the
   689	      pseudonymization + purge implementation is a W4-polish slice
   690	      (pg_cron job or external scheduled job; not yet authored).
   746	  cash_conductor_invoices:
   747	    diagnostic: none
   748	    janitor: none
   749	    scribe: none
   750	    cash_conductor: R+W
   751	    sourcing_scout: none
   752	    concierge: none
   753	
   754	# ============================================================================
   755	# §4 — tenant_adapters.config keys (6 declarations: 5 v0.3-new + 1 pre-v0.3 canonicalised)
   756	# ============================================================================
   757	#
   758	# tenant_adapters.config is JSONB; validation via
   759	# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
   760	# on unknown keys per Rule 2.
   761	
   762	tenant_adapters_config_additions:
   763	
   764	  cash_conductor_last_run:
   765	    type: timestamp
   766	    required: false
   767	    set_by: cash_conductor
   768	    read_by: [cash_conductor]
   769	    notes: |
   770	      Cash Conductor cron sweep updates at session-close. Next run queries
   771	      transactions/invoices since this timestamp.
   772	

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
    31	
    32	# Resolve the autosend-policy + escalation-codes paths through a fallback
    33	# chain (rendered → repo source-tree → computed relatives). Mirrors the
    34	# pattern used in agents/*/context.sh + validate.sh. Without this, direct
    35	# source-tree execution (Day-13 + Day-25 Hays smoke) prints "policy file
    36	# not found" warnings even though Gate A passes via deterministic fallback.
    37	_hh_resolve_shared_path() {
    38	  local filename="$1" override_val="$2" candidate
    39	  if [[ -n "${override_val}" ]]; then
    40	    printf '%s' "${override_val}"
    41	    return 0
    42	  fi
    43	  for candidate in \
    44	    "${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/${filename}" \
    45	    "${IFOS_REPO_ROOT:-}/agents/_shared/${filename}" \
    46	    "${CTX_AGENT_DIR:-.}/../../_shared/${filename}" \
    47	    "${CTX_AGENT_DIR:-.}/../_shared/${filename}" ; do
    48	    if [[ -n "${candidate}" && -f "${candidate}" ]]; then
    49	      printf '%s' "${candidate}"
    50	      return 0
    51	    fi
    52	  done
    53	  # Nothing resolved — fall back to legacy default so downstream consumers
    54	  # fail loudly at use-time with a clear path in the error message.
    55	  printf '%s' "${CTX_AGENT_DIR:-.}/.claude/hooks/_shared/${filename}"
    56	}
    57	
    58	_HH_POLICY_FILE="$(_hh_resolve_shared_path "autosend-policy.yaml" "${HH_POLICY_FILE:-}")"
    59	_HH_ESC_CATALOGUE="$(_hh_resolve_shared_path "escalation-codes.md" "${HH_ESC_CATALOGUE:-}")"
    60	
    61	# Fallback file used when IFOS_DB_URL is unset OR psql is unavailable.
    62	# Resolved at first call to _hh_emit_row().
    63	_hh_resolve_fallback_path() {
    64	  if [[ -n "${IFOS_DECISION_LOG_FALLBACK:-}" ]]; then
    65	    printf '%s' "${IFOS_DECISION_LOG_FALLBACK}"
    66	    return 0
    67	  fi
    68	  local tenant="${CTX_TENANT_SLUG:-unknown}"
    69	  local vault_root="${IFOS_VAULT_ROOT:-/vault}"
    70	  printf '%s/%s/decision-log.jsonl' "${vault_root}" "${tenant}"
    71	}
    72	
    73	# JSON escape a single string for inclusion in a JSON value.
    74	# Use this when BUILDING a JSON document from plain text.
    75	_hh_json_escape() {
    76	  local input="$1"
    77	  input="${input//\\/\\\\}"
    78	  input="${input//\"/\\\"}"
    79	  input="${input//$'\n'/\\n}"
    80	  input="${input//$'\r'/\\r}"
    81	  input="${input//$'\t'/\\t}"
    82	  printf '%s' "${input}"
    83	}
    84	
    85	# SQL escape a string for inclusion in a single-quoted SQL string literal.
    86	# Use this when EMBEDDING values in psql SQL. Doubles single quotes;
    87	# leaves everything else (incl. backslashes, JSON internal " characters)
    88	# alone — Postgres standard_conforming_strings=on (default since 9.1)
    89	# treats backslash as literal.
    90	_hh_sql_escape() {
    91	  local input="$1"
    92	  printf '%s' "${input//\'/\'\'}"
    93	}
    94	
    95	# Current ISO-8601 UTC timestamp with millisecond precision where available.
    96	# GNU date supports %3N (3-digit nanoseconds → milliseconds). BSD date
    97	# (macOS default) does NOT error on the spec but outputs the literal
    98	# string "3N" instead, which Postgres rejects as invalid timestamptz.
    99	# Detect by checking that %3N produced exactly 3 digits.
   100	_hh_now_iso() {
   101	  local ms
   102	  ms=$(date -u +"%3N" 2>/dev/null)
   103	  if [[ "${ms}" =~ ^[0-9]{3}$ ]]; then
   104	    date -u +"%Y-%m-%dT%H:%M:%S.%3NZ"
   105	  else
   106	    date -u +"%Y-%m-%dT%H:%M:%SZ"
   107	  fi
   108	}
   109	
   110	# Validate that ESC code exists in the catalogue.
   111	# Returns 0 if known, 1 otherwise. Catalogue absent → permissive (return 0).
   112	_hh_validate_esc_code() {
   113	  local code="$1"
   114	  if [[ ! -f "${_HH_ESC_CATALOGUE}" ]]; then
   115	    return 0
   116	  fi
   117	  if grep -Fq "\`${code}\`" "${_HH_ESC_CATALOGUE}"; then
   118	    return 0
   119	  fi
   120	  return 1
   121	}
   122	
   123	# ────────────────────────────────────────────────────────────────────────
   124	# Core decision-log writer
   125	# ────────────────────────────────────────────────────────────────────────
   126	
   127	# _hh_emit_row <phase> <outcome> <reason> <payload_json>
   128	#
   129	# Writes one row to decision_log. Live mode (IFOS_DB_URL set + psql available):
   130	# INSERT via psql -v ON_ERROR_STOP=1. Offline mode: append JSON line to
   131	# fallback file. The two formats are reconcilable by the sync worker.
   132	_hh_emit_row() {
   133	  local phase="$1"
   134	  local outcome="${2:-}"
   135	  local reason="${3:-}"
   136	  local payload_json="${4:-{\}}"
   137	
   138	  local tenant agent created_at
   139	  tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   140	  agent="${CTX_AGENT_NAME:?CTX_AGENT_NAME unset}"
   141	  created_at="$(_hh_now_iso)"
   142	
   143	  if [[ -n "${IFOS_DB_URL:-}" ]] && command -v psql >/dev/null 2>&1; then
   144	    local sql
   145	    sql=$(cat <<EOF
   146	BEGIN;
   147	SET LOCAL app.current_tenant = '$(_hh_sql_escape "${tenant}")';
   148	INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload, created_at)
   149	VALUES (
   150	  '$(_hh_sql_escape "${tenant}")',
   151	  '$(_hh_sql_escape "${agent}")',
   152	  '$(_hh_sql_escape "${phase}")',
   153	  $([ -z "${outcome}" ] && echo "NULL" || printf "'%s'" "$(_hh_sql_escape "${outcome}")"),
   154	  $([ -z "${reason}" ] && echo "NULL" || printf "'%s'" "$(_hh_sql_escape "${reason}")"),
   155	  '$(_hh_sql_escape "${payload_json}")'::jsonb,
   156	  '${created_at}'::timestamptz
   157	);
   158	COMMIT;
   159	EOF
   160	)
   161	    local psql_err
   162	    if psql_err=$(printf '%s\n' "${sql}" | psql -v ON_ERROR_STOP=1 -q "${IFOS_DB_URL}" 2>&1); then
   163	      return 0
   164	    fi
   165	    # psql failed — fall through to fallback append + emit warning to stderr
   166	    printf 'hh_emit_row: psql write failed; appending to fallback\n' >&2
   167	    printf 'hh_emit_row: psql error: %s\n' "${psql_err}" >&2
   168	  fi
   169	
   170	  local fallback
   171	  fallback="$(_hh_resolve_fallback_path)"
   172	  mkdir -p "$(dirname "${fallback}")" 2>/dev/null || true
   173	
   174	  local row
   175	  row=$(printf '{"tenant_slug":"%s","agent_name":"%s","phase":"%s","outcome":%s,"reason":%s,"payload":%s,"created_at":"%s","_hh_version":"%s"}' \
   176	    "$(_hh_json_escape "${tenant}")" \
   177	    "$(_hh_json_escape "${agent}")" \
   178	    "$(_hh_json_escape "${phase}")" \
   179	    "$([ -z "${outcome}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${outcome}")")" \
   180	    "$([ -z "${reason}" ] && echo "null" || printf '"%s"' "$(_hh_json_escape "${reason}")")" \
   181	    "${payload_json}" \
   182	    "${created_at}" \
   183	    "${_HH_HELPERS_VERSION}")
   184	
   185	  printf '%s\n' "${row}" >> "${fallback}"
   186	}
   187	
   188	# ────────────────────────────────────────────────────────────────────────
   189	# 3 hh_decision_* contracts (master brief §8.1 Change 2)
   190	# ────────────────────────────────────────────────────────────────────────
   191	
   192	# hh_decision_trigger <trigger_type> [<reason>]
   193	# Writes phase='trigger' row at session start. Required first call of every run.
   194	hh_decision_trigger() {
   195	  local trigger_type="${1:-session_start}"
   196	  local reason="${2:-}"
   197	  local payload
   198	  payload=$(printf '{"trigger_type":"%s","helpers_version":"%s"}' \
   199	    "$(_hh_json_escape "${trigger_type}")" "${_HH_HELPERS_VERSION}")
   200	  _hh_emit_row "trigger" "" "${reason}" "${payload}"
   201	}
   202	
   203	# hh_decision_output <output_type> <artefact_ref> [<reason>]
   204	# Writes phase='output' row per artefact produced. Required before producing
   205	# a customer-visible artefact (Gate B per master brief §1 Rule 4).
   206	hh_decision_output() {
   207	  local output_type="$1"
   208	  local artefact_ref="$2"
   209	  local reason="${3:-}"
   210	  local payload
   211	  payload=$(printf '{"output_type":"%s","artefact_ref":"%s"}' \
   212	    "$(_hh_json_escape "${output_type}")" "$(_hh_json_escape "${artefact_ref}")")
   213	  _hh_emit_row "output" "produced" "${reason}" "${payload}"
   214	}
   215	
   216	# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
   217	# Writes phase='action' or phase='gating_failed' row depending on tier.
   218	# Returns 0 if action allowed; 1 if blocked or approval rejected.
   219	hh_decision_action() {
   220	  local action_type="$1"

exec
/bin/zsh -lc "rg -n \"hh_decision_(trigger|output|action)\\(\\)|hh_decision_(trigger|output|action)\" agents/_shared/hook-helpers.sh" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
192:# hh_decision_trigger <trigger_type> [<reason>]
194:hh_decision_trigger() {
203:# hh_decision_output <output_type> <artefact_ref> [<reason>]
206:hh_decision_output() {
216:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
219:hh_decision_action() {

exec
/bin/zsh -lc 'rg -n "master brief §8.1 Change 1|master brief §8.1 Change 2|Change 1|Change 2|Change 3|99-voice-drift|voice" docs/build-brief/00-MASTER-BRIEF.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
56:3. **Reuse before build.** Every agent uses `agents/_shared/` modules: voice loader, decision-log writer, validate primitives, escalation router. No agent writes its own logging, voice handling, or approval gate. If the shared module is missing, build the module first, then the agent.
159:- **Markdown lives in the vault.** Anything human-readable, voice-related, narrative, playbook-like, or that an agent edits and a human reviews.
163:The vault is the source of truth for voice and playbooks. Postgres is the source of truth for state and provenance. The Brain UI reads both via the `context-assembly` API (the single audit-logged surface).
189:mkdir -p packages/{harness,brain,agents-runtime,vertical-adapters,mcp-connectors,context-assembly,decision-log,vault-syncer,voice,onboarding-wizard,dashboard-ext,agent-renderer}
350:2. **Compile.** A scheduled compile job (per-tenant nightly cron via cortextos `bus add-cron`) reads `raw/*` newer than the last compile, calls Claude (via the runtime; voice-loaded for the tenant), and either creates new pages in `compiled/{type}/{slug}.md` or extends existing ones. Every compiled page has wiki-link backrefs (`[[Candidate: Sarah Bowen]]`) and YAML frontmatter:
406:- **The voice-quality strip.** Persistent footer showing the rolling 4-week voice classifier score. Green ≥ 0.80, amber 0.70–0.80, red < 0.70. Click for trend graph + recent-edit-pattern callouts. **Voice quality is structurally visible, never hidden.**
413:| **v1.0 minimum** | Weeks 11–13 (Ultraplan §9) | 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; **no Brain UI yet**. Total v1.0 effort ~11-13 person-days. |
416:| **v2.0 — the second brain at scale** | Q3 2027 | Reflect-driven hygiene, voice-trend analytics, LoRA-version comparison views |
464:- [ ] **Brain UI scope decision.** Per §5.5 (post-ADR-002 Edit 2 atomic correction): v1.0 ships the parallel `packages/brain/bus-overrides/wiki-*.sh` wrappers + `wiki/lib/*.ts` modules + Postgres tables + pgvector voice index — **no Brain UI yet**. v1.1 adds the today-view + backlinks panel + wiki-find UI; v1.2 adds the graph view. **Confirm this in `docs/decisions/brain-ui-scope.md`** — or document the deviation.
513:| `00-PATTERN-REFERENCE.md` | 6-file agent bundle pattern | `docs/architecture/PATTERN-REFERENCE.md` | Update to v2: `99-voice-drift-canary` fixture required |
557:        └── 99-voice-drift-canary/      # NEW IN V2 — every agent has one.
566:**Change 1 — Voice handling moves into `_shared/voice-loader.sh`.** No agent reads the voice corpus directly. Every `context.sh` calls `hh_load_tone_rules`, `hh_load_voice_samples`, `hh_load_recent_edits`. Agent context scripts become 30 lines, not 200.
568:**Change 2 — Decision logging is enforced.** Three required calls per agent run:
578:**Change 3 — Escalation codes expand to recruitment vocabulary.** ~20–30 codes. Examples:
580:- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
612:mkdir -p agents/recruitment/{name}/tests/fixtures/{01-primary,02-edge-case-{X},99-voice-drift-canary}
780:- `_shared/` shell helpers (voice loader, decision-log writer, validate primitives)
955:> 5. You understand the agent bundle v2 pattern (6 files + 3 fixtures, incl. 99-voice-drift-canary)
970:- Ship an agent without a 99-voice-drift-canary because "we'll add it later"
986:6. **The quality gates** — Gate A binary per-run, Gate B 90-day, Gate C weekly voice classifier

codex
The schema supplement supports the Cash Conductor auxiliary tables and `last_chase_*` fields, so those references are not the blocker. The second hard problem is that the draft claims rich metadata is written in `hh_decision_output` payloads, but the shared helper’s actual contract only stores `output_type` and `artefact_ref`; extra metadata passed as the third argument becomes `reason`, not payload.
exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '206,330p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   206	hh_decision_output() {
   207	  local output_type="$1"
   208	  local artefact_ref="$2"
   209	  local reason="${3:-}"
   210	  local payload
   211	  payload=$(printf '{"output_type":"%s","artefact_ref":"%s"}' \
   212	    "$(_hh_json_escape "${output_type}")" "$(_hh_json_escape "${artefact_ref}")")
   213	  _hh_emit_row "output" "produced" "${reason}" "${payload}"
   214	}
   215	
   216	# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
   217	# Writes phase='action' or phase='gating_failed' row depending on tier.
   218	# Returns 0 if action allowed; 1 if blocked or approval rejected.
   219	hh_decision_action() {
   220	  local action_type="$1"
   221	  local target="$2"
   222	  local payload_hash="$3"
   223	  local payload_preview="$4"
   224	
   225	  local tenant tier
   226	  tenant="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   227	
   228	  if ! tier=$(autosend_policy_lookup "${action_type}"); then
   229	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   230	      "${target}" "${payload_hash}" "${payload_preview}" "policy_lookup_failed"
   231	    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   232	      "${target}" "${payload_hash}" "unknown_action_type"
   233	    return 1
   234	  fi
   235	
   236	  if ! tier=$(autosend_apply_tenant_override "${tier}" "${action_type}" "${tenant}"); then
   237	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   238	      "${target}" "${payload_hash}" "${payload_preview}" "override_resolution_failed"
   239	    autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   240	      "${target}" "${payload_hash}" "override_resolution_failed"
   241	    return 1
   242	  fi
   243	
   244	  case "${tier}" in
   245	    green)
   246	      autosend_emit_decision_log "action" "green" "${action_type}" \
   247	        "${target}" "${payload_hash}" "${payload_preview}" ""
   248	      return 0
   249	      ;;
   250	    yellow)
   251	      autosend_emit_decision_log "action" "yellow" "${action_type}" \
   252	        "${target}" "${payload_hash}" "${payload_preview}" ""
   253	      if autosend_should_sample "${action_type}" "${tenant}"; then
   254	        autosend_spot_check_enqueue "${action_type}" "${target}" \
   255	          "${payload_hash}" "${payload_preview}" "${tenant}"
   256	      fi
   257	      return 0
   258	      ;;
   259	    orange)
   260	      autosend_emit_decision_log "action" "orange" "${action_type}" \
   261	        "${target}" "${payload_hash}" "${payload_preview}" "approval_pending"
   262	      autosend_escalate "ESC_AUTOSEND_NEEDS_REVIEW" "${action_type}" \
   263	        "${target}" "${payload_hash}" "${payload_preview}"
   264	      autosend_await_approval "${action_type}" "${target}" "${payload_hash}"
   265	      return $?
   266	      ;;
   267	    red)
   268	      autosend_emit_decision_log "gating_failed" "red" "${action_type}" \
   269	        "${target}" "${payload_hash}" "${payload_preview}" "red_tier_classification"
   270	      autosend_escalate "ESC_AUTOSEND_BLOCKED" "${action_type}" \
   271	        "${target}" "${payload_hash}" "red_tier_classification"
   272	      return 1
   273	      ;;
   274	    *)
   275	      autosend_emit_decision_log "gating_failed" "fail-safe-red" "${action_type}" \
   276	        "${target}" "${payload_hash}" "${payload_preview}" "unknown_tier:${tier}"
   277	      autosend_escalate "ESC_AUTOSEND_POLICY_LOOKUP_FAILED" "${action_type}" \
   278	        "${target}" "${payload_hash}" "unknown_tier:${tier}"
   279	      return 1
   280	      ;;
   281	  esac
   282	}
   283	
   284	# ────────────────────────────────────────────────────────────────────────
   285	# 7 autosend_* helpers (autosend-safety-policy §4)
   286	# ────────────────────────────────────────────────────────────────────────
   287	
   288	# autosend_policy_lookup <action_type>
   289	# Prints the tier (green|yellow|orange|red) to stdout; returns 0 if found,
   290	# 1 if action_type missing from policy file.
   291	autosend_policy_lookup() {
   292	  local action_type="$1"
   293	  if [[ ! -f "${_HH_POLICY_FILE}" ]]; then
   294	    printf 'autosend_policy_lookup: policy file not found at %s\n' "${_HH_POLICY_FILE}" >&2
   295	    return 1
   296	  fi
   297	  # YAML lookup via awk — finds the action_type key, then reads tier:
   298	  # one line below. Safer than yq/python deps at agent runtime.
   299	  local tier
   300	  tier=$(awk -v key="${action_type}" '
   301	    $0 ~ "^  " key ":" { in_block = 1; next }
   302	    in_block && /^    tier: / { sub(/^    tier: /, ""); print; exit }
   303	    in_block && /^  [a-z]/ { in_block = 0 }
   304	  ' "${_HH_POLICY_FILE}")
   305	  if [[ -z "${tier}" ]]; then
   306	    return 1
   307	  fi
   308	  printf '%s' "${tier}"
   309	}
   310	
   311	# autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>
   312	# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
   313	# tenant override file at /vault/<tenant>/_config/autosend-overrides.yaml.
   314	# Tenants can ELEVATE only (green→yellow→orange→red); red is the floor.
   315	autosend_apply_tenant_override() {
   316	  local base_tier="$1"
   317	  local action_type="$2"
   318	  local tenant_slug="$3"
   319	
   320	  # Red is absolute — no override possible.
   321	  if [[ "${base_tier}" == "red" ]]; then
   322	    printf '%s' "red"
   323	    return 0
   324	  fi
   325	
   326	  local override_file="${IFOS_VAULT_ROOT:-/vault}/${tenant_slug}/_config/autosend-overrides.yaml"
   327	  if [[ ! -f "${override_file}" ]]; then
   328	    printf '%s' "${base_tier}"
   329	    return 0
   330	  fi

exec
/bin/zsh -lc 'rg -n "decision_log:|decision_log|phase:|outcome:|payload:|tier" docs/verticals/recruitment/vertical-schema.yaml docs/runbooks/day-4-provisioning.md docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:16:# Layer over v0.1 generic primitives (entities + entity_links + decision_log
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:86:          Items enum: ["vault_emails", "bullhorn_notes", "marketing_copy", "founder_curated", "consultant_drafts"]. Order documents provenance for the LoRA pipeline (v2.0 Scale tier).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:151:          Enum: ["info", "warn", "block"]. `info` is observational (logged, not enforced); `warn` shows up in decision_log without blocking; `block` is a Gate-A hard-fail (causes regenerate-with-feedback per Ultraplan §5.3 retry budget).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:207:          The agent whose draft was edited. Matches decision_log.agent_name. NOT entity_type — this is a metadata link to the producing agent, not to a domain entity.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:373:  decision_log_phase_implication: |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:335:        notes: Hard gate for autosend orange-tier actions; default false; set true on opt-out.
docs/verticals/recruitment/vertical-schema.yaml:337:      - v1.0 is intentionally thin — only the fields Concierge addressee-resolution needs for orange-tier sends.
docs/verticals/recruitment/vertical-schema.yaml:338:      - v1.1 Triage expands: structured decision-authority (budget tier, decision domain, escalation chain), engagement history aggregate, preferred-channel sentiment.
docs/verticals/recruitment/vertical-schema.yaml:492:      - Lifecycle_stage drives Concierge's most-frequent autosend action (orange-tier `bullhorn_note_customer_visible` per autosend-policy §3 canonical orange).
docs/verticals/recruitment/vertical-schema.yaml:726:    contact: R       # decision-maker resolution for orange-tier sends
docs/verticals/recruitment/vertical-schema.yaml:804:    v0_1_decision: Bullhorn Notes ingest into `decision_log.payload` with `payload.note_content`, `payload.bullhorn_note_id`, `payload.note_external_visibility` (boolean). Not a top-level entity_type in v0.1.
docs/verticals/recruitment/vertical-schema.yaml:806:    rationale: Notes operationally ARE the audit trail (autosend-policy.md §7 confirms); decision_log has RLS + tier metadata + payload_hash for audit; avoid dual-storage problem at v1.0; cheap to promote later if needed.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:817:    rationale: Vertical schema covers tenant-domain entities only. System-internal agents (renderer, validators, ingest pipeline) live in decision_log audit but are not first-class business entities.
docs/verticals/recruitment/vertical-schema.yaml:823:    v1_1_plus_expansion: Sub-fields for decision-domain (technical/budget/strategic), authority tier (final/recommend/influence/observer), engagement history aggregate, preferred-channel sentiment.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:359:  #   agent + which fields were touched in decision_log payload; reviewers
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:369:  # decision_log row records who wrote. Entity-level RLS enforces TENANT
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:431:    # in the Sourcing Scout shortlist artefact (vault markdown + decision_log
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:642:      raw_payload: {type: object, required: false, source: Open Banking provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific. Full Open Banking response cached for audit; pseudonymized at year 7"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:680:      raw_payload: {type: object, required: false, source: Accounting provider, pii: true, free_form: true, notes: "Free-form provider JSON; no shape contract — provider-specific (Xero / QuickBooks / Sage). Full provider response cached for audit"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:806:      orange-tier sends.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:833:      send refusal (autosend-safety-policy §5 red-tier action_type
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:855:  # (per ADR-006 Tier 2 + §5 deferred_to_future_adr). v0.3 does not
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:861:# §5 — decision_log.payload extension (per ADR-006 Tier 2 prerequisite)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:864:decision_log_payload_extension:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:865:  # NOTE: v0.3 does NOT introduce any new decision_log.payload key. The
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:866:  # per_claim_confidence_distribution key planned for ADR-006 Tier 2 is
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:868:  # that ships alongside Tier 2 activation. v0.3 introducing the payload
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:870:  # (bounded values require CHECK or trigger). Tier 2 schema work owns
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:873:    artefact: ADR (number unassigned) — Diagnostic Tier 2 per-claim quality metric
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:876:      Per ADR-006 Tier 2 disposition: per-claim citation analysis is a
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:879:      all land together with Tier 2 activation. Tier 2 doesn't activate
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1023:  v0.3 is DEFERRED to the future W4-polish ADR (per ADR-006 Tier 2 +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1043:    - Diagnostic Tier 2 schema substrate exists (ADR-006 W4-polish prereq)
docs/runbooks/day-4-provisioning.md:10:execution_outcome: All 9 sections complete; §7 RLS isolation gate passed all 5 conditions; 22 of 22 §9 automated checks passed; §11 closing commit landed with LUKS rotation completed.
docs/runbooks/day-4-provisioning.md:60:**Master brief asserts (§6 Day 4 line 478):** "Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`"
docs/runbooks/day-4-provisioning.md:62:**ADR-002 Edit 3 + current-priorities.md (Open) state the corrected table list:** `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:66:### §0.3 — `decision_log.phase` enum: 5 values, not more
docs/runbooks/day-4-provisioning.md:749:-- decision_log (per ADR-002 §3 Decision 3; phase enum per §6.4 below = Tightening 3)
docs/runbooks/day-4-provisioning.md:750:CREATE TABLE decision_log (
docs/runbooks/day-4-provisioning.md:761:CREATE INDEX decision_log_tenant_agent_idx
docs/runbooks/day-4-provisioning.md:762:  ON decision_log (tenant_slug, agent_name, created_at DESC);
docs/runbooks/day-4-provisioning.md:764:GRANT SELECT, INSERT ON decision_log TO ifos_app;
docs/runbooks/day-4-provisioning.md:765:GRANT USAGE, SELECT ON SEQUENCE decision_log_id_seq TO ifos_app;
docs/runbooks/day-4-provisioning.md:801:# Expected: six tables listed (tenants, entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters)
docs/runbooks/day-4-provisioning.md:804:### §6.4 — Tightening 3: `decision_log.phase` enum constraint
docs/runbooks/day-4-provisioning.md:810:ALTER TABLE decision_log
docs/runbooks/day-4-provisioning.md:811:ADD CONSTRAINT decision_log_phase_check
docs/runbooks/day-4-provisioning.md:823:WHERE conrelid = 'decision_log'::regclass AND contype = 'c';
docs/runbooks/day-4-provisioning.md:906:\d decision_log
docs/runbooks/day-4-provisioning.md:915:# - decision_log has the phase CHECK constraint     (Tightening 3)
docs/runbooks/day-4-provisioning.md:934:ALTER TABLE decision_log ENABLE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:941:ALTER TABLE decision_log FORCE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:961:CREATE POLICY tenant_isolation ON decision_log
docs/runbooks/day-4-provisioning.md:1127:- [ ] §6.3 — Six tables exist: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:1130:- [ ] §6.4 (Tightening 3) — `decision_log_phase_check` constraint present with exactly 5 values
docs/runbooks/day-4-provisioning.md:1156:| §6.4 constraint | CHECK constraint fails to add | `ALTER TABLE decision_log DROP CONSTRAINT decision_log_phase_check;` then retry — most common cause is pre-existing rows violating the check, but the table is empty at this point so unusual |
docs/runbooks/day-4-provisioning.md:1248:17. **§7 — RLS isolation gate passed clean (5 of 5).** No-context = 0 ✓, own-tenant insert+select = 1 ✓, cross-tenant = 0 ✓, WITH CHECK adversarial INSERT rejected ✓, own-tenant unaffected = 1 ✓. RLS + FORCE on entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters (5 tables). `tenant_isolation` policy on all 5 with USING + WITH CHECK on `current_setting('app.current_tenant', true)`. Test ran as `ifos_app` over TCP+scram-sha-256 (NOT as postgres superuser, which would bypass RLS). Test data ROLLBACK'd; 2 seeded test tenants cleaned up.

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '150,310p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   150	  # MCP-connector OAuth refresh action_types (added 2026-06-01
   151	  # per Codex cluster F Round 1 — review-mcp-connector §7 requires
   152	  # documented action_types to exist in this policy with matching
   153	  # tier; round-1 REJECT cited all 4 as missing). All green: OAuth
   154	  # refresh is idempotent token rotation, not external send.
   155	  # ───────────────────────────────────────────────────────────
   156	
   157	  xero_oauth:
   158	    tier: green
   159	    agent: cash-conductor
   160	    reason: "Xero OAuth 2.0 refresh — idempotent token rotation against identity.xero.com; @ifos/xero connector handles concurrent-refresh dedup per-tenant; no external send."
   161	    irreversible: false
   162	
   163	  quickbooks_oauth:
   164	    tier: green
   165	    agent: cash-conductor
   166	    reason: "QuickBooks Online OAuth 2.0 refresh — idempotent token rotation against oauth.platform.intuit.com; @ifos/quickbooks connector handles concurrent-refresh dedup per-realm; QB refresh tokens have ~100-day TTL so operator alerting on refreshTokenNearExpiry() is the consumer's responsibility, not this action_type's."
   167	    irreversible: false
   168	
   169	  open_banking_truelayer:
   170	    tier: green
   171	    agent: cash-conductor
   172	    reason: "TrueLayer OAuth 2.0 refresh — idempotent token rotation against auth.truelayer.com; @ifos/open-banking connector handles concurrent-refresh dedup per-connection; PSD2 90-day consent expiry surfaces via ESC_OPEN_BANKING_TOKEN_AGING (separate aging signal, not this action_type)."
   173	    irreversible: false
   174	
   175	  open_banking_plaid_uk:
   176	    tier: green
   177	    agent: cash-conductor
   178	    reason: "Plaid UK OAuth 2.0 refresh — v1.1+ stub; never fires v1.0. Registered now so the README + tools.yaml capability declarations have a matching policy entry per review-mcp-connector §7 set-equality."
   179	    irreversible: false
   180	
   181	  # ───────────────────────────────────────────────────────────
   182	  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
   183	  # ───────────────────────────────────────────────────────────
   184	
   185	  bullhorn_candidate_dedupe:
   186	    tier: yellow
   187	    agent: janitor
   188	    sample_rate: 10
   189	    reason: "Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review"
   190	    irreversible: false
   191	
   192	  bullhorn_field_backfill:
   193	    tier: yellow
   194	    agent: janitor
   195	    sample_rate: 10
   196	    reason: "Fills missing canonical schema fields from Companies House or LinkedIn enrichment; reversible PATCH; high-volume; source provenance logged in payload"
   197	    irreversible: false
   198	
   199	  bullhorn_note_attach:
   200	    tier: yellow
   201	    agent: janitor
   202	    sample_rate: 20
   203	    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
   204	    irreversible: false
   205	
   206	  bullhorn_note_append_summary:
   207	    tier: yellow
   208	    agent: scribe
   209	    sample_rate: 20
   210	    reason: "Appends to candidate record; consultant-only visibility; high-volume; format quality needs review"
   211	    irreversible: false
   212	
   213	  linkedin_connection_request:
   214	    tier: yellow
   215	    agent: sourcing-scout
   216	    sample_rate: 5
   217	    reason: "Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy"
   218	    irreversible: true
   219	
   220	  xero_reminder_draft_internal:
   221	    tier: yellow
   222	    agent: cash-conductor
   223	    sample_rate: 10
   224	    reason: "Generates reminder draft visible to consultant; not yet sent; format + tone needs review"
   225	    irreversible: false
   226	
   227	  bullhorn_note_draft_internal:
   228	    tier: yellow
   229	    agent: concierge
   230	    sample_rate: 10
   231	    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
   232	    irreversible: false
   233	
   234	  bullhorn_scribe_field_write:
   235	    tier: yellow
   236	    agent: scribe
   237	    sample_rate: 10
   238	    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
   239	    irreversible: false
   240	
   241	  accounting_reconciliation_write:
   242	    tier: yellow
   243	    agent: cash-conductor
   244	    sample_rate: 10
   245	    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
   246	    irreversible: false
   247	
   248	  concierge_email_draft:
   249	    tier: yellow
   250	    agent: concierge
   251	    sample_rate: 20
   252	    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
   253	    irreversible: false
   254	
   255	  # ───────────────────────────────────────────────────────────
   256	  # ORANGE — per-action human approval (10 action_types)
   257	  # ───────────────────────────────────────────────────────────
   258	
   259	  bullhorn_note_customer_visible:
   260	    tier: orange
   261	    agent: concierge
   262	    timeout: PT4H
   263	    reason: "CANONICAL ORANGE. Bullhorn Note with isExternal: true — customer-visible in their CRM; single send is irreversible (note in audit trail even if deleted)"
   264	    irreversible: true
   265	    canonical: true
   266	
   267	  gmail_outlook_send_to_candidate:
   268	    tier: orange
   269	    agent: concierge
   270	    timeout: PT4H
   271	    reason: "Outbound email to candidate; customer-facing; reputation effects"
   272	    irreversible: true
   273	
   274	  twilio_sms_send:
   275	    tier: orange
   276	    agent: concierge
   277	    timeout: PT30M
   278	    reason: "Outbound SMS; high-trust channel; cost-per-send; irreversible"
   279	    irreversible: true
   280	
   281	  calendar_invite_send:
   282	    tier: orange
   283	    agent: concierge
   284	    timeout: PT4H
   285	    reason: "Creates calendar event with attendee notification; visible to attendee"
   286	    irreversible: true
   287	
   288	  email_summary_to_customer:
   289	    tier: orange
   290	    agent: scribe
   291	    timeout: PT4H
   292	    reason: "Outbound email summarising call to customer; customer-facing; format-sensitive"
   293	    irreversible: true
   294	
   295	  xero_reminder_send_customer:
   296	    tier: orange
   297	    agent: cash-conductor
   298	    timeout: PT24H
   299	    reason: "Outbound payment reminder to customer; reputation + collection risk"
   300	    irreversible: true
   301	
   302	  diagnostic_email_send:
   303	    tier: orange
   304	    agent: diagnostic
   305	    timeout: PT4H
   306	    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
   307	    irreversible: true
   308	
   309	  diagnostic_calendar_invite:
   310	    tier: orange

exec
/bin/zsh -lc 'rg -n "today|tomorrow|yesterday|Friday|next Sunday|this week|next week|by Friday|this document|until then" agents/recruitment/cash-conductor/agent.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R17 closed §8 sibling files + D1/bridge prereqs + §3 audit-row signatures (4-row chase lifecycle sequence). R19 fixes (today): split draft body out of decision_log payload into vault path (per ADR-002 vault/Postgres split), recent_edit schema R access cite correction, Stage 3 ESC code disambiguation. Awaits Q1 LOI + accounting + Open Banking commercial signups + Founder Decision D1 resolved + autosend bridge built (Concierge W10) + W7 build slice.
16:Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
141:| 2 | **DSO trend** | Days-Sales-Outstanding metric this week vs prior-week vs month-0 baseline; Gate B tracking |
438:## §10 — When this document ratifies
454:Until then: this document is a forward-looking scaffold.

exec
/bin/zsh -lc "ls -la .codex/ratification 2>/dev/null || true && rg --files .codex | rg 'review-agent-bundle|ratification'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
total 136
drwxr-xr-x@ 8 madsadmin  staff    256 May 31 23:19 .
drwxr-xr-x@ 3 madsadmin  staff     96 May 20 13:08 ..
-rw-r--r--@ 1 madsadmin  staff   7686 May 20 13:08 SKILL.md
-rw-r--r--@ 1 madsadmin  staff  11759 May 24 11:19 review-agent-bundle.md
-rw-r--r--@ 1 madsadmin  staff  11166 May 22 13:23 review-architecture-decision.md
-rw-r--r--@ 1 madsadmin  staff   8966 May 31 23:19 review-mcp-connector.md
-rw-r--r--@ 1 madsadmin  staff  11256 May 22 16:17 review-postgres-migration.md
-rw-r--r--@ 1 madsadmin  staff   9804 May 20 13:10 review-schema-change.md
.codex/ratification/review-agent-bundle.md
.codex/ratification/SKILL.md
.codex/ratification/review-postgres-migration.md
.codex/ratification/review-mcp-connector.md
.codex/ratification/review-schema-change.md
.codex/ratification/review-architecture-decision.md

codex
There are now enough concrete blockers for a rejection: citation drift, an unsupported decision-log payload shape, and a relative-date status note. I’m doing one final check of the autosend helper payload implementation so the issue wording is precise.
exec
/bin/zsh -lc "rg -n \"autosend_emit_decision_log\\(|payload_preview|payload_hash|tier\" agents/_shared/hook-helpers.sh" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
20:# raw PII into shell vars (payload_preview must be sanitised by caller).
216:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
217:# Writes phase='action' or phase='gating_failed' row depending on tier.
222:  local payload_hash="$3"
223:  local payload_preview="$4"
225:  local tenant tier
228:  if ! tier=$(autosend_policy_lookup "${action_type}"); then
230:      "${target}" "${payload_hash}" "${payload_preview}" "policy_lookup_failed"
232:      "${target}" "${payload_hash}" "unknown_action_type"
236:  if ! tier=$(autosend_apply_tenant_override "${tier}" "${action_type}" "${tenant}"); then
238:      "${target}" "${payload_hash}" "${payload_preview}" "override_resolution_failed"
240:      "${target}" "${payload_hash}" "override_resolution_failed"
244:  case "${tier}" in
247:        "${target}" "${payload_hash}" "${payload_preview}" ""
252:        "${target}" "${payload_hash}" "${payload_preview}" ""
255:          "${payload_hash}" "${payload_preview}" "${tenant}"
261:        "${target}" "${payload_hash}" "${payload_preview}" "approval_pending"
263:        "${target}" "${payload_hash}" "${payload_preview}"
264:      autosend_await_approval "${action_type}" "${target}" "${payload_hash}"
269:        "${target}" "${payload_hash}" "${payload_preview}" "red_tier_classification"
271:        "${target}" "${payload_hash}" "red_tier_classification"
276:        "${target}" "${payload_hash}" "${payload_preview}" "unknown_tier:${tier}"
278:        "${target}" "${payload_hash}" "unknown_tier:${tier}"
289:# Prints the tier (green|yellow|orange|red) to stdout; returns 0 if found,
297:  # YAML lookup via awk — finds the action_type key, then reads tier:
299:  local tier
300:  tier=$(awk -v key="${action_type}" '
302:    in_block && /^    tier: / { sub(/^    tier: /, ""); print; exit }
305:  if [[ -z "${tier}" ]]; then
308:  printf '%s' "${tier}"
311:# autosend_apply_tenant_override <base_tier> <action_type> <tenant_slug>
312:# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
316:  local base_tier="$1"
321:  if [[ "${base_tier}" == "red" ]]; then
328:    printf '%s' "${base_tier}"
338:    printf '%s' "${base_tier}"
344:  case "${base_tier}" in green) base_rank=0;; yellow) base_rank=1;; orange) base_rank=2;; red) base_rank=3;; *) return 1;; esac
349:      "${base_tier}" "${override}" "${tenant_slug}" "${action_type}" >&2
355:# autosend_emit_decision_log <phase> <tier> <action_type> <target> <payload_hash> <payload_preview> <approval_status_or_reason>
356:# Emits the standard autosend decision_log row with payload.tier set.
357:autosend_emit_decision_log() {
359:  local tier="$2"
362:  local payload_hash="$5"
363:  local payload_preview="$6"
367:  payload=$(printf '{"tier":"%s","action_type":"%s","target":"%s","payload_hash":"%s","payload_preview":"%s","approval_status":%s,"block_reason":%s,"policy_version_sha":"%s"}' \
368:    "$(_hh_json_escape "${tier}")" \
371:    "$(_hh_json_escape "${payload_hash}")" \
372:    "$(_hh_json_escape "${payload_preview}")" \
374:    "$([ "${tier}" = "red" ] || [ "${tier}" = "fail-safe-red" ] && printf '"%s"' "$(_hh_json_escape "${reason_or_status}")" || echo "null")" \
376:  _hh_emit_row "${phase}" "${tier}" "${reason_or_status}" "${payload}"
442:# autosend_spot_check_enqueue <action_type> <target> <payload_hash> <payload_preview> <tenant_slug>
444:# review. Idempotent on payload_hash — duplicate enqueues become single file.
448:  local payload_hash="$3"
449:  local payload_preview="$4"
460:  local outfile="${spot_dir}/${timestamp}-${action_type}-${payload_hash:0:12}.md"
471:    printf -- '- **Payload hash:** %s\n' "${payload_hash}"
473:    printf '## Preview\n\n%s\n' "${payload_preview}"
477:# autosend_await_approval <action_type> <target> <payload_hash>
486:  local payload_hash="$3"
509:  local marker="${pending_dir}/${payload_hash}.pending"
510:  local approved="${pending_dir}/${payload_hash}.approved"
511:  local rejected="${pending_dir}/${payload_hash}.rejected"
516:    printf 'payload_hash=%s\n' "${payload_hash}"
538:          "${target}" "${payload_hash}" "timeout_after_${timeout_s}s"
566:    "${target}" "${payload_hash}" "timeout_after_${timeout_s}s"

exec
/bin/zsh -lc "nl -ba agents/_shared/hook-helpers.sh | sed -n '380,470p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   380	# Writes the ESC row + dispatches Telegram via primitive-5 helper. Catalogue
   381	# lookup is permissive — unknown codes are emitted with phase='gating_failed'
   382	# + ESC_AUTOSEND_POLICY_LOOKUP_FAILED meta-escalation.
   383	autosend_escalate() {
   384	  local code="$1"
   385	  shift
   386	
   387	  if ! _hh_validate_esc_code "${code}"; then
   388	    printf 'autosend_escalate: unknown ESC code: %s\n' "${code}" >&2
   389	    local meta_payload
   390	    meta_payload=$(printf '{"unknown_code":"%s","helpers_version":"%s"}' \
   391	      "$(_hh_json_escape "${code}")" "${_HH_HELPERS_VERSION}")
   392	    _hh_emit_row "gating_failed" "fail-safe-red" "esc_code_unknown" "${meta_payload}"
   393	    return 1
   394	  fi
   395	
   396	  local escaped_code
   397	  escaped_code="$(_hh_json_escape "${code}")"
   398	  local payload="{\"escalation_code\":\"${escaped_code}\""
   399	  local arg
   400	  for arg in "$@"; do
   401	    if [[ "${arg}" == *"="* ]]; then
   402	      local k="${arg%%=*}"
   403	      local v="${arg#*=}"
   404	      payload+=",\"$(_hh_json_escape "${k}")\":\"$(_hh_json_escape "${v}")\""
   405	    fi
   406	  done
   407	  payload+="}"
   408	
   409	  _hh_emit_row "gating_failed" "${code}" "" "${payload}"
   410	
   411	  # Telegram dispatch is a separate primitive — for v0.1 the row is the
   412	  # signal. Dispatcher (autosend-syncer) reads recent gating_failed rows and
   413	  # routes to operator chat per common-notifications.json.
   414	}
   415	
   416	# autosend_should_sample <action_type> <tenant_slug>
   417	# Returns 0 if this invocation should produce a spot-check (1-in-N draw);
   418	# 1 otherwise. Sample rate read from autosend-policy.yaml (sample_rate field);
   419	# tenant override via tenant_adapters.config.sampling_rates.
   420	autosend_should_sample() {
   421	  local action_type="$1"
   422	  # tenant_slug reserved for future per-tenant rate override; currently unused
   423	  local rate
   424	  rate=$(awk -v key="${action_type}" '
   425	    $0 ~ "^  " key ":" { in_block = 1; next }
   426	    in_block && /^    sample_rate: / { sub(/^    sample_rate: /, ""); print; exit }
   427	    in_block && /^  [a-z]/ { in_block = 0 }
   428	  ' "${_HH_POLICY_FILE}")
   429	
   430	  if [[ -z "${rate}" || ! "${rate}" =~ ^[0-9]+$ || "${rate}" -le 0 ]]; then
   431	    return 1
   432	  fi
   433	
   434	  local draw
   435	  draw=$(( RANDOM % rate ))
   436	  if (( draw == 0 )); then
   437	    return 0
   438	  fi
   439	  return 1
   440	}
   441	
   442	# autosend_spot_check_enqueue <action_type> <target> <payload_hash> <payload_preview> <tenant_slug>
   443	# Writes spot-check artefact under /vault/<tenant>/spot-checks/ for operator
   444	# review. Idempotent on payload_hash — duplicate enqueues become single file.
   445	autosend_spot_check_enqueue() {
   446	  local action_type="$1"
   447	  local target="$2"
   448	  local payload_hash="$3"
   449	  local payload_preview="$4"
   450	  local tenant_slug="$5"
   451	
   452	  local spot_dir="${IFOS_VAULT_ROOT:-/vault}/${tenant_slug}/spot-checks"
   453	  mkdir -p "${spot_dir}" 2>/dev/null || {
   454	    printf 'autosend_spot_check_enqueue: cannot mkdir %s\n' "${spot_dir}" >&2
   455	    return 1
   456	  }
   457	
   458	  local timestamp
   459	  timestamp="$(date -u +"%Y-%m-%dT%H%M%SZ")"
   460	  local outfile="${spot_dir}/${timestamp}-${action_type}-${payload_hash:0:12}.md"
   461	
   462	  if [[ -f "${outfile}" ]]; then
   463	    return 0
   464	  fi
   465	
   466	  {
   467	    printf '# Spot check — %s\n\n' "${action_type}"
   468	    printf -- '- **Tenant:** %s\n' "${tenant_slug}"
   469	    printf -- '- **Agent:** %s\n' "${CTX_AGENT_NAME:-unknown}"
   470	    printf -- '- **Target:** %s\n' "${target}"

exec
/bin/zsh -lc "nl -ba docs/runbooks/operational-hygiene-protocol.md | sed -n '1,120p;200,250p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Operational hygiene protocol — A-grade discipline rules
     2	
     3	**Status:** In force (Day 6, 2026-05-18). All sections from Week 0 onwards reference this document at section-gate moments.
     4	**Author:** Claude Code + founder (Maddox), Day-6 evening 2026-05-18
     5	**Source:** Lessons from Days 0-6 execution. Bumps three operational-grade dimensions from B+/C+/B → A by codifying what was previously implicit.
     6	**Audience:** This session and every future session. Reference at the start of any work that involves credentials, runbooks, drafts, or citations.
     7	
     8	---
     9	
    10	## §1 — Why this document exists
    11	
    12	Days 0-6 self-grade on Week-0 retrospective (Day-6 evening):
    13	
    14	| Dimension | Day-6 grade | A-grade target |
    15	|---|---|---|
    16	| Architectural rigour | A | maintain |
    17	| Honest signal | A | maintain |
    18	| Process discipline | A− | maintain |
    19	| **Operational hygiene** | **B+** | A |
    20	| **Length discipline** | **C+** | A |
    21	| **Citation accuracy** | **B** | A |
    22	
    23	The B+/C+/B grades reflect specific lapses where the discipline was implicit rather than written down:
    24	
    25	- **Operational hygiene B+** — Path B was allowed mid-Day-4 (LUKS passphrase entered chat); Day 4 execution had self-inflicted deviations (defensive `sudo file -s` check; missing `sudo` on `sshd -T`; outdated `findmnt` regex)
    26	- **Length discipline C+** — Day 5 autosend policy 658 lines vs 300-500 estimate; Day 6 vertical schema 899 lines vs same estimate
    27	- **Citation accuracy B** — Day 5 §4.1 should have been §4.1 + §6.3 (caught in review); Day 6 "30+" action_type claim was actually 29 (caught in review); **15 fabricated "master brief §10.4" references propagated across 5 files** (caught in Day-6-evening citation audit; see §7 below)
    28	
    29	This document codifies the rules to bring all three to A. Reference it at the section-gate moment of any future work that touches the relevant surface.
    30	
    31	---
    32	
    33	## §2 — Credential-bearing operations: Path A / Path D protocols
    34	
    35	Three named protocols for handling credentials in IFOS operations. Path A is the default for entering existing credentials; Path D is the default for generating new credentials. **Path B is forbidden absent explicit per-session founder waiver.**
    36	
    37	### §2.1 — Path A (default for credential entry)
    38	
    39	**Definition:** Founder enters credentials in their own local terminal session. Credentials never appear in Claude Code chat context, tool input, tool output, or anywhere a transcript could capture them.
    40	
    41	**Use cases:**
    42	- LUKS passphrase entry at `cryptsetup luksFormat` / `luksOpen` / `luksChangeKey`
    43	- Postgres role passwords typed into `psql` prompts
    44	- API tokens entered into Console UIs
    45	- Any password prompt that the application requests interactively
    46	
    47	**Mechanism:**
    48	1. Claude Code prepares the command and surfaces it to the founder
    49	2. Founder opens a fresh local terminal (or uses an existing one outside Claude Code's tool scope)
    50	3. Founder runs the command interactively
    51	4. Founder reports back: success / failure + relevant non-credential output
    52	
    53	**Trade-off:** ~30-90 seconds of founder time per interactive step vs. zero credential exposure.
    54	
    55	**Day-4 lesson:** Path A was the initial agreed protocol for §4.2 luksFormat + §4.3 luksOpen + §4.8 ifos-unlock end-to-end test. Path B was authorised mid-Day-4 for the ifos-unlock test specifically; the operational friction of Path A was found acceptable for first-use (luksFormat) but unacceptable for repeated use (ifos-unlock). Mitigation: Path D pattern (§2.3) eliminates many would-be-Path-B cases by generating credentials on-VPS where they never need to be re-entered.
    56	
    57	### §2.2 — Path B (FORBIDDEN absent explicit waiver)
    58	
    59	**Definition:** Credential enters Claude Code chat context, then gets piped via stdin or written to a temporary file for command execution.
    60	
    61	**Why forbidden:**
    62	- Chat transcript captures the credential
    63	- Future transcript export, search history, or harness telemetry retains it
    64	- Cannot be scrubbed retroactively
    65	- Required to rotate the credential post-use to invalidate the transcript-captured copy
    66	
    67	**Waiver process if Path B is genuinely needed:**
    68	1. Founder types literally: `Path B: protocol override authorised` followed by the credential on a new line
    69	2. Claude Code uses the credential once, immediately
    70	3. Founder **MUST rotate the credential within 24 hours** — non-negotiable. `cryptsetup luksChangeKey` for LUKS; equivalent rotation API for Postgres/OAuth/etc.
    71	4. Rotation **MUST be verified** — for LUKS, `cryptsetup luksChangeKey --test-passphrase` confirms OLD rejected + NEW accepted; for Postgres, `psql -c "SELECT 1;"` with OLD credentials fails and with NEW succeeds
    72	5. Rotation logged in `.agents/decisions/<date>-path-b-rotation-<n>.md` with the original need, the rotation evidence, AND the cryptographic verification output
    73	
    74	**Codex Round 1 strengthening (2026-05-20):** the waiver text above is the *escape hatch*, not the default. **Any Path B use without same-session rotation is a protocol violation that counts as a Risk #1 strike** (operational hygiene degraded). Founder may invoke Path B exactly once per emergency context (e.g., boot-time `ifos-unlock` when Path A is impossible because no interactive terminal is available). Repeated Path B use in a single session indicates Path A/Path D pattern is insufficient — escalate to a new ADR rather than authorise repeatedly.
    75	
    76	**Day-4 incident (reference example of a correctly-handled Path B use):** Path B was authorised once for §4.8 ifos-unlock end-to-end test. Founder rotated WITHIN THE SAME SESSION via `cryptsetup luksChangeKey`; `--test-passphrase` verified OLD rejected + NEW accepted. The leaked passphrase in the transcript became cryptographically invalid against the LUKS volume. **Cost:** ~30 minutes of rotation work + permanent transcript-history annotation. Audit record: Day-4 close commit `98c79b2` + `.agents/decisions/2026-05-17-path-b-rotation-1.md`.
    77	
    78	**Path B was the right call for Day 4 ONLY because the protocol violation was acknowledged and the rotation was committed in the same session.** The Day-4 close commit (`98c79b2`) is the audit record. **Future sessions MUST avoid Path B by defaulting to Path A or Path D.** If Path B is invoked, the same-session-rotation discipline above is non-negotiable.
    79	
    80	### §2.3 — Path D (default for credential generation)
    81	
    82	**Definition:** Credential generated on the remote VPS (or other target system) via `openssl rand` or equivalent. Never echoed to stdout. Stored in a file with mode 0600 root:root. Founder retrieves separately via `sudo cat` in their own terminal, saves to 1Password, then deletes the temp file.
    83	
    84	**Use cases:**
    85	- Postgres role passwords (Day-5 §5.4 `ifos_app` role)
    86	- LUKS passphrase rotation (Day-5 §11 LUKS rotation post-Path-B)
    87	- Future API token generation
    88	- Any random-generated credential
    89	
    90	**Mechanism (worked example from Day-5 §5.4):**
    91	
    92	```bash
    93	# Inside an SSH session as maddox on the VPS:
    94	PASSWORD=$(openssl rand -base64 24)                              # generate; not echoed
    95	printf '%s' "$PASSWORD" | sudo tee /vault/.<name>.tmp >/dev/null # write file; tee output discarded
    96	sudo chmod 600 /vault/.<name>.tmp                                # restrict access
    97	sudo chown root:root /vault/.<name>.tmp                          # root-only
    98	sudo -u postgres psql <<SQL                                      # use via stdin heredoc (not ps-visible)
    99	ALTER ROLE <role> WITH PASSWORD '$PASSWORD';
   100	SQL
   101	unset PASSWORD                                                    # clear from shell env
   102	```
   103	
   104	Founder retrieval (separate terminal, separate SSH session):
   105	
   106	```bash
   107	ssh ... 'sudo cat /vault/.<name>.tmp'   # founder views password
   108	# (founder copies to 1Password)
   109	ssh ... 'sudo rm /vault/.<name>.tmp'    # founder deletes temp file
   110	```
   111	
   112	**Properties:**
   113	- Password never appears in Claude Code's output stream
   114	- `ps auxf` cannot show the password (stdin heredoc, not command-line argument)
   115	- Temp file is on the LUKS-encrypted volume (encrypted at rest)
   116	- Founder retrieves at their convenience; no blocking handoff
   117	- Rotation NOT required because password was never in chat context
   118	
   119	**Trade-off:** ~2-minute founder retrieval at convenience vs. zero chat exposure.
   120	
   200	1. **`§X.Y` references:** open the source document. Verify the section exists and contains what you're about to claim.
   201	2. **`line N` references:** open the source document at that line. Verify it matches.
   202	3. **Numerical claims:** count. "29 action_types" not "30+". "10 entity_links" not "~10". If counting is hard, write the counting query (grep, wc -l, SQL) and run it.
   203	4. **Cross-references:** when citing `<artefact>.md §X.Y`, verify both the artefact exists and §X.Y exists within it. Path drifts and renamed sections are common.
   204	
   205	### §5.2 — Pre-commit citation audit (for new artefacts)
   206	
   207	Before commit, run a citation grep across the artefact:
   208	
   209	```bash
   210	# Find all §-references
   211	grep -nE "§[0-9]+(\.[0-9]+)*" <artefact>
   212	
   213	# Find all line-N references
   214	grep -nE "line [0-9]+" <artefact>
   215	
   216	# Find all numerical-claim patterns
   217	grep -nE "\b[0-9]+ (entities|fields|action_types|relationships|triggers|tiers|sections|edits|items)" <artefact>
   218	```
   219	
   220	For each match, verify against source. Fix any drift before commit.
   221	
   222	### §5.3 — Numerical claims discipline
   223	
   224	- "30+ action_types" → forbidden. Count: 29. Write "29 action_types".
   225	- "~10 entity_links" → forbidden. Count: 10. Write "10 entity_links".
   226	- "covers ~18 of 50+ available fields" → forbidden. Don't estimate the denominator if you don't know it. Write "covers 18 fields; full set TBD pending <named-trigger>".
   227	- "8+ binary triggers" → forbidden if you have a specific count. Count: 10. Write "10 binary triggers".
   228	
   229	### §5.4 — Master brief / cross-artefact citation discipline
   230	
   231	**Day-6 lesson (§7 below):** 15 fabricated "master brief §10.4" references propagated across 5 files. The root cause: Day-4 runbook drafting invented a citation that didn't exist, and subsequent artefacts cited the Day-4 runbook citation without re-verifying against master brief.
   232	
   233	**Discipline:**
   234	- When citing master brief, verify against master brief — never against an intermediate artefact's citation of master brief
   235	- When citing another IFOS artefact, verify the section + line exists in that artefact
   236	- Citation transitivity is not a verification short-cut
   237	
   238	**A-grade test:** zero citation drift in a pre-commit audit. Every reference checks out against source.
   239	
   240	---
   241	
   242	## §6 — When to consult this document
   243	
   244	Reference at the section-gate moment of:
   245	
   246	1. **Any runbook execution** — §3 no-defensive-additions rule applies to every command
   247	2. **Any credential-bearing operation** — §2 Path A/D protocols apply
   248	3. **Any drafting session** — §4 length calibration sets the estimate; §5 citation discipline applies during writing
   249	4. **Any pre-commit audit** — §5.2 citation grep checklist
   250	5. **Any Codex ratification preparation** — §5.2 audit is the input quality gate

exec
/bin/zsh -lc 'rg -n "absolute|relative|today|tomorrow|Friday|dates" docs/runbooks/operational-hygiene-protocol.md docs/build-brief/00-MASTER-BRIEF.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/runbooks/operational-hygiene-protocol.md:284:Day-5 autosend policy §3 + §10 cited `bullhorn-integration-path.md §4.1` as the canonical-orange anchor for Concierge `bullhorn_note_customer_visible`. Verified §4.1 establishes the action exists but does not explicitly frame as sensitive auto-send. Sensitivity framing lives in §6.3 ("Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI").
docs/build-brief/00-MASTER-BRIEF.md:105:1. **There is no `templates/agent-codex` directory on `main` today.** I previously implied Codex-runtime agent templates ship with cortextos. They don't. The `runtime` field discussion exists in some forks/PRs but is not in the published v0.1.1. **Consequence:** the Codex ratification loop in §10 runs Codex CLI as an **external tool**, not as a cortextOS agent runtime. We can revisit if/when codex-app-server lands upstream.
docs/build-brief/00-MASTER-BRIEF.md:318:│       │   ├── candidates/       ← one .md per candidate entity
docs/build-brief/00-MASTER-BRIEF.md:377:    ├── page.tsx                  ← /brain — today's decisions feed
docs/build-brief/00-MASTER-BRIEF.md:405:- **The "today" page.** Default landing. Timeline feed of every agent decision in the last 24h, colour-coded by agent, expandable to show the drafted output and the consultant's action. Each entry deep-links to `/brain/decisions/{id}`.
docs/build-brief/00-MASTER-BRIEF.md:414:| **v1.1 — the wiki proper + today-view** | Q4 2026 | `/brain` (decisions feed) + `/brain/vault/[...path]` (read-only markdown render) + backlinks panel + `wiki-find.sh` + `wiki-history.sh` + `compile.ts` + `lint.ts` + full entity profile pages + wiki-link rendering + search UI |
docs/build-brief/00-MASTER-BRIEF.md:436:### Day 0 (today) — repo reconciliation
docs/build-brief/00-MASTER-BRIEF.md:454:- [ ] If audit reveals primitives 1, 4, or 5 are NOT working today → re-cut Ultraplan §9 sprint plan tomorrow
docs/build-brief/00-MASTER-BRIEF.md:464:- [ ] **Brain UI scope decision.** Per §5.5 (post-ADR-002 Edit 2 atomic correction): v1.0 ships the parallel `packages/brain/bus-overrides/wiki-*.sh` wrappers + `wiki/lib/*.ts` modules + Postgres tables + pgvector voice index — **no Brain UI yet**. v1.1 adds the today-view + backlinks panel + wiki-find UI; v1.2 adds the graph view. **Confirm this in `docs/decisions/brain-ui-scope.md`** — or document the deviation.
docs/build-brief/00-MASTER-BRIEF.md:475:### Day 5 — Friday — Safety policy + kill criterion
docs/build-brief/00-MASTER-BRIEF.md:489:2. Does the CortexOS submodule give us primitives 1, 4, and 5 working today?
docs/build-brief/00-MASTER-BRIEF.md:502:The v1 codebase at `~/code/intel-force-os/` and the `legacy/v1/` mirror in the v2 repo contain a usable scaffold — but it predates cortextOS and the recruitment vertical. The instinct to "start fresh" is right. Several pieces are still valuable; we harvest them with structural adjustments.
docs/build-brief/00-MASTER-BRIEF.md:811:> Then read `.agents/current-priorities.md` and propose the concrete plan for today.
docs/build-brief/00-MASTER-BRIEF.md:839:Verbatim from Ultraplan §10. Full register at `docs/RISK-REGISTER.md`, weekly updates.
docs/build-brief/00-MASTER-BRIEF.md:913:4. Propose today's plan
docs/build-brief/00-MASTER-BRIEF.md:958:> Then read `.agents/current-priorities.md` and propose the concrete plan for today. We are on Week 0; today's task is whichever Day in §6 we're on. **Do not write any agent code until Week 0 is cleared per the §6 Day 7 test.**

exec
/bin/zsh -lc "nl -ba docs/runbooks/day-4-provisioning.md | sed -n '749,760p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   749	-- decision_log (per ADR-002 §3 Decision 3; phase enum per §6.4 below = Tightening 3)
   750	CREATE TABLE decision_log (
   751	  id BIGSERIAL PRIMARY KEY,
   752	  tenant_slug TEXT NOT NULL REFERENCES tenants(tenant_slug) ON DELETE CASCADE,
   753	  agent_name TEXT NOT NULL,
   754	  phase TEXT NOT NULL,
   755	  outcome TEXT,
   756	  reason TEXT,
   757	  payload JSONB DEFAULT '{}'::jsonb,
   758	  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
   759	);
   760	

codex
REJECTED

1. Autosend-policy line citations are wrong. Artefact lines 18, 98, 119, 121, and 253-258 cite `xero_reminder_draft_internal` at lines 188-193 and `xero_reminder_send_customer` at line 263, but `agents/_shared/autosend-policy.yaml` lines 188-193 are Bullhorn/Janitor entries and line 263 is `bullhorn_note_customer_visible`; the Xero draft is lines 220-225 and the Xero customer send is lines 295-300. Fix all autosend line anchors and re-run citation audit.

2. Decision-log payload signatures do not match the shared helper/schema contract. Artefact line 94 describes a `decision_log` row with top-level `tier='yellow'`, but Day-4 `decision_log` schema lines 750-758 has no `tier` column; `tier` is stored inside autosend payload by `hook-helpers.sh` lines 355-376. Artefact lines 118 and 232-234 also claim `hh_decision_output` payload carries `{vault_path, body_sha256, ...}`, but `hh_decision_output` lines 206-213 only writes `output_type` and `artefact_ref`. Fix by rewriting audit-row signatures to the actual helper payload shape, or extend the shared helper/schema before this agent claims richer payload fields.

3. Status metadata uses a relative date. Artefact line 4 says `R19 fixes (today)`, which violates the supplied date discipline requiring absolute dates in artefacts. Replace `today` with the absolute date, e.g. `R19 fixes (2026-05-24)`.
tokens used
98,019
REJECTED

1. Autosend-policy line citations are wrong. Artefact lines 18, 98, 119, 121, and 253-258 cite `xero_reminder_draft_internal` at lines 188-193 and `xero_reminder_send_customer` at line 263, but `agents/_shared/autosend-policy.yaml` lines 188-193 are Bullhorn/Janitor entries and line 263 is `bullhorn_note_customer_visible`; the Xero draft is lines 220-225 and the Xero customer send is lines 295-300. Fix all autosend line anchors and re-run citation audit.

2. Decision-log payload signatures do not match the shared helper/schema contract. Artefact line 94 describes a `decision_log` row with top-level `tier='yellow'`, but Day-4 `decision_log` schema lines 750-758 has no `tier` column; `tier` is stored inside autosend payload by `hook-helpers.sh` lines 355-376. Artefact lines 118 and 232-234 also claim `hh_decision_output` payload carries `{vault_path, body_sha256, ...}`, but `hh_decision_output` lines 206-213 only writes `output_type` and `artefact_ref`. Fix by rewriting audit-row signatures to the actual helper payload shape, or extend the shared helper/schema before this agent claims richer payload fields.

3. Status metadata uses a relative date. Artefact line 4 says `R19 fixes (today)`, which violates the supplied date discipline requiring absolute dates in artefacts. Replace `today` with the absolute date, e.g. `R19 fixes (2026-05-24)`.
