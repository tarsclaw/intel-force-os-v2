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
session id: 019e8857-e8e0-7683-a89a-341e36f4c6d8
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
**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R17 closed §8 sibling files + D1/bridge prereqs + §3 audit-row signatures (4-row chase lifecycle sequence). R19 fixes (2026-05-24): split draft body out of decision_log payload into vault path (per ADR-002 vault/Postgres split), recent_edit schema R access cite correction, Stage 3 ESC code disambiguation. **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram approval-shim; `docs/decisions/2026-05-31-d1-founder-decision.md`); `@ifos/autosend-bridge-telegram` package scaffold landed 2026-06-01 (commit `9b282d8`); Cash Conductor consumer wiring landed (commit `076e231`). Remaining gates: Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice replacing the SKELETON TODOs with live impl + Concierge W10-13 build slice landing the autosend-bridge production wiring (Telegram Bot API + postgres approvals reader) so the orange-tier send path activates.
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
**Build complexity:** L (2 weeks) per ULTRAPLAN A4 line 540.
**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type (registered in autosend-policy.yaml under §ORANGE; grep `^  xero_reminder_send_customer:` to verify); Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW — grep `^  xero_reminder_draft_internal:` to verify; internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (registered under §ORANGE — grep `^  xero_reminder_send_customer:`; consultant approval required before send). **Note on citation discipline:** explicit line numbers in `autosend-policy.yaml` shift across edits; this agent.md uses grep-anchors instead per the pattern established in xero R3 closure (commit `5228fa2`). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** Founder Decision D1 ACCEPTED 2026-05-31 as D1-B (Telegram shim) + package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`); the autosend-bridge **production wiring** (real Telegram Bot API + postgres approvals reader) still lands in Concierge W10-13 build slice. Until then, Cash Conductor cycle.sh Step 10 detects the absent `packages/utilities/autosend-bridge-telegram/dist/` directory and degrades to **drafts-only** mode — produces yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT emit the orange-tier `xero_reminder_send_customer` rows (per §8 fallback row).

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

Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'` (yellow tier per autosend-policy.yaml lookup — `tier` is NOT a top-level decision_log column; it is recorded inside the autosend-emitted payload by `_shared/hook-helpers.sh`'s `hh_decision_action`). Payload `reason`/`payload_preview` carries `match_confidence` + `match_dimensions` as a string; for queryable-structured match metadata, the W7-8 build slice extends `hh_decision_action` to emit structured payload fields OR writes a separate audit row.

### Output 2 — Payment-chase drafts (yellow tier internal; Cash Conductor INITIATES the orange-tier customer send via Concierge approval bridge)

For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type — grep `^  xero_reminder_send_customer:` in `agents/_shared/autosend-policy.yaml` to verify it's registered there under §ORANGE) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.

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
1. `phase='output'`, `output_type='chase_draft_generated'`. Per `_shared/hook-helpers.sh` `hh_decision_output(output_type, artefact_ref, reason)`: the payload jsonb only writes `{output_type, artefact_ref}` — the vault path goes in `artefact_ref` and is the canonical pointer. Additional draft metadata (`body_sha256`, `voice_score`, `escalation_position`, `days_overdue`, `amount_due`) is concatenated into the `reason` string parameter for human/operator-readable audit context. W7-8 build slice may extend `hh_decision_output` to write structured metadata fields if SQL-queryable access is needed for the weekly report aggregation; current shape captures the intent without forcing the helper extension.
2. `phase='action'`, `action_type='xero_reminder_draft_internal'` (yellow tier per autosend-policy.yaml lookup; grep `^  xero_reminder_draft_internal:` to verify) — this row records that Cash Conductor classified the draft as yellow-tier internal. Per `hh_decision_action(action_type, target, payload_hash, payload_preview)`: `target` carries the invoice_id; `payload_hash` is a stable hash of the draft body; `payload_preview` carries the same metadata string as row 1's reason for cross-row correlation.

When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml lookup; grep `^  xero_reminder_send_customer:` to verify; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).

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
      payload_hash, payload_preview) — yellow tier per autosend-policy.yaml
      lookup (grep `^  xero_reminder_draft_internal:` to verify)
    → hh_decision_action("xero_reminder_send_customer", "invoice:<id>",
      payload_hash, payload_preview) — orange tier per autosend-policy.yaml
      lookup (grep `^  xero_reminder_send_customer:` to verify); Cash
      Conductor owns this action_type and OPENS the orange-approval-bridge;
      Concierge handles autosend-bridge call to operator (D1 path per
      Founder Decision)

11. (Operator approves via Concierge's bridge → Concierge transports the
    send → Cash Conductor receives webhook + records state mutation)
    → The orange-tier `xero_reminder_send_customer` action row was
      written by Cash Conductor at Step 10 (Cash Conductor owns this
      action_type per autosend-policy.yaml lookup; agent: cash-conductor).
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
| **Founder Decision D1 (autosend orange-tier path) ACCEPTED 2026-05-31** as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md` | ✅ ACCEPTED |
| **Autosend bridge package scaffold** — `@ifos/autosend-bridge-telegram` lib + types + tests landed 2026-06-01 (commit `9b282d8`); Cash Conductor consumer wiring at cycle.sh Step 10 landed (commit `076e231`) | ✅ SCAFFOLDED (Cash Conductor side) |
| **Autosend bridge production wiring** — real Telegram Bot API + postgres approvals reader; Concierge W10-13 build delivers; blocking for orange-tier send activation | Concierge W10-13 build slice (per D1-B decision-doc §"Implementation surface") | ⏸ |
| Fallback (interim): cycle.sh Step 10 detects absent `packages/utilities/autosend-bridge-telegram/dist/` and runs in drafts-only mode (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` until W10-13 wiring activates) | v1.0 interim — active until W10-13 | n/a |

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

Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies via the cluster Fbis ratification run (`bash scripts/run-codex-ratification.sh --cluster Fbis`). Round-trip history: Day-20 W3 cluster E ratified the agent.md at the contract layer; cluster Fbis (2026-06-02) ratifies the bundle layer now that sibling files (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures) exist alongside.

Status flips Proposed → Accepted when:
- Cluster Fbis returns RATIFIED for this agent.md (in-flight as of 2026-06-02)
- Founder approves §9 Q1 + Q2 + Q4 + Q7 + Q8
- Q3 UX flow approved (operator re-auth path)

NOTE: D1 RESOLVED is NO LONGER a Proposed→Accepted blocker — D1 was Accepted 2026-05-31 as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md`, and the package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`). The autosend-bridge **production wiring** (real Telegram Bot API) remains a Concierge W10-13 deliverable; until then, Cash Conductor runs in drafts-only mode (interim — see §8 fallback row). The bridge wiring is an Accepted→In-Force blocker (build slice + first-production criterion below), not a Proposed→Accepted blocker.

Status flips Accepted → In Force when:
- W7-8 build slice replaces SKELETON TODOs across the bundle with live impl (sibling files exist; live wiring pending)
- Concierge W10-13 lands the autosend-bridge production wiring so orange-tier sends activate
- First production webhook processed end-to-end against migration-test tenant
- 30-day month-0 baseline measured for first pilot
- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
- Codex re-ratifies post-build via `review-agent-bundle.md` skill

