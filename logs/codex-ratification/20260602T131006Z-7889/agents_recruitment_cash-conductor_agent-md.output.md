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
session id: 019e8874-ad4e-7ee3-a55d-515e49a653cd
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

**Reading-discipline note (added 2026-06-02 per Codex Fbis-R3 closure):** this `agent.md` is the **CONTRACT** that the W7-8 build slice implements against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml`) + 3 fixtures EXIST AS SCAFFOLD (landed across commits `6ab59d8` + `5ab2f0f` + `076e231` + `bccef02` + `5d398eb` per Day-26 + R-round closures); they carry `TODO(W7-8)` markers throughout that the W7-8 build slice replaces with live implementation matching the contract below. **Audit-row signatures + workflow steps documented below describe the CONTRACT shape; current SKELETON cycle.sh emits only the minimal trigger/output markers (`session_start`, `auth_refresh_complete`, `mode_routed`, `transactions_ingested`, `invoices_ingested`, `reconciliation_pass`, `chase_pass_complete`, `drafts_only_mode`, `weekly_report`, `cash_conductor_run_complete`) listed at `cycle.sh` lines 88, 100, 114, 127, 140, 152, 178, 287, 329, 342.** The yellow-tier + orange-tier audit rows the contract names are NOT yet emitted at runtime — they're the W7-8 contract surface, not current behavior. Don't read agent.md as a description of running code; read it as the spec the W7-8 build slice implements.
**Date:** 2026-05-24.
**Author:** Founder (Maddox) + Claude Code.
**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
**Build complexity:** L (2 weeks) per ULTRAPLAN A4 line 540.
**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.

---

## §1 — Output contract (one-paragraph screenshot)

Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.

> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the `xero_reminder_send_customer` action_type (registered in autosend-policy.yaml under §ORANGE; grep `^  xero_reminder_send_customer:` to verify) which is the **chase-approval-initiation** audit row; Concierge runs the autosend bridge for approval routing, then performs the transport-execution and writes its OWN orange-tier `gmail_outlook_send_to_candidate` action row (Concierge-owned; registered under §ORANGE). Both agents write tier-classified action rows — the distinction is: Cash Conductor writes the initiation; Concierge writes the transport. The full autosend chain has TWO orange-tier rows in sequence (initiation + transport), both gated, both audited. Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport; and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW — grep `^  xero_reminder_draft_internal:` to verify; internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (registered under §ORANGE — grep `^  xero_reminder_send_customer:`; consultant approval required before send). **Note on citation discipline:** explicit line numbers in `autosend-policy.yaml` shift across edits; this agent.md uses grep-anchors instead per the pattern established in xero R3 closure (commit `5228fa2`). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** Founder Decision D1 ACCEPTED 2026-05-31 as D1-B (Telegram shim) + package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`); the autosend-bridge **production wiring** (real Telegram Bot API + postgres approvals reader) still lands in Concierge W10-13 build slice. Until then, Cash Conductor cycle.sh Step 10 detects the absent `packages/utilities/autosend-bridge-telegram/dist/` directory and emits a **`drafts_only_mode` marker** via `hh_decision_output` indicating that the orange-tier `xero_reminder_send_customer` row is suppressed (see `cycle.sh` line 287 — this marker is the ONLY row Step 10 emits at the SKELETON layer; the W7-8 build slice replaces this with the full yellow-draft-row + vault-draft + orange-row chain documented in §3 below). The chase-draft pipeline currently halts at the marker; consultants pick up nothing because no vault drafts are produced yet — this is the SKELETON state, intentional, distinct from the W7-8 LIVE-impl drafts-only mode that produces yellow rows + vault drafts.

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

When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml lookup; grep `^  xero_reminder_send_customer:` to verify; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval routing AND the transport-execution, and writes ITS OWN orange-tier action row `gmail_outlook_send_to_candidate` (Concierge-owned; registered in autosend-policy.yaml under §ORANGE) per Concierge agent.md §4 Step 12 — the transport-execution audit row. After Concierge confirms send via webhook to Cash Conductor, Cash Conductor writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output that tracks Cash Conductor's local invoice-state update — the customer-facing send was already audited by Concierge's row).

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
      written by Cash Conductor at Step 10 (Cash Conductor owns the
      CHASE-INITIATION action_type per autosend-policy.yaml lookup;
      agent: cash-conductor).
    → Concierge writes its OWN orange-tier `gmail_outlook_send_to_candidate`
      action row at the TRANSPORT-EXECUTION step (Concierge agent.md §4
      Step 12; agent: concierge). The full chain has two orange-tier rows:
      Cash Conductor's chase-initiation + Concierge's transport-execution.
      Both are autosend-gated; both are audited; agent ownership differs.
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

**Honesty note (updated 2026-06-02 per Codex Fbis-R3 closure):** `agents/recruitment/cash-conductor/validate.sh` **EXISTS as SKELETON** (committed `524bac6` on 2026-06-01) — the 5 Gate A checks G1-G5 are defined as TODO(W7-8) markers inside the SKELETON validate.sh; the W7 build slice replaces the TODOs with live impl per the contract above. The §5 contract describes what validate.sh's TODOs will become; the SKELETON file structurally exists and passes shellcheck CLEAN today but does not yet enforce the checks at runtime.

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
| `validate.sh` Gate A logic (G1-G5 checks; SKELETON file exists at commit `524bac6`; W7 wires live impl) | SKELETON shipped 2026-06-01; W7 live-impl ~1 day | ✅ SCAFFOLDED (W4 Day-26) |
| `context.sh` hydration (SKELETON file exists at commit `5ab2f0f`; W7 wires real provider config + tenant_adapters reads) | SKELETON shipped 2026-06-01; W7 live-impl ~0.5 day | ✅ SCAFFOLDED (W4 Day-26) |
| `cycle.sh` orchestration (14-step SKELETON at commit `6ab59d8`; minimal trigger/output markers fire today; W7 wires per-step impl) | SKELETON shipped 2026-06-01; W7 live-impl ~3 days (most complex of v1.0 agents) | ✅ SCAFFOLDED (W4 Day-26) |
| `tools.yaml` MCP capability declarations (xero_oauth, quickbooks_oauth, sage_oauth, open_banking_truelayer / plaid, telegram_notify, autosend_bridge_telegram_propose + _await) | SKELETON shipped 2026-06-01 + 076e231 bridge wiring; W7 ratifies live | ✅ SCAFFOLDED (W4 Day-26) |
| `cleanup.sh` post-run state purge SKELETON (transient OAuth tokens; provider rate-limit caches; TODO(W7-8) markers; commit `5ab2f0f`) | SKELETON shipped 2026-06-01; W7 live-impl ~0.5 day | ✅ SCAFFOLDED (W4 Day-26) |
| 3 fixtures (`01-primary.yaml` + `02-edge-case-fuzzy-match.yaml` + `99-token-aging-canary.yaml` at commit `5ab2f0f`) | SKELETON shipped 2026-06-01; W7 wires golden-output assertions | ✅ SCAFFOLDED (W4 Day-26) |
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
I’ll verify the cited local files and bundle shape against the ratification rules, then return only the required verdict format.
exec
/bin/zsh -lc 'rg -n "ESC_ACCOUNTING_AUTH|ESC_ACCOUNTING_WRITE_FAIL|ESC_OPEN_BANKING_AUTH|ESC_OPEN_BANKING_TOKEN_AGING|ESC_RECONCILIATION_AMBIGUOUS|ESC_AUTOSEND_RACE|ESC_VOICE_DRIFT|ESC_PII_LEAKAGE_RISK|ESC_AGENT_OUTPUT_SHAPE|ESC_ADDRESSEE_MISMATCH|ESC_GATE_B_MISS|ESC_RATE_LIMIT_HIT|ESC_AUTOSEND_ORANGE_PENDING|ESC_AUTOSEND_BLOCKED|ESC_SCHEMA_VIOLATION|ESC_VOICE_DRIFT_TENANT" agents/_shared/escalation-codes.md' in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "rg -n \"Cash Conductor|DSO|Hire #1|week 7|W7|A4|90-day|12 days|paid in last 24h|correct invoice\" docs -g '*ULTRAPLAN*' -g '*.md' | head -120" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
41:#### `ESC_AUTOSEND_BLOCKED`
120:#### `ESC_VOICE_DRIFT`
148:#### `ESC_PII_LEAKAGE_RISK`
156:#### `ESC_RATE_LIMIT_HIT`
163:#### `ESC_SCHEMA_VIOLATION`
170:#### `ESC_VOICE_DRIFT_TENANT`
172:- **Trigger:** ≥ N `ESC_VOICE_DRIFT` rows from same tenant within rolling window (default N=5, window=7d); fired by nightly voice-drift cron per master brief §8.3 99-voice-drift-canary
184:#### `ESC_AGENT_OUTPUT_SHAPE`
186:- **Trigger:** Agent produced output that doesn't match its declared output shape (e.g. Diagnostic report with section count != 12, missing per-section citation, validate.sh V1/V2 check fail). Distinct from `ESC_SCHEMA_VIOLATION` which is for vertical-schema field-constraint violations at write-time
280:#### `ESC_ACCOUNTING_AUTH`
288:#### `ESC_OPEN_BANKING_AUTH`
296:#### `ESC_OPEN_BANKING_TOKEN_AGING`
312:- **Trigger:** Bullhorn REST write (POST/PUT/PATCH) returned 4xx/5xx after retry budget exhausted; distinct from auth failure (ESC_BULLHORN_AUTH) and rate-limit (ESC_RATE_LIMIT_HIT)
317:#### `ESC_ACCOUNTING_WRITE_FAIL`
319:- **Trigger:** Xero (or alt provider) write call failed after retries; distinct from auth (ESC_ACCOUNTING_AUTH)
341:#### `ESC_AUTOSEND_ORANGE_PENDING`
356:#### `ESC_AUTOSEND_RACE`
377:#### `ESC_GATE_B_MISS`
407:#### `ESC_ADDRESSEE_MISMATCH`
417:#### `ESC_RECONCILIATION_AMBIGUOUS`

 succeeded in 0ms:
docs/operations/goal-overnight-2026-05-31.md:61:- Open Banking connector (90-day token rotation — needs daytime focus)
docs/operations/goal-overnight-2026-05-31.md:62:- Cash Conductor bundle scaffold (depends on connectors landing first)
docs/operations/goal-overnight-2026-05-31.md:80:- Next step on pickup: cluster F manifest entry + Open Banking connector + Cash Conductor bundle
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
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
docs/_supplementary/planning-phase-brief.md:38:| **CC9** | **Custom MCP Servers (6 of them)** — DocuSign, GA4, Meta Ads, Companies House, Prospeo, Dentally | Python (FastMCP) or TypeScript | §3.8 (six of the 15 integration specs) |
docs/_supplementary/planning-phase-brief.md:178:- Session 25: Integration Specs Batch 2 — Stripe, GA4, Meta Ads, Cal.com (3.8)
docs/_supplementary/planning-phase-brief.md:196:**End state of week 7:** dashboard fully spec'd; CC1 build in full flight.
docs/specs/ULTRAPLAN.md:4:**Audience:** Maddox first. Future co-founder / Hire #1 second. The senior engineer who reads this in week six and needs to know what to do without asking.
docs/specs/ULTRAPLAN.md:44:Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.
docs/specs/ULTRAPLAN.md:198:- `02-edge-case-*` — at least one. For Triage, this is "candidate withdrawal email". For Cash Conductor, "partial payment with wrong reference". For Watchtower, "AWR week 12 with intervening sickness break". The edge cases come from the workflow analysis document and the temp deep dive.
docs/specs/ULTRAPLAN.md:418:| Cash Conductor | Tenant's DSO at month-3 ≥ 12 days lower than month-0 baseline | DSO computed from accounting MCP every month; baseline captured at onboarding |
docs/specs/ULTRAPLAN.md:529:#### A4. Cash Conductor (real-time mode) — the FD's evenings back
docs/specs/ULTRAPLAN.md:531:- **Build wave:** v1.0 (week 7–8)
docs/specs/ULTRAPLAN.md:538:- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
docs/specs/ULTRAPLAN.md:539:- **Gate B target:** tenant DSO at month-3 ≥ 12 days lower than month-0 baseline
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
docs/_supplementary/execution-plan.md:237:## PHASE 3 — Platform Engineering Specs (target: end of week 7)
docs/_supplementary/execution-plan.md:291:  - *Prompt per integration:* "Write the {Integration Name} Integration Specification: the MCP server choice (fork X / build from Y spec / official), auth setup (OAuth flow or API key), the scopes/permissions required and why, the specific operations used by agents (read leads, write deals, fetch transcript, etc.), fallback behaviour on failure, test checklist, rate limit handling. Priority 1 integrations: Fathom, HubSpot, Gmail, Slack, Notion, DocuSign. Priority 2: Companies House, Prospeo, Kaspr, Stripe, GA4, Meta Ads, Cal.com, Loom, Google Drive."
docs/_supplementary/execution-plan.md:648:You have strategy, architecture, and a working prototype. You are missing the *stuff a developer actually reads* — 95 discrete documents and decisions, organised into 7 sequenced phases. Start with the 18 Open Decisions this week. Then Phase 1's 10 artifacts until one real Proposal Builder works end-to-end. Then Phase 2's 12 agent bundles. Then Phase 3's 12 platform specs. By week 7 you have everything Claude Code needs to build; Phases 4–7 happen in parallel with and after the build. Tick boxes. Resist scope creep. Ship.
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
docs/_supplementary/technical-strategy-v2.md:259:0 7 * * 5 cd /tenant && claude -p "Run the Reporting Engine. Pull last 7 days from Stripe, GA4, Meta Ads, and HubSpot. Produce the weekly briefing. Save to /outbox/reports/. Post the summary to #leadership in Slack." --output-format json >> /logs/reporting-$(date +\%Y\%m\%d).log 2>&1
docs/specs/_archive-build-handoff.md:253:Confirm or revise Ultraplan §9's assumption: **close the first three pilots fastest**. That means Janitor and Cash Conductor close demos before Triage absorbs the development heat. Revise only if a hire's signed or a different pilot dynamic emerges.
docs/specs/_archive-build-handoff.md:380:| 4 | **Cash Conductor** | 7–8 | Xero + Open Banking | FD-tier closer; the "DSO drops by 15 days" pitch |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:66:| 10 | Reporting Engine | Operations | Friday 07:00 | Weekly briefing | Stripe, GA4, Meta Ads, Slack |
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:206:- GA4 (Reporting Engine)
docs/architecture/architecture-cohesion-review.md:91:| A4 | **`ifos_app` Postgres role is the only role used by app code.** No path uses postgres superuser or admin role. | Day-4 §6.3 grants + RLS posture | If any path uses superuser, RLS is bypassed (RLS doesn't apply to superusers by default). |
docs/architecture/architecture-cohesion-review.md:97:8 implicit assumptions documented. **A1, A2, A4 are catastrophic-if-false** (cross-tenant data leak). **A5, A7 are tested empirically** at current SHA + dev box. **A6, A8 are scale assumptions** that need re-verification at v1.1+.
docs/architecture/architecture-cohesion-review.md:128:- **Resolution path:** Founder Decision D3 in `2026-05-20-codex-round-1-founder-decisions.md`. Recommended D3-B (90-day text purge + indefinite metadata).
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/_supplementary/build-plan-original.md:814:- Last 7 days of data from: Stripe, GA4, Meta Ads, Google Ads, HubSpot, CRM, LinkedIn Ads, Shopify (if retail client), Klaviyo, etc.
docs/_supplementary/build-plan-original.md:821:- **GA4 MCP** — traffic + conversion
docs/_supplementary/build-plan-original.md:1261:| GA4 | No official | Build your own wrapper |
docs/_supplementary/strategic-plan.md:92:8. **Reporting Engine** — pulls from Stripe, GA4, Meta Ads, CRM. Delivers weekly briefing in-Slack + PDF
docs/_supplementary/strategic-plan.md:174:│    Notion, GA4, Meta Ads, Stripe, Calendly, Dentally        │
docs/_supplementary/strategic-plan.md:337:- [ ] **Dev**: Integration layer — HubSpot, Gmail, Fathom, Slack, Notion, DocuSign, Stripe, GA4 (MCP where available, n8n bridge where not)
docs/specs/PRODUCT-SPEC.md:73:#### R2. Real-Time Cash Conductor — the FD's evenings back
docs/specs/PRODUCT-SPEC.md:76:- **Revenue story:** "DSO drops by 15+ days. £40k–£120k of working capital unlocked for a mid-sized agency. One bad debt caught per quarter pays for the entire suite."
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:345:- Cash Conductor runs against historical invoices — produces the DSO baseline.
docs/specs/PRODUCT-SPEC.md:398:| 1 | Persistent PTY via PM2 — agent process pre-loaded with firm voice, ATS state, recent context | Triage, Concierge, Pulse, Watchtower, Cash Conductor |
docs/specs/PRODUCT-SPEC.md:401:| 4 | Approval gates with standing authorisations | Every agent that auto-sends — Triage, Concierge, Cash Conductor, Competitor Interception |
docs/specs/PRODUCT-SPEC.md:430:**1. Every agent now has a quantified revenue story, not just a time-saved story.** The internal business plan and the 24/7 directive had revenue stories for some agents (Cash Conductor, Client Hunter, T5) but not all. Triage was pitched on responsiveness; here it's pitched on "2–4 additional placements/year per consultant from never-lost candidates". Janitor was pitched on database hygiene; here it's pitched on "one reactivated dormant-but-clean candidate per month covers the tier price".
docs/specs/PRODUCT-SPEC.md:474:- Cash Conductor (real-time mode)
docs/specs/PRODUCT-SPEC.md:523:2. **Real-Time Cash Conductor** — "DSO drops by 15+ days, working capital unlocked."
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:22:| 7-8 | Cash Conductor |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:74:- Cash Conductor (W7-8) does NOT touch Bullhorn (per master brief §8.2 line 597); proceeds independent of A+B
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/codex-disagreement-2026-06-02-ob-plaid-internal-stub.md:45:`review-mcp-connector.md` §1 verbatim: "An MCP connector is a self-contained TypeScript workspace package that wraps a single upstream provider". The rule's intent is clear: don't smuggle multi-provider abstractions into per-connector scaffolds. Our case is DIFFERENT — the package wraps the **Open Banking PSD2 abstraction** (a regulatory abstraction), with TrueLayer + Plaid UK as alternative implementations of that abstraction. That's the design intent at the Cash Conductor consumer layer: the agent doesn't care which provider; it asks for "the open-banking data" and the connector dispatches.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:68:**Codex's framing:** "`recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:74:- **D3-B: 90-day text purge + indefinite metadata** — purge `original_text` + `edited_text` after 90 days; keep `edit_distance` + `resolution` + `tone_rules_triggered` (already aggregates) forever. **Loses some SFT corpus signal** but retains the "what rules fired" signal indefinitely.
docs/decisions/2026-05-31-d1-founder-decision.md:22:| **D1-B** Lightweight Telegram shim | Concierge posts to operator's tenant-bound Telegram chat: `[ID:<x>] APPROVE drafted email to <recipient>? /approve <ID> or /reject <ID>`; Concierge polls Telegram or receives webhook; on approve → transport executes | <1 day build | Reuses cortextOS primitive #5 (Telegram surface) already in place; consultants are on Telegram already; lowest engineering cost; clean audit chain (every approve/reject = `decision_log` row); works the same for Cash Conductor + Concierge | Approval UX is a chat reply rather than a rich panel; per-draft attachment preview is just a 200-char text snippet + vault path; consultant must read the vault Markdown if they want to see the full draft body before approving |
docs/decisions/2026-05-31-d1-founder-decision.md:51:3. **Cash Conductor `cycle.sh` Step 10** — same `proposeApproval` call for `xero_reminder_send_customer` rows; identical handling.
docs/decisions/2026-05-31-d1-founder-decision.md:52:4. **`tools.yaml` capability declarations** — add `autosend_bridge_telegram` capability to both Concierge and Cash Conductor.
docs/decisions/2026-05-31-d1-founder-decision.md:57:   **Current state (interim until W10-13 ships):** the bridge consumer's `context.sh` reads the chat-id via the `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` env-var fallback (see `agents/recruitment/concierge/context.sh` line 121 + Cash Conductor's equivalent). The autosend-bridge package itself takes the chat-id as a function argument per its README §Dependency injection — it never reads `tenant_adapters` directly. Fixtures (`agents/recruitment/concierge/fixtures/*.yaml`) use a `tenant_env_overrides:` block (not a `tenant_config:` block) to make the env-var-not-postgres distinction explicit. **No consumer code attempts to read a not-yet-allowlisted key at runtime; no schema violation occurs.**
docs/decisions/2026-05-31-d1-founder-decision.md:70:- **Cash Conductor §8 D1-pending fallback** — flips from "drafts-only if unresolved" to "orange-tier `xero_reminder_send_customer` writes are live once Concierge W10-13 lands the autosend-bridge production wiring."
docs/decisions/2026-05-31-d1-founder-decision.md:82:**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commits `669a4f4` + `9ec2bd6`) — **all consumers operate in env-var-fallback mode today** (per `IFOS_FORCE_EMAIL_CHANNEL` + `IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID` in `context.sh`); no `tenant_adapters` reads attempted at runtime; fixtures use `tenant_env_overrides:` blocks to match. W10-13 build slice picks Path A (reuse `approval_routing` allowlist key) or Path B (v0.4 supplement adding `operator_telegram_chat_id` top-level key); both paths satisfy schema-before-code. Codex ratification currently in flight under cluster G (R3 closing 2026-06-02 per `docs/decisions/codex-disagreement-2026-06-02-*` ledger and the cluster G round-trip arc).
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/RISK-REGISTER.md:13:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 to 4 agents; founder solo through end of v1.0 | Active — not yet at trigger |
docs/RISK-REGISTER.md:25:| 10 | **`recent_edit` raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation** — `vertical-schema.v0.2-supplement.yaml` §1 `recent_edit` entity stores `original_text` + `edited_text` verbatim (length-capped 8192 chars), each potentially containing candidate names, salaries, contact info. v0.2 default is indefinite retention to support v2.0 LoRA SFT corpus. Arguably violates GDPR data-minimisation requirement absent retention rules + redaction protocol. | **Medium** (probability GDPR enforcement action depends on pilot scale + regulator interest) | **High** (regulator notification + fines + reputational damage; potential pilot LOI block) | First pilot LOI signing window approaches AND external advisor (D2) hasn't engaged AND PII retention decision (D3) is unresolved. | **Surfaced by Codex Round 1** (`logs/codex-ratification/manual-run/docs_verticals_recruitment_vertical_schema_v0_2_supplement_yaml.output.md` issue 4). Resolution path: bundle Founder Decision D2 (external advisor engagement) + D3 (90-day text purge vs indefinite vs pilot-controlled) in `2026-05-20-codex-round-1-founder-decisions.md`. **Pre-LOI blocker per `v1.0-kill-criterion.md` §3.4 external-advisor must-fill.** Recommended: D2-A + D3-D (engage advisor this week; D3 decision follows advisor's recommendation; likely D3-B = 90-day text purge + indefinite metadata). **Owner:** founder for D2 + D3; Claude Code for implementation once decisions land. **Source:** Codex Round-1 ratification of v0.2 supplement; also master brief §3 vault/Postgres split + autosend §10 pilot-agreement liability placeholder. |
docs/decisions/bullhorn-integration-path.md:36:| A4 Cash Conductor | No direct Bullhorn (Xero / QuickBooks / Sage + Open Banking) | Ultraplan §8.1 A4 line 533-537 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:290:| **A4 Cash Conductor** (no Bullhorn) | n/a (Xero/QuickBooks/Sage + Open Banking per Ultraplan §8.1 line 533-537) | n/a | n/a | n/a | n/a | n/a |
docs/runbooks/tenant-lifecycle.md:33:                                                │  (90-day legal hold │
docs/runbooks/tenant-lifecycle.md:218:### 90-day legal hold
docs/runbooks/tenant-lifecycle.md:225:**v1.0 default:** 90-day legal hold + tenant-controlled retention beyond.
docs/runbooks/tenant-lifecycle.md:390:| L7 | 90-day purge cron (currently manual) | Low | Automation at v1.1+ when offboarding becomes routine | First offboarding cycle complete |
docs/decisions/sequencing-target.md:24:| A4 | Cash Conductor | 7-8 | Xero + Open Banking | "FD-tier closer; 'DSO drops by 15 days'" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:72:- **If Risk #4 (Hire #1 doesn't start) materialises** — drop Concierge + Sourcing Scout to v1.1 (cut 2 of 6 agents); founder solo through end of v1.0.

exec
/bin/zsh -lc 'rg -n "xero_reminder_send_customer|xero_reminder_draft_internal|accounting_reconciliation_write|gmail_outlook_send_to_candidate" agents/_shared/autosend-policy.yaml agents/_shared/autosend-safety-policy.yaml 2>/dev/null || true' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/autosend-policy.yaml:226:  xero_reminder_draft_internal:
agents/_shared/autosend-policy.yaml:247:  accounting_reconciliation_write:
agents/_shared/autosend-policy.yaml:258:    reason: "Concierge drafts customer-facing email per lifecycle event (acknowledgement / prep / debrief / rejection / placement / nurture etc); draft is internal (not yet sent); the actual customer-facing send is a separate orange-tier action_type (gmail_outlook_send_to_candidate or bullhorn_note_customer_visible). Voice-classified at draft time; sample for ongoing quality review"
agents/_shared/autosend-policy.yaml:273:  gmail_outlook_send_to_candidate:
agents/_shared/autosend-policy.yaml:301:  xero_reminder_send_customer:

exec
/bin/zsh -lc 'ls -la agents/recruitment/cash-conductor && find agents/recruitment/cash-conductor -maxdepth 2 -type f | sort' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
total 240
drwxr-xr-x@ 10 madsadmin  staff    320 Jun  2 14:01 .
drwxr-xr-x@  8 madsadmin  staff    256 May 24 10:46 ..
-rw-r--r--@  1 madsadmin  staff   1697 May 24 10:54 README.md
-rw-r--r--@  1 madsadmin  staff  43141 Jun  2 14:01 agent.md
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
The bundle files exist as claimed. I’m checking the higher-risk citations now: schema-backed fields, escalation definitions, policy action types, and whether the contract drifts from the actual helper interfaces.
exec
/bin/zsh -lc "rg -n \"cash_conductor_transactions|cash_conductor_invoices|last_chase_position|last_chase_sent_at|cash_conductor_last_run|recent_edit|voice_corpus|applies_to_agents|tenant_adapters\" docs/verticals/recruitment agents/recruitment/cash-conductor -g '*.yaml' -g '*.md' -g '*.sql'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 6 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:311:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:327:  # `entities:` for voice_corpus + tone_rule + recent_edit (three entries).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:328:  # voice_corpus_chunks is introduced separately around v0.2 supplement line
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:335:  # four (voice_corpus, tone_rule, recent_edit, voice_corpus_chunks) are
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:577:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:584:      rationale) read voice_corpus for ANN-match exemplars. v0.2 only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:      applies_to_agents containing 'janitor' for tacit-note narrative
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
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:700:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:710:  voice_corpus_chunks:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:728:  recent_edit:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:739:  cash_conductor_transactions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:746:  cash_conductor_invoices:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:755:# §4 — tenant_adapters.config keys (6 declarations: 5 v0.3-new + 1 pre-v0.3 canonicalised)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:758:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:759:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:762:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:764:  cash_conductor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:893:    - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule + recent_edit tables exist)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:902:      CREATE TABLE cash_conductor_transactions with RLS isolation policy +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:905:      CREATE TABLE cash_conductor_invoices with RLS + grants + 3 indexes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:916:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:918:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:956:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:983:  Q4_cash_conductor_transactions_retention:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:991:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:998:      cash_conductor_transactions table is GATED by an explicit per-tenant
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1003:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1040:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1042:    - Concierge tenant_adapters.config field refs valid
agents/recruitment/cash-conductor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R17 closed §8 sibling files + D1/bridge prereqs + §3 audit-row signatures (4-row chase lifecycle sequence). R19 fixes (2026-05-24): split draft body out of decision_log payload into vault path (per ADR-002 vault/Postgres split), recent_edit schema R access cite correction, Stage 3 ESC code disambiguation. **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram approval-shim; `docs/decisions/2026-05-31-d1-founder-decision.md`); `@ifos/autosend-bridge-telegram` package scaffold landed 2026-06-01 (commit `9b282d8`); Cash Conductor consumer wiring landed (commit `076e231`). Remaining gates: Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice replacing the SKELETON TODOs with live impl + Concierge W10-13 build slice landing the autosend-bridge production wiring (Telegram Bot API + postgres approvals reader) so the orange-tier send path activates.
agents/recruitment/cash-conductor/agent.md:59:- **Manual triggers (ifosctl below):** require operator OS account in the `ifos-operators` group; per-invocation `--tenant <slug>` is verified against the operator's tenant access list in `tenant_adapters` before execution. Founder + Hire #1 are the v1.0 ifosctl-authorized operators per master brief §8.2 line 604.
agents/recruitment/cash-conductor/agent.md:178:   → store in Postgres table `cash_conductor_transactions` (RLS-isolated per
agents/recruitment/cash-conductor/agent.md:187:   → store in Postgres table `cash_conductor_invoices` (RLS-isolated;
agents/recruitment/cash-conductor/agent.md:216:     sent (read from `cash_conductor_invoices.last_chase_position` — v0.3
agents/recruitment/cash-conductor/agent.md:277:    → Cash Conductor updates `cash_conductor_invoices.last_chase_position`
agents/recruitment/cash-conductor/agent.md:278:      and `last_chase_sent_at` (v0.3 schema-backed fields per migration §3)
agents/recruitment/cash-conductor/agent.md:300:    → update tenant_adapters.config.cash_conductor_last_run = now()
agents/recruitment/cash-conductor/agent.md:374:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
agents/recruitment/cash-conductor/agent.md:378:- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
agents/recruitment/cash-conductor/agent.md:379:- **NOTE: Cash Conductor does NOT read `recent_edit`.** Per v0.3 supplement §2a access grants (line 729; recent_edit block at lines 721-731), Cash Conductor has W-only access — it WRITES recent_edit rows when consultants edit its chase drafts post-send, but does NOT READ them. Voice continuity for Cash Conductor relies on the tenant voice_corpus + tone_rule reads above. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries (LLM step internal to chase-draft generation; classifier scoring distinct from sample retrieval). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked by the canary (which has R access) for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
agents/recruitment/cash-conductor/agent.md:406:| `context.sh` hydration (SKELETON file exists at commit `5ab2f0f`; W7 wires real provider config + tenant_adapters reads) | SKELETON shipped 2026-06-01; W7 live-impl ~0.5 day | ✅ SCAFFOLDED (W4 Day-26) |
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:10:# hh_load_tone_rules / hh_load_voice_samples / hh_load_recent_edits — those
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:18:# voice_corpus.text_chunks + per-entity voice classifier score fields.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:34:#   v0.2 introduces voice_corpus, voice_corpus_chunks, tone_rule, and recent_edit
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:56:  voice_corpus:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:58:      Per-tenant pack of source documents that define the firm's outbound voice — emails the consultant has written, prior Bullhorn Notes, marketing copy, founder-curated style examples. Read by hh_load_voice_samples (semantic ANN retrieval against the embedded chunks). One voice_corpus per tenant; versioned so re-indexing produces a new row rather than mutating the live pack.
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
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:431:      Voice corpus substrate. 3 new entities (voice_corpus, tone_rule, recent_edit) + 1 pgvector HNSW index (voice_samples_embedded over voice_corpus_chunks) + 6 voice_classifier_score / voice_drift_at_close fields on existing entities + 2 relationships.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:443:      Field expansion based on Concierge's real workload findings. Possibly chunk-strategy parameter added to voice_corpus row (semantic-segment-v1 if paragraph chunking underperforms). Tone rule library expansion (initial ~5-15 per tenant → ~30-50 per tenant as edge cases surface).
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:453:      LoRA SFT pair generation from recent_edit + voice_corpus_chunks. Per-firm fine-tuned models. classifier retraining queue feeds production.
agents/recruitment/cash-conductor/tools.yaml:24:  # Accounting providers (per-tenant — choose ONE via tenant_adapters.config.accounting_provider)
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:26:DROP TABLE IF EXISTS recent_edit          CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:28:DROP TABLE IF EXISTS voice_corpus_chunks  CASCADE;
docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql:29:DROP TABLE IF EXISTS voice_corpus         CASCADE;
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:10:--   - 3 new tables: voice_corpus, tone_rule, recent_edit
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:11:--   - 1 auxiliary table: voice_corpus_chunks (holds the pgvector index)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:15:--   - 2 entity_links link_type values (voice_corpus_governs_tone_rules,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:16:--     recent_edit_drives_retraining); also JSONB-backed in entity_links.metadata
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
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:119:  applies_to_agents   TEXT[]      NOT NULL DEFAULT '{}',
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
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:6:-- side effects on existing recent_edit data).
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:15:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:18:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:19:  DROP CONSTRAINT IF EXISTS recent_edit_text_purged_consistency;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:21:DROP INDEX IF EXISTS recent_edit_text_purged_idx;
docs/verticals/recruitment/migrations/v0.3-to-v0.2-pii-purge.sql:23:ALTER TABLE recent_edit
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:11:--   - 2 new auxiliary tables: cash_conductor_transactions + cash_conductor_invoices
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:26:--   - v0.2 migration applied (voice_corpus + voice_corpus_chunks + tone_rule +
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:27:--     recent_edit tables exist; validate_voice_scores trigger active)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:43:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:44:    RAISE EXCEPTION 'v0.2 voice_corpus table missing; run v0.1-to-v0.2.sql first';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:46:  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'voice_corpus_chunks') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:47:    RAISE EXCEPTION 'v0.2 voice_corpus_chunks table missing; run v0.1-to-v0.2.sql first';
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

exec
/bin/zsh -lc "nl -ba agents/_shared/autosend-policy.yaml | sed -n '210,320p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
/bin/zsh -lc 'rg -n "hh_decision_action|hh_decision_output|hh_decision_trigger|hh_load_tone_rules|hh_load_voice_samples" agents/_shared/hook-helpers.sh agents/_shared/voice-loader.sh' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/_shared/voice-loader.sh:13:#   hh_load_tone_rules     — query tone_rule for applies_to_agents filter
agents/_shared/voice-loader.sh:14:#   hh_load_voice_samples  — pgvector ANN against voice_corpus_chunks
agents/_shared/voice-loader.sh:73:# hh_load_tone_rules [<agent_name>]
agents/_shared/voice-loader.sh:79:hh_load_tone_rules() {
agents/_shared/voice-loader.sh:135:# hh_load_voice_samples <task_context> [<top_k>]
agents/_shared/voice-loader.sh:151:hh_load_voice_samples() {
agents/_shared/hook-helpers.sh:192:# hh_decision_trigger <trigger_type> [<reason>]
agents/_shared/hook-helpers.sh:194:hh_decision_trigger() {
agents/_shared/hook-helpers.sh:203:# hh_decision_output <output_type> <artefact_ref> [<reason>]
agents/_shared/hook-helpers.sh:206:hh_decision_output() {
agents/_shared/hook-helpers.sh:216:# hh_decision_action <action_type> <target> <payload_hash> <payload_preview>
agents/_shared/hook-helpers.sh:219:hh_decision_action() {

exec
/bin/zsh -lc "rg -n \"§8\\.2|Cash Conductor|Hire #1|DSO drops|Week|W7\" docs -g '*brief*' -g '*master*' -g '*.md' | head -160" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "rg --files docs | rg -i 'master|brief|kill|autosend'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/build-brief/00-MASTER-BRIEF.md
docs/decisions/autosend-approval-bridge-spec.md
docs/decisions/autosend-safety-policy.md
docs/decisions/v1.0-kill-criterion.md
docs/_supplementary/planning-phase-brief.md

 succeeded in 0ms:
docs/runbooks/pii-purge-operational-pattern.md:167:Weekly health check (recommend a Brain UI v1.1 widget OR ad-hoc query):
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:13:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 to 4 agents; founder solo through end of v1.0 | Active — not yet at trigger |
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:22:| 6 | **Concurrency-document-prerequisite** — without `docs/architecture/vault-concurrency.md`, the wiki/lib/concurrency.ts code can't be reviewed; week-5 first multi-agent test runs against unreviewed concurrency machinery | ~~Medium~~ **Closed** | ~~Medium~~ **Closed** | (closed) | **Closed 2026-05-16 Day 3 evening:** `docs/architecture/vault-concurrency.md` shipped at 455 lines. 4 mechanisms specified with TypeScript worked examples (`flock(2)`, Postgres optimistic concurrency, mtime debounce, rewrite-backlinks cascade). 5 new `ESC_VAULT_*` codes consolidated for `_shared/hook-helpers.sh` Week-1 prereq. Surfaces 1 new Day-4 tightening (`entities.version` column per §3.1). v1.0 atomicity gap honestly documented; v1.2+ WAL pattern deferred. **Source:** Spec gap 2.6 in `second-brain-design.md`. |
docs/RISK-REGISTER.md:23:| 7 | **Master-brief-drift-accumulation** — eight ADR-driven edits + one Day-4 Postgres-rename + multiple Week-1 prerequisite artefacts have accumulated as deferred master-brief / Ultraplan edits. Without the atomic correction commit, drift compounds and the master brief becomes increasingly unreliable as the operative document | Medium | Medium (every session that reads master brief reads stale wording) | Codex Day 7 ratification reviews a master brief that still contains the drifts | Bundle all nine edits into one atomic correction commit at end of Week 0 / early Week 1 with message `docs: master brief reconciliation — ADR-001 + ADR-002 + ADR-003 + Bullhorn + Day 3 spec drifts + Hetzner-NBG1`. Codex ratifies the commit alongside the ten+ Week 0 artefacts. **Owner:** founder + Claude Code, end of Week 0. **Source:** ADR-001 + ADR-002 + ADR-003 + `bullhorn-integration-path.md` + `sequencing-target.md` + `brain-ui-scope.md` + Day 4 runbook §0.1. **Updated Day 4 (2026-05-17):** edit count rose from 8 to 9 with Day-4 Edit 9 (master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner FSN1 or NBG1; both acceptable Hetzner eu-central locations" — verified from Day-4 execution against NBG1 because FSN1 was unavailable at provisioning time). **Citation audit 2026-05-18:** earlier drafts also cited master brief §10.4 as a Hetzner/cost-target section; verified §10.4 is the Codex exclusion list ("What never goes through ratification") and contains no Hetzner or cost-target content. Edit 9 scope corrected to line 477 only. |
docs/RISK-REGISTER.md:46:- Two-instance PATH conflict for bus commands → **Updated 2026-05-16 evening:** folds into the renderer's CLAUDE.md preamble responsibility (ADR-003 design §2.1-A). The preamble draft in design §2.3 sets `CTX_AGENT_DIR` explicitly; rendered hook scripts source `_shared/` helpers via `${CTX_AGENT_DIR}/.claude/hooks/_shared/` rather than relying on `PATH` resolution. Quirk 3 is no longer a Week-1 risk — it's a renderer test case.
docs/RISK-REGISTER.md:59:- 2026-05-16 (Day 1 evening extension) — Risk #5 severity revised from **Blocking** to **High** (ADR-003 + design doc Accepted; staged reductions to Medium and Low named). Risk #7 edit count revised from 3 to 5 (ADR-003 Edit C added). Day-0 quirk 3 (PATH conflict) updated: no longer a Week-1 risk — folds into renderer preamble responsibility per ADR-003 design §2.3. No new risks surfaced from renderer design work.
docs/RISK-REGISTER.md:60:- 2026-05-16 (Day 2) — Risk #2 status entry updated: Sub-decision C **Accepted** per `bullhorn-integration-path.md` §4 + §5; Sub-decisions A and B **Proposed** with named reduction triggers (Sunday/Monday commercial conversations). Two staged severity reductions specified (High → Medium on commercial answers; Medium → Low on first Week 3-4 Bullhorn write landing clean). Risk #7 edit count revised from 5 to 6 (Bullhorn decision §6.6 sixth edit added — master brief §6 Day 2 line 466 `service-account for dev` correction). No new risks surfaced from Day 2 — Sub-decisions A and B Proposed is the intended honest state pending commercial verification, not a new risk surface.
docs/RISK-REGISTER.md:61:- 2026-05-16 (Day 3) — Risk #5 entry updated with three-stage severity ladder per `sequencing-target.md` §4.1 + §6.4 (Blocking → High done Day 1 evening; High → Medium at W4 Diagnostic first render; Medium → Low at W13 all 5 v1.0 bundles rendered). Risk #7 edit count revised from 6 to 8 (`sequencing-target.md` §6.8 7th edit on master brief §6 Day 3 line 471 path drift + `brain-ui-scope.md` §4.5 8th edit on line 472 three-drift bundle). No new risks surfaced from Day 3 — sequencing-target ratifies master brief §8.2 sequence with explicit gating (no new risk surface); brain-ui-scope defers to v1.1 phase (no new risk surface). Two new escalation codes from Day 3 work registered: `ESC_RENDERER_FAILED` (already in ADR-003 design §4.7) and the `decision_log.phase` enum extensions (`gating_failed`, `agent_handoff`) per `sequencing-target.md` §5-A — both Week-1+ implementation prereqs.
docs/RISK-REGISTER.md:62:- 2026-05-16 (Day 3 evening) — **Risk #6 closed.** `docs/architecture/vault-concurrency.md` shipped (455 lines, reference document). 4 mechanisms specified with worked examples; 5 new `ESC_VAULT_*` codes consolidated for `_shared/hook-helpers.sh` Week-1 prereq wiring (`ESC_VAULT_LOCK_TIMEOUT`, `ESC_VAULT_VERSION_MISMATCH`, `ESC_VAULT_HUMAN_EDIT_BLOCKED`, `ESC_VAULT_CASCADE_PARTIAL_FAILURE`, `ESC_VAULT_CASCADE_TIMEOUT`). Risk #7 edit count unchanged at 8 — `vault-concurrency.md` is reference synthesis, surfaces no new master-brief drifts. Surfaces one new Day-4 tightening (`entities.version` column per §3.1) — Day 4 now has 4 consolidated tightenings.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
docs/_archive-build-pack/09-CLAUDE-CODE-UTILITY.md:160:| Weekly | "Pull cortextOS upstream, diff against `packages/harness/cortextos/`, surface what's safe to apply" | Keeps the vendored copy fresh without weekly manual checks |
docs/operations/goal-overnight-2026-05-31.md:62:- Cash Conductor bundle scaffold (depends on connectors landing first)
docs/operations/goal-overnight-2026-05-31.md:80:- Next step on pickup: cluster F manifest entry + Open Banking connector + Cash Conductor bundle
docs/runbooks/day-4-provisioning.md:15:This runbook is the **reviewable plan** for Day 4 of Week 0 per master brief §6 Day 4. It is **not executed by writing it.** Execution happens in a separate session against a real VPS after this document is reviewed and ratified.
docs/runbooks/day-4-provisioning.md:27:- **Rule 2 (Schema before code):** no agent code is written until Week 0 closes. This runbook provisions schema only.
docs/runbooks/day-4-provisioning.md:56:**Master-brief correction:** add to the atomic-correction commit manifest (currently 8 edits at end of Week 0). Proposed Edit 9: master brief §6 Day 4 line 477 — "Hetzner UK" → "Hetzner Falkenstein (FSN1) or Nuremberg (NBG1); both acceptable Hetzner eu-central locations"; flag UK-residency as a commercial-conversation gate. (Earlier drafts also referenced "§10.4" as a separate location-naming surface; verified that §10.4 — "What never goes through ratification" — contains no Hetzner or cost-target content. §10.4 component dropped.)
docs/runbooks/day-4-provisioning.md:100:- v1.1+ multi-user: sudo password may be revisited when Hire #1 onboards (master brief Risk #4)
docs/runbooks/day-4-provisioning.md:1058:### §8.2 — Postgres-level: nightly pg_dump
docs/runbooks/day-4-provisioning.md:1065:# IFOS Postgres nightly backup — Day 4 runbook §8.2
docs/runbooks/day-4-provisioning.md:1133:- [ ] §8.2 — `/etc/cron.d/postgres-backup` exists; manual `pg_dump` test succeeded
docs/runbooks/day-4-provisioning.md:1158:| §8.2 backup | Manual `pg_dump` test fails | Check `/var/backups/postgres` ownership, disk space, Postgres user permissions; the cron will fail nightly until this works |
docs/runbooks/day-4-provisioning.md:1189:- Still single Codex ratification on Day 7 (or end-of-Week-0)
docs/runbooks/day-4-provisioning.md:1285:- Not the agent code (Week 1+ work)
docs/runbooks/day-4-provisioning.md:1286:- Not the wiki-brain provisioning (the `wiki-*` parallel scripts land Week 1-2 per ADR-002)
docs/runbooks/day-4-provisioning.md:1287:- Not the `_shared/voice-loader.sh` + `hook-helpers.sh` build (the remaining Week-1 prereq)
docs/runbooks/day-4-provisioning.md:1288:- Not the Bullhorn MCP connector (Week 1-2 per `bullhorn-integration-path.md` §6)
docs/specs/ULTRAPLAN.md:4:**Audience:** Maddox first. Future co-founder / Hire #1 second. The senior engineer who reads this in week six and needs to know what to do without asking.
docs/specs/ULTRAPLAN.md:44:Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.
docs/specs/ULTRAPLAN.md:198:- `02-edge-case-*` — at least one. For Triage, this is "candidate withdrawal email". For Cash Conductor, "partial payment with wrong reference". For Watchtower, "AWR week 12 with intervening sickness break". The edge cases come from the workflow analysis document and the temp deep dive.
docs/specs/ULTRAPLAN.md:371:Weekly cron job per tenant:
docs/specs/ULTRAPLAN.md:418:| Cash Conductor | Tenant's DSO at month-3 ≥ 12 days lower than month-0 baseline | DSO computed from accounting MCP every month; baseline captured at onboarding |
docs/specs/ULTRAPLAN.md:529:#### A4. Cash Conductor (real-time mode) — the FD's evenings back
docs/specs/ULTRAPLAN.md:601:#### A9. Real-time Cash Conductor reframe (2 weeks)
docs/specs/ULTRAPLAN.md:688:| Cash Conductor | ✓ | | | ✓ | | | | | | ✓ | Open Banking |
docs/specs/ULTRAPLAN.md:713:7. **Xero / QuickBooks / Sage** — 4 of 18 (one per tenant typically). Cash Conductor's blocker.
docs/specs/ULTRAPLAN.md:722:- Maddox solo for weeks 0–6; Hire #1 starts week 7 (per the most plausible reading of the user's memory, with caveat in §10).
docs/specs/ULTRAPLAN.md:727:### Week 0 — Pre-build clearance (the seven-day window from §11)
docs/specs/ULTRAPLAN.md:743:### Weeks 1–2 — Foundation
docs/specs/ULTRAPLAN.md:745:- Week 1: Agent Bundle v2 pattern refactor; `_shared/` module build; voice loader; escalation codes catalogue; vertical schema v0.1
docs/specs/ULTRAPLAN.md:746:- Week 2: Tenancy plumbing (Postgres RLS, tenant provisioning scripts, PM2 ecosystem generator); backup setup; first dry-run tenant provisioned end-to-end
docs/specs/ULTRAPLAN.md:750:### Weeks 3–4 — Bullhorn + Diagnostic
docs/specs/ULTRAPLAN.md:752:- Week 3: Bullhorn MCP server build (auth, read endpoints, write endpoints, webhook subscription)
docs/specs/ULTRAPLAN.md:753:- Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint
docs/specs/ULTRAPLAN.md:757:### Weeks 5–6 — Janitor + Scribe
docs/specs/ULTRAPLAN.md:759:- Week 5: Janitor agent; day-30 before/after report template; CI fixtures
docs/specs/ULTRAPLAN.md:760:- Week 6: Scribe agent; Fathom + Fireflies MCP; tacit-note taxonomy v0.1
docs/specs/ULTRAPLAN.md:764:### Weeks 7–8 — Cash Conductor + Hire #1 onboards
docs/specs/ULTRAPLAN.md:766:- Week 7: Hire #1 onboards (assumed); Xero MCP + Open Banking integration
docs/specs/ULTRAPLAN.md:767:- Week 8: Cash Conductor agent; chase-cadence config; tenant-level baseline DSO captured
docs/specs/ULTRAPLAN.md:769:Milestone: Cash Conductor running in shadow mode against first pilot's accounting data.
docs/specs/ULTRAPLAN.md:771:### Weeks 9–10 — Sourcing Scout + Concierge start
docs/specs/ULTRAPLAN.md:773:- Week 9: Sourcing Scout (daytime); LinkedIn + Reed + CV-Library integration
docs/specs/ULTRAPLAN.md:774:- Week 10: Concierge build starts (4-week build); first pilot landed for shadow-mode trial
docs/specs/ULTRAPLAN.md:778:### Weeks 11–14 — Concierge completion + first pilot conversion
docs/specs/ULTRAPLAN.md:780:- Weeks 11–13: Concierge build continues; Brain UI minimal v1 (the "what did the agents do today" view); auto-send graduation for Triage-eligible categories (initially Concierge-only candidate-acknowledgement)
docs/specs/ULTRAPLAN.md:781:- Week 14: First pilot converts to paid; pilots 2 and 3 sales conversations active
docs/specs/ULTRAPLAN.md:788:- Weekly review: Friday afternoon. Three questions: what shipped, what's stuck, what changed in the plan
docs/specs/ULTRAPLAN.md:800:5. Cash Conductor's escalation-tier-3 (bad debt write-off draft) — manual until 6 months in
docs/specs/ULTRAPLAN.md:819:| 3 | First design partner not signed by end of week 0 | Medium | High | Week 0 ends without LOI | Sales conversations start before week 0; do NOT begin code until first LOI lands |
docs/specs/ULTRAPLAN.md:820:| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0 |
docs/specs/ULTRAPLAN.md:821:| 5 | Open Banking integration takes more than 1 week | Medium | Medium | End of week 7 status not "Xero + first bank connected" | Cash Conductor ships with manual reconciliation in v1.0; webhook-driven mode at v1.1 |
docs/specs/ULTRAPLAN.md:855:- [ ] Hire #1 status one-liner. **Owner:** Maddox.
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:8:## §1 Phase A — Cash Conductor bundle completion (~3h, 3-5 commits)
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:15:Closes goal-week-4-track-1.md §1 criteria 5-10. Cluster F-bis manifest entry queued (Cash Conductor agent-bundle skill) — actual entry to `run-codex-ratification.sh` lands at start of Day-27 when ready to fire cluster F + F-bis together.
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:25:- Fail-safe: timeout returns `{outcome: "timeout"}` not an exception — caller (Cash Conductor cycle.sh Step 10, Concierge cycle.sh) decides how to fire the ESC code
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:27:≥12 vitest (scaffold + config + propose + await with poll-mock + timeout + reject path + concurrent same-approval-id idempotency). Live Telegram tests gated `BRIDGE_LIVE_TESTS=true`. Zero credential interpolations in errors. README documents D1-B precedent + Concierge W10 integration contract + Cash Conductor `cycle.sh` Step 10 wiring.
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:47:Print: phase A/B/C status + commit SHAs · test counts (bridge: ≥12 vitest target) · Cash Conductor bundle 100% complete? · bridge package scaffold complete? · 2 polish items closed? · founder action board refresh · tomorrow's first action (cluster F + F-bis ratification triggers when founder ready; voice classifier microservice begins Tue scaffold).
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:3:**Date:** 2026-05-24 (Day 19; end of Week 3 goal execution)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:15:Week 3 goal at `docs/operations/goal-week-3-polish-and-scaffold.md` Step 7 (Codex Round 4 Phase 1) ratified `agents/recruitment/diagnostic/agent.md`. Codex found 4 issues; mechanical remediation applied (commit `6e0cb86`); Round 5 re-ratification found 5 new issues — 2 re-raises (Codex disagreed with my remediation framing), 3 new findings not visible at Round 4.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:83:**This is the load-bearing finding** — it surfaces that **the lazy-skill deferral is now blocking proper agent.md ratification.** Building `review-agent-bundle.md` is a Week-3-extension or W4 priority.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:92:4. **Authorise Week-3-extension OR W4-priority work** to build `review-agent-bundle.md` Codex skill (Issue 5)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:97:## What this means for Week 3 goal closure
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:104:**Week 3 goal is therefore complete to the boundary of what can be done without founder arbitration.** Final §10 end-of-goal report acknowledges this and queues the founder-decision items.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:106:Recommended next step (post-arbitration): Week-3-extension or W4-prio-1 build of `review-agent-bundle.md` skill; then re-run Codex Round 4 against all 6 v1.0 agent.md files with the proper skill.
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
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:322:### Week-3 close status (honest signal per Rule 5)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:332:- Cash Conductor: pre-build-scaffold; Round-8-reviewed; Postgres-table-creation (Cat-β) + catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:340:4. Re-ratify per agent.md at end of its build wave; not in Week-3 close
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:342:**Week 3 IS closed** per documented protocol: scaffolds at Pre-Build-Round-8-Reviewed status with Cat-α mechanical fixes applied + Cat-β/γ/δ/ε findings categorized + queued. Honest signal: 0/6 RATIFIED by Round 8; categorization shows residual findings are structural (schema landing, build-slice delivery) not relitigation of the 5-category dispositions. Diagnostic v0 Build (validate.sh + cycle.sh exist; just incomplete) remains the most ready for v3-W4 polish.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:355:- `ESC_ADDRESSEE_MISMATCH` — now covers both Cash Conductor xero/bullhorn + Concierge candidate-email (mismatch_class field)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:358:- `ESC_OPEN_BANKING_TOKEN_AGING` — three staged behaviors aligned to Cash Conductor §6
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:373:| Cash Conductor | 5 | 5 | 0 (different findings; 1 Cat-γ closed, 1 new) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:420:5. **§6/§3 cross-agent consistency pass** — 5 Cat-α findings across Diagnostic + Scribe + Cash Conductor + Sourcing Scout + Concierge that span sections; bilateral session 2 or schema-supplement landing
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:429:| Cash Conductor | Pre-Build-Round-9-Reviewed | 5 (Cat-β + Cat-γ residual) | v0.3 + ESC widening 2 |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:433:*End of Codex bilateral disposition document (Phase 1 + 2 + 3 + 4 executed; 10 rounds total; Week 3 closed; v0.3 supplement + ADR-006 are the next structural unblocks).*
docs/_supplementary/PRD-autonomous-agent.md:354:      "description": "Weekly asset library audit"
docs/_supplementary/PRD-autonomous-agent.md:360:      "description": "Weekly performance summary to Telegram"
docs/_supplementary/PRD-autonomous-agent.md:675:- Weekend: lighter/more personality-driven content is acceptable
docs/_supplementary/PRD-autonomous-agent.md:1881:## Sundays 10:00 UTC — Weekly Report
docs/_supplementary/PRD-autonomous-agent.md:1989:### Phase 1: Foundation — End-to-end manual pipeline (Week 1-2)
docs/_supplementary/PRD-autonomous-agent.md:2129:### Phase 2: Templates & Polish (Week 3)
docs/_supplementary/PRD-autonomous-agent.md:2143:### Phase 3: Discovery & Automation (Week 4)
docs/_supplementary/PRD-autonomous-agent.md:2249:### Phase 4: 24/7 Persistence (Week 5)
docs/_supplementary/PRD-autonomous-agent.md:2311:### Phase 5: Learning System (Week 5-6)
docs/_supplementary/PRD-autonomous-agent.md:2349:### Phase 6: Production Run (Week 6+)
docs/runbooks/operational-hygiene-protocol.md:3:**Status:** In force (Day 6, 2026-05-18). All sections from Week 0 onwards reference this document at section-gate moments.
docs/runbooks/operational-hygiene-protocol.md:12:Days 0-6 self-grade on Week-0 retrospective (Day-6 evening):
docs/runbooks/operational-hygiene-protocol.md:329:| 2 | Should §4.1 per-unit-line-budget table get its own per-week revision as new artefact types emerge? | Yes; track in this doc. Update after each new artefact type ships (e.g., when first agent bundle ships in Week 3-4, add "Agent bundle" row with calibrated budget). |
docs/runbooks/operational-hygiene-protocol.md:330:| 3 | Should §5 citation discipline be enforced via pre-commit hook (mechanical grep + verify)? | Defer to Week 1-2. Hook would be valuable but is itself code-to-write. v1.0: discipline is mental; v1.1+: tool-enforced. |
docs/operations/codex-round-2-remediation-prompt.md:202:      Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema,
docs/operations/codex-round-2-remediation-prompt.md:206:      A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate.
docs/operations/codex-round-2-remediation-prompt.md:217:  | Week-1 prereq code | None — substrate is ATS-agnostic | DONE (Phases 1-5 landed Day 8) |
docs/operations/codex-round-2-remediation-prompt.md:268:         enumeration. Note that the bridge implementation slice (Week 9)
docs/operations/codex-round-2-remediation-prompt.md:354:  Resolution path: bridge implementation slice (Week 9) updates §2
docs/specs/_archive-build-handoff.md:35:5. Work the Week 0 checklist before any agent code gets written
docs/specs/_archive-build-handoff.md:253:Confirm or revise Ultraplan §9's assumption: **close the first three pilots fastest**. That means Janitor and Cash Conductor close demos before Triage absorbs the development heat. Revise only if a hire's signed or a different pilot dynamic emerges.
docs/specs/_archive-build-handoff.md:306:**Five yeses → Week 1 starts Monday. Anything less → Week 0 extends by however long it takes to close the no.**
docs/specs/_archive-build-handoff.md:380:| 4 | **Cash Conductor** | 7–8 | Xero + Open Banking | FD-tier closer; the "DSO drops by 15 days" pitch |
docs/specs/_archive-build-handoff.md:384:After Concierge ships, the first pilot converts to paid (Week 14 milestone). v1.1 then layers Triage, Brief Decoder, Competitor Interception, Night Sourcer, and the Temp agents T5 + T3.
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/specs/_archive-build-handoff.md:476:- Skip the Week 0 checklist because "we've already started building"
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:18:> **10 calls per second concurrent throttle** (not enforced here — single-process Cash Conductor cycle.sh is serial)
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:20:Intuit's "10 concurrent calls per realmId" cap fires when ≥10 in-flight HTTP requests exist simultaneously against the same realm. Cash Conductor `cycle.sh` calls `@ifos/quickbooks` from a serial bash flow — `await` resolves before the next call is issued. The number of in-flight requests against any one realm at any moment is **exactly 1**. The concurrent throttle cannot be hit by definition.
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:37:The "not enforced here" caveat is right there in the rate-limit section. A future maintainer who switches Cash Conductor to a multi-process or concurrent caller has the explicit note to act on. This is honest signal, not omission.
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:43:- Cash Conductor cycle.sh becomes multi-process (e.g. one process per tenant running in parallel against the same QB realm — only realistic if a single IFOS tenant connects multiple QB realms or if we shift to a worker-pool model).
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:44:- A new consumer of `@ifos/quickbooks` lands that doesn't share Cash Conductor's serial-bash discipline (e.g. a webhook handler that batches concurrent invoice lookups).
docs/decisions/codex-disagreement-2026-06-02-qb-concurrent-throttle.md:51:Nothing functional. The README + `src/rate-limit.ts` module comment retain the "not enforced here; single-process Cash Conductor cycle.sh is serial" caveats (already present pre-Codex-review). No new code. No new test. No README edit — the existing language is the right disclosure.
docs/_archive-build-pack/07-V1-INHERITED-CONTEXT.md:66:| 10 | Reporting Engine | Operations | Friday 07:00 | Weekly briefing | Stripe, GA4, Meta Ads, Slack |
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:253:| Q5 | When `autosend_approval_mappings` ships in v0.3 with the bridge implementation (per `docs/decisions/autosend-approval-bridge-spec.md`), must T1-T3 + T11 + T12 update the table inventory + audit script? | Bridge implementation slice (Week 9) updates §2 enumeration and `scripts/run-tenancy-audit.sh` `TENANT_TABLES` array. |
docs/runbooks/tenant-lifecycle.md:388:| L5 | Brain UI v1.1 tenant-admin UI for status changes | Medium | Brain UI W11-13 build slice | Week 11 |
docs/build-brief/00-MASTER-BRIEF.md:46:The five rules in §1 govern every decision. The boundary in §3 governs every file. The Week 0 list in §6 is the only thing to do this week. Read all three before writing any agent code.
docs/build-brief/00-MASTER-BRIEF.md:279:| `.agents/current-priorities.md` | What we're doing this week | `Week 0: clear the §6 checklist` |
docs/build-brief/00-MASTER-BRIEF.md:413:| **v1.0 minimum** | Weeks 11–13 (Ultraplan §9) | 9 `wiki-*.sh` parallel wrappers under `packages/brain/bus-overrides/` + 9 `wiki/lib/*.ts` modules + 4 Postgres tables with RLS (`tenants`, `entities`, `entity_links`, `decision_log`) + pgvector index for voice samples — agents can search, ingest, update, append, and list; **no Brain UI yet**. Total v1.0 effort ~11-13 person-days. |
docs/build-brief/00-MASTER-BRIEF.md:432:## 6. Week 0 — the only thing that matters this week
docs/build-brief/00-MASTER-BRIEF.md:441:- [ ] Create `.agents/current-priorities.md`: single line `Week 0: clear the §6 checklist`
docs/build-brief/00-MASTER-BRIEF.md:446:The single most important Week 0 task.
docs/build-brief/00-MASTER-BRIEF.md:465:- [ ] Hire #1 status one-liner
docs/build-brief/00-MASTER-BRIEF.md:494:**Five yeses → Week 1 starts Monday. Anything less → Week 0 extends.**
docs/build-brief/00-MASTER-BRIEF.md:589:Build the catalogue in Week 0. New codes only when production demands one.
docs/build-brief/00-MASTER-BRIEF.md:593:| # | Agent | Weeks | Key dependency | Why this order |
docs/build-brief/00-MASTER-BRIEF.md:598:| 4 | Cash Conductor | 7–8 | Xero + Open Banking | FD-tier closer; "DSO drops by 15 days" |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:764:For Week 0:
docs/build-brief/00-MASTER-BRIEF.md:766:- Day 7: Codex reviews the seven Week 0 artefacts (primitive audit, Bullhorn path, Brain UI scope, infra checklist, safety policy, kill criterion, vertical schema v0.1) — first ratification run
docs/build-brief/00-MASTER-BRIEF.md:768:After Week 0:
docs/build-brief/00-MASTER-BRIEF.md:771:- Weekly ratification of risk register changes (informal — 5 min spot-check)
docs/build-brief/00-MASTER-BRIEF.md:827:| "Let me build Triage first because it's the most exciting..." | §8.2 |

exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/agent.md | sed -n '1,470p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Cash Conductor — the FD's evenings back
     2	
     3	**Status:** Proposed.
     4	**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R17 closed §8 sibling files + D1/bridge prereqs + §3 audit-row signatures (4-row chase lifecycle sequence). R19 fixes (2026-05-24): split draft body out of decision_log payload into vault path (per ADR-002 vault/Postgres split), recent_edit schema R access cite correction, Stage 3 ESC code disambiguation. **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram approval-shim; `docs/decisions/2026-05-31-d1-founder-decision.md`); `@ifos/autosend-bridge-telegram` package scaffold landed 2026-06-01 (commit `9b282d8`); Cash Conductor consumer wiring landed (commit `076e231`). Remaining gates: Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice replacing the SKELETON TODOs with live impl + Concierge W10-13 build slice landing the autosend-bridge production wiring (Telegram Bot API + postgres approvals reader) so the orange-tier send path activates.
     5	
     6	**Reading-discipline note (added 2026-06-02 per Codex Fbis-R3 closure):** this `agent.md` is the **CONTRACT** that the W7-8 build slice implements against. The 6 sibling bundle files (`cycle.sh` + `validate.sh` + `context.sh` + `cleanup.sh` + `tools.yaml`) + 3 fixtures EXIST AS SCAFFOLD (landed across commits `6ab59d8` + `5ab2f0f` + `076e231` + `bccef02` + `5d398eb` per Day-26 + R-round closures); they carry `TODO(W7-8)` markers throughout that the W7-8 build slice replaces with live implementation matching the contract below. **Audit-row signatures + workflow steps documented below describe the CONTRACT shape; current SKELETON cycle.sh emits only the minimal trigger/output markers (`session_start`, `auth_refresh_complete`, `mode_routed`, `transactions_ingested`, `invoices_ingested`, `reconciliation_pass`, `chase_pass_complete`, `drafts_only_mode`, `weekly_report`, `cash_conductor_run_complete`) listed at `cycle.sh` lines 88, 100, 114, 127, 140, 152, 178, 287, 329, 342.** The yellow-tier + orange-tier audit rows the contract names are NOT yet emitted at runtime — they're the W7-8 contract surface, not current behavior. Don't read agent.md as a description of running code; read it as the spec the W7-8 build slice implements.
     7	**Date:** 2026-05-24.
     8	**Author:** Founder (Maddox) + Claude Code.
     9	**Build wave:** v1.0 W7-8 per master brief §8.2 line 598 + ULTRAPLAN §8.1 A4 line 531 (both say W7-8; consistent).
    10	**Build complexity:** L (2 weeks) per ULTRAPLAN A4 line 540.
    11	**Tier:** Tier 1 (persistent watcher on accounting + bank webhooks + cron sweep) per ULTRAPLAN A4 line 532.
    12	**Hire #1 anchor:** per master brief §8.2 line 604 — "Cash Conductor at week 7-8 because Hire #1 is assumed to start week 7". First sprint for Hire #1.
    13	
    14	---
    15	
    16	## §1 — Output contract (one-paragraph screenshot)
    17	
    18	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    19	
    20	> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the `xero_reminder_send_customer` action_type (registered in autosend-policy.yaml under §ORANGE; grep `^  xero_reminder_send_customer:` to verify) which is the **chase-approval-initiation** audit row; Concierge runs the autosend bridge for approval routing, then performs the transport-execution and writes its OWN orange-tier `gmail_outlook_send_to_candidate` action row (Concierge-owned; registered under §ORANGE). Both agents write tier-classified action rows — the distinction is: Cash Conductor writes the initiation; Concierge writes the transport. The full autosend chain has TWO orange-tier rows in sequence (initiation + transport), both gated, both audited. Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport; and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW — grep `^  xero_reminder_draft_internal:` to verify; internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (registered under §ORANGE — grep `^  xero_reminder_send_customer:`; consultant approval required before send). **Note on citation discipline:** explicit line numbers in `autosend-policy.yaml` shift across edits; this agent.md uses grep-anchors instead per the pattern established in xero R3 closure (commit `5228fa2`). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** Founder Decision D1 ACCEPTED 2026-05-31 as D1-B (Telegram shim) + package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`); the autosend-bridge **production wiring** (real Telegram Bot API + postgres approvals reader) still lands in Concierge W10-13 build slice. Until then, Cash Conductor cycle.sh Step 10 detects the absent `packages/utilities/autosend-bridge-telegram/dist/` directory and emits a **`drafts_only_mode` marker** via `hh_decision_output` indicating that the orange-tier `xero_reminder_send_customer` row is suppressed (see `cycle.sh` line 287 — this marker is the ONLY row Step 10 emits at the SKELETON layer; the W7-8 build slice replaces this with the full yellow-draft-row + vault-draft + orange-row chain documented in §3 below). The chase-draft pipeline currently halts at the marker; consultants pick up nothing because no vault drafts are produced yet — this is the SKELETON state, intentional, distinct from the W7-8 LIVE-impl drafts-only mode that produces yellow rows + vault drafts.
    21	
    22	---
    23	
    24	## §2 — Invocation surface
    25	
    26	### Webhook (v1.0 primary path)
    27	
    28	```http
    29	POST https://<tenant>.ifos.app/agents/cash-conductor/webhook
    30	Authorization: Bearer <provider-shared-secret>
    31	Content-Type: application/json
    32	
    33	# Event types (per provider):
    34	# - Xero/QuickBooks/Sage: invoice.created, invoice.sent, invoice.viewed,
    35	#   invoice.paid, payment.received
    36	# - Open Banking (TrueLayer/Plaid UK): transaction.posted, balance.updated
    37	```
    38	
    39	Per-provider webhook auth handled in `tools.yaml`.
    40	
    41	### Cron (daily reconciliation sweep)
    42	
    43	```bash
    44	# 07:00 UTC daily — bank feed catch-up + invoice age scan
    45	0 7 * * * sudo -u ifos_user /usr/local/bin/ifos-cash-conductor.sh --tenant <slug> --mode daily-sweep
    46	```
    47	
    48	### Weekly report cron
    49	
    50	```bash
    51	# Monday 06:00 UTC — cash-flow report regeneration
    52	0 6 * * 1 sudo -u ifos_user /usr/local/bin/ifos-cash-conductor.sh --tenant <slug> --mode weekly-report
    53	```
    54	
    55	### Per-trigger auth requirements
    56	
    57	- **Webhook (v1.0 primary path):** per-provider HMAC / bearer token verified at the ingress per `tools.yaml` capability declarations (matching the Scribe webhook auth pattern).
    58	- **Cron (daily-sweep + weekly-report):** runs under `ifos_user` OS account (per Day-4 §6.5 tenant-provision script) via systemd-timer-style invocation; no inbound auth (process started by cron daemon with the right OS user identity). RLS isolation via `app.current_tenant` SET LOCAL per Day-4 §7.
    59	- **Manual triggers (ifosctl below):** require operator OS account in the `ifos-operators` group; per-invocation `--tenant <slug>` is verified against the operator's tenant access list in `tenant_adapters` before execution. Founder + Hire #1 are the v1.0 ifosctl-authorized operators per master brief §8.2 line 604.
    60	- **v1.1+ Brain UI:** session-cookie auth + per-tenant operator role check (deferred).
    61	
    62	### Manual triggers (v1.0)
    63	
    64	```bash
    65	ifosctl cash-conductor reconcile --tenant <slug> [--invoice <id>]
    66	ifosctl cash-conductor draft-chase --tenant <slug> --invoice <id>
    67	ifosctl cash-conductor weekly-report --tenant <slug>
    68	```
    69	
    70	### v1.1+ surfaces (deferred)
    71	
    72	- Brain UI cash-flow dashboard
    73	- Per-tenant Telegram daily summary
    74	- FD-mode end-of-month report (more detailed than weekly)
    75	
    76	---
    77	
    78	## §3 — Output shape
    79	
    80	Three outputs. All load-bearing.
    81	
    82	### Output 1 — Reconciliation rows (yellow tier)
    83	
    84	Per webhook event, Cash Conductor reconciles incoming bank deposits against the tenant's open invoice register. Match algorithm:
    85	
    86	| Stage | Match dimensions | Confidence |
    87	|---|---|---|
    88	| 1 | Exact amount + matching invoice reference in transaction memo | 0.98 |
    89	| 2 | Exact amount + matching payee name | 0.85 |
    90	| 3 | Exact amount + within-90-day-of-invoice-issue window | 0.70 |
    91	| 4 | Fuzzy amount (±0.5% rounding) + matching payee name | 0.65 |
    92	| 5 | Unmatched (queued for review) | <0.50 |
    93	
    94	Stages 1-2 auto-write reconciliation to accounting system (yellow tier; spot-check sampled). Stages 3-4 queue for consultant review. Stage 5 flagged in weekly report.
    95	
    96	Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'` (yellow tier per autosend-policy.yaml lookup — `tier` is NOT a top-level decision_log column; it is recorded inside the autosend-emitted payload by `_shared/hook-helpers.sh`'s `hh_decision_action`). Payload `reason`/`payload_preview` carries `match_confidence` + `match_dimensions` as a string; for queryable-structured match metadata, the W7-8 build slice extends `hh_decision_action` to emit structured payload fields OR writes a separate audit row.
    97	
    98	### Output 2 — Payment-chase drafts (yellow tier internal; Cash Conductor INITIATES the orange-tier customer send via Concierge approval bridge)
    99	
   100	For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type — grep `^  xero_reminder_send_customer:` in `agents/_shared/autosend-policy.yaml` to verify it's registered there under §ORANGE) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
   101	
   102	Chase draft structure:
   103	
   104	```yaml
   105	draft_id: <uuid>
   106	invoice_id: <accounting-system-invoice-id>
   107	contact_email: <client-billing-contact-email>
   108	subject: "Friendly reminder — invoice <number> from <YYYY-MM-DD>"
   109	body_markdown: <voice-classified consultant-tone reminder>
   110	amount_due: <decimal>
   111	days_overdue: <int>
   112	prior_chases_sent: <int>
   113	escalation_ladder_position: 1-4 per §3.2 below
   114	expected_send_window: orange-tier approval expected within 24h
   115	```
   116	
   117	Each draft writes to vault FIRST then produces TWO `decision_log` rows on the cash-conductor agent_name (per ADR-002 vault/Postgres split — narrative content in vault, structured audit metadata in Postgres):
   118	
   119	0. Draft body written to `/vault/<tenant>/cash-conductor-drafts/<draft_id>.md` (chmod 0600); the YAML+body structure above lands as the canonical narrative source.
   120	1. `phase='output'`, `output_type='chase_draft_generated'`. Per `_shared/hook-helpers.sh` `hh_decision_output(output_type, artefact_ref, reason)`: the payload jsonb only writes `{output_type, artefact_ref}` — the vault path goes in `artefact_ref` and is the canonical pointer. Additional draft metadata (`body_sha256`, `voice_score`, `escalation_position`, `days_overdue`, `amount_due`) is concatenated into the `reason` string parameter for human/operator-readable audit context. W7-8 build slice may extend `hh_decision_output` to write structured metadata fields if SQL-queryable access is needed for the weekly report aggregation; current shape captures the intent without forcing the helper extension.
   121	2. `phase='action'`, `action_type='xero_reminder_draft_internal'` (yellow tier per autosend-policy.yaml lookup; grep `^  xero_reminder_draft_internal:` to verify) — this row records that Cash Conductor classified the draft as yellow-tier internal. Per `hh_decision_action(action_type, target, payload_hash, payload_preview)`: `target` carries the invoice_id; `payload_hash` is a stable hash of the draft body; `payload_preview` carries the same metadata string as row 1's reason for cross-row correlation.
   122	
   123	When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml lookup; grep `^  xero_reminder_send_customer:` to verify; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval routing AND the transport-execution, and writes ITS OWN orange-tier action row `gmail_outlook_send_to_candidate` (Concierge-owned; registered in autosend-policy.yaml under §ORANGE) per Concierge agent.md §4 Step 12 — the transport-execution audit row. After Concierge confirms send via webhook to Cash Conductor, Cash Conductor writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output that tracks Cash Conductor's local invoice-state update — the customer-facing send was already audited by Concierge's row).
   124	
   125	### §3.2 — Chase escalation ladder
   126	
   127	| Position | Trigger | Tone | Voice classifier minimum |
   128	|---|---|---|---|
   129	| 1 | 7 days overdue | "Friendly reminder, hope everything's OK on your end" | ≥0.75 |
   130	| 2 | 14 days overdue, position-1 sent | "Following up — please let us know if there's a query" | ≥0.75 |
   131	| 3 | 21 days overdue, position-2 sent | "Need to flag this; can we schedule a quick call?" | ≥0.80 (higher bar) |
   132	| 4 | 30 days overdue, position-3 sent | "Escalation to operator review" — drafts STOP; operator manual handle | n/a (not sent) |
   133	
   134	Position 4 is the kill-switch: Cash Conductor never auto-drafts beyond position 3. Operator decides next step manually.
   135	
   136	### Output 3 — Weekly cash-flow Markdown report
   137	
   138	Located at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md`. Generated Monday 06:00 UTC. Six sections:
   139	
   140	| # | Section | Content |
   141	|---|---|---|
   142	| 1 | **Week summary** | Receipts received + invoices issued + invoices paid + new chases sent |
   143	| 2 | **DSO trend** | Days-Sales-Outstanding metric this week vs prior-week vs month-0 baseline; Gate B tracking |
   144	| 3 | **Aged debtors** | Invoices outstanding bucketed (0-30 / 31-60 / 61-90 / 90+ days); per-client totals |
   145	| 4 | **Chase pipeline** | Active chase drafts by position 1-3; pending consultant approval; sent-but-no-response |
   146	| 5 | **Cash-flow forecast** | 4-week forward cash projection (open invoices + expected payments per historical conversion rate) |
   147	| 6 | **Exception list** | Reconciliation failures; bank-feed gaps; accounting-API failures; operator action items |
   148	
   149	---
   150	
   151	## §4 — Workflow
   152	
   153	14 steps. Per ADR-003 §3 agent-bundle pattern + the review-agent-bundle Codex ratification skill §4 ("every output/action step MUST call hh_decision_*"): every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`. Master brief §8.1 Change 2 mandates the three-call minimum per agent run (`trigger`, `output`, `action`); the per-step mandatory-write discipline is the agent-bundle contract extension.
   154	
   155	```
   156	0. Session start (webhook OR cron OR manual)
   157	   → context.sh hydrates: tenant config + accounting-provider auth +
   158	     Open Banking auth + voice corpus + tone rules
   159	   → hh_decision_trigger("session_start", "<webhook|cron|manual>")
   160	
   161	1. Provider auth refresh
   162	   → accounting: Xero/QuickBooks/Sage OAuth refresh per provider
   163	   → Open Banking: TrueLayer/Plaid UK 90-day token refresh (CRITICAL —
   164	     gotcha per ULTRAPLAN A4 line 541); staged ESC_OPEN_BANKING_TOKEN_AGING:
   165	     ≤30d info, ≤14d warn, ≤7d blocking (operator must re-authorise)
   166	   → ESC_ACCOUNTING_AUTH or ESC_OPEN_BANKING_AUTH on auth failure
   167	   → hh_decision_output("auth_refresh_complete", "tenant:<slug>",
   168	     "accounting:<ok|fail>; open_banking:<ok|fail>; token_aging_stage:<info|warn|blocking|fresh>")
   169	
   170	2. Event router (mode-dependent)
   171	   → if mode=webhook: parse event_type → routes to Step 3-7 path
   172	   → if mode=daily-sweep: routes to Step 4 (invoice ingest) → Step 5 (reconciliation) → Step 7 (chase generation pass) catch-up sequence; sweeps run the full reconciliation-first-then-chase pipeline
   173	   → if mode=weekly-report: skip to Step 13
   174	
   175	3. Bank transaction ingest (mode=webhook from Open Banking)
   176	   → fetch latest transactions since last_ingested_at
   177	   → normalise schema (TrueLayer vs Plaid have different formats)
   178	   → store in Postgres table `cash_conductor_transactions` (RLS-isolated per
   179	     tenant per Day-4 §6.3 + tenancy-invariants T1-T3; W7 build slice creates
   180	     the table per ADR-002 vault/Postgres split — structured state in Postgres,
   181	     not vault markdown)
   182	   → hh_decision_output("transactions_ingested", "tenant:<slug>",
   183	     "<N> rows since <last_ingested_at>")
   184	
   185	4. Invoice register ingest (mode=webhook from accounting OR daily-sweep)
   186	   → accounting.list_open_invoices() per provider
   187	   → store in Postgres table `cash_conductor_invoices` (RLS-isolated;
   188	     W7 build slice creates per ADR-002 vault/Postgres split)
   189	   → hh_decision_output("invoices_ingested", "tenant:<slug>", "<N> rows")
   190	
   191	5. Reconciliation pass (5-stage match algorithm per §3 Output 1)
   192	   → for each transaction × open invoice: compute match confidence
   193	   → write Stage 1-2 matches to accounting (yellow tier) atomically
   194	   → Stage 3 (single low-confidence exact-amount match): flag in weekly-report
   195	     exception list; NO ESC fire (per §6 row distinguishing Stage 3 from
   196	     Stage 4 — catalogue defines ESC_RECONCILIATION_AMBIGUOUS as multi-
   197	     candidate, not low-confidence single). W4-polish backlog: register
   198	     `ESC_RECONCILIATION_LOW_CONFIDENCE` OR widen catalogue trigger.
   199	   → Stage 4 (fuzzy multi-candidate within tolerance): fire ESC_RECONCILIATION_AMBIGUOUS
   200	     per catalogue (multiple candidates); queue for consultant review.
   201	   → flag Stage 5 (unmatched) in weekly-report exception list
   202	   → hh_decision_output("reconciliation_pass", "tenant:<slug>",
   203	     "stage1_2:<N>; stage3:<N>; stage4:<N>; stage5:<N>")
   204	
   205	6. Reconciliation write (yellow tier; per match)
   206	   → accounting.write_payment_received(invoice_id, payment_id, amount, date)
   207	   → atomic transaction; rollback on 4xx/5xx
   208	   → on success: hh_decision_action("accounting_reconciliation_write",
   209	     "invoice:<id>", payload_hash, payload_preview)
   210	   → on failure: ESC_ACCOUNTING_WRITE_FAIL
   211	   → spot-check sampling per autosend-safety-policy.yaml yellow tier
   212	
   213	7. Chase generation pass (for overdue, unmatched invoices)
   214	   → query open invoices with age >7 days AND no Stage-1/2 reconciliation
   215	   → for each, determine chase position 1-4 based on age + prior chases
   216	     sent (read from `cash_conductor_invoices.last_chase_position` — v0.3
   217	     schema-backed field per migration §3; NOT from decision_log payload)
   218	   → if position=4: STOP — operator review (no auto-draft).
   219	     hh_decision_output("chase_position_4_operator_review",
   220	     "invoice:<id>", "age_days:<N>; prior_chases:3") — records the
   221	     operator-review outcome explicitly per §4 mandatory-write discipline
   222	   → else: proceed to Step 8
   223	
   224	8. LLM chase-draft generation (per overdue invoice)
   225	   → prompt = (invoice details + client context + position-N tone +
   226	     voice corpus + tone rules)
   227	   → output = email body + subject
   228	   → voice classifier scores against tenant style (≥0.75 for position 1-2;
   229	     ≥0.80 for position 3 per §3.2)
   230	   → ESC_VOICE_DRIFT if classifier <threshold after 3 retries
   231	   → write draft body to /vault/<tenant>/cash-conductor-drafts/<draft_id>.md
   232	     (chmod 0600) FIRST — vault path is the authority per §3 Output 2 +
   233	     ADR-002 vault/Postgres split; the body is NOT carried in the payload
   234	   → hh_decision_output("chase_draft_generated", "invoice:<id>",
   235	     "vault_path:<path>; body_sha256:<hash>; escalation_position:<N>; voice_score:<N>; days_overdue:<N>; amount_due:<N>")
   236	     — payload carries METADATA only, matching §3 line 118
   237	
   238	9. Chase-draft validation (Gate A specifics)
   239	   → verify: invoice_number cited matches invoice_id
   240	   → verify: amount_due cited matches accounting record
   241	   → verify: client_contact_email matches active billing contact
   242	   → verify: NOT paid in last 24h (re-query accounting)
   243	   → ESC code mapping by failure class:
   244	     - invoice_number / amount_due / paid-invoice-precondition mismatch →
   245	       `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint failure)
   246	     - client_contact_email / addressee mismatch (chase routed to wrong
   247	       customer) → `ESC_ADDRESSEE_MISMATCH` (per catalogue §2.10 — explicitly
   248	       blocking for Cash Conductor invoice/chase addressee resolution)
   249	     `ESC_AUTOSEND_BLOCKED` is reserved for red-tier action attempts per
   250	     catalogue line 41; Cash Conductor's chase pipeline is orange-tier.
   251	   → hh_decision_output("chase_draft_validated", invoice_id, "passed")
   252	
   253	10. Chase-draft queue to Concierge (opens orange-tier approval bridge)
   254	    → POST internal API → Concierge agent receives draft
   255	    → hh_decision_action("xero_reminder_draft_internal", "invoice:<id>",
   256	      payload_hash, payload_preview) — yellow tier per autosend-policy.yaml
   257	      lookup (grep `^  xero_reminder_draft_internal:` to verify)
   258	    → hh_decision_action("xero_reminder_send_customer", "invoice:<id>",
   259	      payload_hash, payload_preview) — orange tier per autosend-policy.yaml
   260	      lookup (grep `^  xero_reminder_send_customer:` to verify); Cash
   261	      Conductor owns this action_type and OPENS the orange-approval-bridge;
   262	      Concierge handles autosend-bridge call to operator (D1 path per
   263	      Founder Decision)
   264	
   265	11. (Operator approves via Concierge's bridge → Concierge transports the
   266	    send → Cash Conductor receives webhook + records state mutation)
   267	    → The orange-tier `xero_reminder_send_customer` action row was
   268	      written by Cash Conductor at Step 10 (Cash Conductor owns the
   269	      CHASE-INITIATION action_type per autosend-policy.yaml lookup;
   270	      agent: cash-conductor).
   271	    → Concierge writes its OWN orange-tier `gmail_outlook_send_to_candidate`
   272	      action row at the TRANSPORT-EXECUTION step (Concierge agent.md §4
   273	      Step 12; agent: concierge). The full chain has two orange-tier rows:
   274	      Cash Conductor's chase-initiation + Concierge's transport-execution.
   275	      Both are autosend-gated; both are audited; agent ownership differs.
   276	    → Concierge fires webhook back: chase_sent (transport completed)
   277	    → Cash Conductor updates `cash_conductor_invoices.last_chase_position`
   278	      and `last_chase_sent_at` (v0.3 schema-backed fields per migration §3)
   279	    → hh_decision_output("cash_conductor_chase_sent_recorded",
   280	      "invoice:<id>", "position:<N>; sent_at:<ISO>") — phase=output;
   281	      green-tier internal status marker recording state mutation completion
   282	
   283	12. (Mode=webhook only) Re-trigger eligibility check
   284	    → was this webhook also a "payment received" that just hit?
   285	    → re-run Step 5 to check if any chases-in-flight should be cancelled
   286	      (paid-since-draft-but-before-send race condition)
   287	    → if so: ESC_AUTOSEND_RACE → cancel chase draft (do NOT send)
   288	    → hh_decision_output("chase_cancellation_check", "invoice:<id>",
   289	      "cancelled:<bool>")
   290	
   291	13. Weekly report assembly (mode=weekly-report; runs Monday 06:00 UTC)
   292	    → query decision_log + accounting + bank feed for the 7-day window
   293	    → compute DSO metric (Gate B tracking)
   294	    → 6-section Markdown report per §3 Output 3
   295	    → write to /vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md
   296	    → hh_decision_output("weekly_report", report_path,
   297	      "dso_delta_days:<N>; sections:6")
   298	
   299	14. Session close
   300	    → update tenant_adapters.config.cash_conductor_last_run = now()
   301	    → hh_decision_action("cash_conductor_run_complete", "session:<session_id>",
   302	      payload_hash, "run_mode:<mode>; matches:<N>; chases:<N>; report:<bool>")
   303	      — hh_decision_action signature is (action_type, target, payload_hash,
   304	      payload_preview) per agents/_shared/hook-helpers.sh contract
   305	    → exit code 0
   306	```
   307	
   308	---
   309	
   310	## §5 — Gates
   311	
   312	### Gate A — validate.sh (hard-fail before action)
   313	
   314	Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
   315	
   316	- **"chase email references correct invoice number AND correct amount AND correct contact"** (all three; AND not OR)
   317	- **"never proposes chase for an invoice that's been paid in last 24h"** (defence-in-depth re-query at draft time)
   318	- Voice classifier score ≥0.75 for position 1-2 chases; ≥0.80 for position 3
   319	- No PII outside firm boundary in chase body
   320	- Reconciliation match confidence ≥0.85 for auto-write (Stage 1-2 only)
   321	- Open Banking token ≥7 days from expiry (≤7d is blocking per ESC_OPEN_BANKING_TOKEN_AGING staged definition; ≤30d info + ≤14d warn are health-warning states that do NOT block Gate A, only signal upcoming reauth need)
   322	- Accounting auth refresh succeeded in Step 1
   323	
   324	Gate A failures fire either `ESC_AGENT_OUTPUT_SHAPE` (invoice/amount/paid-precondition miss; output-shape constraint) OR `ESC_ADDRESSEE_MISMATCH` (client_contact_email mismatch; blocking per catalogue §2.10 — explicit Cash Conductor invoice/chase addressee case). Draft stays in `/tmp` (auto-purged 24h); operator notified per the specific ESC route.
   325	
   326	**Honesty note (updated 2026-06-02 per Codex Fbis-R3 closure):** `agents/recruitment/cash-conductor/validate.sh` **EXISTS as SKELETON** (committed `524bac6` on 2026-06-01) — the 5 Gate A checks G1-G5 are defined as TODO(W7-8) markers inside the SKELETON validate.sh; the W7 build slice replaces the TODOs with live impl per the contract above. The §5 contract describes what validate.sh's TODOs will become; the SKELETON file structurally exists and passes shellcheck CLEAN today but does not yet enforce the checks at runtime.
   327	
   328	### Gate B — Outcome threshold (FD-tier closer metric)
   329	
   330	Per ULTRAPLAN A4 line 539 verbatim: **"tenant DSO at month-3 ≥ 12 days lower than month-0 baseline"**.
   331	
   332	DSO = Days Sales Outstanding = (Accounts Receivable / Total Credit Sales) × Number of Days.
   333	
   334	Measured monthly via the weekly report's §2 trend. Month-0 baseline established at first pilot LOI signing (before Cash Conductor active). Month-3 target = month-0 minus 12 days.
   335	
   336	This is THE FD-tier closer metric per master brief §8.2 line 598 ("DSO drops by 15 days"; ULTRAPLAN A4 line 539 sets the 12-day Gate B target — note minor drift from the master brief's 15-day pitch which is the more aggressive marketing position) — a local leading metric for Cash Conductor quality. Per bilateral-disposition Cat-3: Cash Conductor's DSO improvement is NOT directly mapped to a v1.0 kill-criterion trigger; it's tracked as a local Gate B signal. Below ≥12 days improvement for 2 consecutive months → `ESC_GATE_B_MISS` → founder + operator review (likely indicates heuristic tuning, escalation-ladder timing, OR tenant-specific late-payment patterns we haven't modelled).
   337	
   338	---
   339	
   340	## §6 — Escalation codes
   341	
   342	Cash Conductor uses these ESC codes from `agents/_shared/escalation-codes.md`:
   343	
   344	| Code | Trigger | Severity | Routing |
   345	|---|---|---|---|
   346	| `ESC_ACCOUNTING_AUTH` | Xero/QuickBooks/Sage OAuth refresh fails after 2 retries | **blocking** | operator + ifos_oncall |
   347	| `ESC_ACCOUNTING_WRITE_FAIL` | Accounting 4xx/5xx on reconciliation write | warn | operator_chat_id |
   348	| `ESC_OPEN_BANKING_AUTH` | TrueLayer/Plaid UK auth fails after 2 retries | **blocking** | operator + ifos_oncall |
   349	| `ESC_OPEN_BANKING_TOKEN_AGING` | Open Banking PSD2 consent approaching 90-day expiry (staged) | info ≤30d / warn ≤14d / **blocking** ≤7d (per catalogue §2.7) | operator_chat_id (info+warn); + ifos_oncall_chat_id at blocking stage |
   350	| `ESC_RECONCILIATION_AMBIGUOUS` | Stage 4 fuzzy multi-candidate match within tolerance (per catalogue §2.10 — bank-feed payment line cannot match a single Xero invoice; multiple candidates) | warn | operator_chat_id |
   351	| (Stage 3 low-confidence single-match review queue) | Stage 3 single low-confidence exact-amount match queued for consultant review — NOT ESC_RECONCILIATION_AMBIGUOUS (catalogue defines ambiguity as multi-candidate, not low-confidence single). v0.3 W4-polish backlog: add ESC_RECONCILIATION_LOW_CONFIDENCE for single-match-low-confidence case OR widen ESC_RECONCILIATION_AMBIGUOUS catalogue trigger. | flagged in weekly report exception list (no ESC fire at v0.3) | (weekly report aggregation) |
   352	| `ESC_AUTOSEND_RACE` | Payment received between chase-draft and chase-send window | warn | operator_chat_id |
   353	| `ESC_VOICE_DRIFT` | Chase voice classifier below threshold after 3 retries | warn | operator_chat_id |
   354	| `ESC_PII_LEAKAGE_RISK` | PII detected outside firm boundary in chase body | **blocking** | operator + ifos_oncall |
   355	| `ESC_AGENT_OUTPUT_SHAPE` | Gate A miss on invoice_number / amount_due / paid-invoice-precondition (NOT addressee mismatch — that uses ESC_ADDRESSEE_MISMATCH) | warn | operator_chat_id |
   356	| `ESC_ADDRESSEE_MISMATCH` | Gate A miss on client_contact_email / addressee resolution (per catalogue §2.10 Cash Conductor case) | **blocking** | operator + ifos_oncall |
   357	| `ESC_GATE_B_MISS` | DSO improvement below 12-day target for 2 consecutive months | warn | founder + operator |
   358	| `ESC_RATE_LIMIT_HIT` | Accounting OR Open Banking 429 | warn | operator_chat_id |
   359	| `ESC_AUTOSEND_ORANGE_PENDING` | Chase draft awaiting consultant approval — heartbeat at ≥50% of declared timeout (per catalogue §2.9 trigger) | info | operator_chat_id (gentle reminder; no oncall CC) |
   360	
   361	Cash Conductor does NOT use:
   362	
   363	- Bullhorn-specific codes (no Bullhorn dependency)
   364	- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
   365	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Cash Conductor's Gate A misses are output-shape failures, not schema-field violations
   366	- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Cash Conductor fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
   367	
   368	---
   369	
   370	## §7 — Voice + tone constraints
   371	
   372	Step 8 (chase-draft generation) is the only voice-classified output. The agent integrates with `_shared/voice-loader.sh`:
   373	
   374	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `cash_conductor`** — surfaces rules like:
   375	  - No "Final demand" or legal-threatening language (escalation ladder caps at position 3; position 4 is operator-handled)
   376	  - No reference to the client's industry / sector pain points (chase is operational, not strategic)
   377	  - No mentions of late-payment fees unless tenant's terms explicitly state them
   378	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching "professional polite chase email" task context.
   379	- **NOTE: Cash Conductor does NOT read `recent_edit`.** Per v0.3 supplement §2a access grants (line 729; recent_edit block at lines 721-731), Cash Conductor has W-only access — it WRITES recent_edit rows when consultants edit its chase drafts post-send, but does NOT READ them. Voice continuity for Cash Conductor relies on the tenant voice_corpus + tone_rule reads above. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries (LLM step internal to chase-draft generation; classifier scoring distinct from sample retrieval). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked by the canary (which has R access) for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
   380	
   381	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   382	
   383	---
   384	
   385	## §8 — Build dependencies (W7-8 prerequisites)
   386	
   387	Cash Conductor build cannot start until ALL of the following are confirmed:
   388	
   389	| Dependency | Source | Status |
   390	|---|---|---|
   391	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   392	| Diagnostic ratified (first-agent precedent) | Week 3 Codex Round 4 Phase 1 | ⏸ |
   393	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   394	| **Tenant's accounting choice confirmed** (Xero / QuickBooks / Sage) | Tenant onboarding | ⏸ |
   395	| **Accounting commercial signup** (developer access + sandbox) | Founder commercial | ⏸ |
   396	| **Open Banking commercial signup** (TrueLayer or Plaid UK) | Founder commercial; ~£100-300/mo | ⏸ |
   397	| Xero MCP connector | W7 build start (~2 days) | ⏸ |
   398	| QuickBooks MCP connector | W7 build start (~2 days) | ⏸ |
   399	| Sage MCP connector | W7 build start (~2 days; may defer if no pilot uses Sage v1.0) | ⏸ |
   400	| Open Banking MCP connector | W7 build start (~3 days; harder due to 90-day token rotation) | ⏸ |
   401	| Per-tenant accounting credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   402	| Per-tenant Open Banking credentials in `_secrets.env` | Tenant onboarding | ⏸ |
   403	| Concierge agent.md ratified Accepted (for chase-send routing contract; full Concierge production-build at W10-13, but Cash Conductor only depends on the Concierge agent.md contract being Accepted, not the full bundle being In Force) | Post-Concierge agent.md re-ratification | ⏸ |
   404	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   405	| `validate.sh` Gate A logic (G1-G5 checks; SKELETON file exists at commit `524bac6`; W7 wires live impl) | SKELETON shipped 2026-06-01; W7 live-impl ~1 day | ✅ SCAFFOLDED (W4 Day-26) |
   406	| `context.sh` hydration (SKELETON file exists at commit `5ab2f0f`; W7 wires real provider config + tenant_adapters reads) | SKELETON shipped 2026-06-01; W7 live-impl ~0.5 day | ✅ SCAFFOLDED (W4 Day-26) |
   407	| `cycle.sh` orchestration (14-step SKELETON at commit `6ab59d8`; minimal trigger/output markers fire today; W7 wires per-step impl) | SKELETON shipped 2026-06-01; W7 live-impl ~3 days (most complex of v1.0 agents) | ✅ SCAFFOLDED (W4 Day-26) |
   408	| `tools.yaml` MCP capability declarations (xero_oauth, quickbooks_oauth, sage_oauth, open_banking_truelayer / plaid, telegram_notify, autosend_bridge_telegram_propose + _await) | SKELETON shipped 2026-06-01 + 076e231 bridge wiring; W7 ratifies live | ✅ SCAFFOLDED (W4 Day-26) |
   409	| `cleanup.sh` post-run state purge SKELETON (transient OAuth tokens; provider rate-limit caches; TODO(W7-8) markers; commit `5ab2f0f`) | SKELETON shipped 2026-06-01; W7 live-impl ~0.5 day | ✅ SCAFFOLDED (W4 Day-26) |
   410	| 3 fixtures (`01-primary.yaml` + `02-edge-case-fuzzy-match.yaml` + `99-token-aging-canary.yaml` at commit `5ab2f0f`) | SKELETON shipped 2026-06-01; W7 wires golden-output assertions | ✅ SCAFFOLDED (W4 Day-26) |
   411	| **Founder Decision D1 (autosend orange-tier path) ACCEPTED 2026-05-31** as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md` | ✅ ACCEPTED |
   412	| **Autosend bridge package scaffold** — `@ifos/autosend-bridge-telegram` lib + types + tests landed 2026-06-01 (commit `9b282d8`); Cash Conductor consumer wiring at cycle.sh Step 10 landed (commit `076e231`) | ✅ SCAFFOLDED (Cash Conductor side) |
   413	| **Autosend bridge production wiring** — real Telegram Bot API + postgres approvals reader; Concierge W10-13 build delivers; blocking for orange-tier send activation | Concierge W10-13 build slice (per D1-B decision-doc §"Implementation surface") | ⏸ |
   414	| Fallback (interim): cycle.sh Step 10 detects absent `packages/utilities/autosend-bridge-telegram/dist/` and runs in drafts-only mode (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` until W10-13 wiring activates) | v1.0 interim — active until W10-13 | n/a |
   415	
   416	**ADR-005 framing:** ADR-005 (Week-3 Diagnostic acceleration) notes Cash Conductor is unaffected by Bullhorn slips because it has zero Bullhorn dependency. v0.3 supplement: Cash Conductor pull-forward (from W7-8 to W4-5) is NOT explicitly authorised by ADR-005 §5.1 (that section number doesn't exist; earlier draft mis-cited). Pull-forward would require a separate ADR (e.g. ADR-007 if/when needed); accounting + Open Banking commercial signups remain founder-action gates regardless of timing.
   417	
   418	---
   419	
   420	## §9 — Status + open questions
   421	
   422	**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start.
   423	
   424	### Open questions for founder review
   425	
   426	| # | Question | Resolution path |
   427	|---|---|---|
   428	| Q1 | First-tenant accounting choice — Xero / QuickBooks / Sage? Affects which connector is W7-prio-1. | Tenant onboarding; depends on first pilot tenant's existing stack. |
   429	| Q2 | Open Banking provider — TrueLayer or Plaid UK? Both have UK coverage; TrueLayer slightly cheaper at low volume; Plaid has broader US-EU coverage for v1.1+ expansion. | Founder commercial. Recommend TrueLayer for v1.0 UK-only pilots. |
   430	| Q3 | Open Banking 90-day token rotation UX — when token nears expiry, operator must re-authenticate via tenant's bank login. How is this triggered? Telegram nudge? Brain UI dashboard? | Recommend: ESC_OPEN_BANKING_TOKEN_AGING fires Telegram nudge at 30/14/7 days; tenant-admin handles via Brain UI v1.1. |
   431	| Q4 | Chase escalation ladder — 4 positions proposed in §3.2. Founder confidence each position's timing + tone is right? | Founder review with first pilot tenant; varies by tenant's payment terms (net-30 vs net-14 vs net-60). |
   432	| Q5 | Reconciliation Stage 3-4 (fuzzy / ambiguous matches) — consultant review queue UX. Brain UI workflow? Telegram? | v1.0: weekly report exception list. v1.1: Brain UI per-row review queue. |
   433	| Q6 | DSO baseline establishment — month-0 baseline measured pre-deployment. How do we measure if accounting system data is incomplete or fragmented? | First pilot tenant: 30-day baseline measurement period BEFORE Cash Conductor goes live; documented in pilot LOI. |
   434	| Q7 | Hire #1 anchor — what specific Cash Conductor sub-tasks does Hire #1 take vs Claude Code? | Founder strategic decision; recommend Hire #1 owns Open Banking connector + ESC_OPEN_BANKING_TOKEN_AGING UX. Cash Conductor agent.md + cycle.sh stays with founder + Claude Code for consistency with other agents. |
   435	| Q8 | Sage connector — defer if no v1.0 pilot uses Sage? Saves ~2 days. Risk: blocks future Sage-using pilots. | Recommend defer to v1.1; document in W7 build start review. |
   436	
   437	### Gotchas (carried forward from ULTRAPLAN A4 line 541)
   438	
   439	1. **Open Banking auth is a 90-day token; rotation logic is non-trivial.** Plan for the rotation UX up-front; ESC_OPEN_BANKING_TOKEN_AGING staged at 30/14/7 days from expiry; document tenant-admin re-auth procedure.
   440	2. **Bank feed reconciliation against invoice register is the hard logic.** Start with exact-amount matches (Stage 1-2); expand to fuzzy (Stage 3-4) as confidence builds.
   441	3. **5 stages of match algorithm** is intentionally conservative for v1.0 to avoid false-positive reconciliation writes (which corrupt the tenant's accounting books).
   442	4. **Hire #1 is assumed to start week 7** per master brief §8.2 line 604 — "verify, don't assume." If Hire #1 doesn't start on time, Cash Conductor build runs founder-solo and may slip.
   443	
   444	---
   445	
   446	## §10 — When this document ratifies
   447	
   448	Per `.codex/ratification/review-agent-bundle.md` skill (built Day 19, commit `825ebd4`): this agent.md ratifies via the cluster Fbis ratification run (`bash scripts/run-codex-ratification.sh --cluster Fbis`). Round-trip history: Day-20 W3 cluster E ratified the agent.md at the contract layer; cluster Fbis (2026-06-02) ratifies the bundle layer now that sibling files (cycle.sh + validate.sh + context.sh + cleanup.sh + tools.yaml + 3 fixtures) exist alongside.
   449	
   450	Status flips Proposed → Accepted when:
   451	- Cluster Fbis returns RATIFIED for this agent.md (in-flight as of 2026-06-02)
   452	- Founder approves §9 Q1 + Q2 + Q4 + Q7 + Q8
   453	- Q3 UX flow approved (operator re-auth path)
   454	
   455	NOTE: D1 RESOLVED is NO LONGER a Proposed→Accepted blocker — D1 was Accepted 2026-05-31 as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md`, and the package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`). The autosend-bridge **production wiring** (real Telegram Bot API) remains a Concierge W10-13 deliverable; until then, Cash Conductor runs in drafts-only mode (interim — see §8 fallback row). The bridge wiring is an Accepted→In-Force blocker (build slice + first-production criterion below), not a Proposed→Accepted blocker.
   456	
   457	Status flips Accepted → In Force when:
   458	- W7-8 build slice replaces SKELETON TODOs across the bundle with live impl (sibling files exist; live wiring pending)
   459	- Concierge W10-13 lands the autosend-bridge production wiring so orange-tier sends activate
   460	- First production webhook processed end-to-end against migration-test tenant
   461	- 30-day month-0 baseline measured for first pilot
   462	- Hire #1 onboarded + integrated into the build workstream (per master brief §8.2 line 604)
   463	- Codex re-ratifies post-build via `review-agent-bundle.md` skill
   464	
   465	Until then: this document is a forward-looking scaffold with all 6 bundle files + 3 fixtures present at the SKELETON layer.
   466	
   467	*End of Cash Conductor agent.md draft.*

exec
/bin/zsh -lc 'rg -n "Composio|AgentMail|packages/harness/cortextos|cortextOS.*brain|kb-" agents/recruitment/cash-conductor/agent.md agents/recruitment/cash-conductor/tools.yaml agents/recruitment/cash-conductor/fixtures/*.yaml' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/cash-conductor/tools.yaml:206:# - No Composio / AgentMail references anywhere in this file.

codex
So far the major citations line up: master brief W7-8, ULTRAPLAN A4 gates, autosend action types, ESC catalogue, voice-loader functions, and v0.3 schema additions are present. I’m doing one more pass for internal contradictions and boundary violations before deciding.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '620,770p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/agent.md | sed -n '185,285p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   185	4. Invoice register ingest (mode=webhook from accounting OR daily-sweep)
   186	   → accounting.list_open_invoices() per provider
   187	   → store in Postgres table `cash_conductor_invoices` (RLS-isolated;
   188	     W7 build slice creates per ADR-002 vault/Postgres split)
   189	   → hh_decision_output("invoices_ingested", "tenant:<slug>", "<N> rows")
   190	
   191	5. Reconciliation pass (5-stage match algorithm per §3 Output 1)
   192	   → for each transaction × open invoice: compute match confidence
   193	   → write Stage 1-2 matches to accounting (yellow tier) atomically
   194	   → Stage 3 (single low-confidence exact-amount match): flag in weekly-report
   195	     exception list; NO ESC fire (per §6 row distinguishing Stage 3 from
   196	     Stage 4 — catalogue defines ESC_RECONCILIATION_AMBIGUOUS as multi-
   197	     candidate, not low-confidence single). W4-polish backlog: register
   198	     `ESC_RECONCILIATION_LOW_CONFIDENCE` OR widen catalogue trigger.
   199	   → Stage 4 (fuzzy multi-candidate within tolerance): fire ESC_RECONCILIATION_AMBIGUOUS
   200	     per catalogue (multiple candidates); queue for consultant review.
   201	   → flag Stage 5 (unmatched) in weekly-report exception list
   202	   → hh_decision_output("reconciliation_pass", "tenant:<slug>",
   203	     "stage1_2:<N>; stage3:<N>; stage4:<N>; stage5:<N>")
   204	
   205	6. Reconciliation write (yellow tier; per match)
   206	   → accounting.write_payment_received(invoice_id, payment_id, amount, date)
   207	   → atomic transaction; rollback on 4xx/5xx
   208	   → on success: hh_decision_action("accounting_reconciliation_write",
   209	     "invoice:<id>", payload_hash, payload_preview)
   210	   → on failure: ESC_ACCOUNTING_WRITE_FAIL
   211	   → spot-check sampling per autosend-safety-policy.yaml yellow tier
   212	
   213	7. Chase generation pass (for overdue, unmatched invoices)
   214	   → query open invoices with age >7 days AND no Stage-1/2 reconciliation
   215	   → for each, determine chase position 1-4 based on age + prior chases
   216	     sent (read from `cash_conductor_invoices.last_chase_position` — v0.3
   217	     schema-backed field per migration §3; NOT from decision_log payload)
   218	   → if position=4: STOP — operator review (no auto-draft).
   219	     hh_decision_output("chase_position_4_operator_review",
   220	     "invoice:<id>", "age_days:<N>; prior_chases:3") — records the
   221	     operator-review outcome explicitly per §4 mandatory-write discipline
   222	   → else: proceed to Step 8
   223	
   224	8. LLM chase-draft generation (per overdue invoice)
   225	   → prompt = (invoice details + client context + position-N tone +
   226	     voice corpus + tone rules)
   227	   → output = email body + subject
   228	   → voice classifier scores against tenant style (≥0.75 for position 1-2;
   229	     ≥0.80 for position 3 per §3.2)
   230	   → ESC_VOICE_DRIFT if classifier <threshold after 3 retries
   231	   → write draft body to /vault/<tenant>/cash-conductor-drafts/<draft_id>.md
   232	     (chmod 0600) FIRST — vault path is the authority per §3 Output 2 +
   233	     ADR-002 vault/Postgres split; the body is NOT carried in the payload
   234	   → hh_decision_output("chase_draft_generated", "invoice:<id>",
   235	     "vault_path:<path>; body_sha256:<hash>; escalation_position:<N>; voice_score:<N>; days_overdue:<N>; amount_due:<N>")
   236	     — payload carries METADATA only, matching §3 line 118
   237	
   238	9. Chase-draft validation (Gate A specifics)
   239	   → verify: invoice_number cited matches invoice_id
   240	   → verify: amount_due cited matches accounting record
   241	   → verify: client_contact_email matches active billing contact
   242	   → verify: NOT paid in last 24h (re-query accounting)
   243	   → ESC code mapping by failure class:
   244	     - invoice_number / amount_due / paid-invoice-precondition mismatch →
   245	       `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint failure)
   246	     - client_contact_email / addressee mismatch (chase routed to wrong
   247	       customer) → `ESC_ADDRESSEE_MISMATCH` (per catalogue §2.10 — explicitly
   248	       blocking for Cash Conductor invoice/chase addressee resolution)
   249	     `ESC_AUTOSEND_BLOCKED` is reserved for red-tier action attempts per
   250	     catalogue line 41; Cash Conductor's chase pipeline is orange-tier.
   251	   → hh_decision_output("chase_draft_validated", invoice_id, "passed")
   252	
   253	10. Chase-draft queue to Concierge (opens orange-tier approval bridge)
   254	    → POST internal API → Concierge agent receives draft
   255	    → hh_decision_action("xero_reminder_draft_internal", "invoice:<id>",
   256	      payload_hash, payload_preview) — yellow tier per autosend-policy.yaml
   257	      lookup (grep `^  xero_reminder_draft_internal:` to verify)
   258	    → hh_decision_action("xero_reminder_send_customer", "invoice:<id>",
   259	      payload_hash, payload_preview) — orange tier per autosend-policy.yaml
   260	      lookup (grep `^  xero_reminder_send_customer:` to verify); Cash
   261	      Conductor owns this action_type and OPENS the orange-approval-bridge;
   262	      Concierge handles autosend-bridge call to operator (D1 path per
   263	      Founder Decision)
   264	
   265	11. (Operator approves via Concierge's bridge → Concierge transports the
   266	    send → Cash Conductor receives webhook + records state mutation)
   267	    → The orange-tier `xero_reminder_send_customer` action row was
   268	      written by Cash Conductor at Step 10 (Cash Conductor owns the
   269	      CHASE-INITIATION action_type per autosend-policy.yaml lookup;
   270	      agent: cash-conductor).
   271	    → Concierge writes its OWN orange-tier `gmail_outlook_send_to_candidate`
   272	      action row at the TRANSPORT-EXECUTION step (Concierge agent.md §4
   273	      Step 12; agent: concierge). The full chain has two orange-tier rows:
   274	      Cash Conductor's chase-initiation + Concierge's transport-execution.
   275	      Both are autosend-gated; both are audited; agent ownership differs.
   276	    → Concierge fires webhook back: chase_sent (transport completed)
   277	    → Cash Conductor updates `cash_conductor_invoices.last_chase_position`
   278	      and `last_chase_sent_at` (v0.3 schema-backed fields per migration §3)
   279	    → hh_decision_output("cash_conductor_chase_sent_recorded",
   280	      "invoice:<id>", "position:<N>; sent_at:<ISO>") — phase=output;
   281	      green-tier internal status marker recording state mutation completion
   282	
   283	12. (Mode=webhook only) Re-trigger eligibility check
   284	    → was this webhook also a "payment received" that just hit?
   285	    → re-run Step 5 to check if any chases-in-flight should be cancelled

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

exec
/bin/zsh -lc "nl -ba docs/specs/ULTRAPLAN.md | sed -n '529,542p' && nl -ba docs/build-brief/00-MASTER-BRIEF.md | sed -n '593,605p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc "rg -n \"TODO\\(W7-8\\)|G1|G2|G3|G4|G5|drafts_only_mode|xero_reminder_send_customer|xero_reminder_draft_internal|cash_conductor_run_complete|hh_decision\" agents/recruitment/cash-conductor/validate.sh agents/recruitment/cash-conductor/cycle.sh agents/recruitment/cash-conductor/tools.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/cash-conductor/validate.sh:3:# (_fail + _warn are not invoked in the W4 Day-26 skeleton — TODO(W7-8)
agents/recruitment/cash-conductor/validate.sh:33:#   G1 — chase email references CORRECT invoice number AND amount AND contact (AND not OR)
agents/recruitment/cash-conductor/validate.sh:34:#   G2 — invoice NOT paid in last 24h (defence-in-depth re-query at draft time)
agents/recruitment/cash-conductor/validate.sh:35:#   G3 — voice classifier score ≥0.75 for position 1-2; ≥0.80 for position 3 (§3.2)
agents/recruitment/cash-conductor/validate.sh:36:#   G4 — No PII outside firm boundary in chase body (regex pass)
agents/recruitment/cash-conductor/validate.sh:37:#   G5 — Reconciliation match confidence ≥0.85 for auto-write (Stage 1-2 only)
agents/recruitment/cash-conductor/validate.sh:105:# G1 — invoice number + amount + contact (per ULTRAPLAN A4 line 538)
agents/recruitment/cash-conductor/validate.sh:111:# TODO(W7-8): parse draft YAML frontmatter; SELECT FROM cash_conductor_invoices
agents/recruitment/cash-conductor/validate.sh:114:# _fail "G1: invoice/amount/contact triple-check failed" + fire ESC_ADDRESSEE_MISMATCH
agents/recruitment/cash-conductor/validate.sh:116:_ok "G1: invoice/amount/contact triple-check — SKELETON (W7-8 wires the SQL)"
agents/recruitment/cash-conductor/validate.sh:119:# G2 — NOT paid in last 24h (defence-in-depth; per ULTRAPLAN A4 line 538 verbatim)
agents/recruitment/cash-conductor/validate.sh:123:# TODO(W7-8): @ifos/xero getInvoice OR @ifos/quickbooks getInvoice → check
agents/recruitment/cash-conductor/validate.sh:126:# hh_decision_action "validate_gate_a_fail" "invoice:<id>" "<hash>" "ESC_AGENT_OUTPUT_SHAPE; paid-in-24h"
agents/recruitment/cash-conductor/validate.sh:127:_ok "G2: not-paid-in-24h — SKELETON (W7-8 wires the accounting re-query)"
agents/recruitment/cash-conductor/validate.sh:130:# G3 — voice classifier score by position threshold (per agent.md §3.2)
agents/recruitment/cash-conductor/validate.sh:134:# TODO(W7-8): parse draft YAML for voice_score + escalation_position; compare
agents/recruitment/cash-conductor/validate.sh:136:# + hh_decision_action validate_gate_a_fail.
agents/recruitment/cash-conductor/validate.sh:137:_ok "G3: voice classifier per-position threshold — SKELETON (W7-8 wires)"
agents/recruitment/cash-conductor/validate.sh:140:# G4 — No PII outside firm boundary (regex pass against chase body)
agents/recruitment/cash-conductor/validate.sh:143:# TODO(W7-8): grep draft body for email patterns NOT matching the tenant's
agents/recruitment/cash-conductor/validate.sh:146:_ok "G4: no PII outside firm boundary — SKELETON (W7-8 wires firm-domain whitelist)"
agents/recruitment/cash-conductor/validate.sh:149:# G5 — Reconciliation match confidence ≥0.85 for auto-write (Stage 1-2 only)
agents/recruitment/cash-conductor/validate.sh:153:_ok "G5: reconciliation match-confidence ≥0.85 — SKELETON (W7-8 wires)"
agents/recruitment/cash-conductor/validate.sh:160:# TODO(W7-8): @ifos/open-banking loadTokens + getTokenAgeStage; if stage=="blocking"
agents/recruitment/cash-conductor/validate.sh:179:  # TODO(W7-8): per-failure routing — different ESC code per failure class
agents/recruitment/cash-conductor/validate.sh:180:  # (G1 → ESC_ADDRESSEE_MISMATCH; G2 → ESC_AGENT_OUTPUT_SHAPE; G3 → ESC_VOICE_DRIFT;
agents/recruitment/cash-conductor/validate.sh:181:  #  G4 → ESC_PII_LEAKAGE_RISK; G5 → ESC_RECONCILIATION_AMBIGUOUS or downgrade;
agents/recruitment/cash-conductor/validate.sh:183:  # hh_decision_action "validate_gate_a_fail" "tenant:${CTX_TENANT_SLUG}" payload_hash \
agents/recruitment/cash-conductor/tools.yaml:15:# + xero_reminder_draft_internal + xero_reminder_send_customer; open_banking_*
agents/recruitment/cash-conductor/tools.yaml:43:    purpose: "Single-entity invoice fetch by Xero InvoiceID (used at Gate A G1 re-check)"
agents/recruitment/cash-conductor/tools.yaml:76:    purpose: "Single-entity invoice fetch by QB Id (Gate A G1 re-check)"
agents/recruitment/cash-conductor/tools.yaml:141:    action_type: xero_reminder_send_customer  # ORANGE tier; REGISTERED at autosend-policy.yaml line 263; Cash Conductor OWNS this action_type per the same line
agents/recruitment/cash-conductor/tools.yaml:190:#   xero_reminder_draft_internal       line 188   yellow
agents/recruitment/cash-conductor/tools.yaml:191:#   xero_reminder_send_customer        line 263   orange    [Cash Conductor OWNS this]
agents/recruitment/cash-conductor/cycle.sh:10:# produces output OR takes action MUST call hh_decision_* from
agents/recruitment/cash-conductor/cycle.sh:27:#   2. Chase drafts → vault + decision_log (yellow xero_reminder_draft_internal;
agents/recruitment/cash-conductor/cycle.sh:28:#      Cash Conductor OWNS the orange xero_reminder_send_customer action_type
agents/recruitment/cash-conductor/cycle.sh:88:hh_decision_trigger "session_start" "cash-conductor mode=${MODE}"
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
agents/recruitment/cash-conductor/cycle.sh:220:  # TODO(W7-8): per draft iteration:
agents/recruitment/cash-conductor/cycle.sh:221:  #   hh_decision_action "xero_reminder_draft_internal" "invoice:${INVOICE_ID}" \
agents/recruitment/cash-conductor/cycle.sh:240:    #      --action xero_reminder_send_customer \
agents/recruitment/cash-conductor/cycle.sh:250:    # 2. Emit ORANGE-tier audit row — Cash Conductor OWNS xero_reminder_send_customer
agents/recruitment/cash-conductor/cycle.sh:253:    #    hh_decision_action "xero_reminder_send_customer" "invoice:${INVOICE_ID}" \
agents/recruitment/cash-conductor/cycle.sh:272:    #        hh_decision_output "approval_rejected" "invoice:${INVOICE_ID}" \
agents/recruitment/cash-conductor/cycle.sh:278:    #        hh_decision_action "validate_gate_a_fail" "invoice:${INVOICE_ID}" \
agents/recruitment/cash-conductor/cycle.sh:282:    : # TODO(W7-8): wire the per-draft loop above (steps 1–4); tsx CLI entrypoints land alongside in the same build slice
agents/recruitment/cash-conductor/cycle.sh:287:    hh_decision_output "drafts_only_mode" "tenant:${CTX_TENANT_SLUG}" \
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
I found one area that needed care: Cash Conductor’s Bullhorn-cache read claim. I’m verifying the base recruitment schema for those entity names before treating that as acceptable or a schema-before-code issue.
exec
/bin/zsh -lc 'rg -n "''^  (placement|client_contact|client|contact|candidate|company):|entity_type:.*placement|client_contact|placement" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | head -200' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:35:# No ALTER TABLE for the candidate / contact / brief / placement / opportunity
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:57:  candidate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:105:  contact:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:173:  placement:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:175:      placement_status:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:281:#   - Janitor placement: R → R+W (lifecycle-state cleanup writes —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:283:#   - Janitor timesheet: none → R (reads for placement-state inference)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:290:#   - Scribe timesheet: none → R (reads for placement-context resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:294:#   - Cash Conductor placement: none → R (reads for client linkage on invoice)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:305:#   - Concierge contractor: R → R+W (lifecycle states for contractor placements)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:307:#   - Concierge placement: R → R+W (writes Bullhorn state advancement per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:309:#   - Concierge timesheet: none → R (reads to verify placement-progress for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:323:  # (candidate, contractor, client, contact, brief, opportunity, placement,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:380:    placement: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:390:    placement: R+W         # lifecycle-state cleanup
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:391:    timesheet: R           # reads for placement-state inference
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:406:    placement: R+W         # check-in field extraction (Bullhorn Placement endpoint A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:407:    timesheet: R           # IFOS-cached read; placement-context resolution (Bullhorn Timesheet endpoint NOT used at v1.0)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:421:    placement: R           # IFOS-cached read; client linkage on invoice
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:440:    placement: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:449:    contractor: R+W        # writes lifecycle states for contractor placements too (Bullhorn endpoint A6 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:454:    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14 (Bullhorn endpoint A6)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:455:    timesheet: R           # IFOS-cached read; placement-progress for 7d/30d/90d nurture (Bullhorn Timesheet endpoint NOT used at v1.0)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:471:  client:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:484:  contact:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:525:  placement:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:539:      - Janitor (R)        # v0.3 NEW — reads for placement-state inference
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:540:      - Scribe (R)         # v0.3 NEW — reads for placement-context on check-in calls
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:542:      - Concierge (R)      # v0.3 NEW — reads to verify placement-progress for nurture
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:546:      placement-related workflows).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:548:  candidate:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:570:      - Concierge (R+W)    # v0.3 UPGRADED — lifecycle states for contractor placements
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:675:      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor resolves the billing contact from cached Bullhorn client_contact rows via the placement→client→contact entity_links relationship; NOT from a denormalized placement.client_contact_id field, which the base schema does not declare)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:911:      candidate / contact / brief / placement / opportunity entity_types.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:972:  Q3_placement_status_enum_lifecycle:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:973:    question: 6-state placement_status enum maps to Bullhorn's native state machine?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:977:      C: Add a mapping table (auxiliary) — placement_status_mapping with
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1030:      placement_status, week_1_status_vault_path, satisfaction_signal,
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:48:#   v0.1 entities (candidate, contractor, contact, brief, opportunity, placement)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:288:  candidate:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:303:  contact:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:327:  placement:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:333:        Snapshot of mean voice classifier score across all Concierge messages for the candidate during the 30 days BEFORE placement close. Captures voice quality at the moment of commercial success — drives "did voice quality predict deal close" reporting + v2.0 LoRA pipeline label generation.
docs/verticals/recruitment/vertical-schema.yaml:48:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
docs/verticals/recruitment/vertical-schema.yaml:155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
docs/verticals/recruitment/vertical-schema.yaml:214:        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
docs/verticals/recruitment/vertical-schema.yaml:218:      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.
docs/verticals/recruitment/vertical-schema.yaml:221:  client:
docs/verticals/recruitment/vertical-schema.yaml:223:      A company that hires through the recruitment agency. Master brief canonical vocabulary at §3.2 line 155 ("candidate, placement, brief") implicitly assumes client as the holder of briefs. Bullhorn calls this `ClientCorporation`.
docs/verticals/recruitment/vertical-schema.yaml:283:  contact:
docs/verticals/recruitment/vertical-schema.yaml:429:  placement:
docs/verticals/recruitment/vertical-schema.yaml:431:      A candidate placed into a client role. The commercial transaction unit — fees accrue per placement, lifecycle events (week-1, month-1, etc.) fire per placement per Product Spec §2.2 R7.
docs/verticals/recruitment/vertical-schema.yaml:434:      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:450:        notes: Nullable for permanent placements; required for contract.
docs/verticals/recruitment/vertical-schema.yaml:456:      placement_type:
docs/verticals/recruitment/vertical-schema.yaml:465:        notes: GBP. For permanent placements typically % of candidate_salary_at_placement; for contract typically per-day margin.
docs/verticals/recruitment/vertical-schema.yaml:471:      candidate_salary_at_placement:
docs/verticals/recruitment/vertical-schema.yaml:491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
docs/verticals/recruitment/vertical-schema.yaml:497:      A candidate-brief pairing in the submission/screening/interview/offer pipeline. Pre-placement state. v1.1+ exercised; v1.0 minimal.
docs/verticals/recruitment/vertical-schema.yaml:587:    target: placement
docs/verticals/recruitment/vertical-schema.yaml:589:    description: A candidate may have multiple placements over time (different clients, different roles). A placement has exactly one candidate.
docs/verticals/recruitment/vertical-schema.yaml:591:      Despite "M:N" cardinality, practically 1:N from placement → candidate (each placement has one candidate; each candidate has 0..N placements). Modelled as M:N for query symmetry.
docs/verticals/recruitment/vertical-schema.yaml:592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
docs/verticals/recruitment/vertical-schema.yaml:594:  placement_for_brief:
docs/verticals/recruitment/vertical-schema.yaml:595:    source: placement
docs/verticals/recruitment/vertical-schema.yaml:598:    description: Each placement fills exactly one brief; a brief may have multiple placements over time (replacement hires, multiple seats).
docs/verticals/recruitment/vertical-schema.yaml:654:  timesheet_for_placement:
docs/verticals/recruitment/vertical-schema.yaml:656:    target: placement
docs/verticals/recruitment/vertical-schema.yaml:658:    description: Each timesheet relates to one (contract) placement; a placement has 0..N timesheets over its duration.
docs/verticals/recruitment/vertical-schema.yaml:677:    placement: none
docs/verticals/recruitment/vertical-schema.yaml:688:    placement: R     # orphan / stale-tag sweep
docs/verticals/recruitment/vertical-schema.yaml:698:    placement: R+W   # note links on placed-candidate calls
docs/verticals/recruitment/vertical-schema.yaml:708:    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
docs/verticals/recruitment/vertical-schema.yaml:718:    placement: none
docs/verticals/recruitment/vertical-schema.yaml:728:    placement: R+W   # lifecycle stage maintenance (week_1, month_1, etc.)
docs/verticals/recruitment/vertical-schema.yaml:741:  candidate:
docs/verticals/recruitment/vertical-schema.yaml:754:  client:
docs/verticals/recruitment/vertical-schema.yaml:760:  contact:
docs/verticals/recruitment/vertical-schema.yaml:771:  placement:
docs/verticals/recruitment/vertical-schema.yaml:835:    revisit_trigger: If Concierge surfaces multi-contractor patterns where the same umbrella company serves multiple IFOS-tracked contractors (e.g., "all contractors at Acme Umbrella who terminate placements within 90 days"), promote umbrella_company to entity_type='umbrella_company' in v1.1.
docs/verticals/recruitment/vertical-schema.yaml:844:  Q9_multi_client_contact:
docs/verticals/recruitment/vertical-schema.yaml:861:    v0_1_decision: placement.lifecycle_stage enum is hardcoded to Product Spec §2.2 R7 values (pre_start, week_1, month_1, month_3, month_6, month_12, month_24, completed).
docs/verticals/recruitment/vertical-schema.yaml:862:    revisit_trigger: Any Product Spec revision touching R7 nurture cadence (e.g., adding week_2 checkpoint, removing month_24, splitting month_12 into quarterly checkpoints) requires schema migration. Migration steps — (1) ALTER TABLE add new enum value(s) to entities.data JSONB validator; (2) backfill existing placement rows if semantic change (e.g., week_1 → week_1_check_in renaming); (3) Concierge nurture-event firing logic updated to match new cadence.

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.yaml | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# IFOS recruitment vertical schema v0.1
     2	# ============================================================================
     3	# Layered above the Day-4 generic primitives:
     4	#   - entities (id, tenant_slug, entity_type, entity_id, data JSONB, version, ...)
     5	#   - entity_links (..., source_entity_type, source_entity_id, target_entity_type, target_entity_id, link_type, ...)
     6	#   - decision_log (..., agent_name, phase, payload JSONB, ...)
     7	# This file specifies the recruitment-domain entity_type + link_type slugs
     8	# and the JSON Schema shape of entities.data per entity_type.
     9	#
    10	# Source: master brief §6 Day 6 line 490 (8 core entities)
    11	#       + bullhorn-integration-path.md §4.1 (per-agent endpoint requirements)
    12	#       + autosend-safety-policy.md §3 (action_type references)
    13	#       + Day-4 runbook §6.3 (canonical Postgres schema)
    14	#       + Day-5 v1.0-kill-criterion.md (Trigger 1 acquisition-by-2026-06-03)
    15	# ============================================================================
    16	
    17	vertical: recruitment
    18	version: v0.1
    19	status: Proposed
    20	date: 2026-05-18
    21	author: founder (Maddox), Day-6 draft via Claude Code
    22	codex_ratification_queue_position: 18
    23	
    24	non_goals:
    25	  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
    26	  - cortextOS substrate entities (PM2 process records, file-bus messages, approval gate entries) are NOT modelled here. They live in cortextOS's own state per master brief §2.4.
    27	  - Vault-internal artefacts (markdown pages, frontmatter, wiki-links) are NOT entity_types. The vault is the source of truth for narrative content; this schema is the source of truth for structured state. See master brief §3.3 vault/Postgres split.
    28	
    29	# ============================================================================
    30	# §1 — Entity definitions
    31	# ============================================================================
    32	# Each entity below specifies:
    33	#   - description: 1-2 sentence definition in the IFOS canonical vocabulary
    34	#   - bullhorn_source: the Bullhorn entity (and any status filter) this maps from
    35	#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
    36	#   - canonical_fields: minimal v1.0 working set (10-20 fields per master brief §6 Day 6 "Every field" intent, scoped to v1.0 agent reach per Q3 decision)
    37	#   - notes: anything entity-specific worth flagging
    38	#
    39	# Field types follow JSON Schema conventions: type = string | integer | number | boolean | array | object | (ISO 8601) timestamp / date
    40	# `required: true` means the entity cannot be persisted without this field set; `required: false` means nullable.
    41	# `source: Bullhorn.<Entity>.<field>` means sourced from Bullhorn at ingest;
    42	# `source: IFOS-derived` means computed/written by IFOS code (e.g., voice_classifier_score).
    43	# ============================================================================
    44	
    45	entities:
    46	
    47	  # --------------------------------------------------------------------------
    48	  candidate:
    49	    description: |
    50	      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
    51	    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
    52	    v1_0_agent_access:
    53	      - Janitor (R+W — sweep + normalisation + dedup-merge proposals per bullhorn §4.1 A2)
    54	      - Scribe (R+W — field updates from call transcripts per bullhorn §4.1 A3)
    55	      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
    56	      - Concierge (R+W — lifecycle state per bullhorn §4.1 A6)
    57	    canonical_fields:
    58	      bullhorn_id:
    59	        type: integer
    60	        required: true
    61	        source: Bullhorn.Candidate.id
    62	        notes: Adapter-layer primary key for Bullhorn round-trip. Stable across ingests.
    63	      first_name:
    64	        type: string
    65	        required: true
    66	        source: Bullhorn.Candidate.firstName
    67	      last_name:
    68	        type: string
    69	        required: true
    70	        source: Bullhorn.Candidate.lastName
    71	      email:
    72	        type: string
    73	        required: false
    74	        source: Bullhorn.Candidate.email
    75	        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
    76	      phone:
    77	        type: string
    78	        required: false
    79	        source: Bullhorn.Candidate.phone
    80	      mobile:
    81	        type: string
    82	        required: false
    83	        source: Bullhorn.Candidate.mobile
    84	      status:
    85	        type: string
    86	        required: true
    87	        source: Bullhorn.Candidate.status
    88	        enum: [active, archived, do_not_contact, placed, contractor_promoted]
    89	        notes: |
    90	          "contractor_promoted" = candidate whose status flipped to contractor; row gets duplicated as entity_type="contractor" via adapter layer.
    91	      owner_user_id:
    92	        type: integer
    93	        required: false
    94	        source: Bullhorn.Candidate.owner.id
    95	        notes: Bullhorn user (consultant) who owns this candidate record.
    96	      date_added_at:
    97	        type: timestamp
    98	        required: true
    99	        source: Bullhorn.Candidate.dateAdded
   100	      date_last_modified_at:
   101	        type: timestamp
   102	        required: true
   103	        source: Bullhorn.Candidate.dateLastModified
   104	      current_role:
   105	        type: string
   106	        required: false
   107	        source: Bullhorn.Candidate.occupation
   108	      current_employer:
   109	        type: string
   110	        required: false
   111	        source: Bullhorn.Candidate.companyName
   112	      desired_role:
   113	        type: string
   114	        required: false
   115	        source: IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)
   116	      salary_expectation_min:
   117	        type: number
   118	        required: false
   119	        source: IFOS-derived (Scribe extraction; GBP annual)
   120	      salary_expectation_max:
   121	        type: number
   122	        required: false
   123	        source: IFOS-derived (GBP annual)
   124	      location:
   125	        type: string
   126	        required: false
   127	        source: Bullhorn.Candidate.address.city
   128	        notes: Free-text city/region for v0.1. Structured location pending v1.1.
   129	      willing_to_relocate:
   130	        type: boolean
   131	        required: false
   132	        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
   133	      notice_period_weeks:
   134	        type: integer
   135	        required: false
   136	        source: IFOS-derived (Scribe extracts)
   137	      source:
   138	        type: string
   139	        required: false
   140	        enum: [linkedin, referral, bullhorn_existing, direct_application, sourcing_scout, other]
   141	        source: IFOS-derived (set by Sourcing Scout at first-touch)
   142	      voice_classifier_score:
   143	        type: number
   144	        required: false
   145	        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
   146	        notes: |
   147	          Concierge gate threshold ≥ 0.75 per bullhorn §4.1. **Bounded [0.0, 1.0] enforced by the `validate_voice_scores` PL/pgSQL trigger** that lands via the v0.2 migration at `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` §7. v0.1 declares the field shape; v0.2 enforces the bound. Insertion attempts with out-of-range values raise `EXCEPTION` and reject the write.
   148	    notes:
   149	      - PII handling — fields email, phone, mobile, location are PII per UK GDPR Art. 4(1). Autosend-policy.md §7 `payload_preview` rules apply.
   150	      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.
   151	
   152	  # --------------------------------------------------------------------------
   153	  contractor:
   154	    description: |
   155	      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
   156	    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
   157	    v1_0_agent_access:
   158	      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
   159	      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
   160	      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
   161	      - Concierge (R+W — lifecycle state; week-1/month-1 check-ins differ for contractors per Product Spec §2.2 R7)
   162	    canonical_fields:
   163	      # Inherits candidate fields conceptually; below are the additional contractor-specific fields.
   164	      # Full implementation: adapter layer materialises both candidate-overlap fields AND contractor-specific fields in entities.data.
   165	      # Schema notes: see candidate canonical_fields for the shared base set.
   166	      bullhorn_id:
   167	        type: integer
   168	        required: true
   169	        source: Bullhorn.Candidate.id
   170	        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
   171	      first_name:
   172	        type: string
   173	        required: true
   174	        source: Bullhorn.Candidate.firstName
   175	      last_name:
   176	        type: string
   177	        required: true
   178	        source: Bullhorn.Candidate.lastName
   179	      email:
   180	        type: string
   181	        required: false
   182	        source: Bullhorn.Candidate.email
   183	      mobile:
   184	        type: string
   185	        required: false
   186	        source: Bullhorn.Candidate.mobile
   187	      ir35_status:
   188	        type: string
   189	        required: true
   190	        enum: [inside_ir35, outside_ir35, undetermined, exempt_small_business]
   191	        source: IFOS-derived (Concierge captures from intake call; v2.0 T4 IR35 agent owns)
   192	        notes: Pilot-agreement liability per autosend-policy.md §10 — incorrect IR35 classification is a tenant liability event. T4 IR35 agent (v2.0) is the canonical owner.
   193	      day_rate_min:
   194	        type: number
   195	        required: false
   196	        source: IFOS-derived (Scribe extracts from call; GBP per day)
   197	      day_rate_max:
   198	        type: number
   199	        required: false
   200	        source: IFOS-derived (GBP per day)
   201	      umbrella_company:
   202	        type: string
   203	        required: false
   204	        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
   205	        notes: v0.1 free-text. v1.1 entity-promotion candidate if Concierge surfaces shared-umbrella-company queries.
   206	      availability_weeks:
   207	        type: integer
   208	        required: false
   209	        source: IFOS-derived (when can contractor start, in weeks from now)
   210	      current_engagement_end_date:
   211	        type: date
   212	        required: false
   213	        source: IFOS-derived
   214	        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
   215	    notes:
   216	      - IR35 classification is regulatory-bearing; v0.1 captures the field but T4 IR35 agent (v2.0 per master brief §9) is the canonical reasoner.
   217	      - Contractor lifecycle differs from candidate — relevant to Concierge nurture cadence per Product Spec §2.2 R7 (week-1 check-in for permanent; weekly check-in for contractor through engagement).
   218	      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.
   219	
   220	  # --------------------------------------------------------------------------

exec
/bin/zsh -lc "rg -n \"placement|client_contact|client contact|billing contact|entity_links\" agents/recruitment/janitor agents/recruitment/scribe agents/recruitment/concierge docs/verticals/recruitment -g '*.md' -g '*.yaml' | head -200" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:35:# No ALTER TABLE for the candidate / contact / brief / placement / opportunity
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:173:  placement:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:175:      placement_status:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:281:#   - Janitor placement: R → R+W (lifecycle-state cleanup writes —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:283:#   - Janitor timesheet: none → R (reads for placement-state inference)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:290:#   - Scribe timesheet: none → R (reads for placement-context resolution
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:294:#   - Cash Conductor placement: none → R (reads for client linkage on invoice)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:305:#   - Concierge contractor: R → R+W (lifecycle states for contractor placements)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:307:#   - Concierge placement: R → R+W (writes Bullhorn state advancement per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:309:#   - Concierge timesheet: none → R (reads to verify placement-progress for
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:323:  # (candidate, contractor, client, contact, brief, opportunity, placement,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:333:  # in the entities/entity_links generic primitive layer from Day-4 §6.3."
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:380:    placement: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:390:    placement: R+W         # lifecycle-state cleanup
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:391:    timesheet: R           # reads for placement-state inference
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:406:    placement: R+W         # check-in field extraction (Bullhorn Placement endpoint A3)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:407:    timesheet: R           # IFOS-cached read; placement-context resolution (Bullhorn Timesheet endpoint NOT used at v1.0)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:421:    placement: R           # IFOS-cached read; client linkage on invoice
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:440:    placement: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:449:    contractor: R+W        # writes lifecycle states for contractor placements too (Bullhorn endpoint A6 — candidate entity)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:454:    placement: R+W         # CORRECTED v0.3 (was R); writes Bullhorn state advancement per concierge §4 Step 14 (Bullhorn endpoint A6)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:455:    timesheet: R           # IFOS-cached read; placement-progress for 7d/30d/90d nurture (Bullhorn Timesheet endpoint NOT used at v1.0)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:525:  placement:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:539:      - Janitor (R)        # v0.3 NEW — reads for placement-state inference
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:540:      - Scribe (R)         # v0.3 NEW — reads for placement-context on check-in calls
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:542:      - Concierge (R)      # v0.3 NEW — reads to verify placement-progress for nurture
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:546:      placement-related workflows).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:570:      - Concierge (R+W)    # v0.3 UPGRADED — lifecycle states for contractor placements
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:675:      client_contact_id: {type: string, required: false, source: IFOS-derived (Cash Conductor resolves the billing contact from cached Bullhorn client_contact rows via the placement→client→contact entity_links relationship; NOT from a denormalized placement.client_contact_id field, which the base schema does not declare)}
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:911:      candidate / contact / brief / placement / opportunity entity_types.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:972:  Q3_placement_status_enum_lifecycle:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:973:    question: 6-state placement_status enum maps to Bullhorn's native state machine?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:977:      C: Add a mapping table (auxiliary) — placement_status_mapping with
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1030:      placement_status, week_1_status_vault_path, satisfaction_signal,
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:16:# Layer over v0.1 generic primitives (entities + entity_links + decision_log
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:36:#   `migrations/v0.1-to-v0.2.sql`), NOT as entity_types in the entities/entity_links
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:48:#   v0.1 entities (candidate, contractor, contact, brief, opportunity, placement)
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:223:        notes: bullhorn_id or IFOS slug. Used in the entity_links join below.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:327:  placement:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:333:        Snapshot of mean voice classifier score across all Concierge messages for the candidate during the 30 days BEFORE placement close. Captures voice quality at the moment of commercial success — drives "did voice quality predict deal close" reporting + v2.0 LoRA pipeline label generation.
docs/verticals/recruitment/vertical-schema.yaml:5:#   - entity_links (..., source_entity_type, source_entity_id, target_entity_type, target_entity_id, link_type, ...)
docs/verticals/recruitment/vertical-schema.yaml:50:      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
docs/verticals/recruitment/vertical-schema.yaml:155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
docs/verticals/recruitment/vertical-schema.yaml:214:        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
docs/verticals/recruitment/vertical-schema.yaml:218:      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.
docs/verticals/recruitment/vertical-schema.yaml:223:      A company that hires through the recruitment agency. Master brief canonical vocabulary at §3.2 line 155 ("candidate, placement, brief") implicitly assumes client as the holder of briefs. Bullhorn calls this `ClientCorporation`.
docs/verticals/recruitment/vertical-schema.yaml:429:  placement:
docs/verticals/recruitment/vertical-schema.yaml:431:      A candidate placed into a client role. The commercial transaction unit — fees accrue per placement, lifecycle events (week-1, month-1, etc.) fire per placement per Product Spec §2.2 R7.
docs/verticals/recruitment/vertical-schema.yaml:434:      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:450:        notes: Nullable for permanent placements; required for contract.
docs/verticals/recruitment/vertical-schema.yaml:456:      placement_type:
docs/verticals/recruitment/vertical-schema.yaml:465:        notes: GBP. For permanent placements typically % of candidate_salary_at_placement; for contract typically per-day margin.
docs/verticals/recruitment/vertical-schema.yaml:471:      candidate_salary_at_placement:
docs/verticals/recruitment/vertical-schema.yaml:491:      - Placement is the canonical commercial unit. Kill criterion §2 Trigger 8 (Gate B revenue uplift <£20k/year/tenant) is computed from placement.fee_amount aggregates.
docs/verticals/recruitment/vertical-schema.yaml:497:      A candidate-brief pairing in the submission/screening/interview/offer pipeline. Pre-placement state. v1.1+ exercised; v1.0 minimal.
docs/verticals/recruitment/vertical-schema.yaml:574:# §2 — Relationship definitions (entity_links.link_type values)
docs/verticals/recruitment/vertical-schema.yaml:587:    target: placement
docs/verticals/recruitment/vertical-schema.yaml:589:    description: A candidate may have multiple placements over time (different clients, different roles). A placement has exactly one candidate.
docs/verticals/recruitment/vertical-schema.yaml:591:      Despite "M:N" cardinality, practically 1:N from placement → candidate (each placement has one candidate; each candidate has 0..N placements). Modelled as M:N for query symmetry.
docs/verticals/recruitment/vertical-schema.yaml:592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
docs/verticals/recruitment/vertical-schema.yaml:594:  placement_for_brief:
docs/verticals/recruitment/vertical-schema.yaml:595:    source: placement
docs/verticals/recruitment/vertical-schema.yaml:598:    description: Each placement fills exactly one brief; a brief may have multiple placements over time (replacement hires, multiple seats).
docs/verticals/recruitment/vertical-schema.yaml:614:      v0.1 captures the PRIMARY decision-maker only. Real-world recruiting often has multiple decision-makers per brief (hiring manager + HR + occasionally CTO/CFO/CEO). The N:1 cardinality is the simplifying v0.1 assumption. Multi-decision-maker panels deferred to v1.1 Triage per Q10 — when v1.1 lands, brief_decision_maker may flip to M:N with role-in-panel metadata (chair, technical-evaluator, hr-lead, budget-approver, etc.) on entity_links.metadata.
docs/verticals/recruitment/vertical-schema.yaml:654:  timesheet_for_placement:
docs/verticals/recruitment/vertical-schema.yaml:656:    target: placement
docs/verticals/recruitment/vertical-schema.yaml:658:    description: Each timesheet relates to one (contract) placement; a placement has 0..N timesheets over its duration.
docs/verticals/recruitment/vertical-schema.yaml:677:    placement: none
docs/verticals/recruitment/vertical-schema.yaml:688:    placement: R     # orphan / stale-tag sweep
docs/verticals/recruitment/vertical-schema.yaml:698:    placement: R+W   # note links on placed-candidate calls
docs/verticals/recruitment/vertical-schema.yaml:708:    placement: none  # Reads placement.fee_amount aggregates but via Xero invoice records, not via Bullhorn placement entity
docs/verticals/recruitment/vertical-schema.yaml:718:    placement: none
docs/verticals/recruitment/vertical-schema.yaml:728:    placement: R+W   # lifecycle stage maintenance (week_1, month_1, etc.)
docs/verticals/recruitment/vertical-schema.yaml:771:  placement:
docs/verticals/recruitment/vertical-schema.yaml:835:    revisit_trigger: If Concierge surfaces multi-contractor patterns where the same umbrella company serves multiple IFOS-tracked contractors (e.g., "all contractors at Acme Umbrella who terminate placements within 90 days"), promote umbrella_company to entity_type='umbrella_company' in v1.1.
docs/verticals/recruitment/vertical-schema.yaml:844:  Q9_multi_client_contact:
docs/verticals/recruitment/vertical-schema.yaml:861:    v0_1_decision: placement.lifecycle_stage enum is hardcoded to Product Spec §2.2 R7 values (pre_start, week_1, month_1, month_3, month_6, month_12, month_24, completed).
docs/verticals/recruitment/vertical-schema.yaml:862:    revisit_trigger: Any Product Spec revision touching R7 nurture cadence (e.g., adding week_2 checkpoint, removing month_24, splitting month_12 into quarterly checkpoints) requires schema migration. Migration steps — (1) ALTER TABLE add new enum value(s) to entities.data JSONB validator; (2) backfill existing placement rows if semantic change (e.g., week_1 → week_1_check_in renaming); (3) Concierge nurture-event firing logic updated to match new cadence.
docs/verticals/recruitment/vertical-schema.yaml:898:      Triage expansion (Q5 contact decision-authority granularity, Q10 panel hiring). Skill taxonomy decision (Q8). Multi-client contact decision (Q9). Umbrella company entity promotion candidate (Q7). Opportunity entity exercise begins.
agents/recruitment/concierge/tools.yaml:53:  - id: bullhorn_get_placement
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:45:  placement_id: "PLAC-202"
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:59:  placement:
agents/recruitment/concierge/fixtures/01-primary.yaml:37:  placement_id: "PLAC-200"
agents/recruitment/concierge/fixtures/01-primary.yaml:50:  placement:
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:42:  placement_id: "PLAC-201"
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:58:  placement:
agents/recruitment/concierge/agent.md:10:**Build complexity:** XL (4 weeks) per ULTRAPLAN A6 line 568 — "the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)".
agents/recruitment/concierge/agent.md:19:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 position 1 / ≥0.78 position 2 / ≥0.82 position 3, per ULTRAPLAN A6 line 566 verbatim) OR any draft with incorrect addressee resolution (per same line — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §Gotchas line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:28:# Bullhorn placement state-change webhook → Concierge handler
agents/recruitment/concierge/agent.md:34:  "event_type": "placement.state_changed" | "candidate.state_changed",
agents/recruitment/concierge/agent.md:84:| 11 | 30-day check-in | Nurture-check-in | Candidate + Client | Slightly longer; both sides; reads for placement-risk signals |
agents/recruitment/concierge/agent.md:93:placement_id: <bullhorn-id or null>
agents/recruitment/concierge/agent.md:95:recipient_role: candidate | client_contact
agents/recruitment/concierge/agent.md:135:   → mode=poll: query Bullhorn for placements/candidates with state_changed_at
agents/recruitment/concierge/agent.md:138:   → mode=nurture-sweep: query Bullhorn placements for time-elapsed events
agents/recruitment/concierge/agent.md:168:   → bullhorn.get_placement(placement_id) → role, client, dates
agents/recruitment/concierge/agent.md:182:   → recipient = candidate.email OR client_contact.email per event_type
agents/recruitment/concierge/agent.md:199:     OR (event_type=on-hold AND placement value >£10k): set escalation_position=3
agents/recruitment/concierge/agent.md:395:- Position 2 (placement-positive, status-update): voice ≥0.78
agents/recruitment/scribe/agent.md:17:> **Scribe ingests a call transcript from Fathom / Fireflies (Ringover deferred to v1.1+ — not in v0 build dependencies; webhook-triggered within 30 seconds of call end) and produces TWO outputs:** (1) a structured Bullhorn write payload populating ≥3 placement-relevant fields on the appropriate entity (candidate / contractor / contact / brief / opportunity / placement per the call context), and (2) one tacit-note Markdown artefact written to `/vault/<tenant>/scribe-notes/<call_id>-<ISO-date>.md` containing the consultant's "things I'd write down but there's no field for" observations. The tacit-note vault artefact is also mirrored as a Bullhorn `Note` attachment on the resolved entity (consultant-visible in their ATS); the vault copy is the canonical narrative source per ADR-002 vault/Postgres split. End-to-end SLA: post-call note in Bullhorn within 10 minutes of webhook receipt per master brief §8.2 line 597. Gate A hard-fails any transcript that doesn't produce ≥3 structured-field extractions AND 1 tacit-note with confidence ≥0.6 (per ULTRAPLAN A3 line 524). Gate B success threshold: 90% of calls processed within 5 minutes; consultant edit-rate on structured fields ≤20% (per ULTRAPLAN A3 line 525). Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml`; tacit-notes are voice-classified (≥0.75 score) per master brief §8.1 Change 1.
agents/recruitment/scribe/agent.md:67:- 1:1 call with client contact → Contact entity update
agents/recruitment/scribe/agent.md:79:| Placement | `start_date`, `placement_status` (v0.3), `week_1_status_vault_path` (v0.3; vault pointer, not narrative), `satisfaction_signal` (v0.3) |
agents/recruitment/scribe/agent.md:82:Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Scribe agent.md will re-verify field-name accuracy against the supplement-as-RATIFIED state at W6 Day-1.
agents/recruitment/scribe/agent.md:161:   → infer call context (1:1 vs briefing vs placement vs opportunity)
agents/recruitment/janitor/agent.md:57:| 1 | **Record counts** | Total candidates / contractors / clients / contacts / placements / opportunities before + after this run; deltas per entity type |
agents/recruitment/janitor/agent.md:94:   → enumerate candidates + contractors + clients + contacts + placements +
agents/recruitment/janitor/agent.md:189:- No merge proposal where EITHER candidate has activity (placement / interview / note) in last 90 days (per ULTRAPLAN A2 line 510 verbatim)
agents/recruitment/janitor/agent.md:246:  - No commercial sensitive information (rates / placement fees / commission %)

exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/tools.yaml | sed -n '130,212p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   130	  # public-API call sites have distinct audit + failure semantics:
   131	  #   - proposeApproval: state-changing; emits ORANGE decision_log row
   132	  #   - awaitApprovalDecision: read-only poll; produces no audit row directly
   133	  # Per D1-B doc §"Implementation surface" item 4: declare the capability on
   134	  # both Concierge AND Cash Conductor (Cash Conductor is the Step-10 consumer).
   135	  # ────────────────────────────────────────────────────────────────────────
   136	
   137	  - id: autosend_bridge_telegram_propose
   138	    package: "@ifos/autosend-bridge-telegram"
   139	    api: proposeApproval
   140	    purpose: "Post orange-tier chase-send approval request to operator Telegram chat (D1-B founder decision)"
   141	    action_type: xero_reminder_send_customer  # ORANGE tier; REGISTERED at autosend-policy.yaml line 263; Cash Conductor OWNS this action_type per the same line
   142	    cycle_step: 10
   143	    state_changing: true
   144	    optional: true  # cycle.sh Step 10 checks for the package dist/; falls back to drafts-only mode if absent (graceful degradation per agent.md §1 readiness caveat)
   145	    failure_modes:
   146	      - condition: "Telegram postMessage transport failure (network, 5xx, invalid chat_id)"
   147	        surface: "BridgeTransportError thrown by package"
   148	        escalation: ESC_AGENT_TOOL_FAILURE  # transport-class failure, NOT timeout (different routing)
   149	
   150	  - id: autosend_bridge_telegram_await
   151	    package: "@ifos/autosend-bridge-telegram"
   152	    api: awaitApprovalDecision
   153	    purpose: "Block on operator approve/reject reply from Telegram (PT4H deadline; authoritative on absolute expires_at_iso, not poll-count × interval)"
   154	    cycle_step: 10
   155	    state_changing: false  # poll-side; does not write tenant data
   156	    optional: true
   157	    failure_modes:
   158	      - condition: "Operator never replies before PT4H expires_at_iso"
   159	        surface: "outcome=timeout (or BridgeTimeoutError via awaitApprovalDecisionOrThrow)"
   160	        escalation: ESC_APPROVAL_BRIDGE_TIMEOUT  # warn-tier per escalation-codes.md lines 348-353; routes operator_chat_id + ifos_oncall_chat_id; action converts to manual reconciliation
   161	
   162	  # ────────────────────────────────────────────────────────────────────────
   163	  # Operator notification (Telegram operator-chat-id; not customer-facing)
   164	  # ────────────────────────────────────────────────────────────────────────
   165	
   166	  - id: telegram_notify
   167	    package: "@ifos/telegram"
   168	    purpose: "Operator-channel Telegram notifications (NOT customer-facing; green tier)"
   169	    action_type: operator_notify_telegram  # green tier; REGISTERED in autosend-policy.yaml
   170	    cycle_step: 14
   171	    state_changing: false  # write to Telegram is an external side-effect but not on tenant data
   172	    secrets_required: [TELEGRAM_BOT_TOKEN]
   173	
   174	  # ────────────────────────────────────────────────────────────────────────
   175	  # Cleanup (cleanup.sh — deferred to Day-27+)
   176	  # ────────────────────────────────────────────────────────────────────────
   177	
   178	  - id: cash_conductor_cleanup
   179	    purpose: "Post-run cleanup (transient OAuth-cache + provider-rate-limit-cache purge)"
   180	    action_type: cash_conductor_cleanup  # green tier; registration queued for cleanup.sh build at W7-8
   181	    state_changing: false
   182	    # NOTE: cleanup.sh skeleton DEFERRED to next bundle pass per goal-w4-day-26 §3 stretch scope
   183	
   184	# ──────────────────────────────────────────────────────────────────────────────
   185	# Action-type registration status (cross-reference autosend-policy.yaml at W7-8)
   186	# ──────────────────────────────────────────────────────────────────────────────
   187	#
   188	# Already REGISTERED in agents/_shared/autosend-policy.yaml (verified 2026-05-25
   189	# during cash-conductor Codex Round 1 closure):
   190	#   xero_reminder_draft_internal       line 188   yellow
   191	#   xero_reminder_send_customer        line 263   orange    [Cash Conductor OWNS this]
   192	#   accounting_reconciliation_write    yellow              (shared with Xero + QB)
   193	#   operator_notify_telegram           green
   194	#
   195	# QUEUED for registration at W7-8 build start:
   196	#   xero_oauth                         green
   197	#   quickbooks_oauth                   green
   198	#   open_banking_truelayer             green
   199	#   open_banking_plaid_uk              green   (v1.1+; queued but never fires v1.0)
   200	#   cash_conductor_cleanup             green
   201	
   202	# ──────────────────────────────────────────────────────────────────────────────
   203	# Boundary check (per master brief §3 + review-mcp-connector.md §8)
   204	# ──────────────────────────────────────────────────────────────────────────────
   205	#
   206	# - No Composio / AgentMail references anywhere in this file.
   207	# - All packages declared are @ifos/* — no third-party adapters with policy
   208	#   semantics smuggled in via tools.yaml.
   209	# - Action types all map to autosend-policy.yaml tiers (or are explicitly
   210	#   marked QUEUED above for W7-8 build-start registration).

exec
/bin/zsh -lc "rg -n \"line 263|line 188|line 41|line 163|line 729|lines 721-731|§2\\.10|§2\\.9|§2\\.7|§2\\.5\" agents/recruitment/cash-conductor/agent.md agents/recruitment/cash-conductor/tools.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/cash-conductor/agent.md:20:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the `xero_reminder_send_customer` action_type (registered in autosend-policy.yaml under §ORANGE; grep `^  xero_reminder_send_customer:` to verify) which is the **chase-approval-initiation** audit row; Concierge runs the autosend bridge for approval routing, then performs the transport-execution and writes its OWN orange-tier `gmail_outlook_send_to_candidate` action row (Concierge-owned; registered under §ORANGE). Both agents write tier-classified action rows — the distinction is: Cash Conductor writes the initiation; Concierge writes the transport. The full autosend chain has TWO orange-tier rows in sequence (initiation + transport), both gated, both audited. Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport; and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW — grep `^  xero_reminder_draft_internal:` to verify; internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (registered under §ORANGE — grep `^  xero_reminder_send_customer:`; consultant approval required before send). **Note on citation discipline:** explicit line numbers in `autosend-policy.yaml` shift across edits; this agent.md uses grep-anchors instead per the pattern established in xero R3 closure (commit `5228fa2`). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** Founder Decision D1 ACCEPTED 2026-05-31 as D1-B (Telegram shim) + package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`); the autosend-bridge **production wiring** (real Telegram Bot API + postgres approvals reader) still lands in Concierge W10-13 build slice. Until then, Cash Conductor cycle.sh Step 10 detects the absent `packages/utilities/autosend-bridge-telegram/dist/` directory and emits a **`drafts_only_mode` marker** via `hh_decision_output` indicating that the orange-tier `xero_reminder_send_customer` row is suppressed (see `cycle.sh` line 287 — this marker is the ONLY row Step 10 emits at the SKELETON layer; the W7-8 build slice replaces this with the full yellow-draft-row + vault-draft + orange-row chain documented in §3 below). The chase-draft pipeline currently halts at the marker; consultants pick up nothing because no vault drafts are produced yet — this is the SKELETON state, intentional, distinct from the W7-8 LIVE-impl drafts-only mode that produces yellow rows + vault drafts.
agents/recruitment/cash-conductor/agent.md:247:       customer) → `ESC_ADDRESSEE_MISMATCH` (per catalogue §2.10 — explicitly
agents/recruitment/cash-conductor/agent.md:250:     catalogue line 41; Cash Conductor's chase pipeline is orange-tier.
agents/recruitment/cash-conductor/agent.md:324:Gate A failures fire either `ESC_AGENT_OUTPUT_SHAPE` (invoice/amount/paid-precondition miss; output-shape constraint) OR `ESC_ADDRESSEE_MISMATCH` (client_contact_email mismatch; blocking per catalogue §2.10 — explicit Cash Conductor invoice/chase addressee case). Draft stays in `/tmp` (auto-purged 24h); operator notified per the specific ESC route.
agents/recruitment/cash-conductor/agent.md:349:| `ESC_OPEN_BANKING_TOKEN_AGING` | Open Banking PSD2 consent approaching 90-day expiry (staged) | info ≤30d / warn ≤14d / **blocking** ≤7d (per catalogue §2.7) | operator_chat_id (info+warn); + ifos_oncall_chat_id at blocking stage |
agents/recruitment/cash-conductor/agent.md:350:| `ESC_RECONCILIATION_AMBIGUOUS` | Stage 4 fuzzy multi-candidate match within tolerance (per catalogue §2.10 — bank-feed payment line cannot match a single Xero invoice; multiple candidates) | warn | operator_chat_id |
agents/recruitment/cash-conductor/agent.md:356:| `ESC_ADDRESSEE_MISMATCH` | Gate A miss on client_contact_email / addressee resolution (per catalogue §2.10 Cash Conductor case) | **blocking** | operator + ifos_oncall |
agents/recruitment/cash-conductor/agent.md:359:| `ESC_AUTOSEND_ORANGE_PENDING` | Chase draft awaiting consultant approval — heartbeat at ≥50% of declared timeout (per catalogue §2.9 trigger) | info | operator_chat_id (gentle reminder; no oncall CC) |
agents/recruitment/cash-conductor/agent.md:364:- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
agents/recruitment/cash-conductor/agent.md:365:- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Cash Conductor's Gate A misses are output-shape failures, not schema-field violations
agents/recruitment/cash-conductor/agent.md:366:- `ESC_VOICE_DRIFT_TENANT` — fired by the nightly voice-drift cron per catalogue §2.5; Cash Conductor fires only per-run `ESC_VOICE_DRIFT`, never the aggregate
agents/recruitment/cash-conductor/agent.md:379:- **NOTE: Cash Conductor does NOT read `recent_edit`.** Per v0.3 supplement §2a access grants (line 729; recent_edit block at lines 721-731), Cash Conductor has W-only access — it WRITES recent_edit rows when consultants edit its chase drafts post-send, but does NOT READ them. Voice continuity for Cash Conductor relies on the tenant voice_corpus + tone_rule reads above. Per-run `ESC_VOICE_DRIFT` fires when the chase voice classifier score is below threshold after 3 retries (LLM step internal to chase-draft generation; classifier scoring distinct from sample retrieval). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Cash Conductor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked by the canary (which has R access) for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Cash Conductor.
agents/recruitment/cash-conductor/tools.yaml:141:    action_type: xero_reminder_send_customer  # ORANGE tier; REGISTERED at autosend-policy.yaml line 263; Cash Conductor OWNS this action_type per the same line
agents/recruitment/cash-conductor/tools.yaml:190:#   xero_reminder_draft_internal       line 188   yellow
agents/recruitment/cash-conductor/tools.yaml:191:#   xero_reminder_send_customer        line 263   orange    [Cash Conductor OWNS this]

codex
REJECTED

1. Adapter-boundary violation in `tools.yaml` line 206. The bundle explicitly mentions the prohibited adapter names in the sentence `"No Composio / AgentMail references anywhere in this file."` The top-level boundary says Composio and AgentMail are never referenced in `tools.yaml`, even as a negative assertion. Fix by deleting the line or replacing it with wording that does not name the adapters.

2. Incorrect autosend-policy line citations in `tools.yaml` lines 141, 190, and 191. `xero_reminder_send_customer` is cited as line 263, but `agents/_shared/autosend-policy.yaml` has it at line 301; `xero_reminder_draft_internal` is cited as line 188, but it is at line 226. Fix by replacing these brittle line references with grep anchors, matching `agent.md` §1’s citation-discipline pattern.
tokens used
136,543
REJECTED

1. Adapter-boundary violation in `tools.yaml` line 206. The bundle explicitly mentions the prohibited adapter names in the sentence `"No Composio / AgentMail references anywhere in this file."` The top-level boundary says Composio and AgentMail are never referenced in `tools.yaml`, even as a negative assertion. Fix by deleting the line or replacing it with wording that does not name the adapters.

2. Incorrect autosend-policy line citations in `tools.yaml` lines 141, 190, and 191. `xero_reminder_send_customer` is cited as line 263, but `agents/_shared/autosend-policy.yaml` has it at line 301; `xero_reminder_draft_internal` is cited as line 188, but it is at line 226. Fix by replacing these brittle line references with grep anchors, matching `agent.md` §1’s citation-discipline pattern.