Until then: this document is a forward-looking scaffold with all 6 bundle files + 3 fixtures present at the SKELETON layer.

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
I’ll verify the cited source anchors and sibling bundle state against the repository before deciding. The main risk here is citation drift or scaffold/production-status mismatch, so I’m checking those directly.
exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/agent.md | sed -n '1,260p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Cash Conductor — the FD's evenings back
     2	
     3	**Status:** Proposed.
     4	**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R17 closed §8 sibling files + D1/bridge prereqs + §3 audit-row signatures (4-row chase lifecycle sequence). R19 fixes (2026-05-24): split draft body out of decision_log payload into vault path (per ADR-002 vault/Postgres split), recent_edit schema R access cite correction, Stage 3 ESC code disambiguation. **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram approval-shim; `docs/decisions/2026-05-31-d1-founder-decision.md`); `@ifos/autosend-bridge-telegram` package scaffold landed 2026-06-01 (commit `9b282d8`); Cash Conductor consumer wiring landed (commit `076e231`). Remaining gates: Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice replacing the SKELETON TODOs with live impl + Concierge W10-13 build slice landing the autosend-bridge production wiring (Telegram Bot API + postgres approvals reader) so the orange-tier send path activates.
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
    18	> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type (registered in autosend-policy.yaml under §ORANGE; grep `^  xero_reminder_send_customer:` to verify); Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW — grep `^  xero_reminder_draft_internal:` to verify; internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (registered under §ORANGE — grep `^  xero_reminder_send_customer:`; consultant approval required before send). **Note on citation discipline:** explicit line numbers in `autosend-policy.yaml` shift across edits; this agent.md uses grep-anchors instead per the pattern established in xero R3 closure (commit `5228fa2`). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** Founder Decision D1 ACCEPTED 2026-05-31 as D1-B (Telegram shim) + package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`); the autosend-bridge **production wiring** (real Telegram Bot API + postgres approvals reader) still lands in Concierge W10-13 build slice. Until then, Cash Conductor cycle.sh Step 10 detects the absent `packages/utilities/autosend-bridge-telegram/dist/` directory and degrades to **drafts-only** mode — produces yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT emit the orange-tier `xero_reminder_send_customer` rows (per §8 fallback row).
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
    94	Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'` (yellow tier per autosend-policy.yaml lookup — `tier` is NOT a top-level decision_log column; it is recorded inside the autosend-emitted payload by `_shared/hook-helpers.sh`'s `hh_decision_action`). Payload `reason`/`payload_preview` carries `match_confidence` + `match_dimensions` as a string; for queryable-structured match metadata, the W7-8 build slice extends `hh_decision_action` to emit structured payload fields OR writes a separate audit row.
    95	
    96	### Output 2 — Payment-chase drafts (yellow tier internal; Cash Conductor INITIATES the orange-tier customer send via Concierge approval bridge)
    97	
    98	For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type — grep `^  xero_reminder_send_customer:` in `agents/_shared/autosend-policy.yaml` to verify it's registered there under §ORANGE) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
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
   118	1. `phase='output'`, `output_type='chase_draft_generated'`. Per `_shared/hook-helpers.sh` `hh_decision_output(output_type, artefact_ref, reason)`: the payload jsonb only writes `{output_type, artefact_ref}` — the vault path goes in `artefact_ref` and is the canonical pointer. Additional draft metadata (`body_sha256`, `voice_score`, `escalation_position`, `days_overdue`, `amount_due`) is concatenated into the `reason` string parameter for human/operator-readable audit context. W7-8 build slice may extend `hh_decision_output` to write structured metadata fields if SQL-queryable access is needed for the weekly report aggregation; current shape captures the intent without forcing the helper extension.
   119	2. `phase='action'`, `action_type='xero_reminder_draft_internal'` (yellow tier per autosend-policy.yaml lookup; grep `^  xero_reminder_draft_internal:` to verify) — this row records that Cash Conductor classified the draft as yellow-tier internal. Per `hh_decision_action(action_type, target, payload_hash, payload_preview)`: `target` carries the invoice_id; `payload_hash` is a stable hash of the draft body; `payload_preview` carries the same metadata string as row 1's reason for cross-row correlation.
   120	
   121	When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml lookup; grep `^  xero_reminder_send_customer:` to verify; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).
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
   254	      payload_hash, payload_preview) — yellow tier per autosend-policy.yaml
   255	      lookup (grep `^  xero_reminder_draft_internal:` to verify)
   256	    → hh_decision_action("xero_reminder_send_customer", "invoice:<id>",
   257	      payload_hash, payload_preview) — orange tier per autosend-policy.yaml
   258	      lookup (grep `^  xero_reminder_send_customer:` to verify); Cash
   259	      Conductor owns this action_type and OPENS the orange-approval-bridge;
   260	      Concierge handles autosend-bridge call to operator (D1 path per

exec
/bin/zsh -lc "rg --files agents/recruitment/cash-conductor agents/_shared docs | rg '(cash-conductor|escalation-codes|autosend-policy|voice-loader|vertical-schema|ULTRAPLAN|master|v1.0-kill|2026-05-31-d1|ADR-005|tenancy|operational-hygiene)'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/cash-conductor/cleanup.sh
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml
agents/recruitment/cash-conductor/fixtures/01-primary.yaml
agents/recruitment/cash-conductor/cycle.sh
agents/recruitment/cash-conductor/README.md
agents/recruitment/cash-conductor/tools.yaml
agents/recruitment/cash-conductor/validate.sh
agents/recruitment/cash-conductor/context.sh
agents/recruitment/cash-conductor/agent.md
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml
docs/verticals/recruitment/vertical-schema.yaml
docs/decisions/v1.0-kill-criterion.md
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md
docs/decisions/2026-05-31-d1-founder-decision.md
docs/runbooks/operational-hygiene-protocol.md
docs/specs/ULTRAPLAN.md
docs/architecture/tenancy-invariants.md
agents/_shared/autosend-policy.yaml
agents/_shared/escalation-codes.md
agents/_shared/voice-loader.sh
agents/_shared/tests/test-voice-loader.sh

exec
/bin/zsh -lc 'ls -la agents/recruitment/cash-conductor && find agents/recruitment/cash-conductor -maxdepth 2 -type f | sort' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
total 232
drwxr-xr-x@ 10 madsadmin  staff    320 Jun  2 13:33 .
drwxr-xr-x@  8 madsadmin  staff    256 May 24 10:46 ..
-rw-r--r--@  1 madsadmin  staff   1697 May 24 10:54 README.md
-rw-r--r--@  1 madsadmin  staff  39492 Jun  2 13:33 agent.md
-rw-r--r--@  1 madsadmin  staff   6426 Jun  1 14:39 cleanup.sh
-rw-r--r--@  1 madsadmin  staff   9323 Jun  1 14:35 context.sh
-rw-r--r--@  1 madsadmin  staff  22304 Jun  1 15:03 cycle.sh
drwxr-xr-x@  5 madsadmin  staff    160 Jun  1 14:38 fixtures
-rw-r--r--@  1 madsadmin  staff  12443 Jun  2 12:08 tools.yaml
-rw-r--r--@  1 madsadmin  staff  11207 Jun  1 14:26 validate.sh
agents/recruitment/cash-conductor/README.md
agents/recruitment/cash-conductor/agent.md
agents/recruitment/cash-conductor/cleanup.sh
agents/recruitment/cash-conductor/context.sh
agents/recruitment/cash-conductor/cycle.sh
agents/recruitment/cash-conductor/fixtures/01-primary.yaml
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml
agents/recruitment/cash-conductor/tools.yaml
agents/recruitment/cash-conductor/validate.sh

codex
I found the full bundle present, so this is not just a missing-file scaffold check. I’m now comparing the agent claims against the actual shared catalogues, schema supplements, and scripts where the ratification skill calls out mandatory verification.
exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/agent.md | sed -n '260,620p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   260	      Concierge handles autosend-bridge call to operator (D1 path per
   261	      Founder Decision)
   262	
   263	11. (Operator approves via Concierge's bridge → Concierge transports the
   264	    send → Cash Conductor receives webhook + records state mutation)
   265	    → The orange-tier `xero_reminder_send_customer` action row was
   266	      written by Cash Conductor at Step 10 (Cash Conductor owns this
   267	      action_type per autosend-policy.yaml lookup; agent: cash-conductor).
   268	      Concierge does NOT write its own action row for this — Concierge's
   269	      role is approval-bridge + transport, not action-row authorship.
   270	    → Concierge fires webhook back: chase_sent (transport completed)
   271	    → Cash Conductor updates `cash_conductor_invoices.last_chase_position`
   272	      and `last_chase_sent_at` (v0.3 schema-backed fields per migration §3)
   273	    → hh_decision_output("cash_conductor_chase_sent_recorded",
   274	      "invoice:<id>", "position:<N>; sent_at:<ISO>") — phase=output;
   275	      green-tier internal status marker recording state mutation completion
   276	
   277	12. (Mode=webhook only) Re-trigger eligibility check
   278	    → was this webhook also a "payment received" that just hit?
   279	    → re-run Step 5 to check if any chases-in-flight should be cancelled
   280	      (paid-since-draft-but-before-send race condition)
   281	    → if so: ESC_AUTOSEND_RACE → cancel chase draft (do NOT send)
   282	    → hh_decision_output("chase_cancellation_check", "invoice:<id>",
   283	      "cancelled:<bool>")
   284	
   285	13. Weekly report assembly (mode=weekly-report; runs Monday 06:00 UTC)
   286	    → query decision_log + accounting + bank feed for the 7-day window
   287	    → compute DSO metric (Gate B tracking)
   288	    → 6-section Markdown report per §3 Output 3
   289	    → write to /vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md
   290	    → hh_decision_output("weekly_report", report_path,
   291	      "dso_delta_days:<N>; sections:6")
   292	
   293	14. Session close
   294	    → update tenant_adapters.config.cash_conductor_last_run = now()
   295	    → hh_decision_action("cash_conductor_run_complete", "session:<session_id>",
   296	      payload_hash, "run_mode:<mode>; matches:<N>; chases:<N>; report:<bool>")
   297	      — hh_decision_action signature is (action_type, target, payload_hash,
   298	      payload_preview) per agents/_shared/hook-helpers.sh contract
   299	    → exit code 0
   300	```
   301	
   302	---
   303	
   304	## §5 — Gates
   305	
   306	### Gate A — validate.sh (hard-fail before action)
   307	
   308	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
   309	
   310	- **"chase email references correct invoice number AND correct amount AND correct contact"** (all three; AND not OR)
   311	- **"never proposes chase for an invoice that's been paid in last 24h"** (defence-in-depth re-query at draft time)
   312	- Voice classifier score ≥0.75 for position 1-2 chases; ≥0.80 for position 3
   313	- No PII outside firm boundary in chase body
   314	- Reconciliation match confidence ≥0.85 for auto-write (Stage 1-2 only)
   315	- Open Banking token ≥7 days from expiry (≤7d is blocking per ESC_OPEN_BANKING_TOKEN_AGING staged definition; ≤30d info + ≤14d warn are health-warning states that do NOT block Gate A, only signal upcoming reauth need)
   316	- Accounting auth refresh succeeded in Step 1
   317	
   318	Gate A failures fire either `ESC_AGENT_OUTPUT_SHAPE` (invoice/amount/paid-precondition miss; output-shape constraint) OR `ESC_ADDRESSEE_MISMATCH` (client_contact_email mismatch; blocking per catalogue §2.10 — explicit Cash Conductor invoice/chase addressee case). Draft stays in `/tmp` (auto-purged 24h); operator notified per the specific ESC route.
   319	
   320	**Honesty note (per bilateral-disposition Cat-5):** Cash Conductor `validate.sh` does NOT exist yet — this scaffold describes the intended Gate A contract for the W7 build slice. The W7 build delivers `agents/recruitment/cash-conductor/validate.sh` against the contract above. Current text is the spec the build slice implements against, not a description of running code.
   321	
   322	### Gate B — Outcome threshold (FD-tier closer metric)
   323	
   324	Per ULTRAPLAN A4 line 539 verbatim: **"tenant DSO at month-3 ≥ 12 days lower than month-0 baseline"**.
   325	
   326	DSO = Days Sales Outstanding = (Accounts Receivable / Total Credit Sales) × Number of Days.
   327	
   328	Measured monthly via the weekly report's §2 trend. Month-0 baseline established at first pilot LOI signing (before Cash Conductor active). Month-3 target = month-0 minus 12 days.
   329	
   330	This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
   331	
   332	---
   333	
   334	## §6 — Escalation codes
   335	
   336	Cash Conductor uses these ESC codes from `agents/_shared/escalation-codes.md`:
   337	
   338	| Code | Trigger | Severity | Routing |
   339	|---|---|---|---|
   340	| `ESC_ACCOUNTING_AUTH` | Xero/QuickBooks/Sage OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   341	| `ESC_ACCOUNTING_WRITE_FAIL` | Accounting 4xx/5xx on reconciliation write | warn | operator_chat_id |
   342	| `ESC_OPEN_BANKING_AUTH` | TrueLayer/Plaid UK auth fails after 2 retries | **blocking** | operator + ifos_oncall |
   343	| `ESC_OPEN_BANKING_TOKEN_AGING` | Open Banking PSD2 consent approaching 90-day expiry (staged) | info ≤30d / warn ≤14d / **blocking** ≤7d (per catalogue §2.7) | operator_chat_id (info+warn); + ifos_oncall_chat_id at blocking stage |
   344	| `ESC_RECONCILIATION_AMBIGUOUS` | Stage 4 fuzzy multi-candidate match within tolerance (per catalogue §2.10 — bank-feed payment line cannot match a single Xero invoice; multiple candidates) | warn | operator_chat_id |
   345	| (Stage 3 low-confidence single-match review queue) | Stage 3 single low-confidence exact-amount match queued for consultant review — NOT ESC_RECONCILIATION_AMBIGUOUS (catalogue defines ambiguity as multi-candidate, not low-confidence single). v0.3 W4-polish backlog: add ESC_RECONCILIATION_LOW_CONFIDENCE for single-match-low-confidence case OR widen ESC_RECONCILIATION_AMBIGUOUS catalogue trigger. | flagged in weekly report exception list (no ESC fire at v0.3) | (weekly report aggregation) |
   346	| `ESC_AUTOSEND_RACE` | Payment received between chase-draft and chase-send window | warn | operator_chat_id |
   347	| `ESC_VOICE_DRIFT` | Chase voice classifier below threshold after 3 retries | warn | operator_chat_id |
   348	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in chase body | **blocking** | operator + ifos_oncall |
   349	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A miss on invoice_number / amount_due / paid-invoice-precondition (NOT addressee mismatch — that uses ESC_ADDRESSEE_MISMATCH) | warn | operator_chat_id |
   350	| `ESC_ADDRESSEE_MISMATCH` | Gate A miss on client_contact_email / addressee resolution (per catalogue §2.10 Cash Conductor case) | **blocking** | operator + ifos_oncall |
   351	| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
   352	| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
   353	| `ESC_AUTOSEND_ORANGE_PENDING` | Chase draft awaiting consultant approval — heartbeat at ≥50% of declared timeout (per catalogue §2.9 trigger) | info | operator_chat_id (gentle reminder; no oncall CC) |
   354	
   355	Cash Conductor does NOT use:
   356	
   357	- Bullhorn-specific codes (no Bullhorn dependency)
   358	- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
   359	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Cash Conductor's Gate A misses are output-shape failures, not schema-field violations
   360	- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Cash Conductor fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
   361	
   362	---
   363	
   364	## §7 — Voice + tone constraints
   365	
   366	Step 8 (chase-draft generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   367	
   368	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
   369	  - No "Final demand" or legal-threatening language (escalation ladder caps at position 3; position 4 is operator-handled)
   370	  - No reference to the client's industry / sector pain points (chase is operational, not strategic)
   371	  - No mentions of late-payment fees unless tenant's terms explicitly state them
   372	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
   373	- **NOTE: Cash Conductor does NOT read `recent_edit`.** Per v0.3 supplement §2a access grants (line 729; recent_edit block at lines 721-731), Cash Conductor has W-only access — it WRITES recent_edit rows when consultants edit its chase drafts post-send, but does NOT READ them. Voice continuity for Cash Conductor relies on the tenant voice_corpus + tone_rule reads above. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries (LLM step internal to chase-draft generation; classifier scoring distinct from sample retrieval). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked by the canary (which has R access) for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
   374	
   375	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   376	
   377	---
   378	
   379	## §8 — Build dependencies (W7-8 prerequisites)
   380	
   381	Cash Conductor build cannot start until ALL of the following are confirmed:
   382	
   383	| Dependency | Source | Status |
   384	|---|---|---|
   385	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   386	| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
   387	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   388	| **Tenant's accounting choice confirmed** (Xero / QuickBooks / Sage) | Tenant onboarding | ⏸ |
   389	| **Accounting commercial signup** (developer access + sandbox) | Founder commercial | ⏸ |
   390	| **Open Banking commercial signup** (TrueLayer or Plaid UK) | Founder commercial; ~£100-300/mo | ⏸ |
   391	| Xero MCP connector | W7 build start (~2 days) | ⏸ |
   392	| QuickBooks MCP connector | W7 build start (~2 days) | ⏸ |
   393	| Sage MCP connector | W7 build start (~2 days; may defer if no pilot uses Sage v1.0) | ⏸ |
   394	| Open Banking MCP connector | W7 build start (~3 days; harder due to 90-day token rotation) | ⏸ |
   395	| Per-tenant accounting credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   396	| Per-tenant Open Banking credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   397	| Concierge agent.md ratified Accepted (for chase-send routing contract; full Concierge production-build at W10-13, but Cash Conductor only depends on the Concierge agent.md contract being Accepted, not the full bundle being In Force) | Post-Concierge agent.md re-ratification | ⏸ |
   398	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   399	| `validate.sh` Gate A logic | Build at W7 start (~1 day; complex due to 4 validators) | ⏸ |
   400	| `context.sh` hydration | Build at W7 start (~0.5 day) | ⏸ |
   401	| `cycle.sh` orchestration (14-step) | Build at W7 start (~3 days; most complex of v1.0 agents) | ⏸ |
   402	| `tools.yaml` MCP capability declarations (xero_oauth, quickbooks_oauth, sage_oauth, open_banking_truelayer / plaid, telegram_notify) | Build at W7 start (~1 day) | ⏸ |
   403	| `cleanup.sh` post-run state purge (transient OAuth tokens; provider rate-limit caches) | Build at W7 start (~0.5 day) | ⏸ |
   404	| 3 fixtures with golden outputs | Build at W7 start (~1 day) | ⏸ |
   405	| **Founder Decision D1 (autosend orange-tier path) ACCEPTED 2026-05-31** as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md` | ✅ ACCEPTED |
   406	| **Autosend bridge package scaffold** — `@ifos/autosend-bridge-telegram` lib + types + tests landed 2026-06-01 (commit `9b282d8`); Cash Conductor consumer wiring at cycle.sh Step 10 landed (commit `076e231`) | ✅ SCAFFOLDED (Cash Conductor side) |
   407	| **Autosend bridge production wiring** — real Telegram Bot API + postgres approvals reader; Concierge W10-13 build delivers; blocking for orange-tier send activation | Concierge W10-13 build slice (per D1-B decision-doc §"Implementation surface") | ⏸ |
   408	| Fallback (interim): cycle.sh Step 10 detects absent `packages/utilities/autosend-bridge-telegram/dist/` and runs in drafts-only mode (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` until W10-13 wiring activates) | v1.0 interim — active until W10-13 | n/a |
   409	
   410	**ADR-005 framing:** ADR-005 (Week-3 Diagnostic acceleration) notes Cash Conductor is unaffected by Bullhorn slips because it has zero Bullhorn dependency. v0.3 supplement: Cash Conductor pull-forward (from W7-8 to W4-5) is NOT explicitly authorised by ADR-005 §5.1 (that section number doesn't exist; earlier draft mis-cited). Pull-forward would require a separate ADR (e.g. ADR-007 if/when needed); accounting + Open Banking commercial signups remain founder-action gates regardless of timing.
   411	
   412	---
   413	
   414	## §9 — Status + open questions
   415	
   416	**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start.
   417	
   418	### Open questions for founder review
   419	
   420	| # | Question | Resolution path |
   421	|---|---|---|
   422	| Q1 | First-tenant accounting choice — Xero / QuickBooks / Sage? Affects which connector is W7-prio-1. | Tenant onboarding; depends on first pilot tenant's existing stack. |
   423	| Q2 | Open Banking provider — TrueLayer or Plaid UK? Both have UK coverage; TrueLayer slightly cheaper at low volume; Plaid has broader US-EU coverage for v1.1+ expansion. | Founder commercial. Recommend TrueLayer for v1.0 UK-only pilots. |
   424	| Q3 | Open Banking 90-day token rotation UX — when token nears expiry, operator must re-authenticate via tenant's bank login. How is this triggered? Telegram nudge? Brain UI dashboard? | Recommend: ESC_OPEN_BANKING_TOKEN_AGING fires Telegram nudge at 30/14/7 days; tenant-admin handles via Brain UI v1.1. |
   425	| Q4 | Chase escalation ladder — 4 positions proposed in §3.2. Founder confidence each position's timing + tone is right? | Founder review with first pilot tenant; varies by tenant's payment terms (net-30 vs net-14 vs net-60). |
   426	| Q5 | Reconciliation Stage 3-4 (fuzzy / ambiguous matches) — consultant review queue UX. Brain UI workflow? Telegram? | v1.0: weekly report exception list. v1.1: Brain UI per-row review queue. |
   427	| Q6 | DSO baseline establishment — month-0 baseline measured pre-deployment. How do we measure if accounting system data is incomplete or fragmented? | First pilot tenant: 30-day baseline measurement period BEFORE Cash Conductor goes live; documented in pilot LOI. |
   428	| Q7 | Hire #1 anchor — what specific Cash Conductor sub-tasks does Hire #1 take vs Claude Code? | Founder strategic decision; recommend Hire #1 owns Open Banking connector + ESC_OPEN_BANKING_TOKEN_AGING UX. Cash Conductor agent.md + cycle.sh stays with founder + Claude Code for consistency with other agents. |
   429	| Q8 | Sage connector — defer if no v1.0 pilot uses Sage? Saves ~2 days. Risk: blocks future Sage-using pilots. | Recommend defer to v1.1; document in W7 build start review. |
   430	
   431	### Gotchas (carried forward from ULTRAPLAN A4 line 541)
   432	
   433	1. **Open Banking auth is a 90-day token; rotation logic is non-trivial.** Plan for the rotation UX up-front; ESC_OPEN_BANKING_TOKEN_AGING staged at 30/14/7 days from expiry; document tenant-admin re-auth procedure.
   434	2. **Bank feed reconciliation against invoice register is the hard logic.** Start with exact-amount matches (Stage 1-2); expand to fuzzy (Stage 3-4) as confidence builds.
   435	3. **5 stages of match algorithm** is intentionally conservative for v1.0 to avoid false-positive reconciliation writes (which corrupt the tenant's accounting books).
   436	4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
   437	
   438	---
   439	
   440	## §10 — When this document ratifies
   441	
   442	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies via the cluster Fbis ratification run (`bash scripts/run-codex-ratification.sh --cluster Fbis`). Round-trip history: Day-20 W3 cluster E ratified the agent.md at the contract layer; cluster Fbis (2026-06-02) ratifies the bundle layer now that sibling files (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures) exist alongside.
   443	
   444	Status flips Proposed → Accepted when:
   445	- Cluster Fbis returns RATIFIED for this agent.md (in-flight as of 2026-06-02)
   446	- Founder approves §9 Q1 + Q2 + Q4 + Q7 + Q8
   447	- Q3 UX flow approved (operator re-auth path)
   448	
   449	NOTE: D1 RESOLVED is NO LONGER a Proposed→Accepted blocker — D1 was Accepted 2026-05-31 as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md`, and the package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`). The autosend-bridge **production wiring** (real Telegram Bot API) remains a Concierge W10-13 deliverable; until then, Cash Conductor runs in drafts-only mode (interim — see §8 fallback row). The bridge wiring is an Accepted→In-Force blocker (build slice + first-production criterion below), not a Proposed→Accepted blocker.
   450	
   451	Status flips Accepted → In Force when:
   452	- W7-8 build slice replaces SKELETON TODOs across the bundle with live impl (sibling files exist; live wiring pending)
   453	- Concierge W10-13 lands the autosend-bridge production wiring so orange-tier sends activate
   454	- First production webhook processed end-to-end against migration-test tenant
   455	- 30-day month-0 baseline measured for first pilot
   456	- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
   457	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   458	
   459	Until then: this document is a forward-looking scaffold with all 6 bundle files + 3 fixtures present at the SKELETON layer.
   460	
   461	*End of Cash Conductor agent.md draft.*

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '487,545p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   487	#### A1. The Diagnostic — the sales tool
   488	
   489	- **Build wave:** v1.0 (week 4–5)
   490	- **Always-on?** No — invoked on demand
   491	- **Trigger type:** Manual (run from CLI or sales-tool web page)
   492	- **CortexOS primitives required:** None — runs as a one-shot batch job
   493	- **MCP tools required:** Companies House, LinkedIn (read-only), web scraper for careers pages
   494	- **Shared modules required:** Voice loader (uses Maddox's voice for the audit narrative), decision log writer
   495	- **External APIs:** Companies House API (free), LinkedIn (via Proxycurl or similar), basic HTTP fetch
   496	- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
   497	- **Gate B target:** ≥30% of diagnostics produced lead to a discovery call booked
   498	- **Build complexity:** **M** (1 week)
   499	- **Gotchas:** LinkedIn ToS — we cannot store profile data beyond the audit. Companies House rate limits — cache aggressively.
   500	
   501	#### A2. The Janitor — the wedge agent
   502	
   503	- **Build wave:** v1.0 (week 5–6)
   504	- **Always-on?** Tier 2 — scheduled nightly cron
   505	- **Trigger type:** Cron 02:00 UTC daily; manual full-cleanup on demand
   506	- **CortexOS primitives required:** None (scheduled batch)
   507	- **MCP tools required:** Bullhorn (read-write), Companies House (for entity enrichment)
   508	- **Shared modules required:** Decision log writer, escalation router
   509	- **External APIs:** Bullhorn REST API, Companies House
   510	- **Gate A:** dedup confidence score ≥ 0.85 on every merge proposal; no merge proposed where candidate has had activity in last 90 days without explicit review flag
   511	- **Gate B target:** day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement
   512	- **Build complexity:** **L** (2 weeks) — the Bullhorn MCP work is the rate-limiting piece
   513	- **Gotchas:** Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0. Estimate 1 week for the MCP server, 1 week for the agent itself. Dedup is hard; start conservative (high-confidence merges only) and tune up.
   514	
   515	#### A3. The Scribe — the data spine
   516	
   517	- **Build wave:** v1.0 (week 6–7)
   518	- **Always-on?** Tier 2 — webhook-driven
   519	- **Trigger type:** Webhook from Fathom / Fireflies / Ringover when a call ends
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
/bin/zsh -lc "rg -n \"Cash Conductor|W7|week 7|Hire #1|DSO|8\\.2|Cash\" docs -g '*.md'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '1,220p' && rg -n \"xero_reminder|accounting_reconciliation|cash_conductor_run_complete\" agents/_shared/autosend-policy.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# IFOS auto-send policy (runtime table)
     2	#
     3	# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
     4	# Read by agents/_shared/hook-helpers.sh::autosend_policy_lookup() at every
     5	# hh_decision_action() invocation. Per-tenant overrides live in Postgres
     6	# tenant_adapters.config.tier_overrides (§8).
     7	#
     8	# 47 v1.0 action_types: 19 green + 10 yellow + 10 orange + 8 red.
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
    21	version: "v1.0-2026-05-24"
    22	
    23	action_types:
    24	
    25	  # ───────────────────────────────────────────────────────────
    26	  # GREEN — auto-send without review (19 action_types)
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
    65	  operator_notify_telegram:
    66	    tier: green
    67	    agent: all
    68	    reason: "Internal operator-only Telegram notification (escalations + run-complete markers); not customer-facing; idempotent within decision_log payload_hash dedup window"
    69	    irreversible: false
    70	
    71	  janitor_run_complete:
    72	    tier: green
    73	    agent: janitor
    74	    reason: "Internal run-complete status marker written to decision_log; no external comms; informational"
    75	    irreversible: false
    76	
    77	  scout_run_complete:
    78	    tier: green
    79	    agent: sourcing-scout
    80	    reason: "Internal run-complete status marker; no external comms"
    81	    irreversible: false
    82	
    83	  scribe_run_complete:
    84	    tier: green
    85	    agent: scribe
    86	    reason: "Internal run-complete status marker; no external comms"
    87	    irreversible: false
    88	
    89	  concierge_run_complete:
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
   121	    agent: all
   122	    reason: "Internal audit row written by validate.sh when Gate A enforcement fails. Carries the specific ESC code (e.g. ESC_AGENT_OUTPUT_SHAPE | ESC_PII_LEAKAGE_RISK) in the payload; the action itself is just the audit-row write, not an external send. Each agent's validate.sh emits this row before exit 1."
   123	    irreversible: false
   124	
   125	  diagnostic_input_invalid:
   126	    tier: green
   127	    agent: diagnostic
   128	    reason: "Internal audit row written by cycle.sh Step 1 when firm-name validation fails. Carries ESC_INPUT_VALIDATION_FAIL payload; just the audit-row write, not external send."
   129	    irreversible: false
   130	
   131	  diagnostic_generator_empty:
   132	    tier: green
   133	    agent: diagnostic
   134	    reason: "Internal audit row written by cycle.sh when @ifos/diagnostic-generator produces empty stdout. Carries ESC_AGENT_OUTPUT_SHAPE payload."
   135	    irreversible: false
   136	
   137	  linkedin_cache_purge_fail:
   138	    tier: green
   139	    agent: all
   140	    reason: "Internal audit row written by cleanup.sh when the transient LinkedIn /tmp cache cannot be purged (defense-in-depth per LinkedIn ToS gotcha; tools.yaml sets ttl=0 but explicit purge can still fail). Operator must manually verify cache cleared."
   141	    irreversible: false
   142	
   143	  diagnostic_cleanup:
   144	    tier: green
   145	    agent: diagnostic
   146	    reason: "Internal audit row written by cleanup.sh at end of normal-completion run. Records cache-purge status + workspace cleanup; no external comms."
   147	    irreversible: false
   148	
   149	  # ───────────────────────────────────────────────────────────
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
   181	  bullhorn_activity_log_write:
   182	    tier: green
   183	    agent: concierge
   184	    reason: "Internal Bullhorn activity-log entry — NOT customer-visible (separate from bullhorn_note_customer_visible which is orange). Maintains the audit trail in Bullhorn itself so downstream consultant ops see Concierge actions on the candidate's record. Idempotent within payload_hash dedup window. Registered per Codex Fbis-R1 closure 2026-06-02 — Concierge agent.md §4 Step 13 needs this for tier classification of the external write."
   185	    irreversible: false
   186	
   187	  # ───────────────────────────────────────────────────────────
   188	  # YELLOW — auto-send with 1-in-N spot-check (10 action_types)
   189	  # ───────────────────────────────────────────────────────────
   190	
   191	  bullhorn_candidate_dedupe:
   192	    tier: yellow
   193	    agent: janitor
   194	    sample_rate: 10
   195	    reason: "Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review"
   196	    irreversible: false
   197	
   198	  bullhorn_field_backfill:
   199	    tier: yellow
   200	    agent: janitor
   201	    sample_rate: 10
   202	    reason: "Fills missing canonical schema fields from Companies House or LinkedIn enrichment; reversible PATCH; high-volume; source provenance logged in payload"
   203	    irreversible: false
   204	
   205	  bullhorn_note_attach:
   206	    tier: yellow
   207	    agent: janitor
   208	    sample_rate: 20
   209	    reason: "Attaches tacit-note narrative summary harvested from decision_log recent_edit resolutions; consultant-visible; non-customer-facing; voice-classified before write"
   210	    irreversible: false
   211	
   212	  bullhorn_note_append_summary:
   213	    tier: yellow
   214	    agent: scribe
   215	    sample_rate: 20
   216	    reason: "Appends to candidate record; consultant-only visibility; high-volume; format quality needs review"
   217	    irreversible: false
   218	
   219	  linkedin_connection_request:
   220	    tier: yellow
107:  cash_conductor_run_complete:
226:  xero_reminder_draft_internal:
247:  accounting_reconciliation_write:
301:  xero_reminder_send_customer:

 succeeded in 0ms:
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:13:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 to 4 agents; founder solo through end of v1.0 | Active — not yet at trigger |
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
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
docs/architecture/agent-bundle-renderer-design.md:165:Concierge is the Tier-1 always-on candidate-lifecycle agent per master brief §8.2 A6 and Product Spec §2.2 R7. v1.0 build weeks 10-13. First user of the rendered output is the renderer's own integration test; production first-user is the first paid pilot in Q3 2026.
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/operations/goal-overnight-2026-05-31.md:62:- Cash Conductor bundle scaffold (depends on connectors landing first)
docs/operations/goal-overnight-2026-05-31.md:80:- Next step on pickup: cluster F manifest entry + Open Banking connector + Cash Conductor bundle
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:121:| Cash Conductor | ~5-7 (count regex 58) | `logs/codex-ratification/20260524T102316Z-...` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:163:5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:250:- autosend-policy.yaml: 29 → 41 action_types (8 status markers + 1 Cash Conductor reconciliation + 1 Concierge email draft + 2 added during Phase 2)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:263:- ULTRAPLAN line-number corrections: Cash Conductor A4 538/539/540/541 (not 539/540/541/542)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:275:| Cash Conductor | 5 | `20260524T113038Z-83732` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:285:- Cash Conductor master brief §8.2 line 597→598 with documented 12-day-vs-15-day drift acknowledgement
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:297:- `ESC_ADDRESSEE_MISMATCH` — Concierge uses for candidate email mismatch; catalogue defines for Cash Conductor invoice mismatch. Resolution: widen catalogue definition to cover both use cases (candidate vs invoice addressee resolution).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:300:- `ESC_OPEN_BANKING_TOKEN_AGING` — Cash Conductor uses <30 days warn / <7 days blocking staged; catalogue defines ≤14 days info. Resolution: align catalogue to Cash Conductor's actual staged definition.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:301:- `ESC_AUTOSEND_RACE` — Cash Conductor uses for payment-received-during-chase race; catalogue defines for two-agents-same-payload_hash race. Resolution: widen to cover both.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:317:  - Cash Conductor Steps 7-8, 11
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:332:- Cash Conductor: pre-build-scaffold; Round-8-reviewed; Postgres-table-creation (Cat-β) + catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:355:- `ESC_ADDRESSEE_MISMATCH` — now covers both Cash Conductor xero/bullhorn + Concierge candidate-email (mismatch_class field)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:358:- `ESC_OPEN_BANKING_TOKEN_AGING` — three staged behaviors aligned to Cash Conductor §6
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:373:| Cash Conductor | 5 | 5 | 0 (different findings; 1 Cat-γ closed, 1 new) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:429:| Cash Conductor | Pre-Build-Round-9-Reviewed | 5 (Cat-β + Cat-γ residual) | v0.3 + ESC widening 2 |
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
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:773:| Cash Conductor | 10:1 | reads invoice + placement + client on every chase; writes only on event |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:944:- **Week 13:** wiki-aware agent integration — Concierge (v1.0 A6, master brief §8.2) is the first user; voice-loader.sh from §2.4.3 reads `voice_samples_embedded` via the new library; first end-to-end Concierge run hits the wiki for `search-by-name` and `update-entity`. Brain UI minimal v1 (the "what did the agents do today" view from master brief §6 Day 3) is built as a thin read-only page over `decision_log` — no new wiki API needed.
docs/decisions/2026-05-18-codex-ratification-manifest.md:23:| 8 | `docs/decisions/sequencing-target.md` | Accepted (Option Alpha) | Verify 6-agent sequence against master brief §8.2; check §6.6 three failure conditions fold into kill criterion |
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:131:| 8 | `agents/recruitment/scribe/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 515-527 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:132:| 9 | `agents/recruitment/cash-conductor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 lines 529-542 + Hire-#1 anchor master brief line 604 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:133:| 10 | `agents/recruitment/sourcing-scout/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 599 + ULTRAPLAN §8.1 A5 lines 543-555 (note drift: ULTRAPLAN says W8-9, master brief says W9) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:8:## §1 Phase A — Cash Conductor bundle completion (~3h, 3-5 commits)
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:15:Closes goal-week-4-track-1.md §1 criteria 5-10. Cluster F-bis manifest entry queued (Cash Conductor agent-bundle skill) — actual entry to `run-codex-ratification.sh` lands at start of Day-27 when ready to fire cluster F + F-bis together.
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:25:- Fail-safe: timeout returns `{outcome: "timeout"}` not an exception — caller (Cash Conductor cycle.sh Step 10, Concierge cycle.sh) decides how to fire the ESC code
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:27:≥12 vitest (scaffold + config + propose + await with poll-mock + timeout + reject path + concurrent same-approval-id idempotency). Live Telegram tests gated `BRIDGE_LIVE_TESTS=true`. Zero credential interpolations in errors. README documents D1-B precedent + Concierge W10 integration contract + Cash Conductor `cycle.sh` Step 10 wiring.
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:47:Print: phase A/B/C status + commit SHAs · test counts (bridge: ≥12 vitest target) · Cash Conductor bundle 100% complete? · bridge package scaffold complete? · 2 polish items closed? · founder action board refresh · tomorrow's first action (cluster F + F-bis ratification triggers when founder ready; voice classifier microservice begins Tue scaffold).
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:18:> **10 calls per second concurrent throttle** (not enforced here — single-process Cash Conductor cycle.sh is serial)
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:20:Intuit's "10 concurrent calls per realmId" cap fires when ≥10 in-flight HTTP requests exist simultaneously against the same realm. Cash Conductor `cycle.sh` calls `@ifos/quickbooks` from a serial bash flow — `await` resolves before the next call is issued. The number of in-flight requests against any one realm at any moment is **exactly 1**. The concurrent throttle cannot be hit by definition.
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:37:The "not enforced here" caveat is right there in the rate-limit section. A future maintainer who switches Cash Conductor to a multi-process or concurrent caller has the explicit note to act on. This is honest signal, not omission.
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:43:- Cash Conductor cycle.sh becomes multi-process (e.g. one process per tenant running in parallel against the same QB realm — only realistic if a single IFOS tenant connects multiple QB realms or if we shift to a worker-pool model).
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:44:- A new consumer of `@ifos/quickbooks` lands that doesn't share Cash Conductor's serial-bash discipline (e.g. a webhook handler that batches concurrent invoice lookups).
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:51:Nothing functional. The README + `src/rate-limit.ts` module comment retain the "not enforced here; single-process Cash Conductor cycle.sh is serial" caveats (already present pre-Codex-review). No new code. No new test. No README edit — the existing language is the right disclosure.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:22:| 7-8 | Cash Conductor |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:31:- **Diagnostic has zero Bullhorn dependency** per master brief §8.2 line 595: "Diagnostic, Week 3-4. Dependencies: LinkedIn + Companies House + scrape. Sales tool — needed before any other agent matters."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:104:- Master brief §8.2 line 595 (Diagnostic = W3-4 build wave 1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:105:- Master brief §8.2 line 604 ("Do not build out of order" — we are not; Diagnostic stays first)
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
docs/decisions/2026-05-31-d1-founder-decision.md:22:| **D1-B** Lightweight Telegram shim | Concierge posts to operator's tenant-bound Telegram chat: `[ID:<x>] APPROVE drafted email to <recipient>? /approve <ID> or /reject <ID>`; Concierge polls Telegram or receives webhook; on approve → transport executes | <1 day build | Reuses cortextOS primitive #5 (Telegram surface) already in place; consultants are on Telegram already; lowest engineering cost; clean audit chain (every approve/reject = `decision_log` row); works the same for Cash Conductor + Concierge | Approval UX is a chat reply rather than a rich panel; per-draft attachment preview is just a 200-char text snippet + vault path; consultant must read the vault Markdown if they want to see the full draft body before approving |
docs/decisions/2026-05-31-d1-founder-decision.md:51:3. **Cash Conductor `cycle.sh` Step 10** — same `proposeApproval` call for `xero_reminder_send_customer` rows; identical handling.
docs/decisions/2026-05-31-d1-founder-decision.md:52:4. **`tools.yaml` capability declarations** — add `autosend_bridge_telegram` capability to both Concierge and Cash Conductor.
docs/decisions/2026-05-31-d1-founder-decision.md:64:- **Cash Conductor §8 D1-pending fallback** — flips from "drafts-only if unresolved" to "orange-tier `xero_reminder_send_customer` writes are live once Concierge W10-13 lands the autosend-bridge production wiring."
docs/decisions/2026-05-31-d1-founder-decision.md:76:**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commits `669a4f4` + `9ec2bd6`) — **in FUNCTION-ARG MODE only**, no `tenant_adapters.config.operator_telegram_chat_id` read attempts until the v0.4 schema supplement lands in the Concierge W10-13 build slice; Codex ratification currently in flight under cluster G (R2 closing 2026-06-02 per `docs/decisions/codex-disagreement-2026-06-02-*` ledger and the cluster G round-trip arc).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/codex-disagreement-2026-06-02-ob-plaid-internal-stub.md:45:`review-mcp-connector.md` §1 verbatim: "An MCP connector is a self-contained TypeScript workspace package that wraps a single upstream provider". The rule's intent is clear: don't smuggle multi-provider abstractions into per-connector scaffolds. Our case is DIFFERENT — the package wraps the **Open Banking PSD2 abstraction** (a regulatory abstraction), with TrueLayer + Plaid UK as alternative implementations of that abstraction. That's the design intent at the Cash Conductor consumer layer: the agent doesn't care which provider; it asks for "the open-banking data" and the connector dispatches.
docs/runbooks/day-4-provisioning.md:100:- v1.1+ multi-user: sudo password may be revisited when Hire #1 onboards (master brief Risk #4)
docs/runbooks/day-4-provisioning.md:1058:### §8.2 — Postgres-level: nightly pg_dump
docs/runbooks/day-4-provisioning.md:1065:# IFOS Postgres nightly backup — Day 4 runbook §8.2
docs/runbooks/day-4-provisioning.md:1133:- [ ] §8.2 — `/etc/cron.d/postgres-backup` exists; manual `pg_dump` test succeeded
docs/runbooks/day-4-provisioning.md:1158:| §8.2 backup | Manual `pg_dump` test fails | Check `/var/backups/postgres` ownership, disk space, Postgres user permissions; the cron will fail nightly until this works |
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:97:**Source:** `sequencing-target.md` §6.6 failure condition (iii); master brief §12 Risk #4 (Hire #1 mitigation calls for scope cut from 6 → 4 agents but explicitly warns against further cuts).
docs/decisions/v1.0-kill-criterion.md:148:**Source:** Day-4 runbook §1.4 founder-set cost budget (£20/mo for v1.0 single-tenant pilot; master brief does not specify a numeric cost target); Risk #4 in `docs/RISK-REGISTER.md` (Hire #1 delays compound infrastructure spend if architecture sprawls).
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:377:**For Risk Register.** Triggers 1, 2, 3, 5, 6, 7, 9, 10 each correspond to existing register entries (Risks #1-#8 in some combination). Risk #3 is updated in this Day-5 commit to reflect the Day-5 status. Risk #4 (Hire #1) is implicitly linked to Trigger 4 (scope cuts). Codex Day-7 ratification reviews the alignment between kill criterion triggers and risk register entries.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
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
docs/decisions/autosend-approval-bridge-spec.md:7:**Prerequisite for:** Concierge build (W10-13 per master brief §8.2)
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:85:| Cash Conductor | `xero_query_invoices` | Read-only against Xero; rate-limited via Xero's own quotas; no side effect |
docs/decisions/autosend-safety-policy.md:95:| Cash Conductor | `xero_reminder_draft_internal` | 1-in-10 | Generates reminder draft visible to consultant; not yet sent; format + tone needs review |
docs/decisions/autosend-safety-policy.md:107:| Cash Conductor | `xero_reminder_send_customer` | Outbound payment reminder to customer; reputation + collection risk |
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:70:- **First production render target:** Diagnostic agent (master brief §8.2 A1) at Week 4 per ADR-003 §"Consequences for Week 1 work".
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/2026-06-02-codex-cluster-f-r3-justification.md:25:| QB README "Cash Conductor full bundle lands later" wording | R2 (new) | Self-inflicted: the bundle landed yesterday (`5ab2f0f` Cash Conductor; `eb1f884` Concierge). Honest-signal drift caused by my own continued work. | Fix (update wording) |
docs/operations/founder-manual-playbook-2026-05-31.md:20:**Why first:** unblocks all v0.3 schema usage (Cash Conductor tables, Janitor dedup config, blocked_recipients, etc.). Without this, every downstream W4 build is just writing code against schema that doesn't exist on the live database.
docs/operations/founder-manual-playbook-2026-05-31.md:275:### 6.1 Xero developer account (~15 min) — unblocks live Cash Conductor test
docs/operations/founder-manual-playbook-2026-05-31.md:279:- Sign up → create an app called "IFOS Cash Conductor" → choose **Web App** flavour → set redirect URI to `https://migration-test.ifos.app/oauth/xero/callback` (placeholder; we'll wire properly at W4-5)
docs/operations/founder-manual-playbook-2026-05-31.md:298:- Cost: $39/mo for 5,000 credits (low-volume v1.0 sufficient; scales with usage — Cash Conductor §8 estimates $20-50/day at peak per consultant)
docs/operations/goal-week-4-track-1.md:1:# /goal — Week 4 Track 1: Cash Conductor MCP connectors + Diagnostic live polish
docs/operations/goal-week-4-track-1.md:5:**Master plan citations:** Master brief §8.2 (build wave W4 Cash Conductor MCP connectors) + ULTRAPLAN §8.1 A4 (Cash Conductor spec lines 531-545) + ADR-005 (Week-3 acceleration → Cash Conductor pulled forward to W4 substrate) + `agents/recruitment/cash-conductor/agent.md` §8 build dependencies + `docs/decisions/2026-05-31-d1-founder-decision.md` (D1-B resolved) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic live render by 2026-06-14).
docs/operations/goal-week-4-track-1.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §1 (five rules) + §3 (boundaries) + §8.2 W4-W7 rows + §10 (ratification cadence + always-ratify list) + §10.5
docs/operations/goal-week-4-track-1.md:18:4. **`docs/specs/ULTRAPLAN.md`** §8.1 A4 lines 531-545 (Cash Conductor spec) + §10 risk rows referencing Open Banking 90-day token rotation
docs/operations/goal-week-4-track-1.md:19:5. **`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`** (Cash Conductor pull-forward authorisation)
docs/operations/goal-week-4-track-1.md:20:6. **`docs/decisions/2026-05-31-d1-founder-decision.md`** (D1-B Telegram shim — affects Cash Conductor `xero_reminder_send_customer` flow)
docs/operations/goal-week-4-track-1.md:21:7. **`agents/recruitment/cash-conductor/agent.md`** in full (the output contract; §4 workflow shows the 14 steps Cash Conductor needs the connectors to fulfil)
docs/operations/goal-week-4-track-1.md:31:After reading: post in chat **"Read order complete. Five rules: [verbatim]. Four boundaries: [verbatim]. W4 Track 1 scope: Xero + QuickBooks + Open Banking MCP connectors + Cash Conductor bundle scaffold + Diagnostic live-smoke wrapper + review-mcp-connector Codex skill + cluster F manifest. Ready to begin Step 1."**
docs/operations/goal-week-4-track-1.md:43:3. **`packages/mcp-connectors/open-banking/`** exists; abstraction over TrueLayer + Plaid UK (provider chosen per-tenant config). Capabilities: `oauth_refresh` (90-day PSD2 consent), `list_transactions_since(last_ingested_at)`, `get_account_balance`. **Token-aging logic implemented**: emits `ESC_OPEN_BANKING_TOKEN_AGING` with `info`/`warn`/`blocking` staging per Cash Conductor §6 (≤30d/14d/7d). ≥15 vitest passing.
docs/operations/goal-week-4-track-1.md:44:4. **Sage MCP connector — DEFERRED** per Cash Conductor §9 Q8 recommendation; documented in W4-5 backlog as "rebuild at first pilot tenant on Sage."
docs/operations/goal-week-4-track-1.md:46:### Cash Conductor bundle scaffold (Day 5)
docs/operations/goal-week-4-track-1.md:57:11. **Cash Conductor agent.md `Status: Proposed`** unchanged — the agent.md was already RATIFIED by Codex R3; the bundle scaffold doesn't flip Status (production-readiness still gates on Hire #1 + accounting/Open Banking commercial signups per §8).
docs/operations/goal-week-4-track-1.md:91:| Xero MCP connector (fixture-first; OAuth scaffold) | §1 success criterion 1; Cash Conductor's most likely first-tenant accounting system |
docs/operations/goal-week-4-track-1.md:94:| Cash Conductor bundle scaffold (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures) | §1 criteria 5-10; agent.md is already RATIFIED, needs siblings |
docs/operations/goal-week-4-track-1.md:104:| Sage MCP connector | Cash Conductor §9 Q8 — defer to first-pilot-on-Sage trigger |
docs/operations/goal-week-4-track-1.md:107:| Cash Conductor live integration tests (against real Xero/QB sandbox) | Gated on founder commercial signups (item 10); fixture-first is the v1.0 ship gate |
docs/operations/goal-week-4-track-1.md:108:| `autosend-bridge-telegram` package | Reserved for Concierge W10 build slice per D1-B doc §"Implementation surface"; Cash Conductor cycle.sh degrades gracefully when absent (drafts-only mode) |
docs/operations/goal-week-4-track-1.md:265:### DAY 5 — Cash Conductor bundle scaffold
docs/operations/goal-week-4-track-1.md:305:Commit: `feat(codex-harness): add cluster F for W4 Track-1 connectors + Cash Conductor bundle`
docs/operations/goal-week-4-track-1.md:325:1. **`.agents/current-priorities.md`** — W4 Track 1 close section. List shipped artefacts. Update Open backlog: W4 Track 2 (Bullhorn-dependent agents — Janitor/Scribe) conditional on Bullhorn A+B Accepted; Cash Conductor full live test conditional on accounting/Open Banking commercial signups; Diagnostic live render gated on API keys.
docs/operations/goal-week-4-track-1.md:366:| Cash Conductor bundle integration with `autosend-bridge-telegram` blocked (package not yet built — that's Concierge W10) | cycle.sh degrades to drafts-only mode per agent.md §1 readiness caveat; documented and tested via fixture 01-primary |
docs/operations/goal-week-4-track-1.md:390:- Any reduction in Gate A strictness on the Cash Conductor bundle
docs/operations/goal-week-4-track-1.md:406:Add CLUSTERS[F] to `scripts/run-codex-ratification.sh`. 4 artefacts (3 connectors + Cash Conductor bundle).
docs/operations/goal-week-4-track-1.md:444:W4 TRACK 1 COMPLETE — Cash Conductor MCP CONNECTORS + DIAGNOSTIC LIVE-SMOKE WRAPPER
docs/operations/goal-week-4-track-1.md:452:Cash Conductor bundle:
docs/operations/goal-week-4-track-1.md:487:  ✓ ADR-005 — Cash Conductor pull-forward to W4 substrate
docs/operations/goal-week-4-track-1.md:488:  ✓ master brief §8.2 W4 row — Cash Conductor MCP connectors
docs/operations/goal-week-4-track-1.md:489:  ✓ ULTRAPLAN §8.1 A4 — Cash Conductor spec lines 531-545
docs/operations/goal-week-4-track-1.md:523:| 5 | Cash Conductor bundle integration test surface grows beyond fixture coverage | Medium | Three fixtures targeted at the highest-risk paths (happy / fuzzy-match-ambiguity / token-aging); broader integration coverage deferred to first-pilot-tenant phase |
docs/operations/goal-week-4-track-1.md:525:| 7 | Goal slippage past 7-day window | Low-medium | Open Banking is the longest step (~5 hours); if it slips, defer to Day-7 polish; ship Xero + QB + Cash Conductor scaffold + smoke wrapper first |
docs/operations/goal-week-4-track-1.md:539:**Day 7 (2026-06-05) is the soft target. Day 9 (2026-06-07) is the hard cutoff** (W5 Janitor build starts then per master brief §8.2 if Bullhorn A+B has Accepted). If Day 9 hits without completion, escalate to founder review + scope-cut decision.
docs/specs/ULTRAPLAN.md:4:**Audience:** Maddox first. Future co-founder / Hire #1 second. The senior engineer who reads this in week six and needs to know what to do without asking.
docs/specs/ULTRAPLAN.md:44:Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.
docs/specs/ULTRAPLAN.md:198:- `02-edge-case-*` — at least one. For Triage, this is "candidate withdrawal email". For Cash Conductor, "partial payment with wrong reference". For Watchtower, "AWR week 12 with intervening sickness break". The edge cases come from the workflow analysis document and the temp deep dive.
docs/specs/ULTRAPLAN.md:418:| Cash Conductor | Tenant's DSO at month-3 ≥ 12 days lower than month-0 baseline | DSO computed from accounting MCP every month; baseline captured at onboarding |
docs/specs/ULTRAPLAN.md:529:#### A4. Cash Conductor (real-time mode) — the FD's evenings back
docs/specs/ULTRAPLAN.md:531:- **Build wave:** v1.0 (week 7–8)
docs/specs/ULTRAPLAN.md:539:- **Gate B target:** tenant DSO at month-3 ≥ 12 days lower than month-0 baseline
docs/specs/ULTRAPLAN.md:571:### 8.2 v1.1 agents (seven, in build order)
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
docs/operations/goal-week-3-polish-and-scaffold.md:7:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:52:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:53:6. **`agents/recruitment/scribe/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A3 lines 518-527.
docs/operations/goal-week-3-polish-and-scaffold.md:54:7. **`agents/recruitment/cash-conductor/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 597 + ULTRAPLAN §8.1 A4 lines 533-545. NO Bullhorn dependency (Cash Conductor's independence is its strategic value per ADR-005).
docs/operations/goal-week-3-polish-and-scaffold.md:55:8. **`agents/recruitment/sourcing-scout/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 598 + ULTRAPLAN §8.1 A5 lines 547-558.
docs/operations/goal-week-3-polish-and-scaffold.md:56:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:61:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:95:| 5 agent.md scaffolds | Master brief §8.2 + ULTRAPLAN §8.1 |
docs/operations/goal-week-3-polish-and-scaffold.md:103:| Full agent BUILDS for any non-Diagnostic agent | Reserved for W4 (Cash Conductor) + W5+ (Bullhorn-touching). Week 3 = scaffold-only for the 5 new agent.md contracts. |
docs/operations/goal-week-3-polish-and-scaffold.md:105:| Cash Conductor MCP connectors (Xero, QuickBooks, etc.) | Reserved for W4 per ADR-005 |
docs/operations/goal-week-3-polish-and-scaffold.md:294:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:303:- **Build wave:** W5 per master brief §8.2 line 596
docs/operations/goal-week-3-polish-and-scaffold.md:332:- master brief §8.2 line 597 (Scribe row: "Scribe, Week 6, Fathom/Fireflies MCP + Bullhorn W, Post-call note in Bullhorn within 10 min")
docs/operations/goal-week-3-polish-and-scaffold.md:338:- **Build wave:** W6 per master brief §8.2 line 597
docs/operations/goal-week-3-polish-and-scaffold.md:340:- **§1 Output contract:** ingests transcript from Fathom or Fireflies (webhook-triggered within 30s of call end); extracts structured fields (placement-relevant: budget, deadline, sector, role-type, decision-criteria, next-steps); writes to Bullhorn entity (placement / brief / contact / candidate as appropriate); attaches tacit-note Markdown summary to Bullhorn entity. Within 10 min of call end per master brief §8.2 line 597.
docs/operations/goal-week-3-polish-and-scaffold.md:354:### DAY 18 — Cash Conductor agent.md scaffold (Step 10)
docs/operations/goal-week-3-polish-and-scaffold.md:359:- ULTRAPLAN §8.1 A4 lines 533-545 (Cash Conductor spec — note Hire #1 anchor at line 766)
docs/operations/goal-week-3-polish-and-scaffold.md:360:- master brief §8.2 line 597 (Cash Conductor row: "Cash Conductor, Week 7-8, Xero/QuickBooks/Sage + Open Banking, Hire-#1-anchored")
docs/operations/goal-week-3-polish-and-scaffold.md:361:- master brief §8.2 line 604 ("Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7 — verify, don't assume")
docs/operations/goal-week-3-polish-and-scaffold.md:362:- `vertical-schema.yaml` §3 agent_access_matrix Cash Conductor row
docs/operations/goal-week-3-polish-and-scaffold.md:363:- ADR-005 §5.1 (Cash Conductor independence from Bullhorn — strategic value)
docs/operations/goal-week-3-polish-and-scaffold.md:367:- **Build wave:** W7-8 per master brief §8.2 line 597 (Hire #1 anchor); MAY be pulled forward to W4-5 per ADR-005 contingency if Bullhorn delays continue
docs/operations/goal-week-3-polish-and-scaffold.md:370:- **§3 Output shape:** (a) reconciliation rows (invoice ↔ deposit matches; payment chase queue); (b) weekly cash-flow Markdown report; (c) orange-tier email drafts pending consultant approval (Concierge handles the actual send — Cash Conductor only drafts).
docs/operations/goal-week-3-polish-and-scaffold.md:373:- **§5 Gate B:** ≥95% invoice match accuracy (vs human spot-check) + ≥15% reduction in days-sales-outstanding (DSO) after 60 days operation.
docs/operations/goal-week-3-polish-and-scaffold.md:389:- master brief §8.2 line 598 (Sourcing Scout row: "Sourcing Scout, Week 9, LinkedIn + Bullhorn R")
docs/operations/goal-week-3-polish-and-scaffold.md:395:- **Build wave:** W9 per master brief §8.2 line 598
docs/operations/goal-week-3-polish-and-scaffold.md:415:- master brief §8.2 line 599 (Concierge row: "Concierge, Week 10-13, Bullhorn R+W + autosend orange")
docs/operations/goal-week-3-polish-and-scaffold.md:422:- **Build wave:** W10-13 per master brief §8.2 line 599 (4 weeks — most complex agent)
docs/operations/goal-week-3-polish-and-scaffold.md:461:1. **`.agents/current-priorities.md`** — Day-20 Week-3 close section. List shipped artefacts. Update Open backlog: Week 4 (Cash Conductor build OR Bullhorn-dependent agent depending on A+B status).
docs/operations/goal-week-3-polish-and-scaffold.md:591:2. **Every cited line number is verified.** Before commit, grep the cited content. If `master brief §8.2 line 597` is cited as "Cash Conductor row," verify line 597 actually says that.
docs/operations/goal-week-3-polish-and-scaffold.md:620:  Cash Conductor (W7-8):  <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:642:  ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/goal-week-3-polish-and-scaffold.md:650:    - Cash Conductor MCP connectors (Xero + QuickBooks + Sage + Open Banking)
docs/operations/goal-week-3-polish-and-scaffold.md:651:    - Cash Conductor build (full bundle)
docs/operations/goal-option-c-diagnostic-end-to-end.md:5:**Master plan citations:** Master brief §8.2 line 595 ("Diagnostic, Week 3-4. Sales tool — needed before any other agent matters"), ULTRAPLAN line 753-755 ("Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint. Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact."), `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14).
docs/operations/goal-option-c-diagnostic-end-to-end.md:17:3. **`docs/build-brief/00-MASTER-BRIEF.md`** §8.2 (build wave 1 = Diagnostic) + §6 Day 4-7 (verifying foundation state).
docs/operations/goal-option-c-diagnostic-end-to-end.md:79:| Bullhorn anything | Out of Diagnostic's dependency chain (master brief §8.2 line 595) |
docs/operations/goal-option-c-diagnostic-end-to-end.md:251:- **Context:** ULTRAPLAN §8.1 specifies Week 3 = Bullhorn MCP, Week 4 = Diagnostic. Bullhorn Sub-decisions A+B remain Proposed pending Bullhorn partnership response (sent 2026-05-23). Diagnostic has zero Bullhorn dependency per master brief §8.2 line 595.
docs/operations/goal-option-c-diagnostic-end-to-end.md:254:- **Cites:** master brief §8.2 line 595 + line 604, ULTRAPLAN line 752-755, sequencing-target.md §3.1 (build waves), v1.0-kill-criterion.md Trigger 2.
docs/operations/goal-w4-day-26-2026-06-01.md:18:8. Cluster F manifest entry in `scripts/run-codex-ratification.sh` — xero + quickbooks + open-banking via `mcp-connector` skill. Cash Conductor bundle queued for next manifest update when scaffold lands.
docs/operations/goal-w4-day-26-2026-06-01.md:21:9. Cash Conductor bundle skeletons — `cycle.sh` (14-step per agent.md §4) + `validate.sh` (Gate A per §5) + `tools.yaml`. Fixtures + `context.sh` + `cleanup.sh` deferred. Drafts-only graceful degradation when `autosend-bridge-telegram` absent (D1-B doc).
docs/operations/goal-w4-day-26-2026-06-01.md:37:Print: commits + SHAs · test counts per new package · Phase 1 ✓ + context-cost reduction · ECC patterns adopted (≤3) · Phase 2 status (qb / open-banking; partial OK) · Phase 3 reached? · founder action board refresh · tomorrow's first action: Cash Conductor bundle + cluster F run.
docs/operations/decision-log.md:59:- **Cash Conductor bundle scaffold** — cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures; depends on at least Xero + Open Banking landing
docs/operations/decision-log.md:60:- **Cluster F manifest add** — add Xero + QuickBooks + Open Banking + Cash Conductor to `scripts/run-codex-ratification.sh` and trigger founder-side ratification run
docs/operations/decision-log.md:77:- **Third attempt: SUCCESS.** Migration applied cleanly (BEGIN…41 DDL…in-migration smoke "v0.3 migration smoke passed"…COMMIT). Post-flight verification confirmed: both Cash Conductor tables present and `postgres`-owned (Day-12 compliant); `validate_voice_scores` trigger replaced by `validate_entities_data_v0_3`; `validate_tenant_adapters_config_v0_3` present.
docs/operations/decision-log.md:88:- **Cash Conductor `cash_conductor_transactions` + `cash_conductor_invoices` tables exist on live VPS** — the W4 Track-1 /goal can wire MCP connectors against real schema (not just fixtures).
docs/operations/decision-log.md:121:| 10 | Xero developer account | DEFERRABLE | gates live Cash Conductor test (scaffold proceeds fixture-first) |
docs/operations/decision-log.md:184:   - **Cash Conductor (2):** autosend line cites (182→188, 257→263); missing vault-write step
docs/operations/decision-log.md:237:| Cash Conductor | Pre-Build-Round-18-Bilateral-Confirmed | 3 | 0 (all in `9ae6874`) | Codex R19 re-ratification |
docs/operations/decision-log.md:254:  - Cash Conductor: R10-R17 (Pre-Build-Round-17-Reviewed; 3 last-mile)
docs/operations/decision-log.md:375:- ❌ Diagnostic W3-4 agent build (and all named v1.0 agent builds: Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/operations/decision-log.md:408:- `d64d1c5` (Step 10) Cash Conductor agent.md (377 lines)
docs/operations/decision-log.md:428:| Cash Conductor agent.md | REJECTED ~5-7 issues | Same |
docs/operations/decision-log.md:452:- ✓ master brief §8.2 — build sequence W3-W13 fully spec'd
docs/operations/decision-log.md:461:- Cash Conductor MCP connectors (Xero + QuickBooks + Sage + Open Banking)
docs/operations/decision-log.md:462:- Cash Conductor build (full bundle)
docs/operations/decision-log.md:483:- **Step 10** (`d64d1c5`) — Cash Conductor agent.md (377 lines) per ULTRAPLAN §8.1 A4 (W7-8 build wave; Hire #1 anchor)
docs/operations/decision-log.md:500:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: Proposed; ready for Codex Round 4 Phase 2
docs/operations/decision-log.md:502:Per master brief §8.2 + ULTRAPLAN §8.1, each scaffold cites verbatim:
docs/operations/decision-log.md:508:| Cash Conductor | W7-8 (Hire #1 anchor) | A4 lines 529-542 |
docs/operations/decision-log.md:517:- Cash Conductor MCP connectors (Xero + QuickBooks + Sage + Open Banking)
docs/operations/decision-log.md:936:  - Agent × Entity R/W matrix across all 6 v1.0 agents (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) — cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3
docs/operations/decision-log.md:1007:- Postgres 16.14 + pgvector 0.8.2 on the LUKS volume; data directory on `/dev/mapper/ifos_data`; service `is-enabled: disabled` at boot (LUKS-noauto conflict per §5.2 deviation 14); `ifos-unlock` starts it post-mount.
docs/operations/decision-log.md:1062:- `docs/decisions/sequencing-target.md` — 522 lines, 7 sections. **Accepted** Option Alpha (master brief §8.2 ratified)
docs/operations/decision-log.md:1159:- **Day 3 ratification**: master brief §8.2 sequence ratified verbatim — Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 (Hire-#1-anchored) → Sourcing Scout W9 → Concierge W10-13
docs/operations/w4-day-20-founder-runbook.md:111:4. Cash Conductor (3 findings) — depends on D1 decision documentation
docs/_supplementary/planning-phase-brief.md:196:**End state of week 7:** dashboard fully spec'd; CC1 build in full flight.
docs/operations/w4-bilateral-pass-6-agent-md.md:38:| 4 | Cash Conductor | 3 | Blocked partially by D1 (W4 #4) — pre-resolve docs-only items. |
docs/operations/w4-bilateral-pass-6-agent-md.md:134:## 4. Cash Conductor — `agents/recruitment/cash-conductor/agent.md`
docs/operations/w4-bilateral-pass-6-agent-md.md:146:  - **Codex says:** "Line 380 says Cash Conductor only depends on Concierge `agent.md` being Accepted, but lines 235-253 require Concierge to receive drafts, run the approval bridge, transport sends, and callback; line 244 also cites the unresolved D1 path. Add Founder Decision D1 resolved + autosend bridge/Concierge transport availability as explicit prerequisites, or rewrite §4 to use the existing shared autosend approval helper without Concierge."
docs/specs/PRODUCT-SPEC.md:73:#### R2. Real-Time Cash Conductor — the FD's evenings back
docs/specs/PRODUCT-SPEC.md:76:- **Revenue story:** "DSO drops by 15+ days. £40k–£120k of working capital unlocked for a mid-sized agency. One bad debt caught per quarter pays for the entire suite."
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
docs/_supplementary/PRD-autonomous-agent.md:1143:  "overall_score": 8.2,
docs/_supplementary/strategic-plan.md:394:### 8.2 Channels, ranked by realistic ROI for you
docs/_supplementary/execution-plan.md:237:## PHASE 3 — Platform Engineering Specs (target: end of week 7)
docs/_supplementary/execution-plan.md:648:You have strategy, architecture, and a working prototype. You are missing the *stuff a developer actually reads* — 95 discrete documents and decisions, organised into 7 sequenced phases. Start with the 18 Open Decisions this week. Then Phase 1's 10 artifacts until one real Proposal Builder works end-to-end. Then Phase 2's 12 agent bundles. Then Phase 3's 12 platform specs. By week 7 you have everything Claude Code needs to build; Phases 4–7 happen in parallel with and after the build. Tick boxes. Resist scope creep. Ship.
docs/build-brief/00-MASTER-BRIEF.md:465:- [ ] Hire #1 status one-liner
docs/build-brief/00-MASTER-BRIEF.md:591:### 8.2 The build order — v1.0 only
docs/build-brief/00-MASTER-BRIEF.md:598:| 4 | Cash Conductor | 7–8 | Xero + Open Banking | FD-tier closer; "DSO drops by 15 days" |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |
docs/build-brief/00-MASTER-BRIEF.md:846:| 4 | Hire #1 doesn't start until Q4 2026 | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); founder solo through end of v1.0 |

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '220,330p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   220	    tier: yellow
   221	    agent: sourcing-scout
   222	    sample_rate: 5
   223	    reason: "Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy"
   224	    irreversible: true
   225	
   226	  xero_reminder_draft_internal:
   227	    tier: yellow
   228	    agent: cash-conductor
   229	    sample_rate: 10
   230	    reason: "Generates reminder draft visible to consultant; not yet sent; format + tone needs review"
   231	    irreversible: false
   232	
   233	  bullhorn_note_draft_internal:
   234	    tier: yellow
   235	    agent: concierge
   236	    sample_rate: 10
   237	    reason: "Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate"
   238	    irreversible: false
   239	
   240	  bullhorn_scribe_field_write:
   241	    tier: yellow
   242	    agent: scribe
   243	    sample_rate: 10
   244	    reason: "Scribe writes structured fields (call outcome, next action, sentiment) to Bullhorn placement/candidate; reversible PATCH; high-volume; extraction quality needs ongoing review"
   245	    irreversible: false
   246	
   247	  accounting_reconciliation_write:
   248	    tier: yellow
   249	    agent: cash-conductor
   250	    sample_rate: 10
   251	    reason: "Cash Conductor writes payment-received reconciliation rows to tenant accounting system (Xero/QuickBooks/Sage). Match-confidence ≥0.85 (Stage 1-2 algorithm) only auto-writes; reversible via accounting undo; high-volume; reconciliation match quality needs ongoing review"
   252	    irreversible: false
   253	
   254	  concierge_email_draft:
   255	    tier: yellow
   256	    agent: concierge
   257	    sample_rate: 20
   258	    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
   259	    irreversible: false
   260	
   261	  # ───────────────────────────────────────────────────────────
   262	  # ORANGE — per-action human approval (10 action_types)
   263	  # ───────────────────────────────────────────────────────────
   264	
   265	  bullhorn_note_customer_visible:
   266	    tier: orange
   267	    agent: concierge
   268	    timeout: PT4H
   269	    reason: "CANONICAL ORANGE. Bullhorn Note with isExternal: true — customer-visible in their CRM; single send is irreversible (note in audit trail even if deleted)"
   270	    irreversible: true
   271	    canonical: true
   272	
   273	  gmail_outlook_send_to_candidate:
   274	    tier: orange
   275	    agent: concierge
   276	    timeout: PT4H
   277	    reason: "Outbound email to candidate; customer-facing; reputation effects"
   278	    irreversible: true
   279	
   280	  twilio_sms_send:
   281	    tier: orange
   282	    agent: concierge
   283	    timeout: PT30M
   284	    reason: "Outbound SMS; high-trust channel; cost-per-send; irreversible"
   285	    irreversible: true
   286	
   287	  calendar_invite_send:
   288	    tier: orange
   289	    agent: concierge
   290	    timeout: PT4H
   291	    reason: "Creates calendar event with attendee notification; visible to attendee"
   292	    irreversible: true
   293	
   294	  email_summary_to_customer:
   295	    tier: orange
   296	    agent: scribe
   297	    timeout: PT4H
   298	    reason: "Outbound email summarising call to customer; customer-facing; format-sensitive"
   299	    irreversible: true
   300	
   301	  xero_reminder_send_customer:
   302	    tier: orange
   303	    agent: cash-conductor
   304	    timeout: PT24H
   305	    reason: "Outbound payment reminder to customer; reputation + collection risk"
   306	    irreversible: true
   307	
   308	  diagnostic_email_send:
   309	    tier: orange
   310	    agent: diagnostic
   311	    timeout: PT4H
   312	    reason: "Outbound diagnostic report to prospect; sales-stage outreach; reputation"
   313	    irreversible: true
   314	
   315	  diagnostic_calendar_invite:
   316	    tier: orange
   317	    agent: diagnostic
   318	    timeout: PT4H
   319	    reason: "Books intro call with prospect; reputation + scheduling friction"
   320	    irreversible: true
   321	
   322	  linkedin_inmail_send:
   323	    tier: orange
   324	    agent: sourcing-scout
   325	    timeout: PT4H
   326	    reason: "Outbound InMail (paid credit); cost-per-send; customer-facing"
   327	    irreversible: true
   328	
   329	  bullhorn_placement_terminate:
   330	    tier: orange

exec
/bin/zsh -lc 'rg -n "hh_load_tone_rules|hh_load_voice_samples|recent_edit|cash_conductor|voice_corpus|applies_to_agents" agents/_shared/voice-loader.sh docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:15:#   hh_load_recent_edits   — query recent_edit for last N days
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:88:             AND (cardinality(applies_to_agents) = 0 OR '$(_hh_json_escape "${agent_name}")' = ANY(applies_to_agents))
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
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:18:# voice_corpus.text_chunks + per-entity voice classifier score fields.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:56:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:113:        notes: True for the version currently served to hh_load_voice_samples. Exactly one row per tenant has `is_active=true` (enforced via partial unique index).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:120:      Versioning matters because (1) tenants may want to roll back if a re-index degrades voice quality (Risk: bad embedding model selection), (2) the LoRA SFT corpus is derived from {voice_corpus, decision_log.agent_drafts} and needs a stable snapshot to train against, (3) audit answers "what voice was the agent grounded against on date X" via voice_corpus.version + agent.payload.policy_version_sha pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:125:      Per-tenant tone constraints expressed as rules. Read by hh_load_tone_rules at session start; constraints are surfaced to the agent as part of the context-assembly bundle (master brief §9). Distinct from voice_corpus: voice_corpus is implicit (semantic similarity); tone_rule is explicit (declarative).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:140:        notes: Stable slug, e.g. "no-i-hope-this-finds-you-well". Referenced by recent_edit when a rule fires.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:152:      applies_to_agents:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:186:      Tone rules are the explicit complement to voice_corpus's implicit grounding. v0.2 ships with ~5-15 rules per tenant (curated at onboarding). v1.1 grows the rule library based on recent_edit patterns (tenant-specific drift becomes a rule).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:189:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:195:      - Concierge (R — context-bundle includes recent edits per master brief §8.1 Change 1 hh_load_recent_edits)
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
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:374:    No new phase values needed. recent_edit writes piggy-back on existing `phase='action'` + `phase='gating_failed'` distinctions for the underlying autosend decision. tone_rule mutations write as decision_log with `agent_name='_tenant_admin'` + `phase='trigger'` per autosend §8 override propagation pattern.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:384:  Q11_voice_corpus_chunk_storage:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:386:      Should voice_corpus_chunks store the raw text alongside the embedding, or only the embedding + a pointer back to the source document in /vault/?
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:311:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:327:  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:328:  # voice_corpus_chunks is introduced separately around v0.2 supplement line
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:335:  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:409:  cash_conductor:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:577:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:584:      rationale) read voice_corpus for ANN-match exemplars. v0.2 only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:591:      Janitor agent.md §7 calls hh_load_tone_rules filtered by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:      applies_to_agents containing 'janitor' for tacit-note narrative
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:597:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:609:      Cash Conductor, Sourcing Scout (each writes its own recent_edit rows
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:620:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:638:      matched_invoice_id: {type: string, required: false, source: IFOS-derived, notes: "Logical reference (NOT DB-enforced FK) to cash_conductor_invoices.invoice_id when match_status='matched'; application-layer integrity check"}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:658:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:693:      W4 polish, production use of cash_conductor_invoices is GATED by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:694:      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:695:      per §3 cash_conductor_transactions.retention). Migration-test tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:700:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:707:    cash_conductor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:710:  voice_corpus_chunks:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:716:    cash_conductor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:725:    cash_conductor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:728:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:736:    cash_conductor: W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:739:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:743:    cash_conductor: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:746:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:750:    cash_conductor: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:764:  cash_conductor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:767:    set_by: cash_conductor
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:768:    read_by: [cash_conductor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:893:    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:902:      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:905:      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:920:      Smoke verification DO block confirms both cash_conductor_*
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:983:  Q4_cash_conductor_transactions_retention:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:998:      cash_conductor_transactions table is GATED by an explicit per-tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1040:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid

exec
/bin/zsh -lc 'for code in ESC_ACCOUNTING_AUTH ESC_ACCOUNTING_WRITE_FAIL ESC_OPEN_BANKING_AUTH ESC_OPEN_BANKING_TOKEN_AGING ESC_RECONCILIATION_AMBIGUOUS ESC_AUTOSEND_RACE ESC_VOICE_DRIFT ESC_PII_LEAKAGE_RISK ESC_AGENT_OUTPUT_SHAPE ESC_ADDRESSEE_MISMATCH ESC_GATE_B_MISS ESC_RATE_LIMIT_HIT ESC_AUTOSEND_ORANGE_PENDING ESC_AUTOSEND_BLOCKED ESC_SCHEMA_VIOLATION ESC_VOICE_DRIFT_TENANT; do rg -n "(''^##|''^###|'"\\"'`?$code'"\\"'`?|$code)" agents/_shared/escalation-codes.md; done' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
319:- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol
9:## §1 — How escalation codes work
28:## §2 — Catalogue (52 codes)
30:### 2.1 — Auto-send safety (3 codes)
33:#### `ESC_AUTOSEND_NEEDS_REVIEW`
41:#### `ESC_AUTOSEND_BLOCKED`
48:#### `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`
56:### 2.2 — Vault concurrency (5 codes)
59:#### `ESC_VAULT_LOCK_TIMEOUT`
66:#### `ESC_VAULT_VERSION_MISMATCH`
73:#### `ESC_VAULT_HUMAN_EDIT_BLOCKED`
80:#### `ESC_VAULT_CASCADE_PARTIAL_FAILURE`
87:#### `ESC_VAULT_CASCADE_TIMEOUT`
94:### 2.3 — Bullhorn integration (1 code)
97:#### `ESC_BULLHORN_AUTH`
105:### 2.4 — Renderer (1 code)
108:#### `ESC_RENDERER_FAILED`
117:### 2.5 — Recruitment-domain vocabulary (10 codes)
120:#### `ESC_VOICE_DRIFT`
127:#### `ESC_DUPLICATE_DETECTED`
134:#### `ESC_JSL_RED_FLAG`
141:#### `ESC_BRIEF_AMBIGUITY`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
177:#### `ESC_INPUT_VALIDATION_FAIL`
184:#### `ESC_AGENT_OUTPUT_SHAPE`
191:### 2.6 — Cross-cutting infrastructure (6 codes)
194:#### `ESC_HUMAN_EDITING_LOCK`
201:#### `ESC_VAULT_CONCURRENCY`
209:#### `ESC_VAULT_RENAME_RACE`
216:#### `ESC_CORTEXTOS_RESTART_REQUESTED`
223:#### `ESC_CORTEXTOS_HANDOFF`
230:#### `ESC_CORTEXTOS_DEGRADED`
237:### 2.7 — Upstream provider auth (8 codes)
240:#### `ESC_REED_AUTH`
248:#### `ESC_CVLIBRARY_AUTH`
256:#### `ESC_LINKEDIN_AUTH`
264:#### `ESC_GMAIL_AUTH`
272:#### `ESC_MS_GRAPH_AUTH`
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
307:### 2.8 — Provider read/write failures (4 codes)
310:#### `ESC_BULLHORN_WRITE_FAIL`
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
324:#### `ESC_PROVIDER_FETCH_FAIL`
331:#### `ESC_SEND_FAIL`
338:### 2.9 — Auto-send orchestration (4 codes)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
356:#### `ESC_AUTOSEND_RACE`
366:#### `ESC_AUTOSEND_SAMPLED_SPOT_CHECK`
374:### 2.10 — Agent workflow (10 codes)
377:#### `ESC_GATE_B_MISS`
385:#### `ESC_TONE_RULE_VIOLATION`
393:#### `ESC_FIELD_EXTRACTION_LOW_CONFIDENCE`
400:#### `ESC_CANDIDATE_DATA_INCOMPLETE`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`
424:#### `ESC_DNC_FILTER_HIT`
431:#### `ESC_CONCIERGE_SLA_MISS`
441:#### `ESC_SCRIBE_SLA_MISS`
448:#### `ESC_LIFECYCLE_STATE_UNKNOWN`
459:## §3 — Reserved codes (not-yet-wired)
470:## §4 — Wiring requirements (Phase 3 `hook-helpers.sh`)
483:## §5 — Change protocol

exec
/bin/zsh -lc 'rg -n "TODO|SKELETON|xero_reminder_send_customer|autosend-bridge|drafts-only|dist|cash_conductor_run_complete|hh_decision_action|hh_decision_output" agents/recruitment/cash-conductor/*.sh agents/recruitment/cash-conductor/tools.yaml agents/recruitment/cash-conductor/fixtures/*.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:13:# Per Stage 3 distinction (agent.md §6 row): single low-confidence exact-amount
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:18:# Status: Proposed (W4 Day-26 SKELETON).
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:93:      action_type: cash_conductor_run_complete
agents/recruitment/cash-conductor/tools.yaml:3:# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice may add per-tenant
agents/recruitment/cash-conductor/tools.yaml:15:# + xero_reminder_draft_internal + xero_reminder_send_customer; open_banking_*
agents/recruitment/cash-conductor/tools.yaml:62:    purpose: "QuickBooks OAuth 2.0 refresh (per-realm; PSD2-distinct from Xero per-tenant)"
agents/recruitment/cash-conductor/tools.yaml:130:  # public-API call sites have distinct audit + failure semantics:
agents/recruitment/cash-conductor/tools.yaml:138:    package: "@ifos/autosend-bridge-telegram"
agents/recruitment/cash-conductor/tools.yaml:141:    action_type: xero_reminder_send_customer  # ORANGE tier; REGISTERED at autosend-policy.yaml line 263; Cash Conductor OWNS this action_type per the same line
agents/recruitment/cash-conductor/tools.yaml:144:    optional: true  # cycle.sh Step 10 checks for the package dist/; falls back to drafts-only mode if absent (graceful degradation per agent.md §1 readiness caveat)
agents/recruitment/cash-conductor/tools.yaml:151:    package: "@ifos/autosend-bridge-telegram"
agents/recruitment/cash-conductor/tools.yaml:191:#   xero_reminder_send_customer        line 263   orange    [Cash Conductor OWNS this]
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:8:#   to Concierge approval bridge (if autosend-bridge-telegram present)
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:9:#   OR drafts-only mode (if bridge absent — per D1-B agent.md §1 caveat).
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:13:# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice wires the real
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:91:      action_type: cash_conductor_run_complete
agents/recruitment/cash-conductor/validate.sh:3:# (_fail + _warn are not invoked in the W4 Day-26 skeleton — TODO(W7-8)
agents/recruitment/cash-conductor/validate.sh:6:#  the TODOs without re-declaring helpers.)
agents/recruitment/cash-conductor/validate.sh:8:# Cash Conductor agent — validate.sh (Gate A enforcement; W4 Day-26 SKELETON)
agents/recruitment/cash-conductor/validate.sh:10:# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice completes the impl).
agents/recruitment/cash-conductor/validate.sh:111:# TODO(W7-8): parse draft YAML frontmatter; SELECT FROM cash_conductor_invoices
agents/recruitment/cash-conductor/validate.sh:116:_ok "G1: invoice/amount/contact triple-check — SKELETON (W7-8 wires the SQL)"
agents/recruitment/cash-conductor/validate.sh:123:# TODO(W7-8): @ifos/xero getInvoice OR @ifos/quickbooks getInvoice → check
agents/recruitment/cash-conductor/validate.sh:126:# hh_decision_action "validate_gate_a_fail" "invoice:<id>" "<hash>" "ESC_AGENT_OUTPUT_SHAPE; paid-in-24h"
agents/recruitment/cash-conductor/validate.sh:127:_ok "G2: not-paid-in-24h — SKELETON (W7-8 wires the accounting re-query)"
agents/recruitment/cash-conductor/validate.sh:134:# TODO(W7-8): parse draft YAML for voice_score + escalation_position; compare
agents/recruitment/cash-conductor/validate.sh:136:# + hh_decision_action validate_gate_a_fail.
agents/recruitment/cash-conductor/validate.sh:137:_ok "G3: voice classifier per-position threshold — SKELETON (W7-8 wires)"
agents/recruitment/cash-conductor/validate.sh:143:# TODO(W7-8): grep draft body for email patterns NOT matching the tenant's
agents/recruitment/cash-conductor/validate.sh:146:_ok "G4: no PII outside firm boundary — SKELETON (W7-8 wires firm-domain whitelist)"
agents/recruitment/cash-conductor/validate.sh:153:_ok "G5: reconciliation match-confidence ≥0.85 — SKELETON (W7-8 wires)"
agents/recruitment/cash-conductor/validate.sh:160:# TODO(W7-8): @ifos/open-banking loadTokens + getTokenAgeStage; if stage=="blocking"
agents/recruitment/cash-conductor/validate.sh:163:_ok "G6: Open Banking token ≥7d from PSD2 expiry — SKELETON (W7-8 wires)"
agents/recruitment/cash-conductor/validate.sh:170:_ok "G7: accounting auth refresh in this session — SKELETON (W7-8 wires)"
agents/recruitment/cash-conductor/validate.sh:179:  # TODO(W7-8): per-failure routing — different ESC code per failure class
agents/recruitment/cash-conductor/validate.sh:183:  # hh_decision_action "validate_gate_a_fail" "tenant:${CTX_TENANT_SLUG}" payload_hash \
agents/recruitment/cash-conductor/context.sh:2:# Cash Conductor agent — context.sh (hydration; W4 Day-26 SKELETON)
agents/recruitment/cash-conductor/context.sh:4:# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice replaces stubs with
agents/recruitment/cash-conductor/context.sh:76:# TODO(W7-8): SELECT config->>'accounting_provider', config->>'open_banking_provider'
agents/recruitment/cash-conductor/context.sh:89:# TODO(W7-8): replace skeleton stubs with real voice-loader calls. Skeleton
agents/recruitment/cash-conductor/context.sh:96:# TODO(W7-8): CTX_TONE_RULES=$(hh_load_tone_rules "cash_conductor" 2>/dev/null || echo "[]")
agents/recruitment/cash-conductor/context.sh:97:# TODO(W7-8): CTX_TONE_RULES_COUNT=$(echo "${CTX_TONE_RULES}" | jq 'length')
agents/recruitment/cash-conductor/context.sh:103:# TODO(W7-8): CTX_VOICE_CORPUS_ID=$(hh_load_voice_samples "${CTX_TENANT_SLUG}" "chase-email" 2>/dev/null)
agents/recruitment/cash-conductor/context.sh:118:# TODO(W7-8): node -e "import('@ifos/open-banking').then(ob => {
agents/recruitment/cash-conductor/context.sh:132:# TODO(W7-8): query Postgres via the daemon
agents/recruitment/cash-conductor/cleanup.sh:2:# Cash Conductor agent — cleanup.sh (post-run state purge; W4 Day-26 SKELETON)
agents/recruitment/cash-conductor/cleanup.sh:4:# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice replaces stubs with
agents/recruitment/cash-conductor/cleanup.sh:83:# TODO(W7-8): replace these STUB counts with actual find -delete invocations
agents/recruitment/cash-conductor/cleanup.sh:107:# TODO(W7-8): once cash_conductor_cleanup action_type is registered in
agents/recruitment/cash-conductor/cleanup.sh:109:# from hh_decision_output to hh_decision_action for proper tier classification.
agents/recruitment/cash-conductor/cleanup.sh:110:hh_decision_output "cash_conductor_cleanup" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/cash-conductor/cleanup.sh:111:  "xero_cache_purged:${XERO_PURGED}; qb_cache_purged:${QB_PURGED}; ob_cache_purged:${OB_PURGED}; total:${TOTAL_PURGED}; mode:SKELETON"
agents/recruitment/cash-conductor/cleanup.sh:114:printf '[cash-conductor cleanup.sh] tenant=%s purged total=%d (xero=%d qb=%d ob=%d) mode=SKELETON\n' \
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:20:# Status: Proposed (W4 Day-26 SKELETON).
agents/recruitment/cash-conductor/cycle.sh:4:# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice replaces stubs with
agents/recruitment/cash-conductor/cycle.sh:28:#      Cash Conductor OWNS the orange xero_reminder_send_customer action_type
agents/recruitment/cash-conductor/cycle.sh:98:# TODO(W7-8): replace this STUB with actual provider refresh calls. Skeleton
agents/recruitment/cash-conductor/cycle.sh:100:hh_decision_output "auth_refresh_complete" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/cash-conductor/cycle.sh:114:hh_decision_output "mode_routed" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/cash-conductor/cycle.sh:125:  # TODO(W7-8): @ifos/open-banking listTransactionsSince(since=last_ingested_at)
agents/recruitment/cash-conductor/cycle.sh:127:  hh_decision_output "transactions_ingested" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/cash-conductor/cycle.sh:138:  # TODO(W7-8): provider-aware (tenant_adapters.config.accounting_provider)
agents/recruitment/cash-conductor/cycle.sh:140:  hh_decision_output "invoices_ingested" "tenant:${CTX_TENANT_SLUG}" "STUB rows"
agents/recruitment/cash-conductor/cycle.sh:150:  # TODO(W7-8): match algorithm per agent.md §3 stages 1-5. SQL JOIN against
agents/recruitment/cash-conductor/cycle.sh:152:  hh_decision_output "reconciliation_pass" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/cash-conductor/cycle.sh:163:  # TODO(W7-8): per-match: accounting.writePaymentReceived(...) → emit per write
agents/recruitment/cash-conductor/cycle.sh:164:  # hh_decision_action "accounting_reconciliation_write" "invoice:<id>" payload_hash payload_preview
agents/recruitment/cash-conductor/cycle.sh:165:  # On failure: ESC_ACCOUNTING_WRITE_FAIL via hh_decision_action validate_gate_a_fail
agents/recruitment/cash-conductor/cycle.sh:176:  # TODO(W7-8): SELECT overdue invoices; determine chase position 1-4 per §3.2;
agents/recruitment/cash-conductor/cycle.sh:177:  #             if position=4 → hh_decision_output "chase_position_4_operator_review" + STOP
agents/recruitment/cash-conductor/cycle.sh:178:  hh_decision_output "chase_pass_complete" "tenant:${CTX_TENANT_SLUG}" "STUB candidates"
agents/recruitment/cash-conductor/cycle.sh:191:  # TODO(W7-8): LLM call → write draft body to vault → emit:
agents/recruitment/cash-conductor/cycle.sh:192:  # hh_decision_output "chase_draft_generated" "invoice:<id>" \
agents/recruitment/cash-conductor/cycle.sh:203:  # TODO(W7-8): per draft → bash validate.sh <draft_path>; exit on fail.
agents/recruitment/cash-conductor/cycle.sh:210:# Cash Conductor OWNS xero_reminder_send_customer action_type per autosend-policy.yaml
agents/recruitment/cash-conductor/cycle.sh:211:# line 263; Concierge handles autosend-bridge-telegram approval routing + transport.
agents/recruitment/cash-conductor/cycle.sh:212:# Drafts-only graceful degradation when autosend-bridge-telegram package absent
agents/recruitment/cash-conductor/cycle.sh:220:  # TODO(W7-8): per draft iteration:
agents/recruitment/cash-conductor/cycle.sh:221:  #   hh_decision_action "xero_reminder_draft_internal" "invoice:${INVOICE_ID}" \
agents/recruitment/cash-conductor/cycle.sh:224:  if [[ -d "${IFOS_REPO_ROOT:-}/packages/utilities/autosend-bridge-telegram/dist" ]]; then
agents/recruitment/cash-conductor/cycle.sh:228:    # Production-shape call site (SKELETON; W7-8 build slice wires the per-draft
agents/recruitment/cash-conductor/cycle.sh:230:    # packages/utilities/autosend-bridge-telegram/bin/{propose,await}.ts and
agents/recruitment/cash-conductor/cycle.sh:237:    #    deadline. Package: @ifos/autosend-bridge-telegram (proposeApproval).
agents/recruitment/cash-conductor/cycle.sh:239:    #    PROPOSE_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/propose.ts" \
agents/recruitment/cash-conductor/cycle.sh:240:    #      --action xero_reminder_send_customer \
agents/recruitment/cash-conductor/cycle.sh:250:    # 2. Emit ORANGE-tier audit row — Cash Conductor OWNS xero_reminder_send_customer
agents/recruitment/cash-conductor/cycle.sh:253:    #    hh_decision_action "xero_reminder_send_customer" "invoice:${INVOICE_ID}" \
agents/recruitment/cash-conductor/cycle.sh:258:    #    Package: @ifos/autosend-bridge-telegram (awaitApprovalDecision).
agents/recruitment/cash-conductor/cycle.sh:260:    #    AWAIT_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/await.ts" \
agents/recruitment/cash-conductor/cycle.sh:272:    #        hh_decision_output "approval_rejected" "invoice:${INVOICE_ID}" \
agents/recruitment/cash-conductor/cycle.sh:278:    #        hh_decision_action "validate_gate_a_fail" "invoice:${INVOICE_ID}" \
agents/recruitment/cash-conductor/cycle.sh:282:    : # TODO(W7-8): wire the per-draft loop above (steps 1–4); tsx CLI entrypoints land alongside in the same build slice
agents/recruitment/cash-conductor/cycle.sh:284:    # Bridge package ABSENT (dist/ missing) — drafts-only graceful degradation.
agents/recruitment/cash-conductor/cycle.sh:287:    hh_decision_output "drafts_only_mode" "tenant:${CTX_TENANT_SLUG}" \
agents/recruitment/cash-conductor/cycle.sh:288:      "autosend-bridge-telegram package dist/ not present — drafts retained in vault for manual consultant pickup; build the package (pnpm --filter @ifos/autosend-bridge-telegram build) to enable the D1-B send path"
agents/recruitment/cash-conductor/cycle.sh:300:  # TODO(W7-8): webhook-driven; UPDATE cash_conductor_invoices SET ...
agents/recruitment/cash-conductor/cycle.sh:301:  # hh_decision_output "cash_conductor_chase_sent_recorded" "invoice:<id>" "position:<N>; sent_at:<ISO>"
agents/recruitment/cash-conductor/cycle.sh:312:  # TODO(W7-8): re-query Step 5 for paid-since detection; ESC_AUTOSEND_RACE
agents/recruitment/cash-conductor/cycle.sh:313:  # hh_decision_output "chase_cancellation_check" "invoice:<id>" "cancelled:<bool>"
agents/recruitment/cash-conductor/cycle.sh:324:  # TODO(W7-8): SELECT decision_log + cash tables for 7-day window; compute
agents/recruitment/cash-conductor/cycle.sh:328:  printf '# Weekly cash-flow report — STUB\n\nTODO(W7-8): full §3 Output 3 6-section report.\n' > "${REPORT_PATH}" 2>/dev/null || true
agents/recruitment/cash-conductor/cycle.sh:329:  hh_decision_output "weekly_report" "${REPORT_PATH}" \
agents/recruitment/cash-conductor/cycle.sh:339:# TODO(W7-8): UPDATE tenant_adapters SET config = jsonb_set(config, '{cash_conductor_last_run}', '"<ISO>"')
agents/recruitment/cash-conductor/cycle.sh:342:hh_decision_action "cash_conductor_run_complete" "session:${CTX_TENANT_SLUG}" "stub-hash" \

codex
The first concrete mismatch is an honest-signal problem: the document says `validate.sh` does not exist, while the bundle includes it. I’m checking whether that is isolated wording or part of a broader mismatch between the document’s claimed bundle state and the files on disk.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '620,775p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   691	    enforcement_gate: |
   692	      Until pseudonymization + 90d-cancelled-purge implementation lands as
   693	      W4 polish, production use of cash_conductor_invoices is GATED by
   694	      explicit per-tenant DPA addendum (same gate as cash_conductor_transactions
   695	      per §3 cash_conductor_transactions.retention). Migration-test tenant
   696	      data is exempt; pilot tenants require the DPA addendum signed before
   697	      go-live.
   698	
   699	auxiliary_table_access_matrix:
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
   773	  concierge_last_poll:
   774	    type: timestamp
   775	    required: false

exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '280,430p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/cycle.sh | sed -n '1,370p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Cash Conductor agent — cycle.sh (14-step orchestration)
     3	#
     4	# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice replaces stubs with
     5	#         full package wiring per agent.md §4).
     6	# Reading order: agent.md §1 (output contract) + §3 (3 outputs) + §4 (this
     7	#         workflow's 14 steps) + §5 (Gate A) first.
     8	#
     9	# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
    10	# produces output OR takes action MUST call hh_decision_* from
    11	# agents/_shared/hook-helpers.sh.
    12	#
    13	# Invocation modes (per agent.md §2):
    14	#   mode=webhook       — Open Banking / accounting webhook event-driven (primary)
    15	#   mode=daily-sweep   — cron 07:00 UTC: bank-feed catch-up + invoice age scan
    16	#   mode=weekly-report — cron Mon 06:00 UTC: cash-flow report regeneration
    17	#   mode=manual        — ifosctl cash-conductor reconcile|draft-chase|weekly-report
    18	#
    19	# Package dependencies (W4 Day-25/26 scaffolded; v0.1.0 fixture-first):
    20	#   @ifos/xero            — Xero accounting provider
    21	#   @ifos/quickbooks      — QuickBooks accounting provider
    22	#   @ifos/open-banking    — TrueLayer + Plaid UK bank-feed
    23	#   @ifos/companies-house — addressee resolution (cached Bullhorn placement client lookup)
    24	#
    25	# Output contract per agent.md §1 (READ THAT FIRST). Triple write surface:
    26	#   1. Reconciliation rows → accounting system (yellow tier accounting_reconciliation_write)
    27	#   2. Chase drafts → vault + decision_log (yellow xero_reminder_draft_internal;
    28	#      Cash Conductor OWNS the orange xero_reminder_send_customer action_type
    29	#      per autosend-policy.yaml line 263; Concierge handles approval-bridge transport
    30	#      per D1-B Telegram shim — docs/decisions/2026-05-31-d1-founder-decision.md)
    31	#   3. Weekly cash-flow report → /vault/<tenant>/cash-conductor-reports/weekly-<ISO>.md
    32	
    33	set -euo pipefail
    34	
    35	# ────────────────────────────────────────────────────────────────────────
    36	# Pre-flight: hydrate context + resolve _shared/ helpers
    37	# ────────────────────────────────────────────────────────────────────────
    38	
    39	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    40	  printf 'cash-conductor/cycle.sh: CTX_AGENT_DIR unset\n' >&2
    41	  exit 2
    42	fi
    43	if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
    44	  printf 'cash-conductor/cycle.sh: CTX_TENANT_SLUG unset\n' >&2
    45	  exit 2
    46	fi
    47	: "${CTX_AGENT_NAME:=cash-conductor}"
    48	
    49	# Resolve _shared/ helpers (rendered location OR repo source-tree fallback —
    50	# 4-candidate chain copied from agents/recruitment/diagnostic/validate.sh per
    51	# the smoke-hotfix pattern landed at commit d7d52c5).
    52	_SHARED_DIR=""
    53	for _candidate in \
    54	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    55	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    56	  "${CTX_AGENT_DIR}/../../_shared" \
    57	  "${CTX_AGENT_DIR}/../_shared" ; do
    58	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    59	    _SHARED_DIR="${_candidate}"
    60	    break
    61	  fi
    62	done
    63	if [[ -z "${_SHARED_DIR}" ]]; then
    64	  printf 'cycle.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
    65	  exit 1
    66	fi
    67	# shellcheck source=/dev/null
    68	source "${_SHARED_DIR}/hook-helpers.sh"
    69	
    70	# Mode dispatch (default = manual; tools.yaml capability invocation passes --mode)
    71	MODE="manual"
    72	INVOICE_ARG=""
    73	while [[ $# -gt 0 ]]; do
    74	  case "$1" in
    75	    --mode)     MODE="${2:-}"; shift 2 ;;
    76	    --invoice)  INVOICE_ARG="${2:-}"; shift 2 ;;
    77	    *)          shift ;;
    78	  esac
    79	done
    80	# INVOICE_ARG: parsed for future per-invoice scoped runs (manual mode); not yet
    81	# consumed by the W4 Day-26 skeleton — wired at W7-8 build slice.
    82	export INVOICE_ARG
    83	
    84	# ────────────────────────────────────────────────────────────────────────
    85	# Step 0 — Session start
    86	# ────────────────────────────────────────────────────────────────────────
    87	
    88	hh_decision_trigger "session_start" "cash-conductor mode=${MODE}"
    89	
    90	# ────────────────────────────────────────────────────────────────────────
    91	# Step 1 — Provider auth refresh (accounting + Open Banking)
    92	# Reference: agent.md §4 Step 1; emits ESC_ACCOUNTING_AUTH /
    93	# ESC_OPEN_BANKING_AUTH / ESC_OPEN_BANKING_TOKEN_AGING (staged) on failure.
    94	# W7-8 wires: @ifos/xero (or quickbooks) refreshTokens +
    95	#             @ifos/open-banking refreshTokens (with getTokenAgeStage check).
    96	# ────────────────────────────────────────────────────────────────────────
    97	
    98	# TODO(W7-8): replace this STUB with actual provider refresh calls. Skeleton
    99	# emits the audit row shape that the full implementation will preserve.
   100	hh_decision_output "auth_refresh_complete" "tenant:${CTX_TENANT_SLUG}" \
   101	  "accounting:STUB; open_banking:STUB; token_aging_stage:STUB"
   102	
   103	# ────────────────────────────────────────────────────────────────────────
   104	# Step 2 — Event router (mode-dependent)
   105	# ────────────────────────────────────────────────────────────────────────
   106	
   107	case "${MODE}" in
   108	  webhook)        STEPS_TO_RUN="3 4 5 6 7 8 9 10 11 12 14" ;;
   109	  daily-sweep)    STEPS_TO_RUN="3 4 5 6 7 8 9 10 11 14" ;;
   110	  weekly-report)  STEPS_TO_RUN="13 14" ;;
   111	  manual)         STEPS_TO_RUN="3 4 5 6 7 8 9 10 11 14" ;;
   112	  *)              printf 'cycle.sh: unknown mode %s\n' "${MODE}" >&2; exit 2 ;;
   113	esac
   114	hh_decision_output "mode_routed" "tenant:${CTX_TENANT_SLUG}" \
   115	  "mode:${MODE}; steps_planned:${STEPS_TO_RUN}"
   116	
   117	# ────────────────────────────────────────────────────────────────────────
   118	# Step 3 — Bank transaction ingest (mode=webhook from Open Banking)
   119	# Reference: agent.md §4 Step 3 + ADR-002 vault/Postgres split.
   120	# W7-8 wires: @ifos/open-banking listTransactionsSince — store in Postgres
   121	#             cash_conductor_transactions (v0.3 schema; applied 2026-05-31).
   122	# ────────────────────────────────────────────────────────────────────────
   123	
   124	if [[ "${STEPS_TO_RUN}" == *3* ]]; then
   125	  # TODO(W7-8): @ifos/open-banking listTransactionsSince(since=last_ingested_at)
   126	  #             → normalise → INSERT INTO cash_conductor_transactions
   127	  hh_decision_output "transactions_ingested" "tenant:${CTX_TENANT_SLUG}" \
   128	    "STUB rows since=STUB"
   129	fi
   130	
   131	# ────────────────────────────────────────────────────────────────────────
   132	# Step 4 — Invoice register ingest (mode=webhook from accounting OR daily-sweep)
   133	# Reference: agent.md §4 Step 4. W7-8 wires: @ifos/xero or @ifos/quickbooks
   134	# listOpenInvoices → INSERT INTO cash_conductor_invoices.
   135	# ────────────────────────────────────────────────────────────────────────
   136	
   137	if [[ "${STEPS_TO_RUN}" == *4* ]]; then
   138	  # TODO(W7-8): provider-aware (tenant_adapters.config.accounting_provider)
   139	  #             listOpenInvoices → store in Postgres cash_conductor_invoices
   140	  hh_decision_output "invoices_ingested" "tenant:${CTX_TENANT_SLUG}" "STUB rows"
   141	fi
   142	
   143	# ────────────────────────────────────────────────────────────────────────
   144	# Step 5 — Reconciliation pass (5-stage match algorithm per agent.md §3 Output 1)
   145	# Stage 1-2 auto-write yellow tier; Stage 3 single low-confidence flagged;
   146	# Stage 4 fuzzy multi-candidate → ESC_RECONCILIATION_AMBIGUOUS; Stage 5 unmatched.
   147	# ────────────────────────────────────────────────────────────────────────
   148	
   149	if [[ "${STEPS_TO_RUN}" == *5* ]]; then
   150	  # TODO(W7-8): match algorithm per agent.md §3 stages 1-5. SQL JOIN against
   151	  #             cash_conductor_invoices + cash_conductor_transactions.
   152	  hh_decision_output "reconciliation_pass" "tenant:${CTX_TENANT_SLUG}" \
   153	    "stage1_2:STUB; stage3:STUB; stage4:STUB; stage5:STUB"
   154	fi
   155	
   156	# ────────────────────────────────────────────────────────────────────────
   157	# Step 6 — Reconciliation write (yellow tier per match)
   158	# Reference: agent.md §3 Output 1. W7-8 wires: @ifos/xero writePaymentReceived
   159	# or @ifos/quickbooks writePaymentReceived; atomic per write; rollback on 4xx/5xx.
   160	# ────────────────────────────────────────────────────────────────────────
   161	
   162	if [[ "${STEPS_TO_RUN}" == *6* ]]; then
   163	  # TODO(W7-8): per-match: accounting.writePaymentReceived(...) → emit per write
   164	  # hh_decision_action "accounting_reconciliation_write" "invoice:<id>" payload_hash payload_preview
   165	  # On failure: ESC_ACCOUNTING_WRITE_FAIL via hh_decision_action validate_gate_a_fail
   166	  :
   167	fi
   168	
   169	# ────────────────────────────────────────────────────────────────────────
   170	# Step 7 — Chase generation pass (for overdue, unmatched invoices)
   171	# Reference: agent.md §4 Step 7. Read cash_conductor_invoices.last_chase_position
   172	# (v0.3 schema-backed). Position 4 = operator review (no auto-draft).
   173	# ────────────────────────────────────────────────────────────────────────
   174	
   175	if [[ "${STEPS_TO_RUN}" == *7* ]]; then
   176	  # TODO(W7-8): SELECT overdue invoices; determine chase position 1-4 per §3.2;
   177	  #             if position=4 → hh_decision_output "chase_position_4_operator_review" + STOP
   178	  hh_decision_output "chase_pass_complete" "tenant:${CTX_TENANT_SLUG}" "STUB candidates"
   179	fi
   180	
   181	# ────────────────────────────────────────────────────────────────────────
   182	# Step 8 — LLM chase-draft generation (per overdue invoice)
   183	# Reference: agent.md §4 Step 8 + §3.2 escalation ladder (position thresholds).
   184	# Voice classifier ≥0.75 for position 1-2; ≥0.80 for position 3.
   185	# Per agent.md §3 line 117: draft body written to VAULT FIRST (ADR-002
   186	# vault/Postgres split); decision_log carries METADATA only (vault_path +
   187	# body_sha256 + voice_score + escalation_position + days_overdue + amount_due).
   188	# ────────────────────────────────────────────────────────────────────────
   189	
   190	if [[ "${STEPS_TO_RUN}" == *8* ]]; then
   191	  # TODO(W7-8): LLM call → write draft body to vault → emit:
   192	  # hh_decision_output "chase_draft_generated" "invoice:<id>" \
   193	  #   "vault_path:<path>; body_sha256:<hash>; escalation_position:<N>; voice_score:<N>; ..."
   194	  :
   195	fi
   196	
   197	# ────────────────────────────────────────────────────────────────────────
   198	# Step 9 — Chase-draft validation (Gate A specifics; validate.sh)
   199	# Reference: agent.md §5 (Gate A); §6 ESC mapping.
   200	# ────────────────────────────────────────────────────────────────────────
   201	
   202	if [[ "${STEPS_TO_RUN}" == *9* ]]; then
   203	  # TODO(W7-8): per draft → bash validate.sh <draft_path>; exit on fail.
   204	  :
   205	fi
   206	
   207	# ────────────────────────────────────────────────────────────────────────
   208	# Step 10 — Chase-draft queue to Concierge (opens orange-tier approval bridge)
   209	# Reference: agent.md §4 Step 10 + D1-B (2026-05-31 founder decision).
   210	# Cash Conductor OWNS xero_reminder_send_customer action_type per autosend-policy.yaml
   211	# line 263; Concierge handles autosend-bridge-telegram approval routing + transport.
   212	# Drafts-only graceful degradation when autosend-bridge-telegram package absent
   213	# (per agent.md §1 readiness caveat).
   214	# ────────────────────────────────────────────────────────────────────────
   215	
   216	if [[ "${STEPS_TO_RUN}" == *10* ]]; then
   217	  # Always emit the YELLOW-tier internal-draft row first — this is the audit
   218	  # record that the draft exists in vault regardless of whether the orange
   219	  # send-approval path fires.
   220	  # TODO(W7-8): per draft iteration:
   221	  #   hh_decision_action "xero_reminder_draft_internal" "invoice:${INVOICE_ID}" \
   222	  #     "${PAYLOAD_HASH}" "vault_path:${DRAFT_PATH}; position:${CHASE_POSITION}"
   223	
   224	  if [[ -d "${IFOS_REPO_ROOT:-}/packages/utilities/autosend-bridge-telegram/dist" ]]; then
   225	    # Bridge package PRESENT — route each draft through the D1-B Telegram shim.
   226	    # Per D1-B doc §"Implementation surface" items 1 + 3 (Cash Conductor consumer).
   227	    #
   228	    # Production-shape call site (SKELETON; W7-8 build slice wires the per-draft
   229	    # loop + the tsx CLI entrypoints — they live alongside the package at
   230	    # packages/utilities/autosend-bridge-telegram/bin/{propose,await}.ts and
   231	    # are intentionally NOT in the v0.1 scaffold per the package README §
   232	    # "Out of scope (v1.0)" line on CLI wrappers).
   233	    #
   234	    # Per-draft flow:
   235	    #
   236	    # 1. proposeApproval — posts to operator Telegram, returns approval-id +
   237	    #    deadline. Package: @ifos/autosend-bridge-telegram (proposeApproval).
   238	    #
   239	    #    PROPOSE_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/propose.ts" \
   240	    #      --action xero_reminder_send_customer \
   241	    #      --tenant "${CTX_TENANT_SLUG}" \
   242	    #      --operator-chat "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
   243	    #      --target "${DRAFT_CONTACT_EMAIL}" \
   244	    #      --preview "${DRAFT_PREVIEW_500_CHARS}" \
   245	    #      --vault-path "${DRAFT_PATH}" \
   246	    #      --timeout-seconds 14400)
   247	    #    APPROVAL_ID=$(printf '%s' "${PROPOSE_JSON}" | jq -r .approval_id)
   248	    #    EXPIRES_AT_ISO=$(printf '%s' "${PROPOSE_JSON}" | jq -r .expires_at_iso)
   249	    #
   250	    # 2. Emit ORANGE-tier audit row — Cash Conductor OWNS xero_reminder_send_customer
   251	    #    per autosend-policy.yaml line 263.
   252	    #
   253	    #    hh_decision_action "xero_reminder_send_customer" "invoice:${INVOICE_ID}" \
   254	    #      "${PAYLOAD_HASH}" \
   255	    #      "approval_id:${APPROVAL_ID}; expires_at:${EXPIRES_AT_ISO}; position:${CHASE_POSITION}; vault:${DRAFT_PATH}"
   256	    #
   257	    # 3. awaitApprovalDecision — block until decision or PT4H deadline.
   258	    #    Package: @ifos/autosend-bridge-telegram (awaitApprovalDecision).
   259	    #
   260	    #    AWAIT_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/await.ts" \
   261	    #      --approval-id "${APPROVAL_ID}" \
   262	    #      --expires-at "${EXPIRES_AT_ISO}")
   263	    #    OUTCOME=$(printf '%s' "${AWAIT_JSON}" | jq -r .outcome)
   264	    #    DECIDED_BY=$(printf '%s' "${AWAIT_JSON}" | jq -r '.decided_by // ""')
   265	    #
   266	    # 4. Branch on outcome:
   267	    #    case "${OUTCOME}" in
   268	    #      approved)
   269	    #        # Step 11 transport proceeds (webhook-driven from Concierge after send)
   270	    #        : ;;
   271	    #      rejected)
   272	    #        hh_decision_output "approval_rejected" "invoice:${INVOICE_ID}" \
   273	    #          "approval_id:${APPROVAL_ID}; decided_by:${DECIDED_BY}; rationale:operator_rejected" ;;
   274	    #      timeout)
   275	    #        # ESC_APPROVAL_BRIDGE_TIMEOUT per agents/_shared/escalation-codes.md
   276	    #        # lines 348-353: warn-tier; operator + ifos_oncall_chat_id routing;
   277	    #        # action converts to manual reconciliation; operator handles offline.
   278	    #        hh_decision_action "validate_gate_a_fail" "invoice:${INVOICE_ID}" \
   279	    #          "${PAYLOAD_HASH}" \
   280	    #          "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:14400; approval_id:${APPROVAL_ID}" ;;
   281	    #    esac
   282	    : # TODO(W7-8): wire the per-draft loop above (steps 1–4); tsx CLI entrypoints land alongside in the same build slice
   283	  else
   284	    # Bridge package ABSENT (dist/ missing) — drafts-only graceful degradation.
   285	    # DO NOT emit the orange row; Cash Conductor's chase pipeline halts at the
   286	    # vault-draft stage and a consultant picks the drafts up manually.
   287	    hh_decision_output "drafts_only_mode" "tenant:${CTX_TENANT_SLUG}" \
   288	      "autosend-bridge-telegram package dist/ not present — drafts retained in vault for manual consultant pickup; build the package (pnpm --filter @ifos/autosend-bridge-telegram build) to enable the D1-B send path"
   289	  fi
   290	fi
   291	
   292	# ────────────────────────────────────────────────────────────────────────
   293	# Step 11 — (After operator approves) Send execution — orange-tier
   294	# Reference: agent.md §4 Step 11 + D1-B doc §"Implementation surface".
   295	# Cash Conductor receives webhook from Concierge after transport completes;
   296	# updates cash_conductor_invoices.last_chase_position + last_chase_sent_at.
   297	# ────────────────────────────────────────────────────────────────────────
   298	
   299	if [[ "${STEPS_TO_RUN}" == *11* ]]; then
   300	  # TODO(W7-8): webhook-driven; UPDATE cash_conductor_invoices SET ...
   301	  # hh_decision_output "cash_conductor_chase_sent_recorded" "invoice:<id>" "position:<N>; sent_at:<ISO>"
   302	  :
   303	fi
   304	
   305	# ────────────────────────────────────────────────────────────────────────
   306	# Step 12 — Re-trigger eligibility check (mode=webhook only)
   307	# Reference: agent.md §4 Step 12. Cancels chase-drafts on race conditions
   308	# (paid-since-draft-but-before-send) → ESC_AUTOSEND_RACE.
   309	# ────────────────────────────────────────────────────────────────────────
   310	
   311	if [[ "${STEPS_TO_RUN}" == *12* ]]; then
   312	  # TODO(W7-8): re-query Step 5 for paid-since detection; ESC_AUTOSEND_RACE
   313	  # hh_decision_output "chase_cancellation_check" "invoice:<id>" "cancelled:<bool>"
   314	  :
   315	fi
   316	
   317	# ────────────────────────────────────────────────────────────────────────
   318	# Step 13 — Weekly report assembly (mode=weekly-report; Mondays 06:00 UTC)
   319	# Reference: agent.md §4 Step 13 + §3 Output 3 (6-section Markdown report).
   320	# DSO metric (Gate B tracking) per ULTRAPLAN A4 line 539.
   321	# ────────────────────────────────────────────────────────────────────────
   322	
   323	if [[ "${STEPS_TO_RUN}" == *13* ]]; then
   324	  # TODO(W7-8): SELECT decision_log + cash tables for 7-day window; compute
   325	  # DSO; assemble Markdown; write to /vault/<tenant>/cash-conductor-reports/
   326	  REPORT_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/cash-conductor-reports/weekly-$(date -u +%Y-%m-%d).md"
   327	  mkdir -p "$(dirname "${REPORT_PATH}")" 2>/dev/null || true
   328	  printf '# Weekly cash-flow report — STUB\n\nTODO(W7-8): full §3 Output 3 6-section report.\n' > "${REPORT_PATH}" 2>/dev/null || true
   329	  hh_decision_output "weekly_report" "${REPORT_PATH}" \
   330	    "dso_delta_days:STUB; sections:STUB"
   331	fi
   332	
   333	# ────────────────────────────────────────────────────────────────────────
   334	# Step 14 — Session close
   335	# ────────────────────────────────────────────────────────────────────────
   336	
   337	# tenant_adapters.config.cash_conductor_last_run (declared in v0.3 supplement; validated
   338	# by validate_tenant_adapters_config_v0_3 trigger landed 2026-05-31).
   339	# TODO(W7-8): UPDATE tenant_adapters SET config = jsonb_set(config, '{cash_conductor_last_run}', '"<ISO>"')
   340	
   341	if [[ "${STEPS_TO_RUN}" == *13* ]]; then REPORT_RAN="true"; else REPORT_RAN="false"; fi
   342	hh_decision_action "cash_conductor_run_complete" "session:${CTX_TENANT_SLUG}" "stub-hash" \
   343	  "mode:${MODE}; matches:STUB; chases:STUB; report:${REPORT_RAN}"
   344	
   345	exit 0

exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/validate.sh | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# shellcheck disable=SC2329
     3	# (_fail + _warn are not invoked in the W4 Day-26 skeleton — TODO(W7-8)
     4	#  blocks invoke them when the per-check impl lands. Keeping them defined
     5	#  so the skeleton matches the final shape + the build-slice author can fill
     6	#  the TODOs without re-declaring helpers.)
     7	#
     8	# Cash Conductor agent — validate.sh (Gate A enforcement; W4 Day-26 SKELETON)
     9	#
    10	# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice completes the impl).
    11	# Reading order: agent.md §5 (Gate A specifics) + §6 (ESC codes) first.
    12	#
    13	# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is the
    14	# hard-fail gate that runs BETWEEN the chase-draft generation (cycle.sh Step 8)
    15	# and the queue-to-Concierge (Step 10). If any check fails, validate.sh exits
    16	# non-zero + emits an ESC_* escalation row to decision_log; the chase draft does
    17	# NOT route to Concierge; cycle.sh aborts the draft pipeline.
    18	#
    19	# Invocation contract:
    20	#   bash validate.sh <draft_path>
    21	#
    22	# Inputs:
    23	#   - $1: path to the vault chase-draft file (cycle.sh Step 8 wrote it)
    24	#   - env: CTX_TENANT_SLUG, CTX_AGENT_NAME, CTX_VOICE_CORPUS_ID,
    25	#          CTX_TONE_RULES (json string)
    26	#
    27	# Exit codes:
    28	#   0  All Gate A checks pass; cycle.sh proceeds to Step 10
    29	#   1  At least one check failed; ESC_* row emitted; cycle.sh aborts the draft
    30	#   2  validate.sh invocation error (bad args, missing draft, etc.)
    31	#
    32	# Checks (per agent.md §5 Gate A, ULTRAPLAN A4 line 538 verbatim):
    33	#   G1 — chase email references CORRECT invoice number AND amount AND contact (AND not OR)
    34	#   G2 — invoice NOT paid in last 24h (defence-in-depth re-query at draft time)
    35	#   G3 — voice classifier score ≥0.75 for position 1-2; ≥0.80 for position 3 (§3.2)
    36	#   G4 — No PII outside firm boundary in chase body (regex pass)
    37	#   G5 — Reconciliation match confidence ≥0.85 for auto-write (Stage 1-2 only)
    38	#   G6 — Open Banking token ≥7 days from expiry (≤7d → ESC_OPEN_BANKING_TOKEN_AGING blocking)
    39	#   G7 — Accounting auth refresh succeeded in Step 1
    40	
    41	set -uo pipefail
    42	
    43	# ────────────────────────────────────────────────────────────────────────
    44	# Pre-flight
    45	# ────────────────────────────────────────────────────────────────────────
    46	
    47	if [[ $# -lt 1 ]]; then
    48	  printf 'cash-conductor/validate.sh: usage: validate.sh <draft_path>\n' >&2
    49	  exit 2
    50	fi
    51	
    52	readonly DRAFT="$1"
    53	
    54	if [[ ! -f "${DRAFT}" ]]; then
    55	  printf 'validate.sh: draft not found at %s\n' "${DRAFT}" >&2
    56	  exit 2
    57	fi
    58	
    59	if [[ -z "${CTX_TENANT_SLUG:-}" || -z "${CTX_AGENT_NAME:-}" ]]; then
    60	  printf 'validate.sh: CTX_TENANT_SLUG or CTX_AGENT_NAME unset\n' >&2
    61	  exit 2
    62	fi
    63	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    64	  printf 'validate.sh: CTX_AGENT_DIR unset\n' >&2
    65	  exit 2
    66	fi
    67	
    68	# Resolve _shared/ helpers (4-candidate fallback; matches diagnostic/validate.sh
    69	# pattern post smoke-hotfix commit d7d52c5).
    70	_SHARED_DIR=""
    71	for _candidate in \
    72	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    73	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    74	  "${CTX_AGENT_DIR}/../../_shared" \
    75	  "${CTX_AGENT_DIR}/../_shared" ; do
    76	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    77	    _SHARED_DIR="${_candidate}"
    78	    break
    79	  fi
    80	done
    81	if [[ -z "${_SHARED_DIR}" ]]; then
    82	  printf 'validate.sh: cannot locate _shared/ helpers; set IFOS_REPO_ROOT\n' >&2
    83	  exit 2
    84	fi
    85	# shellcheck source=/dev/null
    86	source "${_SHARED_DIR}/hook-helpers.sh"
    87	
    88	# Track failures + warnings across all checks (collect all before exit for richer audit)
    89	declare -a FAILURES=()
    90	declare -a WARNINGS=()
    91	
    92	_fail() {
    93	  FAILURES+=("$1")
    94	  printf '  ✗ %s\n' "$1" >&2
    95	}
    96	_warn() {
    97	  WARNINGS+=("$1")
    98	  printf '  ! %s\n' "$1" >&2
    99	}
   100	_ok() {
   101	  printf '  ✓ %s\n' "$1"
   102	}
   103	
   104	# ────────────────────────────────────────────────────────────────────────
   105	# G1 — invoice number + amount + contact (per ULTRAPLAN A4 line 538)
   106	# Reads draft YAML frontmatter (per agent.md §3 Output 2 schema):
   107	#   invoice_id, contact_email, amount_due, days_overdue, escalation_position
   108	# Cross-checks against cash_conductor_invoices.<invoice_id>.
   109	# ────────────────────────────────────────────────────────────────────────
   110	
   111	# TODO(W7-8): parse draft YAML frontmatter; SELECT FROM cash_conductor_invoices
   112	# WHERE invoice_id = <draft.invoice_id>; assert TotalAmt/Balance match draft.amount_due
   113	# AND CustomerRef.email matches draft.contact_email. On any mismatch:
   114	# _fail "G1: invoice/amount/contact triple-check failed" + fire ESC_ADDRESSEE_MISMATCH
   115	# (per agent.md §6; blocking; operator + ifos_oncall routing).
   116	_ok "G1: invoice/amount/contact triple-check — SKELETON (W7-8 wires the SQL)"
   117	
   118	# ────────────────────────────────────────────────────────────────────────
   119	# G2 — NOT paid in last 24h (defence-in-depth; per ULTRAPLAN A4 line 538 verbatim)
   120	# Re-query accounting (Xero/QB) at draft time; if paid_in_last_24h: _fail + ESC_AGENT_OUTPUT_SHAPE
   121	# ────────────────────────────────────────────────────────────────────────
   122	
   123	# TODO(W7-8): @ifos/xero getInvoice OR @ifos/quickbooks getInvoice → check
   124	# AmountPaid timestamp; if within 24h _fail + emit ESC_AGENT_OUTPUT_SHAPE
   125	# (output-shape constraint per catalogue line 184) via:
   126	# hh_decision_action "validate_gate_a_fail" "invoice:<id>" "<hash>" "ESC_AGENT_OUTPUT_SHAPE; paid-in-24h"
   127	_ok "G2: not-paid-in-24h — SKELETON (W7-8 wires the accounting re-query)"
   128	
   129	# ────────────────────────────────────────────────────────────────────────
   130	# G3 — voice classifier score by position threshold (per agent.md §3.2)
   131	# Position 1-2: ≥0.75 ; Position 3: ≥0.80 (sensitive sends like position-3 escalation)
   132	# ────────────────────────────────────────────────────────────────────────
   133	
   134	# TODO(W7-8): parse draft YAML for voice_score + escalation_position; compare
   135	# to threshold; on fail emit ESC_VOICE_DRIFT (warn per catalogue lines 120-125)
   136	# + hh_decision_action validate_gate_a_fail.
   137	_ok "G3: voice classifier per-position threshold — SKELETON (W7-8 wires)"
   138	
   139	# ────────────────────────────────────────────────────────────────────────
   140	# G4 — No PII outside firm boundary (regex pass against chase body)
   141	# ────────────────────────────────────────────────────────────────────────
   142	
   143	# TODO(W7-8): grep draft body for email patterns NOT matching the tenant's
   144	# firm-domain whitelist; if any: _fail + ESC_PII_LEAKAGE_RISK (blocking;
   145	# operator + ifos_oncall).
   146	_ok "G4: no PII outside firm boundary — SKELETON (W7-8 wires firm-domain whitelist)"
   147	
   148	# ────────────────────────────────────────────────────────────────────────
   149	# G5 — Reconciliation match confidence ≥0.85 for auto-write (Stage 1-2 only)
   150	# Only fires on Stage 1-2 auto-write path; Stage 3-4 already operator-queued.
   151	# ────────────────────────────────────────────────────────────────────────
   152	
   153	_ok "G5: reconciliation match-confidence ≥0.85 — SKELETON (W7-8 wires)"
   154	
   155	# ────────────────────────────────────────────────────────────────────────
   156	# G6 — Open Banking token age ≥7 days from PSD2 consent expiry
   157	# Per @ifos/open-banking getTokenAgeStage; ≤7d = "blocking" stage = hard fail.
   158	# ────────────────────────────────────────────────────────────────────────
   159	
   160	# TODO(W7-8): @ifos/open-banking loadTokens + getTokenAgeStage; if stage=="blocking"
   161	# _fail + ESC_OPEN_BANKING_TOKEN_AGING (catalogue staged severity per §2.7;
   162	# blocking severity routes operator + ifos_oncall_chat_id).
   163	_ok "G6: Open Banking token ≥7d from PSD2 expiry — SKELETON (W7-8 wires)"
   164	
   165	# ────────────────────────────────────────────────────────────────────────
   166	# G7 — Accounting auth refreshed in Step 1
   167	# Sanity check that cycle.sh Step 1 wrote a fresh auth_refresh_complete row.
   168	# ────────────────────────────────────────────────────────────────────────
   169	
   170	_ok "G7: accounting auth refresh in this session — SKELETON (W7-8 wires)"
   171	
   172	# ────────────────────────────────────────────────────────────────────────
   173	# Verdict + audit-row emission
   174	# ────────────────────────────────────────────────────────────────────────
   175	
   176	printf '\nValidate Gate A: '
   177	if [[ ${#FAILURES[@]} -gt 0 ]]; then
   178	  printf 'FAIL (%d failures; %d warnings)\n' "${#FAILURES[@]}" "${#WARNINGS[@]}"
   179	  # TODO(W7-8): per-failure routing — different ESC code per failure class
   180	  # (G1 → ESC_ADDRESSEE_MISMATCH; G2 → ESC_AGENT_OUTPUT_SHAPE; G3 → ESC_VOICE_DRIFT;
   181	  #  G4 → ESC_PII_LEAKAGE_RISK; G5 → ESC_RECONCILIATION_AMBIGUOUS or downgrade;
   182	  #  G6 → ESC_OPEN_BANKING_TOKEN_AGING; G7 → ESC_ACCOUNTING_AUTH)
   183	  # hh_decision_action "validate_gate_a_fail" "tenant:${CTX_TENANT_SLUG}" payload_hash \
   184	  #   "ESC_<class>; agent_name:cash-conductor; failures:${#FAILURES[@]}"
   185	  exit 1
   186	fi
   187	printf 'PASS (warnings=%d)\n' "${#WARNINGS[@]}"
   188	exit 0

exec
/bin/zsh -lc "rg --files | rg 'autosend.*policy'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml
docs/decisions/autosend-safety-policy.md
logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md
logs/codex-ratification/round-2-autonomous/docs_decisions_autosend-safety-policy-md.output.md

exec
/bin/zsh -lc 'rg -n "AgentMail|Composio|packages/harness/cortextos|cortextOS|KB|brain" agents/recruitment/cash-conductor/agent.md agents/recruitment/cash-conductor/tools.yaml agents/recruitment/cash-conductor/fixtures/*.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/cash-conductor/tools.yaml:10:# state-changing call emits. cortextOS bus uses this to authorise capability
agents/recruitment/cash-conductor/tools.yaml:206:# - No Composio / AgentMail references anywhere in this file.

exec
/bin/zsh -lc 'rg -n "autosend-safety-policy|autosend-policy" agents/recruitment/cash-conductor/agent.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type (registered in autosend-policy.yaml under §ORANGE; grep `^  xero_reminder_send_customer:` to verify); Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW — grep `^  xero_reminder_draft_internal:` to verify; internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (registered under §ORANGE — grep `^  xero_reminder_send_customer:`; consultant approval required before send). **Note on citation discipline:** explicit line numbers in `autosend-policy.yaml` shift across edits; this agent.md uses grep-anchors instead per the pattern established in xero R3 closure (commit `5228fa2`). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** Founder Decision D1 ACCEPTED 2026-05-31 as D1-B (Telegram shim) + package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`); the autosend-bridge **production wiring** (real Telegram Bot API + postgres approvals reader) still lands in Concierge W10-13 build slice. Until then, Cash Conductor cycle.sh Step 10 detects the absent `packages/utilities/autosend-bridge-telegram/dist/` directory and degrades to **drafts-only** mode — produces yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT emit the orange-tier `xero_reminder_send_customer` rows (per §8 fallback row).
94:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'` (yellow tier per autosend-policy.yaml lookup — `tier` is NOT a top-level decision_log column; it is recorded inside the autosend-emitted payload by `_shared/hook-helpers.sh`'s `hh_decision_action`). Payload `reason`/`payload_preview` carries `match_confidence` + `match_dimensions` as a string; for queryable-structured match metadata, the W7-8 build slice extends `hh_decision_action` to emit structured payload fields OR writes a separate audit row.
98:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type — grep `^  xero_reminder_send_customer:` in `agents/_shared/autosend-policy.yaml` to verify it's registered there under §ORANGE) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
119:2. `phase='action'`, `action_type='xero_reminder_draft_internal'` (yellow tier per autosend-policy.yaml lookup; grep `^  xero_reminder_draft_internal:` to verify) — this row records that Cash Conductor classified the draft as yellow-tier internal. Per `hh_decision_action(action_type, target, payload_hash, payload_preview)`: `target` carries the invoice_id; `payload_hash` is a stable hash of the draft body; `payload_preview` carries the same metadata string as row 1's reason for cross-row correlation.
121:When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml lookup; grep `^  xero_reminder_send_customer:` to verify; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).
209:   → spot-check sampling per autosend-safety-policy.yaml yellow tier
254:      payload_hash, payload_preview) — yellow tier per autosend-policy.yaml
257:      payload_hash, payload_preview) — orange tier per autosend-policy.yaml
267:      action_type per autosend-policy.yaml lookup; agent: cash-conductor).
308:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):

exec
/bin/zsh -lc "nl -ba docs/decisions/2026-05-31-d1-founder-decision.md | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Founder Decision D1 — autosend orange-tier path
     2	
     3	**Status:** Accepted (founder-arbitrated 2026-05-31 via explicit delegation: *"i pretty much trust your decision making for the technical build stuff"*).
     4	**Decision:** **D1-B — Telegram shim** for v1.0; D1-A as v1.1+ upgrade.
     5	**Date:** 2026-05-31
     6	**Author:** Claude Code (arbitrating per delegated authority); founder may override at any time before Concierge W10 build start.
     7	**Supersedes:** the "D1 founder decision" line item in `2026-05-20-codex-round-1-founder-decisions.md` and the open-question rows in:
     8	- `agents/recruitment/concierge/agent.md` §9 Q1
     9	- `agents/recruitment/cash-conductor/agent.md` §8 (D1-pending fallback row)
    10	
    11	---
    12	
    13	## Context
    14	
    15	Per `docs/decisions/autosend-safety-policy.md` §4, orange-tier action_types (customer-facing sends like `xero_reminder_send_customer`, `gmail_outlook_send_to_candidate`, `bullhorn_note_customer_visible`) require **synchronous consultant approval** before the send executes. The agent drafts; the consultant says yes; the transport fires; an audit row records the full chain.
    16	
    17	Three paths were on the table for the v1.0 orange-tier approval mechanism:
    18	
    19	| Option | Mechanism | v1.0 cost | Strengths | Weaknesses |
    20	|---|---|---|---|---|
    21	| **D1-A** Bridge to cortextOS approval system | Concierge POSTs to an internal cortextOS approval API; operator approves in Brain UI; bridge calls back | ~2 days build (~3 days if approval-API doesn't yet exist) | Architecturally clean; reuses cortextOS primitive #4 (approval gates); UX in Brain UI is consistent with other approval flows | Brain UI v1.0 approval UX not yet built; depends on cortextOS approval-API stability; tightest coupling to upstream |
    22	| **D1-B** Lightweight Telegram shim | Concierge posts to operator's tenant-bound Telegram chat: `[ID:<x>] APPROVE drafted email to <recipient>? /approve <ID> or /reject <ID>`; Concierge polls Telegram or receives webhook; on approve → transport executes | <1 day build | Reuses cortextOS primitive #5 (Telegram surface) already in place; consultants are on Telegram already; lowest engineering cost; clean audit chain (every approve/reject = `decision_log` row); works the same for Cash Conductor + Concierge | Approval UX is a chat reply rather than a rich panel; per-draft attachment preview is just a 200-char text snippet + vault path; consultant must read the vault Markdown if they want to see the full draft body before approving |
    23	| **D1-C** No autosend; manual pickup | Concierge writes the draft to vault; sets `requires_consultant_action=true`; no notification; consultant manually polls vault and copies drafts to outbound | 0 days build (already supported by drafts-to-vault flow) | Zero risk of incorrect autosend; zero new build | UX is brutal; consultants miss drafts; defeats Concierge's "no candidate ghosted" promise; effectively kills Concierge as a v1.0 differentiator |
    24	
    25	---
    26	
    27	## Decision: D1-B (Telegram shim)
    28	
    29	**Why D1-B wins for v1.0:**
    30	
    31	1. **Cost-aligned to v1.0 scope.** D1-A's clean architecture is the right *v1.1+* answer once Brain UI matures; for v1.0 ship, D1-B's <1-day build matches the W10-13 Concierge slice budget.
    32	2. **Reuses an already-built primitive.** cortextOS primitive #5 (Telegram surface) is in place; operators already receive escalation notifications there. Adding `/approve <ID>` / `/reject <ID>` commands extends an existing surface rather than introducing a new one.
    33	3. **Audit chain is identical to D1-A.** Both paths emit the same `decision_log` rows (`xero_reminder_send_customer` orange action → operator approve/reject → transport `gmail_outlook_send_to_candidate` action). The Telegram interaction is the trigger, not the audit substrate.
    34	4. **D1-C kills Concierge's value.** Manual vault polling means missed drafts means ghosted candidates means Concierge fails its Gate B (`ghosted-rate <5%`). Non-starter.
    35	
    36	**Tradeoff accepted:** the approval UX is text-only on Telegram. Consultants who want to see the full draft body before approving open the vault path in the Telegram message. This is the same friction as reviewing an email draft in any other ticket system; acceptable for v1.0.
    37	
    38	**v1.1+ upgrade path (queued, not blocking):** D1-A bridge to cortextOS approval system + Brain UI rich-panel approval surface. The D1-B Telegram path stays available as a fallback (e.g., operator on the move, away from a desk). v1.1+ adds the *option* of D1-A, doesn't replace D1-B.
    39	
    40	---
    41	
    42	## Implementation surface (delivered by Concierge W10-13 build slice)
    43	
    44	1. **`packages/utilities/autosend-bridge-telegram/`** — small TypeScript package:
    45	   - `proposeApproval(action_type, target, draft_preview, vault_path, timeout=PT4H) → approval_id`
    46	   - Posts to operator's tenant Telegram chat with `[ID:<approval_id>]` + draft preview + vault path + `/approve <id>` / `/reject <id>` instructions.
    47	   - Polls or webhooks for the operator's reply.
    48	   - Returns `{outcome: approved | rejected | timeout, decided_by: <telegram_user_id>}`.
    49	   - Timeout default `PT4H` per `escalation-codes.md` `ESC_APPROVAL_BRIDGE_TIMEOUT` lines 348-353.
    50	2. **Concierge `cycle.sh` Step 11** — calls `proposeApproval` for orange-tier drafts; on `approved`, proceeds to Step 12 transport; on `rejected` or `timeout`, fires `ESC_APPROVAL_BRIDGE_TIMEOUT` (timeout) or records rejection in `decision_log` (rejected).
    51	3. **Cash Conductor `cycle.sh` Step 10** — same `proposeApproval` call for `xero_reminder_send_customer` rows; identical handling.
    52	4. **`tools.yaml` capability declarations** — add `autosend_bridge_telegram` capability to both Concierge and Cash Conductor.
    53	5. **Tenant config — schema-work pending.** The natural storage location for the per-tenant operator Telegram chat-id is `tenant_adapters.config`, BUT the v0.3 supplement's `validate_tenant_adapters_config_v0_3` trigger hard-fails on unknown keys per Rule 2 — and `operator_telegram_chat_id` is NOT currently in the 6-key allowlist (`cash_conductor_last_run`, `concierge_last_poll`, `concierge_send_window`, `janitor_dedup_threshold`, the 2026-05-31 Janitor key, `blocked_recipients`). Resolution path: **W10-13 Concierge build slice lands a v0.4 supplement** adding `operator_telegram_chat_id` to the allowlist (type: string; required: false; set_by: tenant-admin; read_by: concierge + cash-conductor for the autosend-bridge consumer). Until then, the bridge consumer (`@ifos/autosend-bridge-telegram`) takes the chat-id as a function argument rather than reading it from tenant_adapters — the function-arg shim is already in place per the package scaffold landed 2026-06-01 (commit `9b282d8`). This decision-doc does NOT block on the schema work; D1-B's APPROVAL is structural (Telegram vs cortextOS approval system vs no-autosend); the storage-location detail is a W10-13 implementation question.
    54	
    55	---
    56	
    57	## Codex ratification
    58	
    59	This decision doc ratifies via `.codex/ratification/review-architecture-decision.md` skill. Currently in flight under **cluster G** (`bash scripts/run-codex-ratification.sh --cluster G`); session-by-session ratification status is tracked in the closing Status-update line.
    60	
    61	## Consequences
    62	
    63	- **Concierge §9 Q1 RESOLVED** — strike from "open questions" list at next agent.md touch.
    64	- **Cash Conductor §8 D1-pending fallback** — flips from "drafts-only if unresolved" to "orange-tier `xero_reminder_send_customer` writes are live once Concierge W10-13 lands the autosend-bridge production wiring."
    65	- **Concierge ratification §10** — `Founder Decision D1 RESOLVED` blocker now satisfied. Remaining Concierge Proposed → Accepted blockers per §10: ADR-007 Accepted + Codex RATIFIED (DONE 2026-05-31 + Round 3), pilot LOI (PENDING), Bullhorn A+B (PENDING), founder approves §9 Q2-Q6 (PENDING).
    66	- **Schema impact: v0.4 supplement required (deferred to W10-13 Concierge build slice).** D1-B requires a per-tenant operator-Telegram-chat-id storage location. `tenant_adapters.config` is the natural home BUT the v0.3 supplement's `validate_tenant_adapters_config_v0_3` trigger hard-fails on unknown keys per Rule 2 and `operator_telegram_chat_id` is NOT in the current allowlist (see implementation surface item 5 for the full rationale + interim function-arg-mode workaround). The schema work + migration land in the W10-13 Concierge build slice as part of bridge-production-wiring; the decision-doc itself is structurally complete without that schema work. The previously-stated "No schema impact" claim has been removed — it was inconsistent with implementation surface item 5.
    67	- **No additional API keys/signups for the founder vault.** Day-4 provisioning (`docs/runbooks/day-4-provisioning.md` §6.5) creates the `_secrets.env` SKELETON only (touched empty at mode 0600); the Telegram bot token is populated by founder bootstrap (covered separately by tenant onboarding playbook — NOT Day-4), and the per-tenant operator chat-id is populated by tenant onboarding (W10-13 build slice; see implementation surface item 5 above). Once both are in place, no recurring credentials work — the bot token doesn't rotate per send; the chat-id is per-tenant-stable.
    68	- **Schema-before-code discipline — interim acceptance.** The five rules (master brief §1) state schema-before-code. Today's state has the bridge package scaffold + consumer wiring landed BEFORE the schema supplement. The interim resolution is acceptable because the consumers run in **function-arg mode only** (chat-id passed as function argument, NOT read from `tenant_adapters`) — so no consumer code actually attempts to read the not-yet-allowlisted key. The schema-before-code rule is respected at the runtime level (no schema-violating read happens); the consumer scaffolding is fine to exist as long as the function-arg-only constraint holds until the v0.4 supplement lands.
    69	
    70	---
    71	
    72	*End of D1 decision doc.*
    73	
    74	---
    75	
    76	**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commits `669a4f4` + `9ec2bd6`) — **in FUNCTION-ARG MODE only**, no `tenant_adapters.config.operator_telegram_chat_id` read attempts until the v0.4 schema supplement lands in the Concierge W10-13 build slice; Codex ratification currently in flight under cluster G (R2 closing 2026-06-02 per `docs/decisions/codex-disagreement-2026-06-02-*` ledger and the cluster G round-trip arc).

codex
REJECTED

1. Honest-signal state is internally inconsistent. Line 320 says `validate.sh` "does NOT exist yet", but §10 line 442 says the sibling files exist, and the repository contains `validate.sh`, `cycle.sh`, `context.sh`, `cleanup.sh`, `tools.yaml`, and 3 fixtures. §8 lines 399-404 also marks those same sibling files as future build prerequisites rather than existing SKELETON files. Fix by distinguishing "file exists as SKELETON" from "live Gate A implementation not yet wired" throughout §5, §8, and §10.

2. The drafts-only fallback claim does not match the bundle implementation. Line 18 says absent bridge `dist/` produces yellow-tier `xero_reminder_draft_internal` rows plus vault drafts; actual `cycle.sh` fallback only emits `hh_decision_output "drafts_only_mode"` and does not write the vault draft or yellow-tier draft action row. Fix the output contract or wire Step 10 fallback to emit the promised vault draft + `xero_reminder_draft_internal` audit row.

3. The transport audit chain bypasses or contradicts autosend gate discipline. Line 18 says Concierge handles transport but "not action-row authorship", and lines 263-269 say Concierge does not write its own action row; however the actual Microsoft Graph/Gmail transport is a customer-facing send and must have an autosend-governed `decision_log` action row, consistent with the D1 chain. Fix by specifying that Cash Conductor owns `xero_reminder_send_customer` approval initiation while Concierge writes the transport action row, or explicitly register `xero_reminder_send_customer` as the sole transport action and remove the no-action-row wording.
tokens used
105,992
REJECTED

1. Honest-signal state is internally inconsistent. Line 320 says `validate.sh` "does NOT exist yet", but §10 line 442 says the sibling files exist, and the repository contains `validate.sh`, `cycle.sh`, `context.sh`, `cleanup.sh`, `tools.yaml`, and 3 fixtures. §8 lines 399-404 also marks those same sibling files as future build prerequisites rather than existing SKELETON files. Fix by distinguishing "file exists as SKELETON" from "live Gate A implementation not yet wired" throughout §5, §8, and §10.

2. The drafts-only fallback claim does not match the bundle implementation. Line 18 says absent bridge `dist/` produces yellow-tier `xero_reminder_draft_internal` rows plus vault drafts; actual `cycle.sh` fallback only emits `hh_decision_output "drafts_only_mode"` and does not write the vault draft or yellow-tier draft action row. Fix the output contract or wire Step 10 fallback to emit the promised vault draft + `xero_reminder_draft_internal` audit row.

3. The transport audit chain bypasses or contradicts autosend gate discipline. Line 18 says Concierge handles transport but "not action-row authorship", and lines 263-269 say Concierge does not write its own action row; however the actual Microsoft Graph/Gmail transport is a customer-facing send and must have an autosend-governed `decision_log` action row, consistent with the D1 chain. Fix by specifying that Cash Conductor owns `xero_reminder_send_customer` approval initiation while Concierge writes the transport action row, or explicitly register `xero_reminder_send_customer` as the sole transport action and remove the no-action-row wording.
