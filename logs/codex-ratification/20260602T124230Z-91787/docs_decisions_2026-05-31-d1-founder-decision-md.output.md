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
session id: 019e885b-6186-76f0-84c9-724fb020d2d8
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

=== TYPE-SPECIFIC SKILL: architecture-decision ===

# Codex ratification skill — review-architecture-decision

Type-specific checks for: ADRs (`docs/decisions/ADR-*.md`), decision docs (`docs/decisions/*.md` other than ADRs), reference designs (`docs/architecture/*.md`), runbooks (`docs/runbooks/*.md`).

This skill ADDS to the top-level `SKILL.md`. Apply that first; everything below is incremental.

---

## §1 — Decision-doc shape requirements

Every artefact of this type MUST have:

1. **Status field** — one of `Proposed | Accepted | In Force | Reference | Superseded | Deprecated`. Match the file's content honestly:
   - `Proposed` = the decision exists but hasn't been ratified or actioned
   - `Accepted` = founder has approved + work is underway/done
   - `In Force` = the decision is binding operational policy right now
   - `Reference` = factual recording (audits, inventories, manifests)
   - `Superseded` = a later artefact replaces this one
   - `Deprecated` = the decision is no longer applied

   REJECT if status is missing, conflicts with content (e.g., "Accepted" but Sub-decisions are "Proposed pending commercial conversations"), or is "Accepted" without a Founder decision date.

2. **Context section** — explains the problem before the solution. Should be readable cold; if a new reader can't tell what this decision is about from the Context alone, REJECT. **Required for ALL statuses.**

3. **Decision section** — names the choice, not the deliberation. If the artefact is mostly deliberation with no clear decision, REJECT. **Required for `Proposed | Accepted`. EXEMPT for `Reference` (audits, inventories, manifests) and `In Force` (runbooks, operational standing policies) — those artefacts encode their "decisions" in the working content itself (audit findings table; runbook procedure steps); a separate Decision heading would be redundant ceremony.**

4. **Alternatives considered** — for ADRs, at least 2 alternatives MUST be named + rejected with reasons. If only one option is presented, REJECT — that's a memo, not a decision document. **Required for `Proposed | Accepted` ADRs only. EXEMPT for non-ADR Reference + In Force artefacts.**

5. **Consequences section** — what changes downstream. Includes risk register implications, master brief edits authorised (if any), downstream-artefact updates required. **Required for `Proposed | Accepted`. EXEMPT for `Reference` + `In Force` — downstream impact may be inline (e.g., "Day-7 single-sentence test Q2 references this audit") rather than under a dedicated heading; verify via cross-references in body text.**

6. **Status update line at end** — current state ("Accepted on 2026-05-16 by founder + Claude Code") OR ratification-pending note. **Required for ALL statuses.**

### §1-Exemption — Softening for Reference + In Force (Codex Round 1 D5)

The exemptions in items 3, 4, 5 above are the result of Founder Decision D5 (commit `2026-05-22`) resolving the disagreement at `docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md`. Reference artefacts (e.g., `cortexos-primitive-status.md` audit, `architecture-cohesion-review.md`, `tenancy-invariants.md`) and In Force artefacts (e.g., `operational-hygiene-protocol.md` runbook, `tenant-lifecycle.md` runbook) legitimately do not have "decisions" or "alternatives weighed" — they document findings or procedures.

**The Context requirement (item 2) and Status update line (item 6) still apply to ALL artefacts under this skill.** Citation accuracy (§3) and boundary checks (top-level SKILL.md §2) also apply to all.

If a `Reference` or `In Force` artefact is making material architectural claims that warrant deliberation, RATIFY with an advisory note suggesting the author consider promoting parts to an ADR. Do not REJECT solely for the missing Decision/Consequences sections on these status types.

---

## §2 — ADR-specific structure (for files matching `ADR-*.md`)

In addition to §1, ADRs MUST:

- Have a numbered identifier in the filename matching the contents ("ADR-003" in filename → "# ADR-003 —" as the H1)
- Be sequentially numbered (no gaps — ADR-001 → 002 → 003 → 004)
- Link to predecessor ADRs if extending or referring to them
- Have at least one "Decision" heading + at least one explicit "Decision 1 — <terse summary>" subheading per distinct decision

REJECT if any of these are missing.

---

## §3 — Citation accuracy (heavily-tested area)

Past audits found 15 fabricated `§10.4` references in one batch. Recurrence is likely. Check:

For every cited section reference (e.g., "master brief §6 Day 7 line 502"):

1. Open the cited file
2. Find the cited section
3. Verify the citation matches the content the artefact claims it does

If even one citation is wrong, REJECT with the specific citation listed. Past pattern: `master brief §10.4 cost target` cited 15 times; §10.4 is actually the Codex exclusion list with no cost-target content.

For relative references ("per ADR-003 §3.3.3"), confirm the section exists in the predecessor.

For commit-SHA references (e.g., `c21fbfe`, `fec8872`), confirm the SHA matches the artefact's date + makes sense in context. Don't require running `git show` if the SHA is consistent with the narrative.

---

## §4 — Master brief edit authorisation

If the ADR authorises master brief edits (an "## Master brief edits authorised by this ADR" section):

1. The proposed text MUST be quoted verbatim — both current AND proposed.
2. The edit's line numbers MUST match the live master brief (sample-check at least one).
3. Edits MUST land in either (a) this commit, (b) the next atomic-correction commit, or (c) an explicit deferred queue. Vague "later" disposition = REJECT.
4. Risk #7 (master-brief-drift-accumulation) edit count MUST update if this ADR adds edits to the queue.

---

## §5 — Spec-gap surfacing

Reference design docs often surface spec gaps (`§N.M-A`, `§N.M-B` etc.). Each gap MUST:

- Be numbered uniquely within the design doc
- State the gap (what's missing in the upstream spec)
- Recommend a resolution OR be explicitly deferred to a named owner + week
- Not contradict each other (gap §2.1-A resolution must not break gap §2.1-B resolution)

REJECT if a gap is stated without a resolution path AND not explicitly deferred with owner + trigger.

---

## §6 — Implementation deviation acknowledgement

If the ADR ratifies deviations from a predecessor ADR (e.g., ADR-004 deviates from ADR-003):

1. Predecessor MUST be linked
2. Each deviation MUST be numbered + reasoned individually
3. Predecessor's text MUST be quoted to show what's being deviated from
4. Reason for deviation MUST be concrete (citing a boundary, a runtime constraint, a discovered bug — not "felt cleaner")
5. Rollback or alternative path MUST be named ("if rejected: build X shim instead")

REJECT if deviations are listed without quoting the predecessor or without concrete reasoning.

---

## §7 — Decision_log audit fields (master brief §8.1 Change 2)

Architecture decisions don't directly write to `decision_log` (the agent runtime does), but they MAY constrain what the runtime writes. Check:

- If the decision adds a `decision_log.phase` value: confirm Day-4 §6.3 schema CHECK constraint includes it (`trigger | output | action | gating_failed | agent_handoff`)
- If the decision adds a new ESC code: confirm `agents/_shared/escalation-codes.md` (Phase 1 of Day 8) has the code listed
- If the decision references `payload.tier` or `payload.<key>`: confirm autosend-safety-policy §7 documents the field shape
- If the decision restricts `agent_name` values: confirm sentinel names (`_renderer`, `_tenant_admin`, `_codex_ratifier`, `_shared`) are consistent with usage

REJECT if a decision adds an enum value or column to `decision_log` without confirming the schema supports it.

---

## §8 — Boundary-specific rejections for this artefact type

In addition to the four boundaries in `SKILL.md` §2:

- **Submodule reference** — decision docs MAY name cortextOS files for reference (e.g., `add-agent.ts:131-140`); they MUST NOT propose modifying them. If the ADR proposes a modification to `packages/harness/cortextos/*` outside the shadow points, REJECT.

- **Adapter boundary** — `Composio` and `AgentMail` may appear in INTERNAL discussion text (e.g., "we considered Composio") but MUST NOT appear in `tools.yaml` shape definitions, agent.md examples, or schema fixtures. If the ADR proposes including either in any of those locations, REJECT.

- **v1 source code** — `~/code/intel-force-os/` (the v1 codebase) MUST NOT be modified. ADRs MAY reference v1 for prior-art lessons; MUST NOT instruct edits.

---

## §9 — Common false-RATIFY traps to watch for

Past patterns that look RATIFIABLE but should REJECT:

- **"Trust me" architecture** — the artefact asserts a design works without alternatives weighed. Even simple decisions need at least one weighted alternative.

- **Over-elaborated worked examples** — a 200-line "Concierge worked example" inside an architecture decision is a red flag for masking a thin decision underneath. Skim the worked example; if the decision itself is < 50 lines, REJECT and demand more decision-content.

- **Status drift** — file says `Accepted` but content includes `TODO`, `pending`, `to be decided`. REJECT.

- **Hidden caveats** — major limitations buried at the bottom in a "Notes" section. Surface to the Decision or Consequences section. REJECT.

- **Cross-cite hallucination** — references "as documented in §X" but §X doesn't actually document it. Check.

- **Numbered options that omit the chosen one's reasoning** — "Options: A, B, C. Chose B." but no reasoning for WHY B. REJECT.

---

## §10 — When to RATIFY-with-notes

Use this sparingly. RATIFIED-with-notes is appropriate when:

- The artefact passes all required checks but has typos or wording suboptimalities
- A genuinely advisory observation worth surfacing but not blocking
- The author should fix-up at next touch but the merge is fine

Anything load-bearing — citation errors, spec gaps without resolution, status drift, boundary violations — is REJECTED, not RATIFIED-with-notes. If you find yourself adding more than 5 lines of notes, the artefact has structural issues and should be REJECTED.

---

## §11 — Quick checklist (run this for every ADR-type artefact)

- [ ] Has Status field with valid value matching content
- [ ] Has Context, Decision, Consequences sections
- [ ] (If ADR) Numbered + sequentially located + has alternatives weighed
- [ ] All citations verifiable (sample at least 3)
- [ ] No fabricated section references
- [ ] No submodule modifications proposed outside shadow points
- [ ] No Composio/AgentMail in `tools.yaml`/`agent.md` examples
- [ ] No v1-source modifications proposed
- [ ] Any master-brief edits include current+proposed text + line numbers + disposition
- [ ] Spec gaps (if any) have named resolution or deferred owner
- [ ] Status field matches content honesty (no Accepted-with-pending-sub-decisions unless explicitly noted)

If all clear: RATIFIED.
If any fail: REJECTED with numbered issues citing specifics.

=== ARTEFACT UNDER REVIEW ===

Path: docs/decisions/2026-05-31-d1-founder-decision.md

--- BEGIN ARTEFACT ---

# Founder Decision D1 — autosend orange-tier path

**Status:** Accepted (founder-arbitrated 2026-05-31 via explicit delegation: *"i pretty much trust your decision making for the technical build stuff"*).
**Decision:** **D1-B — Telegram shim** for v1.0; D1-A as v1.1+ upgrade.
**Date:** 2026-05-31
**Author:** Claude Code (arbitrating per delegated authority); founder may override at any time before Concierge W10 build start.
**Supersedes:** the "D1 founder decision" line item in `2026-05-20-codex-round-1-founder-decisions.md` and the open-question rows in:
- `agents/recruitment/concierge/agent.md` §9 Q1
- `agents/recruitment/cash-conductor/agent.md` §8 (D1-pending fallback row)

---

## Context

Per `docs/decisions/autosend-safety-policy.md` §4, orange-tier action_types (customer-facing sends like `xero_reminder_send_customer`, `gmail_outlook_send_to_candidate`, `bullhorn_note_customer_visible`) require **synchronous consultant approval** before the send executes. The agent drafts; the consultant says yes; the transport fires; an audit row records the full chain.

Three paths were on the table for the v1.0 orange-tier approval mechanism:

| Option | Mechanism | v1.0 cost | Strengths | Weaknesses |
|---|---|---|---|---|
| **D1-A** Bridge to cortextOS approval system | Concierge POSTs to an internal cortextOS approval API; operator approves in Brain UI; bridge calls back | ~2 days build (~3 days if approval-API doesn't yet exist) | Architecturally clean; reuses cortextOS primitive #4 (approval gates); UX in Brain UI is consistent with other approval flows | Brain UI v1.0 approval UX not yet built; depends on cortextOS approval-API stability; tightest coupling to upstream |
| **D1-B** Lightweight Telegram shim | Concierge posts to operator's tenant-bound Telegram chat: `[ID:<x>] APPROVE drafted email to <recipient>? /approve <ID> or /reject <ID>`; Concierge polls Telegram or receives webhook; on approve → transport executes | <1 day build | Reuses cortextOS primitive #5 (Telegram surface) already in place; consultants are on Telegram already; lowest engineering cost; clean audit chain (every approve/reject = `decision_log` row); works the same for Cash Conductor + Concierge | Approval UX is a chat reply rather than a rich panel; per-draft attachment preview is just a 200-char text snippet + vault path; consultant must read the vault Markdown if they want to see the full draft body before approving |
| **D1-C** No autosend; manual pickup | Concierge writes the draft to vault; sets `requires_consultant_action=true`; no notification; consultant manually polls vault and copies drafts to outbound | 0 days build (already supported by drafts-to-vault flow) | Zero risk of incorrect autosend; zero new build | UX is brutal; consultants miss drafts; defeats Concierge's "no candidate ghosted" promise; effectively kills Concierge as a v1.0 differentiator |

---

## Decision: D1-B (Telegram shim)

**Why D1-B wins for v1.0:**

1. **Cost-aligned to v1.0 scope.** D1-A's clean architecture is the right *v1.1+* answer once Brain UI matures; for v1.0 ship, D1-B's <1-day build matches the W10-13 Concierge slice budget.
2. **Reuses an already-built primitive.** cortextOS primitive #5 (Telegram surface) is in place; operators already receive escalation notifications there. Adding `/approve <ID>` / `/reject <ID>` commands extends an existing surface rather than introducing a new one.
3. **Audit chain is identical to D1-A.** Both paths emit the same `decision_log` rows (`xero_reminder_send_customer` orange action → operator approve/reject → transport `gmail_outlook_send_to_candidate` action). The Telegram interaction is the trigger, not the audit substrate.
4. **D1-C kills Concierge's value.** Manual vault polling means missed drafts means ghosted candidates means Concierge fails its Gate B (`ghosted-rate <5%`). Non-starter.

**Tradeoff accepted:** the approval UX is text-only on Telegram. Consultants who want to see the full draft body before approving open the vault path in the Telegram message. This is the same friction as reviewing an email draft in any other ticket system; acceptable for v1.0.

**v1.1+ upgrade path (queued, not blocking):** D1-A bridge to cortextOS approval system + Brain UI rich-panel approval surface. The D1-B Telegram path stays available as a fallback (e.g., operator on the move, away from a desk). v1.1+ adds the *option* of D1-A, doesn't replace D1-B.

---

## Implementation surface (delivered by Concierge W10-13 build slice)

1. **`packages/utilities/autosend-bridge-telegram/`** — small TypeScript package:
   - `proposeApproval(action_type, target, draft_preview, vault_path, timeout=PT4H) → approval_id`
   - Posts to operator's tenant Telegram chat with `[ID:<approval_id>]` + draft preview + vault path + `/approve <id>` / `/reject <id>` instructions.
   - Polls or webhooks for the operator's reply.
   - Returns `{outcome: approved | rejected | timeout, decided_by: <telegram_user_id>}`.
   - Timeout default `PT4H` per `escalation-codes.md` `ESC_APPROVAL_BRIDGE_TIMEOUT` lines 348-353.
2. **Concierge `cycle.sh` Step 11** — calls `proposeApproval` for orange-tier drafts; on `approved`, proceeds to Step 12 transport; on `rejected` or `timeout`, fires `ESC_APPROVAL_BRIDGE_TIMEOUT` (timeout) or records rejection in `decision_log` (rejected).
3. **Cash Conductor `cycle.sh` Step 10** — same `proposeApproval` call for `xero_reminder_send_customer` rows; identical handling.
4. **`tools.yaml` capability declarations** — add `autosend_bridge_telegram` capability to both Concierge and Cash Conductor.
5. **Tenant config — schema-work pending.** The natural storage location for the per-tenant operator Telegram chat-id is `tenant_adapters.config`, BUT the v0.3 supplement's `validate_tenant_adapters_config_v0_3` trigger hard-fails on unknown keys per Rule 2 — and `operator_telegram_chat_id` is NOT currently in the 6-key allowlist (`cash_conductor_last_run`, `concierge_last_poll`, `concierge_send_window`, `janitor_dedup_threshold`, the 2026-05-31 Janitor key, `blocked_recipients`). Resolution path: **W10-13 Concierge build slice lands a v0.4 supplement** adding `operator_telegram_chat_id` to the allowlist (type: string; required: false; set_by: tenant-admin; read_by: concierge + cash-conductor for the autosend-bridge consumer). Until then, the bridge consumer (`@ifos/autosend-bridge-telegram`) takes the chat-id as a function argument rather than reading it from tenant_adapters — the function-arg shim is already in place per the package scaffold landed 2026-06-01 (commit `9b282d8`). This decision-doc does NOT block on the schema work; D1-B's APPROVAL is structural (Telegram vs cortextOS approval system vs no-autosend); the storage-location detail is a W10-13 implementation question.

---

## Codex ratification

This decision doc ratifies via `.codex/ratification/review-architecture-decision.md` skill. Currently in flight under **cluster G** (`bash scripts/run-codex-ratification.sh --cluster G`); session-by-session ratification status is tracked in the closing Status-update line.

## Consequences

- **Concierge §9 Q1 RESOLVED** — strike from "open questions" list at next agent.md touch.
- **Cash Conductor §8 D1-pending fallback** — flips from "drafts-only if unresolved" to "orange-tier `xero_reminder_send_customer` writes are live once Concierge W10-13 lands the autosend-bridge production wiring."
- **Concierge ratification §10** — `Founder Decision D1 RESOLVED` blocker now satisfied. Remaining Concierge Proposed → Accepted blockers per §10: ADR-007 Accepted + Codex RATIFIED (DONE 2026-05-31 + Round 3), pilot LOI (PENDING), Bullhorn A+B (PENDING), founder approves §9 Q2-Q6 (PENDING).
- **Schema impact: v0.4 supplement required (deferred to W10-13 Concierge build slice).** D1-B requires a per-tenant operator-Telegram-chat-id storage location. `tenant_adapters.config` is the natural home BUT the v0.3 supplement's `validate_tenant_adapters_config_v0_3` trigger hard-fails on unknown keys per Rule 2 and `operator_telegram_chat_id` is NOT in the current allowlist (see implementation surface item 5 for the full rationale + interim function-arg-mode workaround). The schema work + migration land in the W10-13 Concierge build slice as part of bridge-production-wiring; the decision-doc itself is structurally complete without that schema work. The previously-stated "No schema impact" claim has been removed — it was inconsistent with implementation surface item 5.
- **No additional API keys/signups for the founder vault.** Day-4 provisioning (`docs/runbooks/day-4-provisioning.md` §6.5) creates the `_secrets.env` SKELETON only (touched empty at mode 0600); the Telegram bot token is populated by founder bootstrap (covered separately by tenant onboarding playbook — NOT Day-4), and the per-tenant operator chat-id is populated by tenant onboarding (W10-13 build slice; see implementation surface item 5 above). Once both are in place, no recurring credentials work — the bot token doesn't rotate per send; the chat-id is per-tenant-stable.
- **Schema-before-code discipline — interim acceptance.** The five rules (master brief §1) state schema-before-code. Today's state has the bridge package scaffold + consumer wiring landed BEFORE the schema supplement. The interim resolution is acceptable because the consumers run in **function-arg mode only** (chat-id passed as function argument, NOT read from `tenant_adapters`) — so no consumer code actually attempts to read the not-yet-allowlisted key. The schema-before-code rule is respected at the runtime level (no schema-violating read happens); the consumer scaffolding is fine to exist as long as the function-arg-only constraint holds until the v0.4 supplement lands.

---

*End of D1 decision doc.*

---

**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commits `669a4f4` + `9ec2bd6`) — **in FUNCTION-ARG MODE only**, no `tenant_adapters.config.operator_telegram_chat_id` read attempts until the v0.4 schema supplement lands in the Concierge W10-13 build slice; Codex ratification currently in flight under cluster G (R2 closing 2026-06-02 per `docs/decisions/codex-disagreement-2026-06-02-*` ledger and the cluster G round-trip arc).

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
I’ll check the cited local files and the live repo state for the load-bearing claims: autosend policy, escalation code lines, schema allowlist, and the referenced decision/agent sections.
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '330,365p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc 'rg -n "''^##? §?4|orange|xero_reminder_send_customer|gmail_outlook_send_to_candidate|bullhorn_note_customer_visible|payload'"\\.tier|tier\" docs/decisions/autosend-safety-policy.md" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
39:**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
45:Four-tier traffic light. Every governed action falls into exactly one tier at every moment of execution. Tiers are properties of the **(action_type × tenant_override)** pair, not of the agent.
49:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
55:Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
61:Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
67:Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
73:## §3 — Examples per tier across the v1.0 agent surface
75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
100:| Agent | action_type | Why orange |
102:| **Concierge** | **`bullhorn_note_customer_visible`** | **CANONICAL ORANGE.** Writes a Bullhorn Note with `isExternal: true` (or equivalent) that becomes visible to the customer's full team in their CRM. Single send is irreversible (note remains in audit trail even if deleted). Source: `bullhorn-integration-path.md` §4.1 (establishes Concierge produces Notes on every lifecycle-event communication) + §6.3 (explicit sensitivity framing: "Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI"). |
103:| Concierge | `gmail_outlook_send_to_candidate` | Outbound email to candidate; customer-facing; reputation effects |
107:| Cash Conductor | `xero_reminder_send_customer` | Outbound payment reminder to customer; reputation + collection risk |
128:## §4 — Integration with the `hh_decision_action` contract
157:  # 1. Policy lookup — read tier from the canonical policy table
158:  local tier
159:  tier=$(autosend_policy_lookup "$action_type") || {
166:  tier=$(autosend_apply_tenant_override "$tier" "$action_type" "$tenant_slug") || {
173:  case "$tier" in
185:    orange)
186:      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
193:      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
194:      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
198:      # Fail-safe: unknown tier → red
199:      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
200:      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
215:Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:
223:  - bullhorn_note_customer_visible   # orange (CANONICAL — bullhorn-integration-path §4.1)
224:  - gmail_outlook_send_to_candidate  # orange
225:  - calendar_invite_send             # orange
226:  - twilio_sms_send                  # orange
239:**Tier:** orange
240:**Fires when:** an orange-tier action is invoked; opens cortextOS approval gate (primitive 4)
272:Action: bullhorn_note_customer_visible
283:**Fires when:** a red-tier action is invoked; blocked unconditionally
292:  "block_reason": "<enum: red_tier_classification | blocked_recipient | unauthorized_adapter | cross_tenant_violation | payment_action | billing_modification | legal_artefact | pii_geographic_breach>",
302:3. Operator may file a `false-block` feedback report via Brain UI if the tier classification seems wrong; report becomes input to next policy review
304:**Expected resolution:** no human response required. Informational only. Policy review may revisit tier classification if false-block reports accumulate (>3 reports for same `action_type` over 30 days → re-tier proposal goes to Codex ratification).
314:Block reason: payment_action (red-tier; never auto-sent in v1.0)
330:  "lookup_error": "<enum: unknown_action_type | policy_table_corrupt | override_resolution_failed | tenant_not_found | unknown_tier:<value>>",
338:1. `autosend_emit_decision_log` writes the row with `phase='gating_failed'`, `payload.tier='fail-safe-red'`
353:| Policy file references undefined tier | Tier dispatch hits `*)` default | `ESC_AUTOSEND_POLICY_LOOKUP_FAILED` with `lookup_error='unknown_tier:<value>'` | Policy file fixed; Codex ratifies; redeploy |
356:| Approval gate timeout (orange action) | `autosend_await_approval` returns timeout | Action auto-rejected with `payload.approval_status='timeout_rejected'`; agent receives non-zero from `hh_decision_action`; agent must abort or take alternate path | Operator may approve retroactively via Brain UI; new action_type variant fires (not auto-resumed) |
357:| Telegram primitive 5 unavailable (bot down, chat_id invalid) | `autosend_escalate` returns non-zero | Decision_log row still written; orange action falls back to **block-with-pending** state; agent halts at the action | IFOS oncall investigates Telegram primitive; once restored, pending approval gates resume |
380:--   phase = 'action'         when allowed (green/yellow/orange-approved)
381:--   phase = 'gating_failed'  when blocked (red/fail-safe-red/orange-rejected/orange-timeout-rejected)
384:--     "tier": "green|yellow|orange|red|fail-safe-red",
390:--     "approval_id": "<cortextOS approval gate id if orange>",
402:1. **"Did the agent send X?"** — query `decision_log WHERE tenant_slug=? AND agent_name=? AND payload->>'action_type'=? AND created_at > ?`. Result includes tier, target, approval_status, policy_version_sha.
404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
432:    "tier_overrides": {
434:      "linkedin_connection_request": "orange",
435:      "bullhorn_candidate_dedupe": "orange"
448:      "xero_reminder_send_customer": "PT24H"
461:1. **Elevation only.** Tenants can move an action_type from green → yellow → orange → red. They cannot move it the other direction (red → orange, orange → yellow, yellow → green).
464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
466:6. **`sampling_rates`** allow per-action_type adjustment to the 1-in-N spot-check rate for yellow tier. Tenant cannot set rate to 0 (disable sampling); minimum is 1-in-100.
481:- **Yellow** (sampled review) requires building the spot-check queue infrastructure (spot_check_queue table, Brain UI review interface, sampling-disagreement-feedback loop). Defers without operational risk: high-volume agent work can run as green at v1.0 without sampled review, with tier elevation to orange-in-v1.1 as a fallback if quality issues surface.
483:- v1.0 handles "needs approval" cases via **ad-hoc Telegram approval** outside the policy pipeline: agent emits a manual approval request via existing primitive 5, founder/operator resolves manually, agent proceeds. These cases are tracked as "would-be-orange" candidates for v1.1 prioritisation.
487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
488:- **Yellow tier:** spot-check sampling. Implementation tasks: `spot_check_queue` table, `autosend_should_sample` function, Brain UI spot-check review interface, sampling-disagreement feedback loop into policy review.
493:- **Adaptive tiering:** ML-driven tier adjustment based on incident history. E.g., if `linkedin_connection_request` shows 0 false-blocks over 90 days, automatically propose downgrade from orange to yellow.
494:- **Per-recipient reputation:** recipients with high engagement may be in implicit "always-orange" zone; recipients with prior unsubscribes may be elevated to red.
495:- **Pre-action policy simulation:** Brain UI feature — operator types proposed action; system shows tier, override impact, approval routing, expected resolution time. Reduces accidental tier-aware design.
511:classifies each agent action into one of four tiers: green, yellow,
512:orange, or red. The classification in effect at the moment of send, as
524:  (c) any action classified as orange that was approved by Tenant's
526:  (d) any tier override defined in Tenant's tenant_adapters configuration
527:      that elevates or otherwise alters the policy default tier
536:      tier;
555:payload.policy_version_sha field. Material changes to tier classification
599:| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
600:| 5 | Spot-check sampling rate for yellow tier — what's N? Default 1-in-10, but variable by action_type. | §2 + §8 | Recommend defaults per action_type in autosend-policy.yaml; tenant overrides within range 1-in-100 to 1-in-2. |
601:| 6 | v1.0 "would-be-orange" cases without orange tier implementation — how does the agent halt for ad-hoc Telegram approval without breaking the green/red binary? | §9 | Recommend a `hh_decision_action_ad_hoc_approval` helper that lives alongside `hh_decision_action`; agent explicitly calls it for known orange cases at v1.0; v1.1 deprecates as orange tier ships. |
603:| 8 | Spot-check disagreement feedback loop — what's the mechanism for spot-check reviewer disagreement to elevate an action_type's tier? | §2 + §11 | Recommend a `spot_check_disagreement` table; >3 disagreements over 30 days triggers a tier-elevation proposal that goes through Codex ratification. v1.1 builds this. |
604:| 9 | Cross-action coupling — can two green actions combine into an orange-tier effect? (e.g., two green Bullhorn tags applied together could equal an orange-tier "candidate placed on hold" state) | §1 + §3 | Recommend deferring — v1.0 treats actions as independent. If combinatorial effects surface in pilot operations, ADR-006+ revisits with per-pilot evidence. |
621:- **Q5 (sampling rate defaults for yellow tier):** ACCEPTED for v1.0 with explicit operational-guess flag. Real sampling rates need pilot data; current defaults (1-in-5 to 1-in-20 per `action_type` in §3) are operational guesses calibrated by analogy to typical CRM audit-sampling practice. Refinement happens once first pilot generates 4+ tenant-weeks of yellow-tier action volume.
622:- **Q6 (v1.0 ad-hoc orange handling without orange tier shipped):** ACCEPTED. `hh_decision_action_ad_hoc_approval` helper sits alongside `hh_decision_action` in `_shared/hook-helpers.sh` (Week-1 prereq 3). Agent explicitly calls `_ad_hoc_approval` for known orange cases at v1.0; v1.1 deprecates the helper as full orange tier ships through `hh_decision_action`'s case-orange branch.
634:**For Week 3-4 (Diagnostic agent build).** Diagnostic's `tools.yaml` will declare 3 action_types: `diagnostic_report_render` (green), `diagnostic_email_send` (orange — falls back to ad-hoc Telegram approval at v1.0 per §9 + §11 question 6), `diagnostic_calendar_invite` (orange — same).
636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
642:1. Tier classifications per §3 (especially canonical orange = Concierge Bullhorn Note)
657:- v1.0 ship date: tier coverage is green + red. Yellow + orange phase in v1.1.

exec
/bin/zsh -lc 'rg -n "Q1|D1|Founder Decision D1|orange-tier|autosend" agents/recruitment/concierge/agent.md agents/recruitment/cash-conductor/agent.md docs/decisions/2026-05-20-codex-round-1-founder-decisions.md' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/cash-conductor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R17 closed §8 sibling files + D1/bridge prereqs + §3 audit-row signatures (4-row chase lifecycle sequence). R19 fixes (2026-05-24): split draft body out of decision_log payload into vault path (per ADR-002 vault/Postgres split), recent_edit schema R access cite correction, Stage 3 ESC code disambiguation. **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram approval-shim; `docs/decisions/2026-05-31-d1-founder-decision.md`); `@ifos/autosend-bridge-telegram` package scaffold landed 2026-06-01 (commit `9b282d8`); Cash Conductor consumer wiring landed (commit `076e231`). Remaining gates: Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice replacing the SKELETON TODOs with live impl + Concierge W10-13 build slice landing the autosend-bridge production wiring (Telegram Bot API + postgres approvals reader) so the orange-tier send path activates.
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type (registered in autosend-policy.yaml under §ORANGE; grep `^  xero_reminder_send_customer:` to verify); Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW — grep `^  xero_reminder_draft_internal:` to verify; internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (registered under §ORANGE — grep `^  xero_reminder_send_customer:`; consultant approval required before send). **Note on citation discipline:** explicit line numbers in `autosend-policy.yaml` shift across edits; this agent.md uses grep-anchors instead per the pattern established in xero R3 closure (commit `5228fa2`). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** Founder Decision D1 ACCEPTED 2026-05-31 as D1-B (Telegram shim) + package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`); the autosend-bridge **production wiring** (real Telegram Bot API + postgres approvals reader) still lands in Concierge W10-13 build slice. Until then, Cash Conductor cycle.sh Step 10 detects the absent `packages/utilities/autosend-bridge-telegram/dist/` directory and degrades to **drafts-only** mode — produces yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT emit the orange-tier `xero_reminder_send_customer` rows (per §8 fallback row).
agents/recruitment/cash-conductor/agent.md:94:Each reconciliation write: `decision_log` row with `agent_name='cash_conductor'`, `phase='action'`, `action_type='accounting_reconciliation_write'` (yellow tier per autosend-policy.yaml lookup — `tier` is NOT a top-level decision_log column; it is recorded inside the autosend-emitted payload by `_shared/hook-helpers.sh`'s `hh_decision_action`). Payload `reason`/`payload_preview` carries `match_confidence` + `match_dimensions` as a string; for queryable-structured match metadata, the W7-8 build slice extends `hh_decision_action` to emit structured payload fields OR writes a separate audit row.
agents/recruitment/cash-conductor/agent.md:96:### Output 2 — Payment-chase drafts (yellow tier internal; Cash Conductor INITIATES the orange-tier customer send via Concierge approval bridge)
agents/recruitment/cash-conductor/agent.md:98:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type — grep `^  xero_reminder_send_customer:` in `agents/_shared/autosend-policy.yaml` to verify it's registered there under §ORANGE) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
agents/recruitment/cash-conductor/agent.md:112:expected_send_window: orange-tier approval expected within 24h
agents/recruitment/cash-conductor/agent.md:119:2. `phase='action'`, `action_type='xero_reminder_draft_internal'` (yellow tier per autosend-policy.yaml lookup; grep `^  xero_reminder_draft_internal:` to verify) — this row records that Cash Conductor classified the draft as yellow-tier internal. Per `hh_decision_action(action_type, target, payload_hash, payload_preview)`: `target` carries the invoice_id; `payload_hash` is a stable hash of the draft body; `payload_preview` carries the same metadata string as row 1's reason for cross-row correlation.
agents/recruitment/cash-conductor/agent.md:121:When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml lookup; grep `^  xero_reminder_send_customer:` to verify; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).
agents/recruitment/cash-conductor/agent.md:209:   → spot-check sampling per autosend-safety-policy.yaml yellow tier
agents/recruitment/cash-conductor/agent.md:248:     catalogue line 41; Cash Conductor's chase pipeline is orange-tier.
agents/recruitment/cash-conductor/agent.md:251:10. Chase-draft queue to Concierge (opens orange-tier approval bridge)
agents/recruitment/cash-conductor/agent.md:254:      payload_hash, payload_preview) — yellow tier per autosend-policy.yaml
agents/recruitment/cash-conductor/agent.md:257:      payload_hash, payload_preview) — orange tier per autosend-policy.yaml
agents/recruitment/cash-conductor/agent.md:260:      Concierge handles autosend-bridge call to operator (D1 path per
agents/recruitment/cash-conductor/agent.md:265:    → The orange-tier `xero_reminder_send_customer` action row was
agents/recruitment/cash-conductor/agent.md:267:      action_type per autosend-policy.yaml lookup; agent: cash-conductor).
agents/recruitment/cash-conductor/agent.md:308:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
agents/recruitment/cash-conductor/agent.md:358:- `ESC_AUTOSEND_BLOCKED` — that's red-tier per catalogue line 41; Cash Conductor's pipeline is orange-tier (chase send) or yellow-tier (reconciliation write); Gate A misses fire `ESC_AGENT_OUTPUT_SHAPE` instead
agents/recruitment/cash-conductor/agent.md:387:| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
agents/recruitment/cash-conductor/agent.md:405:| **Founder Decision D1 (autosend orange-tier path) ACCEPTED 2026-05-31** as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md` | ✅ ACCEPTED |
agents/recruitment/cash-conductor/agent.md:406:| **Autosend bridge package scaffold** — `@ifos/autosend-bridge-telegram` lib + types + tests landed 2026-06-01 (commit `9b282d8`); Cash Conductor consumer wiring at cycle.sh Step 10 landed (commit `076e231`) | ✅ SCAFFOLDED (Cash Conductor side) |
agents/recruitment/cash-conductor/agent.md:407:| **Autosend bridge production wiring** — real Telegram Bot API + postgres approvals reader; Concierge W10-13 build delivers; blocking for orange-tier send activation | Concierge W10-13 build slice (per D1-B decision-doc §"Implementation surface") | ⏸ |
agents/recruitment/cash-conductor/agent.md:408:| Fallback (interim): cycle.sh Step 10 detects absent `packages/utilities/autosend-bridge-telegram/dist/` and runs in drafts-only mode (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` until W10-13 wiring activates) | v1.0 interim — active until W10-13 | n/a |
agents/recruitment/cash-conductor/agent.md:416:**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start.
agents/recruitment/cash-conductor/agent.md:422:| Q1 | First-tenant accounting choice — Xero / QuickBooks / Sage? Affects which connector is W7-prio-1. | Tenant onboarding; depends on first pilot tenant's existing stack. |
agents/recruitment/cash-conductor/agent.md:446:- Founder approves §9 Q1 + Q2 + Q4 + Q7 + Q8
agents/recruitment/cash-conductor/agent.md:449:NOTE: D1 RESOLVED is NO LONGER a Proposed→Accepted blocker — D1 was Accepted 2026-05-31 as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md`, and the package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`). The autosend-bridge **production wiring** (real Telegram Bot API) remains a Concierge W10-13 deliverable; until then, Cash Conductor runs in drafts-only mode (interim — see §8 fallback row). The bridge wiring is an Accepted→In-Force blocker (build slice + first-production criterion below), not a Proposed→Accepted blocker.
agents/recruitment/cash-conductor/agent.md:453:- Concierge W10-13 lands the autosend-bridge production wiring so orange-tier sends activate
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:11:## D1 — Auto-send v1.0 tier enforcement (orange-tier behavior)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:14:- `docs/decisions/autosend-safety-policy.md` §3 (defines 4 tiers + classifies 10 action_types as orange)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:15:- `docs/decisions/autosend-safety-policy.md` §9 (says "v1.0 ships green + red only")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:16:- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issues 1+2
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:23:- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:24:- **D1-C: Ship orange-as-red default + manual override** — orange action_types refused by default in v1.0, but per-action manual approval via founder's Telegram bot allowed as escape hatch. Pragmatic; aligns with autosend §9 "orange handled outside the policy pipeline" wording. **Closest to current artefact wording but explicit about the manual surface.**
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:26:**Claude's recommendation (initial briefing, Day 8):** D1-C. v1.0 ships with orange-as-red default + documented manual approval path. Concierge demo pitch becomes "voice-classified drafts that the operator can approve in Telegram"; doesn't promise full auto-send-with-policy in v1.0. v1.1 implements full orange approval gate.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:28:**Claude's recommendation (Day-11 update, post implementation-spec investigation):** **D1-B.** Investigation surfaced that the "~1 week extra" cost was overestimated — cortextOS Primitive 4 (`createApproval` + `updateApproval` in `packages/harness/cortextos/src/bus/approval.ts`) already implements the Telegram fan-out + button-press routing. IFOS-side work is a thin bridge: 2 file watchers + a small Postgres state table. Realistic effort: 2-3 days. See `docs/decisions/autosend-approval-bridge-spec.md` for the full implementation surface (10 acceptance criteria, 6 risks, 600 lines TypeScript scaffold + tests).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:32:**Alternative timing:** Insert as next IFOS Claude slice now (post-Diagnostic-build, ~Week 8). Marginal benefit: D1 becomes a closed item earlier; bridge gets stress-tested before Concierge needs it. Cost: 2-3 days inserted before Concierge.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:34:**Cost of deferral:** Concierge W10 build risks slipping if bridge isn't ready. Concrete delay: ~3 days. Risk #2 (Bullhorn) is the bigger blocker for Concierge (auth path); D1 is downstream of that.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:36:**D1 Concrete recommendation:** Schedule for Week 9 (default). Founder explicitly approves D1-B; bridge spec ratifies through Codex Round 2; bridge implementation slice authored Week 9.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:44:- `docs/decisions/autosend-safety-policy.md` §10 ("Pilot-agreement liability language placeholder — counsel-reviewed")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:45:- Codex output `logs/codex-ratification/manual-run/docs_decisions_autosend_safety_policy_md.output.md` issue 3
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:49:**Real issue:** v1.0 kill-criterion §3.4 names "external advisor" as a Week 1-2 must-fill. This is also the resolution path for autosend §10 pilot-agreement liability. Today = 2026-05-20 (Day 8 = Week 1 underway). No advisor identified.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:53:- **D2-B: Defer to first pilot LOI signing window** — risky; if Q1 LOI lands before D2-A advisor is engaged, founder is choosing between (a) signing without legal cover, or (b) delaying LOI signing.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:65:- `docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml` §6 Q13 (UK GDPR retention question)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:68:**Codex's framing:** "`recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:142:| **D1** (autosend v1.0 tier) | This week | Concierge build scope (W10-13) |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:147:**Recommended order:** D5 (quickest, unblocks Round 2) → D1 (Concierge planning) → D2 + D3 (legal bundle) → D4 (no-rush).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:158:## D1 — Resolution (2026-05-XX)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:160:Founder picks D1-C: ship orange-as-red default + manual override.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:164:Implementation work: <commit reference or "in autosend §9 update commit">
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:167:OR open a follow-on ADR if the decision warrants more substantive recording (e.g., ADR-005 for D1; ADR-006 for D2 + D3 bundle).
agents/recruitment/concierge/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (2026-05-24): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) **Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3** — the agent.md Status-flip blocker on the ADR side is now CLOSED. Remaining Proposed → Accepted blockers: Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + W10 build slice (see §10).
agents/recruitment/concierge/agent.md:17:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 position 1 / ≥0.78 position 2 / ≥0.82 position 3, per ULTRAPLAN A6 line 566 verbatim) OR any draft with incorrect addressee resolution (per same line — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §Gotchas line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:68:One output per lifecycle event: an email draft (yellow tier `concierge_email_draft` per autosend-policy.yaml; only the customer-facing SEND is orange tier — `gmail_outlook_send_to_candidate` / `bullhorn_note_customer_visible` / `twilio_sms_send` / `calendar_invite_send` per channel). 12 lifecycle events × per-tenant comms-template variants:
agents/recruitment/concierge/agent.md:107:2. `phase='action'` via `hh_decision_action("concierge_email_draft", "candidate:<bullhorn_id>:<event_type>", payload_hash, payload_preview)`. This is the tier-classified row — `concierge_email_draft` is registered yellow tier per autosend-policy.yaml lookup (grep `^  concierge_email_draft:` to verify). Tier is recorded inside the autosend-emitted payload by the helper; it is NOT a top-level decision_log column. `payload_preview` carries `event_type`, `voice_score`, `recipient`, `escalation_position` as a concatenated string for cross-row correlation. Action_type stays stable across all 12 lifecycle events — event_type is in the preview string, not part of the action_type identifier.
agents/recruitment/concierge/agent.md:109:The actual SEND is a separate orange-tier action_type:
agents/recruitment/concierge/agent.md:110:- `gmail_outlook_send_to_candidate` (orange tier per autosend-policy.yaml §ORANGE) when channel=email
agents/recruitment/concierge/agent.md:111:- `bullhorn_note_customer_visible` (orange tier; canonical orange per autosend-policy.yaml §ORANGE) when channel=Bullhorn note with isExternal=true
agents/recruitment/concierge/agent.md:112:- `twilio_sms_send` (orange tier per autosend-policy.yaml §ORANGE) when channel=SMS (v1.1+)
agents/recruitment/concierge/agent.md:113:- `calendar_invite_send` (orange tier per autosend-policy.yaml §ORANGE) when event includes calendar attachment
agents/recruitment/concierge/agent.md:115:Consultant approves via autosend-bridge (D1 path) → orange-tier send executes → Bullhorn activity-log entry written post-send.
agents/recruitment/concierge/agent.md:187:     (highest voice-classifier bar; mandatory consultant approval per autosend-policy)
agents/recruitment/concierge/agent.md:214:     tier=yellow per autosend-policy.yaml
agents/recruitment/concierge/agent.md:236:11. Autosend-bridge routing (D1 path)
agents/recruitment/concierge/agent.md:237:    → per Founder Decision D1 (final selection at W10 design):
agents/recruitment/concierge/agent.md:238:      D1-A (bridge to cortextOS approval system): POST internal API
agents/recruitment/concierge/agent.md:239:      D1-B (lightweight Telegram shim): send approval prompt to operator
agents/recruitment/concierge/agent.md:240:      D1-C (no autosend in v1.0): draft to vault for manual consultant pickup
agents/recruitment/concierge/agent.md:241:    → per autosend-policy.yaml: orange-tier; consultant approves
agents/recruitment/concierge/agent.md:243:      (default PT4H per autosend-policy.yaml (grep `^  gmail_outlook_send_to_candidate:` or `^  bullhorn_note_customer_visible:` to verify the orange-tier `timeout` field; default `PT4H`) + escalation-codes.md
agents/recruitment/concierge/agent.md:244:      lines 348-353; looked up per action_type, not hardcoded) (D1-A/B)
agents/recruitment/concierge/agent.md:249:12. (After operator approval) Send execution — orange-tier
agents/recruitment/concierge/agent.md:265:      autosend-policy.yaml (registered 2026-06-02 per Codex Fbis-R1 closure;
agents/recruitment/concierge/agent.md:267:      action_type required for tier classification per autosend-policy §3.
agents/recruitment/concierge/agent.md:283:      sends:<N>; ghosted_rate:<float>") — green tier per autosend-policy.yaml;
agents/recruitment/concierge/agent.md:295:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
agents/recruitment/concierge/agent.md:311:ALL FOUR cause Gate A to block the draft from sending (validate.sh exits non-zero; draft stays in vault; cycle.sh aborts the orange-tier emission). The "blocking" of the DRAFT is `validate.sh` behavior; the "blocking" severity of the ESC code is the operator-paging-urgency lookup. These are separate dimensions. Draft is moved to `/tmp` (out of the customer-facing path) regardless of ESC severity; operator is notified immediately for blocking-tier ESCs, asynchronously-aggregated for warn-tier.
agents/recruitment/concierge/agent.md:345:| `ESC_APPROVAL_BRIDGE_TIMEOUT` | No consultant approval within the policy timeout (default PT4H per escalation-codes.md `ESC_APPROVAL_BRIDGE_TIMEOUT` block + autosend-policy.yaml grep `^  gmail_outlook_send_to_candidate:` or `^  bullhorn_note_customer_visible:` to verify the orange-tier `timeout` field) | warn | operator + ifos_oncall (catalogue verbatim — operator absent + commitment may need rerouting; tenant-admin involvement is a manual escalation choice when bridge-timeout becomes pattern-recurring, not part of catalogue routing) |
agents/recruitment/concierge/agent.md:350:| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow/orange-tier sample row selected for audit | info | operator_chat_id |
agents/recruitment/concierge/agent.md:394:| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
agents/recruitment/concierge/agent.md:395:| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
agents/recruitment/concierge/agent.md:402:| **Founder Decision D1 (autosend orange-tier path)** RESOLVED | Founder decision; awaits review of D1-A/B/C spec | ⏸ |
agents/recruitment/concierge/agent.md:403:| Autosend bridge built (per D1 outcome) | W10 build start (~2 days for D1-A; less for D1-B/C) | ⏸ |
agents/recruitment/concierge/agent.md:421:**Status:** Proposed. Awaits Bullhorn A+B + per-tenant email-provider signups + D1 founder decision + Q1 LOI + W10-13 build slice.
agents/recruitment/concierge/agent.md:427:| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
agents/recruitment/concierge/agent.md:436:| Q10 | 90-day check-in (event 12) — relationship-building tone. Should Concierge also surface "anyone in your network looking?" referral request? | Founder review with first pilot consultant + tenant brand voice. Recommend: opt-in via tenant config. |
agents/recruitment/concierge/agent.md:454:- **Founder Decision D1 RESOLVED** (Q1 above) — without this, Concierge build cannot start

exec
/bin/zsh -lc "rg -n \"validate_tenant_adapters_config_v0_3|operator_telegram_chat_id|cash_conductor_last_run|concierge_last_poll|concierge_send_window|janitor_dedup_threshold|blocked_recipients\" docs/verticals/recruitment vertical-schema.yaml migrations packages agents docs -g '"'!node_modules'"'" in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
rg: vertical-schema.yaml: No such file or directory (os error 2)
rg: migrations: No such file or directory (os error 2)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:13:# added closing Janitor R11 Finding 4 + blocked_recipients added closing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:14:# Sourcing Scout R8 Finding 1. blocked_recipients is pre-v0.3 origin
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:759:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:764:  cash_conductor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:773:  concierge_last_poll:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:782:  concierge_send_window:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:808:  janitor_dedup_threshold:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:823:  blocked_recipients:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:916:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1003:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1021:  new + 2 Janitor + 1 blocked_recipients pre-v0.3 canonicalised). The
agents/_shared/autosend-policy.yaml:393:    reason: "Recipient in tenant's blocked_recipients override list"
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:13:# added closing Janitor R11 Finding 4 + blocked_recipients added closing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:14:# Sourcing Scout R8 Finding 1. blocked_recipients is pre-v0.3 origin
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:759:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:764:  cash_conductor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:773:  concierge_last_poll:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:782:  concierge_send_window:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:808:  janitor_dedup_threshold:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:823:  blocked_recipients:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:916:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1003:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1021:  new + 2 Janitor + 1 blocked_recipients pre-v0.3 canonicalised). The
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:23:- Telegram bot token from `_secrets.env` (existing per Day-4 provisioning); operator chat ID from `tenant_adapters.config.operator_telegram_chat_id` (canonical config key)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:426:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:434:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:440:    'cash_conductor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:441:    'concierge_last_poll',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:442:    'concierge_send_window'
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:461:  IF c ? 'concierge_send_window' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:462:    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:463:      RAISE EXCEPTION 'concierge_send_window must be object';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:465:    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:466:      RAISE EXCEPTION 'concierge_send_window must include timezone';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:468:    IF NOT (c->'concierge_send_window' ? 'weekday_start') OR
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:469:       NOT (c->'concierge_send_window' ? 'weekday_end') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:470:      RAISE EXCEPTION 'concierge_send_window must include weekday_start + weekday_end';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:472:    IF c->'concierge_send_window' ? 'weekend_send_enabled' AND
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:473:       jsonb_typeof(c->'concierge_send_window'->'weekend_send_enabled') != 'boolean' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:474:      RAISE EXCEPTION 'concierge_send_window.weekend_send_enabled must be boolean';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:479:  IF c ? 'cash_conductor_last_run' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:480:    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:481:      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:485:  IF c ? 'concierge_last_poll' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:486:    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:487:      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:492:  -- janitor_dedup_threshold: number in [0.75, 0.95] per supplement default 0.85
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:493:  IF c ? 'janitor_dedup_threshold' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:494:    IF jsonb_typeof(c->'janitor_dedup_threshold') != 'number' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:495:      RAISE EXCEPTION 'janitor_dedup_threshold must be number';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:497:    IF (c->>'janitor_dedup_threshold')::numeric < 0.75
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:498:       OR (c->>'janitor_dedup_threshold')::numeric > 0.95 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:499:      RAISE EXCEPTION 'janitor_dedup_threshold out of [0.75, 0.95] range: %', c->>'janitor_dedup_threshold';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:510:  -- blocked_recipients: array of strings (pre-v0.3 origin; canonicalised here).
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:514:  IF c ? 'blocked_recipients' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:515:    IF jsonb_typeof(c->'blocked_recipients') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:516:      RAISE EXCEPTION 'blocked_recipients must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:518:    FOR elem IN SELECT * FROM jsonb_array_elements(c->'blocked_recipients') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:520:        RAISE EXCEPTION 'blocked_recipients items must be strings; got %', jsonb_typeof(elem);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:529:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:531:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:534:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:426:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:434:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:440:    'cash_conductor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:441:    'concierge_last_poll',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:442:    'concierge_send_window'
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:461:  IF c ? 'concierge_send_window' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:462:    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:463:      RAISE EXCEPTION 'concierge_send_window must be object';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:465:    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:466:      RAISE EXCEPTION 'concierge_send_window must include timezone';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:468:    IF NOT (c->'concierge_send_window' ? 'weekday_start') OR
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:469:       NOT (c->'concierge_send_window' ? 'weekday_end') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:470:      RAISE EXCEPTION 'concierge_send_window must include weekday_start + weekday_end';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:472:    IF c->'concierge_send_window' ? 'weekend_send_enabled' AND
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:473:       jsonb_typeof(c->'concierge_send_window'->'weekend_send_enabled') != 'boolean' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:474:      RAISE EXCEPTION 'concierge_send_window.weekend_send_enabled must be boolean';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:479:  IF c ? 'cash_conductor_last_run' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:480:    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:481:      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:485:  IF c ? 'concierge_last_poll' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:486:    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:487:      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:492:  -- janitor_dedup_threshold: number in [0.75, 0.95] per supplement default 0.85
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:493:  IF c ? 'janitor_dedup_threshold' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:494:    IF jsonb_typeof(c->'janitor_dedup_threshold') != 'number' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:495:      RAISE EXCEPTION 'janitor_dedup_threshold must be number';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:497:    IF (c->>'janitor_dedup_threshold')::numeric < 0.75
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:498:       OR (c->>'janitor_dedup_threshold')::numeric > 0.95 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:499:      RAISE EXCEPTION 'janitor_dedup_threshold out of [0.75, 0.95] range: %', c->>'janitor_dedup_threshold';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:510:  -- blocked_recipients: array of strings (pre-v0.3 origin; canonicalised here).
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:514:  IF c ? 'blocked_recipients' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:515:    IF jsonb_typeof(c->'blocked_recipients') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:516:      RAISE EXCEPTION 'blocked_recipients must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:518:    FOR elem IN SELECT * FROM jsonb_array_elements(c->'blocked_recipients') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:520:        RAISE EXCEPTION 'blocked_recipients items must be strings; got %', jsonb_typeof(elem);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:529:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:531:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:534:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:91:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:35:  operator_telegram_chat_id: "operator-test-chat-id"
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:91:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
agents/recruitment/cash-conductor/cycle.sh:337:# tenant_adapters.config.cash_conductor_last_run (declared in v0.3 supplement; validated
agents/recruitment/cash-conductor/cycle.sh:338:# by validate_tenant_adapters_config_v0_3 trigger landed 2026-05-31).
agents/recruitment/cash-conductor/cycle.sh:339:# TODO(W7-8): UPDATE tenant_adapters SET config = jsonb_set(config, '{cash_conductor_last_run}', '"<ISO>"')
docs/operations/w4-bilateral-pass-6-agent-md.md:102:### Finding 4. `janitor_dedup_threshold` + `janitor_last_run` keys absent from schema supplement
docs/operations/w4-bilateral-pass-6-agent-md.md:104:  - **Codex says:** "Lines 42, 95, and 166 rely on `janitor_dedup_threshold` and `janitor_last_run`; `rg` finds these only in the v0.2-to-v0.3 migration allowlist, not in `vertical-schema.yaml` or the v0.3 supplement's `tenant_adapters_config_additions`. Fix by adding both keys with type/owner/read-write semantics to the schema supplement, then cite that schema section instead of only the migration allowlist."
docs/operations/w4-bilateral-pass-6-agent-md.md:114:### Finding 1. False schema-status claim for `blocked_recipients`
docs/operations/w4-bilateral-pass-6-agent-md.md:116:  - **Codex says:** "It says 'the actual config-key SCHEMA registration is v0.4-supplement-pending' and that v0.3 only registers other keys, but `docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql` §5 allowlists `blocked_recipients` at line 397. Fix by removing the v0.4-pending claim for `blocked_recipients`; keep v0.4-pending only for `auto_source_on_brief_create`."
docs/operations/w4-bilateral-pass-6-agent-md.md:117:  - **Likely:** FIX-IN-PLACE. Remove v0.4-pending claim for `blocked_recipients`; keep it only for `auto_source_on_brief_create`. (Verify: v0.3 migration line 397 does include `blocked_recipients` in allowlist? Confirmed in our earlier read: "tier_overrides, blocked_recipients, janitor_dedup_threshold..." — yes.)
docs/operations/w4-day-20-founder-runbook.md:72:- ✓ `validate_tenant_adapters_config_v0_3` trigger present on `tenant_adapters`
agents/recruitment/cash-conductor/agent.md:294:    → update tenant_adapters.config.cash_conductor_last_run = now()
agents/recruitment/scribe/agent.md:82:Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Scribe agent.md will re-verify field-name accuracy against the supplement-as-RATIFIED state at W6 Day-1.
packages/utilities/autosend-bridge-telegram/src/bridge.ts:47:  if (!input.operator_telegram_chat_id) {
packages/utilities/autosend-bridge-telegram/src/bridge.ts:48:    throw new BridgeInputError("operator_telegram_chat_id is required");
packages/utilities/autosend-bridge-telegram/src/bridge.ts:85:      chat_id: input.operator_telegram_chat_id,
packages/utilities/autosend-bridge-telegram/src/types.ts:30:  /** Telegram chat ID for the tenant's operator (from tenant_adapters.config.operator_telegram_chat_id). */
packages/utilities/autosend-bridge-telegram/src/types.ts:31:  operator_telegram_chat_id: string;
agents/recruitment/sourcing-scout/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fix applied. R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`. R19 (today): adds `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:7:- `tenant_adapters.config.blocked_recipients` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist (key at line 398; allowlist block lines 396-409); canonical Postgres-backed v1.0 DNC source per ADR-002. Declared in `vertical-schema.v0.3-supplement.yaml` lines 810-827 (R19 added this declaration; no longer deferred).
agents/recruitment/sourcing-scout/agent.md:21:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:114:     + DNC list from `tenant_adapters.config.blocked_recipients` (Postgres-
agents/recruitment/sourcing-scout/agent.md:196:   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
agents/recruitment/sourcing-scout/agent.md:202:     (the webhook auto-source trigger config), NOT to `blocked_recipients`.
agents/recruitment/sourcing-scout/agent.md:204:     `blocked_recipients` is now declared in `vertical-schema.v0.3-supplement.yaml`
agents/recruitment/sourcing-scout/agent.md:261:- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
agents/recruitment/sourcing-scout/agent.md:348:| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
agents/recruitment/sourcing-scout/agent.md:369:| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:21:  operator_telegram_chat_id: "987654321",
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:130:      proposeApproval({ ...validInput, operator_telegram_chat_id: "" }, { transport, decisions }),
agents/recruitment/janitor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority. R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4. R19 fixes (2026-05-25): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice.
agents/recruitment/janitor/agent.md:43:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold` — declared in `vertical-schema.v0.3-supplement.yaml §4 tenant_adapters_config_additions.janitor_dedup_threshold`; enforced by `migrations/v0.2-to-v0.3.sql §5` validator allowlist)
agents/recruitment/janitor/agent.md:289:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:21:  operator_telegram_chat_id: "987654321",
packages/utilities/autosend-bridge-telegram/tests/message-format.test.ts:14:  operator_telegram_chat_id: "987654321",
docs/operations/decision-log.md:77:- **Third attempt: SUCCESS.** Migration applied cleanly (BEGIN…41 DDL…in-migration smoke "v0.3 migration smoke passed"…COMMIT). Post-flight verification confirmed: both Cash Conductor tables present and `postgres`-owned (Day-12 compliant); `validate_voice_scores` trigger replaced by `validate_entities_data_v0_3`; `validate_tenant_adapters_config_v0_3` present.
docs/operations/decision-log.md:91:- **The tenant_adapters config validator** enforces the allowlist including `blocked_recipients`, `janitor_dedup_threshold`, `concierge_send_window` — Sourcing Scout / Janitor / Concierge build slices land on a verified config surface.
docs/operations/decision-log.md:183:   - **Sourcing Scout (3):** blocked_recipients now-declared cite; recent_edit read removed (W-only); Gate A decision-log write
docs/operations/decision-log.md:188:   - **v0.3 supplement (3):** Sourcing Scout candidate/contractor R+W→R **[DECISION]**; client_contact_id derivation via entity_links; blocked_recipients element-string validation in migration
docs/operations/decision-log.md:226:3. `bd3c145 fix(janitor-r12 + v0.3-supplement.0.1)` — Finding 4 closed via v0.3 supplement §4 amendment adding `janitor_dedup_threshold` + `janitor_last_run` declarations; agent.md citations updated. Findings 1+2+3 already in post-R11 commit `e5a2c74`. **v0.3 supplement amended — needs re-ratification**.
docs/operations/decision-log.md:227:4. `0e0d741 fix(sourcing-scout-r9)` — 3 R8 residuals already in `d1f4c53`; R9 polish: §10 three-state lifecycle (Proposed → Ratified-as-Scaffold → Accepted → In Force) + §1 Schema-key block rewrite + §4 Step 8 blocked_recipients cite corrected
docs/operations/decision-log.md:969:  - Per-tenant override §8: elevation only; red is absolute floor; `blocked_recipients` additive
docs/operations/founder-manual-playbook-2026-05-31.md:20:**Why first:** unblocks all v0.3 schema usage (Cash Conductor tables, Janitor dedup config, blocked_recipients, etc.). Without this, every downstream W4 build is just writing code against schema that doesn't exist on the live database.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:38:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/fixtures/01-primary.yaml:30:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:35:  operator_telegram_chat_id: "987654321"
docs/decisions/autosend-safety-policy.md:124:| `send_to_blocked_recipient` | `blocked_recipient` | Recipient in tenant's `blocked_recipients` override list |
docs/decisions/autosend-safety-policy.md:437:    "blocked_recipients": [
docs/decisions/autosend-safety-policy.md:463:3. **`blocked_recipients`** is additive only. Recipients can be added; system-default red-list recipients cannot be removed. Pattern matching supported via `*` wildcards.
docs/decisions/autosend-safety-policy.md:539:  (c) breaches of Tenant's configured blocked_recipients list by the
docs/decisions/autosend-safety-policy.md:599:| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
agents/recruitment/concierge/context.sh:27:#   - Resolve operator_telegram_chat_id from tenant_adapters.config
agents/recruitment/concierge/context.sh:118:# TODO(W10-13): SELECT config->>'operator_telegram_chat_id' FROM tenant_adapters
agents/recruitment/concierge/agent.md:134:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:429:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
docs/decisions/2026-05-31-d1-founder-decision.md:53:5. **Tenant config — schema-work pending.** The natural storage location for the per-tenant operator Telegram chat-id is `tenant_adapters.config`, BUT the v0.3 supplement's `validate_tenant_adapters_config_v0_3` trigger hard-fails on unknown keys per Rule 2 — and `operator_telegram_chat_id` is NOT currently in the 6-key allowlist (`cash_conductor_last_run`, `concierge_last_poll`, `concierge_send_window`, `janitor_dedup_threshold`, the 2026-05-31 Janitor key, `blocked_recipients`). Resolution path: **W10-13 Concierge build slice lands a v0.4 supplement** adding `operator_telegram_chat_id` to the allowlist (type: string; required: false; set_by: tenant-admin; read_by: concierge + cash-conductor for the autosend-bridge consumer). Until then, the bridge consumer (`@ifos/autosend-bridge-telegram`) takes the chat-id as a function argument rather than reading it from tenant_adapters — the function-arg shim is already in place per the package scaffold landed 2026-06-01 (commit `9b282d8`). This decision-doc does NOT block on the schema work; D1-B's APPROVAL is structural (Telegram vs cortextOS approval system vs no-autosend); the storage-location detail is a W10-13 implementation question.
docs/decisions/2026-05-31-d1-founder-decision.md:66:- **Schema impact: v0.4 supplement required (deferred to W10-13 Concierge build slice).** D1-B requires a per-tenant operator-Telegram-chat-id storage location. `tenant_adapters.config` is the natural home BUT the v0.3 supplement's `validate_tenant_adapters_config_v0_3` trigger hard-fails on unknown keys per Rule 2 and `operator_telegram_chat_id` is NOT in the current allowlist (see implementation surface item 5 for the full rationale + interim function-arg-mode workaround). The schema work + migration land in the W10-13 Concierge build slice as part of bridge-production-wiring; the decision-doc itself is structurally complete without that schema work. The previously-stated "No schema impact" claim has been removed — it was inconsistent with implementation surface item 5.
docs/decisions/2026-05-31-d1-founder-decision.md:76:**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commits `669a4f4` + `9ec2bd6`) — **in FUNCTION-ARG MODE only**, no `tenant_adapters.config.operator_telegram_chat_id` read attempts until the v0.4 schema supplement lands in the Concierge W10-13 build slice; Codex ratification currently in flight under cluster G (R2 closing 2026-06-02 per `docs/decisions/codex-disagreement-2026-06-02-*` ledger and the cluster G round-trip arc).

codex
The main citations mostly resolve, but I’m checking whether the decision’s “function-arg mode only” claim is actually true in the files it says have already landed. That matters because the schema key is explicitly not allowlisted yet.
exec
/bin/zsh -lc "nl -ba packages/utilities/autosend-bridge-telegram/src/types.ts | sed -n '1,80p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	// @ifos/autosend-bridge-telegram — public types
     2	//
     3	// Mirrors the D1-B founder-decision implementation surface
     4	// (docs/decisions/2026-05-31-d1-founder-decision.md §"Implementation surface").
     5	
     6	/** Default approval window per ESC_APPROVAL_BRIDGE_TIMEOUT (escalation-codes.md lines 348-353). */
     7	export const DEFAULT_TIMEOUT_SECONDS = 4 * 60 * 60; // PT4H
     8	
     9	/** Poll cadence default (operator latency vs. API call cost balance). */
    10	export const DEFAULT_POLL_INTERVAL_SECONDS = 30;
    11	
    12	/**
    13	 * Action types currently consuming the bridge.
    14	 * Keep this enumerated rather than `string` so callers get a hard compile-time
    15	 * error if they try to propose an action_type that has not been registered in
    16	 * autosend-policy.yaml at the orange tier.
    17	 *
    18	 * Add new entries here when (and only when) the corresponding action lands in
    19	 * autosend-policy.yaml at orange severity.
    20	 */
    21	export type SupportedActionType =
    22	  | "gmail_outlook_send_to_candidate" // Concierge orange
    23	  | "xero_reminder_send_customer"; // Cash Conductor orange
    24	
    25	export interface ProposeApprovalInput {
    26	  /** Audit-log action_type (must be orange per autosend-policy.yaml). */
    27	  action_type: SupportedActionType;
    28	  /** Tenant slug for routing + the audit row. */
    29	  tenant_slug: string;
    30	  /** Telegram chat ID for the tenant's operator (from tenant_adapters.config.operator_telegram_chat_id). */
    31	  operator_telegram_chat_id: string;
    32	  /** Recipient/contextual handle (email, phone, customer name) the operator will use to identify the draft. */
    33	  target: string;
    34	  /** Short preview (≤500 chars; Telegram message-length budget). */
    35	  draft_preview: string;
    36	  /** Full vault path the operator can open for the complete draft body. */
    37	  vault_path: string;
    38	  /** Timeout in seconds. Default `DEFAULT_TIMEOUT_SECONDS` (PT4H). */
    39	  timeout_seconds?: number;
    40	  /** ID of the originating decision_log row (used by ESC_APPROVAL_BRIDGE_TIMEOUT payload). */
    41	  originating_decision_log_id?: string;
    42	}
    43	
    44	export interface ProposeApprovalResult {
    45	  /** Unique approval-id, also embedded as `[ID:<id>]` in the Telegram message. */
    46	  approval_id: string;
    47	  /** ISO timestamp the proposal was posted. */
    48	  posted_at_iso: string;
    49	  /** Computed deadline ISO (posted_at + timeout). */
    50	  expires_at_iso: string;
    51	}
    52	
    53	export type ApprovalOutcome = "approved" | "rejected" | "timeout";
    54	
    55	export interface AwaitApprovalInput {
    56	  approval_id: string;
    57	  /** Optional override of the poll interval (mainly for testing). */
    58	  poll_interval_seconds?: number;
    59	  /** Optional override of the expiry deadline (mainly for testing). */
    60	  expires_at_iso?: string;
    61	}
    62	
    63	export interface AwaitApprovalResult {
    64	  outcome: ApprovalOutcome;
    65	  /** Telegram user-id of the operator who decided (undefined on timeout). */
    66	  decided_by?: string;
    67	  /** ISO timestamp the decision was recorded (undefined on timeout). */
    68	  decided_at_iso?: string;
    69	}
    70	
    71	/**
    72	 * One operator decision row read from the Telegram polling layer.
    73	 * Production wiring: the @ifos/telegram-surface package writes rows to a
    74	 * postgres approvals table; the bridge polls it.
    75	 * Test wiring: an in-memory store satisfies the interface.
    76	 */
    77	export interface PendingDecision {
    78	  approval_id: string;
    79	  outcome: Exclude<ApprovalOutcome, "timeout">;
    80	  decided_by: string;

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/context.sh | sed -n '1,140p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	#!/usr/bin/env bash
     2	# Concierge agent — context.sh (pre-cycle hydration; W4 Day-26 SKELETON)
     3	#
     4	# Status: Proposed (W4 Day-26 SKELETON; W10-13 build slice replaces stubs
     5	#         with real provider config + tenant_adapters reads).
     6	# Reading order: agent.md §2 (invocation surface) + §4 Step 0 (session start)
     7	# + §7 (voice + tone constraints) first.
     8	#
     9	# Per ADR-003 v2 agent-bundle pattern: bus invokes context.sh BEFORE cycle.sh
    10	# at session start. context.sh hydrates session-scoped CTX_* env vars that
    11	# cycle.sh + validate.sh read, then emits the mandatory session_start trigger
    12	# row to anchor the session in decision_log.
    13	#
    14	# Invocation contract:
    15	#   bash context.sh
    16	#
    17	# Inputs (env from bus):
    18	#   CTX_AGENT_DIR        — agent's directory (this file's dirname)
    19	#   CTX_TENANT_SLUG      — tenant the run targets
    20	#   CTX_CONCIERGE_MODE   — webhook | poll | nurture-sweep | manual
    21	#
    22	# Side effects (W10-13 build slice):
    23	#   - Refresh Bullhorn OAuth (per agent.md §4 Step 0 + Q-12 disposition)
    24	#   - Refresh Microsoft Graph OR Gmail OAuth (per tenant_adapters.config.email_channel)
    25	#   - Load voice corpus pgvector index for CTX_VOICE_CORPUS_ID
    26	#   - Load tone-rules YAML for tenant
    27	#   - Resolve operator_telegram_chat_id from tenant_adapters.config
    28	#   - Load tenant comms-template library path
    29	#   - Hydrate addressee-resolution allowlists (firm-domain whitelist +
    30	#     competitor list for Gate A G2/G4 enforcement)
    31	#
    32	# Outputs (exported CTX_* vars; cycle.sh + validate.sh consume):
    33	#   CTX_AGENT_NAME                       — "concierge"
    34	#   CTX_EMAIL_CHANNEL                    — "microsoft-graph" | "gmail"
    35	#   CTX_OPERATOR_TELEGRAM_CHAT_ID        — tenant operator's Telegram chat ID
    36	#   CTX_VOICE_CORPUS_ID                  — pgvector index ref
    37	#   CTX_TONE_RULES_PATH                  — vault path to tone-rules YAML
    38	#   CTX_COMMS_TEMPLATE_LIBRARY_PATH      — /vault/<slug>/concierge-templates/
    39	#   CTX_BULLHORN_TOKEN_STATE             — fresh | refreshed | failed
    40	#   CTX_EMAIL_PROVIDER_TOKEN_STATE       — fresh | refreshed | failed
    41	
    42	set -euo pipefail
    43	
    44	# ────────────────────────────────────────────────────────────────────────
    45	# Pre-flight: CTX env + _shared/ helper resolution
    46	# ────────────────────────────────────────────────────────────────────────
    47	
    48	if [[ -z "${CTX_AGENT_DIR:-}" ]]; then
    49	  printf 'concierge/context.sh: CTX_AGENT_DIR unset (bus must set this)\n' >&2
    50	  exit 2
    51	fi
    52	if [[ -z "${CTX_TENANT_SLUG:-}" ]]; then
    53	  printf 'concierge/context.sh: CTX_TENANT_SLUG unset\n' >&2
    54	  exit 2
    55	fi
    56	export CTX_AGENT_NAME="concierge"
    57	
    58	# 4-candidate _shared/ helper fallback (matches sibling agents post d7d52c5).
    59	_SHARED_DIR=""
    60	for _candidate in \
    61	  "${CTX_AGENT_DIR}/.claude/hooks/_shared" \
    62	  "${IFOS_REPO_ROOT:-}/agents/_shared" \
    63	  "${CTX_AGENT_DIR}/../../_shared" \
    64	  "${CTX_AGENT_DIR}/../_shared" ; do
    65	  if [[ -n "${_candidate}" && -d "${_candidate}" && -f "${_candidate}/hook-helpers.sh" ]]; then
    66	    _SHARED_DIR="${_candidate}"
    67	    break
    68	  fi
    69	done
    70	if [[ -z "${_SHARED_DIR}" ]]; then
    71	  printf 'context.sh: cannot locate _shared/ helpers\n' >&2
    72	  exit 1
    73	fi
    74	# shellcheck source=/dev/null
    75	source "${_SHARED_DIR}/hook-helpers.sh"
    76	
    77	# ────────────────────────────────────────────────────────────────────────
    78	# Step 1 — Email channel resolution (MS Graph OR Gmail per tenant)
    79	# ────────────────────────────────────────────────────────────────────────
    80	
    81	# TODO(W10-13): SELECT config->>'email_channel' FROM tenant_adapters WHERE tenant_slug=$1
    82	# Default: microsoft-graph (most common in UK recruitment per CSM survey).
    83	export CTX_EMAIL_CHANNEL="${IFOS_FORCE_EMAIL_CHANNEL:-microsoft-graph}"
    84	
    85	# ────────────────────────────────────────────────────────────────────────
    86	# Step 2 — Bullhorn OAuth refresh
    87	# ────────────────────────────────────────────────────────────────────────
    88	
    89	# TODO(W10-13): @ifos/bullhorn refreshTokens(); on success export CTX_BULLHORN_TOKEN_STATE=refreshed
    90	# On 6+ consecutive failures: emit ESC_BULLHORN_AUTH (blocking) + exit 1
    91	export CTX_BULLHORN_TOKEN_STATE="STUB"
    92	
    93	# ────────────────────────────────────────────────────────────────────────
    94	# Step 3 — Email provider OAuth refresh (per channel)
    95	# ────────────────────────────────────────────────────────────────────────
    96	
    97	# TODO(W10-13):
    98	#   if [[ "${CTX_EMAIL_CHANNEL}" == "microsoft-graph" ]]; then
    99	#     @ifos/microsoft-graph refreshTokens() → on fail ESC_MS_GRAPH_AUTH blocking
   100	#   else
   101	#     @ifos/gmail refreshTokens() → on fail ESC_GMAIL_AUTH blocking
   102	#   fi
   103	export CTX_EMAIL_PROVIDER_TOKEN_STATE="STUB"
   104	
   105	# ────────────────────────────────────────────────────────────────────────
   106	# Step 4 — Voice corpus + tone rules + comms-template library
   107	# ────────────────────────────────────────────────────────────────────────
   108	
   109	# TODO(W10-13): resolve via tenant_adapters.config; default fallback chain.
   110	export CTX_VOICE_CORPUS_ID="${IFOS_FORCE_VOICE_CORPUS_ID:-default}"
   111	export CTX_TONE_RULES_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/tone-rules.yaml"
   112	export CTX_COMMS_TEMPLATE_LIBRARY_PATH="${IFOS_VAULT_ROOT:-${HOME}/.ifos-local-vault}/${CTX_TENANT_SLUG}/concierge-templates/"
   113	
   114	# ────────────────────────────────────────────────────────────────────────
   115	# Step 5 — Operator routing (Telegram chat ID for autosend-bridge per D1-B)
   116	# ────────────────────────────────────────────────────────────────────────
   117	
   118	# TODO(W10-13): SELECT config->>'operator_telegram_chat_id' FROM tenant_adapters
   119	# WHERE tenant_slug=$1 (per D1-B doc §"Implementation surface" item 5 — already
   120	# supported by existing Telegram surface; no new schema needed).
   121	export CTX_OPERATOR_TELEGRAM_CHAT_ID="${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID:-STUB}"
   122	
   123	# ────────────────────────────────────────────────────────────────────────
   124	# Step 6 — Session-start trigger row (mandatory; anchors session in decision_log)
   125	# ────────────────────────────────────────────────────────────────────────
   126	
   127	hh_decision_trigger "session_start" \
   128	  "agent:concierge; tenant:${CTX_TENANT_SLUG}; mode:${CTX_CONCIERGE_MODE:-webhook}; email_channel:${CTX_EMAIL_CHANNEL}"
   129	
   130	# Operator-readable trace (NOT a decision_log row; just stdout for the bus log)
   131	printf '[concierge context.sh] tenant=%s channel=%s bullhorn_token=%s email_token=%s voice_corpus=%s\n' \
   132	  "${CTX_TENANT_SLUG}" "${CTX_EMAIL_CHANNEL}" "${CTX_BULLHORN_TOKEN_STATE}" \
   133	  "${CTX_EMAIL_PROVIDER_TOKEN_STATE}" "${CTX_VOICE_CORPUS_ID}"
   134	
   135	exit 0

exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/cycle.sh | sed -n '230,285p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc "nl -ba packages/utilities/autosend-bridge-telegram/src/bridge.ts | sed -n '1,130p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	// Core bridge implementation. Stateless wrt the package — all state lives in
     2	// the injected `TelegramTransport` + `DecisionSource` so callers can swap a
     3	// production wiring (Telegram Bot API + postgres approvals table) for the
     4	// in-memory test wiring without changing the bridge.
     5	
     6	import { randomUUID } from "node:crypto";
     7	
     8	import {
     9	  BridgeInputError,
    10	  BridgeTimeoutError,
    11	  BridgeTransportError,
    12	} from "./errors.js";
    13	import { renderApprovalMessage } from "./message-format.js";
    14	import {
    15	  DEFAULT_POLL_INTERVAL_SECONDS,
    16	  DEFAULT_TIMEOUT_SECONDS,
    17	} from "./types.js";
    18	import type {
    19	  AwaitApprovalInput,
    20	  AwaitApprovalResult,
    21	  BridgeDependencies,
    22	  Clock,
    23	  ProposeApprovalInput,
    24	  ProposeApprovalResult,
    25	  SupportedActionType,
    26	} from "./types.js";
    27	
    28	const SUPPORTED_ACTIONS: ReadonlySet<SupportedActionType> = new Set([
    29	  "gmail_outlook_send_to_candidate",
    30	  "xero_reminder_send_customer",
    31	]);
    32	
    33	const realClock: Clock = {
    34	  nowMs: () => Date.now(),
    35	  sleepMs: (ms) => new Promise((r) => setTimeout(r, ms)),
    36	};
    37	
    38	function validateProposeInput(input: ProposeApprovalInput): void {
    39	  if (!SUPPORTED_ACTIONS.has(input.action_type)) {
    40	    throw new BridgeInputError(
    41	      `action_type "${input.action_type}" not registered for the approval bridge ` +
    42	        `(supported: ${[...SUPPORTED_ACTIONS].join(", ")}). ` +
    43	        `Register in autosend-policy.yaml at orange tier first, then add to SupportedActionType.`,
    44	    );
    45	  }
    46	  if (!input.tenant_slug) throw new BridgeInputError("tenant_slug is required");
    47	  if (!input.operator_telegram_chat_id) {
    48	    throw new BridgeInputError("operator_telegram_chat_id is required");
    49	  }
    50	  if (!input.target) throw new BridgeInputError("target is required");
    51	  if (!input.draft_preview) throw new BridgeInputError("draft_preview is required");
    52	  if (!input.vault_path) throw new BridgeInputError("vault_path is required");
    53	  if (
    54	    input.timeout_seconds !== undefined &&
    55	    (!Number.isFinite(input.timeout_seconds) || input.timeout_seconds <= 0)
    56	  ) {
    57	    throw new BridgeInputError("timeout_seconds, if provided, must be positive finite");
    58	  }
    59	}
    60	
    61	/**
    62	 * Posts an orange-tier autosend proposal to the operator's Telegram chat and
    63	 * returns the approval-id + deadline. Caller is expected to record the result
    64	 * (approval-id, expires_at) on the originating `decision_log` row and then
    65	 * call `awaitApprovalDecision(approval_id)` (typically in the same tick).
    66	 */
    67	export async function proposeApproval(
    68	  input: ProposeApprovalInput,
    69	  deps: BridgeDependencies,
    70	): Promise<ProposeApprovalResult> {
    71	  validateProposeInput(input);
    72	
    73	  const clock = deps.clock ?? realClock;
    74	  const generate = deps.generateApprovalId ?? (() => randomUUID());
    75	
    76	  const approval_id = generate();
    77	  const timeoutSecs = input.timeout_seconds ?? DEFAULT_TIMEOUT_SECONDS;
    78	  const posted_at_iso = new Date(clock.nowMs()).toISOString();
    79	  const expires_at_iso = new Date(clock.nowMs() + timeoutSecs * 1000).toISOString();
    80	
    81	  const text = renderApprovalMessage(input, approval_id, expires_at_iso);
    82	
    83	  try {
    84	    await deps.transport.postMessage({
    85	      chat_id: input.operator_telegram_chat_id,
    86	      text,
    87	    });
    88	  } catch (cause) {
    89	    throw new BridgeTransportError(
    90	      `Telegram postMessage failed for approval ${approval_id}; ` +
    91	        `agent layer should surface ESC_AGENT_TOOL_FAILURE, not ESC_APPROVAL_BRIDGE_TIMEOUT`,
    92	      cause,
    93	    );
    94	  }
    95	
    96	  return { approval_id, posted_at_iso, expires_at_iso };
    97	}
    98	
    99	/**
   100	 * Polls the `DecisionSource` until the operator decides or the deadline
   101	 * passes. Default behaviour returns `{outcome: "timeout"}` on expiry (matches
   102	 * the discriminated-union surface in the D1-B doc); if `throwOnTimeout` is set
   103	 * via wrapper, swap for `BridgeTimeoutError`.
   104	 *
   105	 * Defence-in-depth: we always treat the absolute deadline (`expires_at_iso`)
   106	 * as authoritative — not "N polls × interval" — so a paused/slow event loop
   107	 * doesn't accidentally extend the window past PT4H.
   108	 */
   109	export async function awaitApprovalDecision(
   110	  input: AwaitApprovalInput,
   111	  deps: BridgeDependencies,
   112	): Promise<AwaitApprovalResult> {
   113	  if (!input.approval_id) throw new BridgeInputError("approval_id is required");
   114	
   115	  const clock = deps.clock ?? realClock;
   116	  const pollMs = (input.poll_interval_seconds ?? DEFAULT_POLL_INTERVAL_SECONDS) * 1000;
   117	
   118	  // Compute deadline. If caller supplied expires_at_iso (the contract — they
   119	  // got it from proposeApproval), trust it; otherwise fall back to the default
   120	  // window measured from now (lets callers use the polling layer for an
   121	  // already-posted approval, e.g. on agent restart).
   122	  const deadlineMs = input.expires_at_iso
   123	    ? Date.parse(input.expires_at_iso)
   124	    : clock.nowMs() + DEFAULT_TIMEOUT_SECONDS * 1000;
   125	
   126	  if (!Number.isFinite(deadlineMs)) {
   127	    throw new BridgeInputError(`expires_at_iso is not a valid ISO timestamp: ${input.expires_at_iso}`);
   128	  }
   129	
   130	  for (;;) {

codex
I found a live contradiction around the pending schema key: the decision says no reads happen until v0.4, while the landed Concierge context scaffold still directs a `tenant_adapters.config.operator_telegram_chat_id` read and even says no new schema is needed. I’m checking if that is enough by itself or if there are additional blocking inconsistencies.
exec
/bin/zsh -lc "nl -ba docs/decisions/2026-05-31-d1-founder-decision.md | sed -n '1,95p'" in /Users/madsadmin/code/CortexOS
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

exec
/bin/zsh -lc 'rg -n "operator_telegram_chat_id|approval_routing|telegram|chat-id|chat_id" docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql agents/recruitment/concierge/fixtures agents/recruitment/cash-conductor/fixtures' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:438:    'approval_routing', 'approval_timeouts', 'sampling_rates',
docs/verticals/recruitment/vertical-schema.yaml:325:        enum: [email, phone, telegram, whatsapp, linkedin]
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:8:#   to Concierge approval bridge (if autosend-bridge-telegram present)
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:35:  operator_telegram_chat_id: "operator-test-chat-id"
agents/recruitment/concierge/fixtures/01-primary.yaml:30:  operator_telegram_chat_id: "987654321"
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:10:# Per agent.md §6: ESC_RECONCILIATION_AMBIGUOUS is warn-severity, operator_chat_id
agents/recruitment/cash-conductor/fixtures/02-edge-case-fuzzy-match.yaml:81:      routing: operator_chat_id
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:8:# ifos_oncall_chat_id per catalogue §2.7) and EXIT 1 without attempting
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:17:# (info ≤30d / warn ≤14d / blocking ≤7d); blocking adds ifos_oncall_chat_id
agents/recruitment/cash-conductor/fixtures/99-token-aging-canary.yaml:64:      routing: [operator_chat_id, ifos_oncall_chat_id]
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:6:# never responds — the @ifos/autosend-bridge-telegram package's
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:38:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:77:# The autosend-bridge-telegram package's test wiring uses a fake clock to
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:96:      routing: [operator_chat_id, tenant_admin]   # per agent.md §6 row 11 (NOT ifos_oncall — that's the Cash Conductor routing variant)
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:35:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:84:      routing: [operator_chat_id]
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:119:    Per agent.md §6 ESC_VOICE_DRIFT row: routes operator_chat_id (warn-tier

exec
/bin/zsh -lc "rg -n \"autosend_bridge_telegram|autosend-bridge|operator_telegram_chat_id|Telegram shim\" agents/recruitment/concierge agents/recruitment/cash-conductor packages/utilities/autosend-bridge-telegram -g 'tools.yaml' -g 'agent.md' -g '*.sh' -g '*.yaml' -g '*.ts'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/utilities/autosend-bridge-telegram/src/index.ts:1:// @ifos/autosend-bridge-telegram — public API
packages/utilities/autosend-bridge-telegram/src/bridge.ts:47:  if (!input.operator_telegram_chat_id) {
packages/utilities/autosend-bridge-telegram/src/bridge.ts:48:    throw new BridgeInputError("operator_telegram_chat_id is required");
packages/utilities/autosend-bridge-telegram/src/bridge.ts:85:      chat_id: input.operator_telegram_chat_id,
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:8:#   to Concierge approval bridge (if autosend-bridge-telegram present)
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:35:  operator_telegram_chat_id: "operator-test-chat-id"
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:6:# never responds — the @ifos/autosend-bridge-telegram package's
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:38:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:77:# The autosend-bridge-telegram package's test wiring uses a fake clock to
packages/utilities/autosend-bridge-telegram/src/errors.ts:1:// Error types for @ifos/autosend-bridge-telegram. Maps to escalation codes per
agents/recruitment/concierge/fixtures/01-primary.yaml:30:  operator_telegram_chat_id: "987654321"
agents/recruitment/cash-conductor/tools.yaml:128:  # Autosend bridge (D1-B Telegram shim per 2026-05-31 founder decision;
agents/recruitment/cash-conductor/tools.yaml:137:  - id: autosend_bridge_telegram_propose
agents/recruitment/cash-conductor/tools.yaml:138:    package: "@ifos/autosend-bridge-telegram"
agents/recruitment/cash-conductor/tools.yaml:150:  - id: autosend_bridge_telegram_await
agents/recruitment/cash-conductor/tools.yaml:151:    package: "@ifos/autosend-bridge-telegram"
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:35:  operator_telegram_chat_id: "987654321"
packages/utilities/autosend-bridge-telegram/src/types.ts:1:// @ifos/autosend-bridge-telegram — public types
packages/utilities/autosend-bridge-telegram/src/types.ts:30:  /** Telegram chat ID for the tenant's operator (from tenant_adapters.config.operator_telegram_chat_id). */
packages/utilities/autosend-bridge-telegram/src/types.ts:31:  operator_telegram_chat_id: string;
agents/recruitment/concierge/context.sh:27:#   - Resolve operator_telegram_chat_id from tenant_adapters.config
agents/recruitment/concierge/context.sh:115:# Step 5 — Operator routing (Telegram chat ID for autosend-bridge per D1-B)
agents/recruitment/concierge/context.sh:118:# TODO(W10-13): SELECT config->>'operator_telegram_chat_id' FROM tenant_adapters
agents/recruitment/cash-conductor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R17 closed §8 sibling files + D1/bridge prereqs + §3 audit-row signatures (4-row chase lifecycle sequence). R19 fixes (2026-05-24): split draft body out of decision_log payload into vault path (per ADR-002 vault/Postgres split), recent_edit schema R access cite correction, Stage 3 ESC code disambiguation. **Founder Decision D1 ACCEPTED 2026-05-31** as D1-B (Telegram approval-shim; `docs/decisions/2026-05-31-d1-founder-decision.md`); `@ifos/autosend-bridge-telegram` package scaffold landed 2026-06-01 (commit `9b282d8`); Cash Conductor consumer wiring landed (commit `076e231`). Remaining gates: Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice replacing the SKELETON TODOs with live impl + Concierge W10-13 build slice landing the autosend-bridge production wiring (Telegram Bot API + postgres approvals reader) so the orange-tier send path activates.
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type (registered in autosend-policy.yaml under §ORANGE; grep `^  xero_reminder_send_customer:` to verify); Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW — grep `^  xero_reminder_draft_internal:` to verify; internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (registered under §ORANGE — grep `^  xero_reminder_send_customer:`; consultant approval required before send). **Note on citation discipline:** explicit line numbers in `autosend-policy.yaml` shift across edits; this agent.md uses grep-anchors instead per the pattern established in xero R3 closure (commit `5228fa2`). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** Founder Decision D1 ACCEPTED 2026-05-31 as D1-B (Telegram shim) + package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`); the autosend-bridge **production wiring** (real Telegram Bot API + postgres approvals reader) still lands in Concierge W10-13 build slice. Until then, Cash Conductor cycle.sh Step 10 detects the absent `packages/utilities/autosend-bridge-telegram/dist/` directory and degrades to **drafts-only** mode — produces yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT emit the orange-tier `xero_reminder_send_customer` rows (per §8 fallback row).
agents/recruitment/cash-conductor/agent.md:98:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type — grep `^  xero_reminder_send_customer:` in `agents/_shared/autosend-policy.yaml` to verify it's registered there under §ORANGE) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
agents/recruitment/cash-conductor/agent.md:260:      Concierge handles autosend-bridge call to operator (D1 path per
agents/recruitment/cash-conductor/agent.md:405:| **Founder Decision D1 (autosend orange-tier path) ACCEPTED 2026-05-31** as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md` | ✅ ACCEPTED |
agents/recruitment/cash-conductor/agent.md:406:| **Autosend bridge package scaffold** — `@ifos/autosend-bridge-telegram` lib + types + tests landed 2026-06-01 (commit `9b282d8`); Cash Conductor consumer wiring at cycle.sh Step 10 landed (commit `076e231`) | ✅ SCAFFOLDED (Cash Conductor side) |
agents/recruitment/cash-conductor/agent.md:408:| Fallback (interim): cycle.sh Step 10 detects absent `packages/utilities/autosend-bridge-telegram/dist/` and runs in drafts-only mode (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` until W10-13 wiring activates) | v1.0 interim — active until W10-13 | n/a |
agents/recruitment/cash-conductor/agent.md:449:NOTE: D1 RESOLVED is NO LONGER a Proposed→Accepted blocker — D1 was Accepted 2026-05-31 as D1-B (Telegram shim) per `docs/decisions/2026-05-31-d1-founder-decision.md`, and the package scaffold + Cash Conductor consumer wiring landed 2026-06-01 (commits `9b282d8` + `076e231`). The autosend-bridge **production wiring** (real Telegram Bot API) remains a Concierge W10-13 deliverable; until then, Cash Conductor runs in drafts-only mode (interim — see §8 fallback row). The bridge wiring is an Accepted→In-Force blocker (build slice + first-production criterion below), not a Proposed→Accepted blocker.
agents/recruitment/cash-conductor/agent.md:453:- Concierge W10-13 lands the autosend-bridge production wiring so orange-tier sends activate
agents/recruitment/cash-conductor/cycle.sh:30:#      per D1-B Telegram shim — docs/decisions/2026-05-31-d1-founder-decision.md)
agents/recruitment/cash-conductor/cycle.sh:211:# line 263; Concierge handles autosend-bridge-telegram approval routing + transport.
agents/recruitment/cash-conductor/cycle.sh:212:# Drafts-only graceful degradation when autosend-bridge-telegram package absent
agents/recruitment/cash-conductor/cycle.sh:224:  if [[ -d "${IFOS_REPO_ROOT:-}/packages/utilities/autosend-bridge-telegram/dist" ]]; then
agents/recruitment/cash-conductor/cycle.sh:225:    # Bridge package PRESENT — route each draft through the D1-B Telegram shim.
agents/recruitment/cash-conductor/cycle.sh:230:    # packages/utilities/autosend-bridge-telegram/bin/{propose,await}.ts and
agents/recruitment/cash-conductor/cycle.sh:237:    #    deadline. Package: @ifos/autosend-bridge-telegram (proposeApproval).
agents/recruitment/cash-conductor/cycle.sh:239:    #    PROPOSE_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/propose.ts" \
agents/recruitment/cash-conductor/cycle.sh:258:    #    Package: @ifos/autosend-bridge-telegram (awaitApprovalDecision).
agents/recruitment/cash-conductor/cycle.sh:260:    #    AWAIT_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/await.ts" \
agents/recruitment/cash-conductor/cycle.sh:288:      "autosend-bridge-telegram package dist/ not present — drafts retained in vault for manual consultant pickup; build the package (pnpm --filter @ifos/autosend-bridge-telegram build) to enable the D1-B send path"
agents/recruitment/concierge/validate.sh:16:# the autosend-bridge propose call (Step 11). If any check fails, validate.sh
agents/recruitment/concierge/tools.yaml:115:  # Autosend bridge (D1-B Telegram shim per 2026-05-31 founder decision;
agents/recruitment/concierge/tools.yaml:122:  - id: autosend_bridge_telegram_propose
agents/recruitment/concierge/tools.yaml:123:    package: "@ifos/autosend-bridge-telegram"
agents/recruitment/concierge/tools.yaml:135:  - id: autosend_bridge_telegram_await
agents/recruitment/concierge/tools.yaml:136:    package: "@ifos/autosend-bridge-telegram"
agents/recruitment/concierge/agent.md:17:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 position 1 / ≥0.78 position 2 / ≥0.82 position 3, per ULTRAPLAN A6 line 566 verbatim) OR any draft with incorrect addressee resolution (per same line — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §Gotchas line 570 gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:115:Consultant approves via autosend-bridge (D1 path) → orange-tier send executes → Bullhorn activity-log entry written post-send.
agents/recruitment/concierge/agent.md:239:      D1-B (lightweight Telegram shim): send approval prompt to operator
agents/recruitment/concierge/agent.md:394:| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
agents/recruitment/concierge/agent.md:427:| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
agents/recruitment/concierge/cycle.sh:24:#   @ifos/autosend-bridge-telegram — D1-B Telegram approval shim (Concierge OWNS Step 11)
agents/recruitment/concierge/cycle.sh:34:#   gated by autosend-bridge approval per D1-B founder decision.
agents/recruitment/concierge/cycle.sh:276:  if [[ -d "${IFOS_REPO_ROOT:-}/packages/utilities/autosend-bridge-telegram/dist" ]]; then
agents/recruitment/concierge/cycle.sh:279:    # entrypoints; entrypoints land at packages/utilities/autosend-bridge-telegram/
agents/recruitment/concierge/cycle.sh:285:    # 1. proposeApproval — @ifos/autosend-bridge-telegram proposeApproval API:
agents/recruitment/concierge/cycle.sh:287:    #    PROPOSE_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/propose.ts" \
agents/recruitment/concierge/cycle.sh:306:    #    AWAIT_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/await.ts" \
agents/recruitment/concierge/cycle.sh:332:      "autosend-bridge-telegram package dist/ not present — D1-C mode active; drafts retained in vault for manual consultant pickup; build the package (pnpm --filter @ifos/autosend-bridge-telegram build) to enable D1-B send path"
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:21:  operator_telegram_chat_id: "987654321",
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:130:      proposeApproval({ ...validInput, operator_telegram_chat_id: "" }, { transport, decisions }),
packages/utilities/autosend-bridge-telegram/tests/message-format.test.ts:14:  operator_telegram_chat_id: "987654321",
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:21:  operator_telegram_chat_id: "987654321",

exec
/bin/zsh -lc "rg -n \"agent_name|phase|CHECK|trigger \\| output \\| action \\| gating_failed \\| agent_handoff|agent_handoff\" docs/verticals/recruitment/vertical-schema.yaml docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml docs/verticals/recruitment/migrations -g '*.sql' -g '*.yaml'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:368:  # layer (cycle.sh + hh_decision_action) where the agent_name in the
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:870:  # (bounded values require CHECK or trigger). Tier 2 schema work owns
docs/verticals/recruitment/vertical-schema.yaml:6:#   - decision_log (..., agent_name, phase, payload JSONB, ...)
docs/verticals/recruitment/vertical-schema.yaml:25:  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
docs/verticals/recruitment/vertical-schema.yaml:816:    decision: System agent names like `_renderer` are NOT entity_types in this schema. They appear in `decision_log.agent_name` only, with `phase` from the live 5-value enum (`trigger | output | action | gating_failed | agent_handoff` per Day-4 §6.3 + Day-5 migration). The sentinel `_renderer` writes `phase='gating_failed'` for failures and `phase='action'` for successful renders per ADR-004 Decision 7.
docs/verticals/recruitment/vertical-schema.yaml:872:      Codex Day-7 ratification reviews whether stricter source-field schema would improve machine-parseability. If accepted, v1.0 introduces structured source object — e.g., `source: {origin: bullhorn | ifos_derived, bullhorn_field?: <entity.field>, ifos_agent?: <agent_name>, citation?: <doc-ref>}`.
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:20:--     payload key and its enforcement (CHECK constraint or trigger).
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:80:  CONSTRAINT cct_match_status_valid CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:83:  CONSTRAINT cct_bank_provider_valid CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:86:  CONSTRAINT cct_match_confidence_range CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:137:  CONSTRAINT cci_status_valid CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:140:  CONSTRAINT cci_provider_valid CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:143:  CONSTRAINT cci_chase_position_range CHECK (
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:146:  CONSTRAINT cci_amount_paid_non_negative CHECK (
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:50:  source_doc_count      INTEGER     NOT NULL CHECK (source_doc_count >= 0),
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:52:  chunk_count           INTEGER     NOT NULL CHECK (chunk_count >= 0),
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:53:  chunking_strategy     TEXT        NOT NULL CHECK (chunking_strategy IN ('paragraph', 'sentence-window-5', 'semantic-segment-v1')),
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:118:  severity            TEXT        NOT NULL CHECK (severity IN ('info', 'warn', 'block')),
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:121:  created_by          TEXT        NOT NULL CHECK (created_by IN ('founder', 'tenant-admin', 'ifos-csm')),
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:144:  agent_name             TEXT        NOT NULL,
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:150:  edit_distance          INTEGER     CHECK (edit_distance IS NULL OR edit_distance >= 0),
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:151:  resolution             TEXT        NOT NULL CHECK (resolution IN ('approved_verbatim', 'approved_after_edit', 'rejected', 'deferred')),
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:160:CREATE INDEX IF NOT EXISTS recent_edit_tenant_agent_idx ON recent_edit (tenant_slug, agent_name, resolved_at DESC);
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:255:-- entity_links.link_type is TEXT; we add a soft-enum CHECK constraint update
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:260:-- Probe + extend the entity_links.link_type CHECK constraint if present.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:261:-- (Day-4 §6.3 declares link_type as TEXT without CHECK by default; this DO
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:262:-- block is defensive for the case where v0.1 added a CHECK we need to widen.)
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:271:  -- If no CHECK exists, do nothing; new values insert freely.
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:272:  -- If CHECK exists, surface for manual review (DDL changes to CHECK
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:275:    RAISE NOTICE 'entity_links.link_type CHECK constraint exists: %; new link_types may need manual extension', existing_check;
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:44:-- §2 — Optional defence-in-depth CHECK constraint
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:55:  ADD CONSTRAINT recent_edit_text_purged_consistency CHECK (

codex
There is also a citation/content accuracy problem in the allowlist description: the decision calls it a 6-key allowlist, but the live migration allowlist includes the earlier autosend keys as well. I’m going to keep the rejection focused on blocking factual/schema claims rather than style.
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '426,445p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '740,835p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   426	CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
   427	RETURNS TRIGGER AS $$
   428	DECLARE
   429	  c JSONB := NEW.config;
   430	  k TEXT;
   431	  elem JSONB;
   432	  allowed_keys TEXT[] := ARRAY[
   433	    -- v0.1 + v0.2 keys (forwarded; do not remove)
   434	    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
   435	    'janitor_last_run',
   436	    'pii_retention_days',  -- v0.2 PII purge runbook key
   437	    -- autosend-safety-policy.md keys
   438	    'approval_routing', 'approval_timeouts', 'sampling_rates',
   439	    -- v0.3 additions
   440	    'cash_conductor_last_run',
   441	    'concierge_last_poll',
   442	    'concierge_send_window'
   443	    -- diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   444	    -- (per ADR-006 Tier 2); v0.3 trigger does not allowlist this key
   445	  ];

 succeeded in 0ms:
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
   776	    set_by: concierge
   777	    read_by: [concierge]
   778	    notes: |
   779	      Concierge polling cron updates at end of each cycle. Next poll queries
   780	      Bullhorn for state transitions since this timestamp.
   781	
   782	  concierge_send_window:
   783	    type: object
   784	    required: false
   785	    default:
   786	      timezone: Europe/London
   787	      weekday_start: '09:00'
   788	      weekday_end: '17:00'
   789	      weekend_send_enabled: false
   790	    set_by: [tenant-admin]
   791	    read_by: [concierge]
   792	    object_shape:
   793	      timezone:
   794	        type: string
   795	        notes: IANA timezone identifier
   796	      weekday_start:
   797	        type: string
   798	        notes: HH:MM 24-hour format
   799	      weekday_end:
   800	        type: string
   801	        notes: HH:MM 24-hour format
   802	      weekend_send_enabled:
   803	        type: boolean
   804	    notes: |
   805	      Per-tenant outbound sending hours. Concierge respects when scheduling
   806	      orange-tier sends.
   807	
   808	  janitor_dedup_threshold:
   809	    type: number
   810	    required: false
   811	    default: 0.85
   812	    range: [0.75, 0.95]
   813	    set_by: [tenant-admin]
   814	    read_by: [janitor]
   815	    notes: |
   816	      Per-tenant dedup confidence threshold for candidate merges. v1.0 default
   817	      0.85 per ULTRAPLAN A2 line 510. Tenant-admin override range [0.75, 0.95]
   818	      via the wizard. The migration validator (v0.2-to-v0.3.sql §5 allowlist +
   819	      type-validation trigger extension added in R19) enforces both the
   820	      allowlist membership and the [0.75, 0.95] range. Schema declaration
   821	      added Day-20 W4 bilateral pass closing Janitor R11 Codex Finding 4.
   822	
   823	  blocked_recipients:
   824	    type: array
   825	    items:
   826	      type: string
   827	    required: false
   828	    default: []
   829	    set_by: [tenant-admin, janitor]
   830	    read_by: [concierge, sourcing-scout, cash-conductor, janitor]
   831	    notes: |
   832	      Per-tenant DNC (do not contact) list. v1.0 canonical source for outbound
   833	      send refusal (autosend-safety-policy §5 red-tier action_type
   834	      `send_to_blocked_recipient`) and pre-outbound sourcing filter (Sourcing
   835	      Scout §4 Step 8). Per ADR-002 vault/Postgres split — structured state in

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml | sed -n '30,105p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
    30	  flags:
    31	    - --mode
    32	    - webhook
    33	    - --tenant
    34	    - migration-test
    35	
    36	tenant_config:
    37	  email_channel: microsoft-graph
    38	  operator_telegram_chat_id: "987654321"
    39	  bullhorn_org_id: "10001"
    40	
    41	webhook_payload:
    42	  event_type: interview-completed   # event #3 — debrief; standard position-1
    43	  candidate_id: "CAND-102"
    44	  placement_id: "PLAC-202"
    45	  contact_id: "CONT-302"
    46	  client_id: "CLIENT-402"
    47	  state_from: interview-scheduled
    48	  state_to: interview-completed
    49	  event_timestamp_iso: "2026-06-01T15:00:00.000Z"
    50	
    51	mocked_bullhorn:
    52	  candidate:
    53	    id: CAND-102
    54	    name: Casey Park
    55	    email: casey.park@example.com
    56	    comms_history:
    57	      - {type: interview-booked, at: "2026-05-22T10:00:00Z"}
    58	  placement:
    59	    id: PLAC-202
    60	    role: Staff Engineer
    61	    client_id: CLIENT-402
    62	  client:
    63	    id: CLIENT-402
    64	    company: Acme Tech Ltd
    65	    primary_contact_id: CONT-302
    66	  contact:
    67	    id: CONT-302
    68	    name: Jordan Lee
    69	    email: jordan@acme-tech.example
    70	
    71	# Draft passes Gate A cleanly. Position-1; voice 0.81 > 0.75 threshold.
    72	mocked_voice_classifier:
    73	  draft_score: 0.81
    74	  position: 1
    75	
    76	# Force the bridge to behave as if the operator never replied.
    77	# The autosend-bridge-telegram package's test wiring uses a fake clock to
    78	# advance past expires_at_iso without setting a decision in the DecisionSource;
    79	# this fixture exercises the agent-layer reaction to that outcome.
    80	test_mode_overrides:
    81	  autosend_bridge:
    82	    proposeApproval_returns:
    83	      approval_id: "fixture-canary-99-deadbeefcafe"
    84	      posted_at_iso: "2026-06-01T15:00:30.000Z"
    85	      expires_at_iso: "2026-06-01T19:00:30.000Z"   # +PT4H
    86	    awaitApprovalDecision_returns:
    87	      outcome: timeout
    88	      decided_by: null
    89	      decided_at_iso: null
    90	
    91	expected:
    92	  cycle_step_reached: 11   # cycle.sh halts at Step 11 timeout branch; Step 12 NOT reached
    93	  esc_codes_emitted:
    94	    - code: ESC_APPROVAL_BRIDGE_TIMEOUT
    95	      severity: warn
    96	      routing: [operator_chat_id, tenant_admin]   # per agent.md §6 row 11 (NOT ifos_oncall — that's the Cash Conductor routing variant)
    97	      payload_includes:
    98	        - approval_id: fixture-canary-99-deadbeefcafe
    99	        - timeout_seconds: 14400
   100	        - action_type: gmail_outlook_send_to_candidate
   101	        - candidate_id: CAND-102
   102	        - event_type: interview-completed
   103	  draft_written:
   104	    vault_path_pattern: "/vault/migration-test/concierge-drafts/*.md"
   105	    expected_recipient: casey.park@example.com

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/cycle.sh | sed -n '270,335p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   270	# orange-tier drafts; on approved, proceeds to Step 12 transport; on rejected
   271	# or timeout, fires ESC_APPROVAL_BRIDGE_TIMEOUT (timeout) or records rejection
   272	# in decision_log (rejected)."
   273	# ────────────────────────────────────────────────────────────────────────
   274	
   275	if [[ "${STEPS_TO_RUN}" == *11* ]]; then
   276	  if [[ -d "${IFOS_REPO_ROOT:-}/packages/utilities/autosend-bridge-telegram/dist" ]]; then
   277	    # Bridge package PRESENT — production-shape per-draft flow.
   278	    # SKELETON (W10-13 build slice wires the per-draft iteration + tsx CLI
   279	    # entrypoints; entrypoints land at packages/utilities/autosend-bridge-telegram/
   280	    # bin/{propose,await}.ts in the same build slice — they are intentionally
   281	    # NOT in v0.1 scaffold per the package README §"Out of scope (v1.0)").
   282	    #
   283	    # Per draft produced at Step 7:
   284	    #
   285	    # 1. proposeApproval — @ifos/autosend-bridge-telegram proposeApproval API:
   286	    #
   287	    #    PROPOSE_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/propose.ts" \
   288	    #      --action gmail_outlook_send_to_candidate \
   289	    #      --tenant "${CTX_TENANT_SLUG}" \
   290	    #      --operator-chat "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
   291	    #      --target "${RECIPIENT_EMAIL}" \
   292	    #      --preview "${DRAFT_PREVIEW_500_CHARS}" \
   293	    #      --vault-path "${DRAFT_PATH}" \
   294	    #      --timeout-seconds 14400)
   295	    #    APPROVAL_ID=$(printf '%s' "${PROPOSE_JSON}" | jq -r .approval_id)
   296	    #    EXPIRES_AT_ISO=$(printf '%s' "${PROPOSE_JSON}" | jq -r .expires_at_iso)
   297	    #
   298	    # 2. Emit concierge_approval_routed audit row (R19 registration):
   299	    #
   300	    #    hh_decision_action "concierge_approval_routed" \
   301	    #      "candidate:${BULLHORN_ID}:${EVENT_TYPE}" "${PAYLOAD_HASH}" \
   302	    #      "d1_path:B; bridge_target:${APPROVAL_ID}; expires:${EXPIRES_AT_ISO}"
   303	    #
   304	    # 3. awaitApprovalDecision — block until decision or PT4H deadline:
   305	    #
   306	    #    AWAIT_JSON=$(tsx "${IFOS_REPO_ROOT}/packages/utilities/autosend-bridge-telegram/bin/await.ts" \
   307	    #      --approval-id "${APPROVAL_ID}" \
   308	    #      --expires-at "${EXPIRES_AT_ISO}")
   309	    #    OUTCOME=$(printf '%s' "${AWAIT_JSON}" | jq -r .outcome)
   310	    #    DECIDED_BY=$(printf '%s' "${AWAIT_JSON}" | jq -r '.decided_by // ""')
   311	    #
   312	    # 4. Branch on outcome:
   313	    #    case "${OUTCOME}" in
   314	    #      approved) : ;;  # Step 12 transport proceeds
   315	    #      rejected)
   316	    #        hh_decision_output "approval_rejected" \
   317	    #          "candidate:${BULLHORN_ID}:${EVENT_TYPE}" \
   318	    #          "approval_id:${APPROVAL_ID}; decided_by:${DECIDED_BY}" ;;
   319	    #      timeout)
   320	    #        # ESC_APPROVAL_BRIDGE_TIMEOUT per agents/_shared/escalation-codes.md
   321	    #        # lines 348-353: warn-tier; operator + tenant-admin per agent.md §6 row 11
   322	    #        hh_decision_action "validate_gate_a_fail" \
   323	    #          "candidate:${BULLHORN_ID}:${EVENT_TYPE}" "${PAYLOAD_HASH}" \
   324	    #          "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:14400; approval_id:${APPROVAL_ID}" ;;
   325	    #    esac
   326	    : # TODO(W10-13): wire the per-draft loop above; tsx CLI entrypoints land alongside
   327	  else
   328	    # Bridge package ABSENT — D1-C graceful degradation (drafts-only).
   329	    # DO NOT emit concierge_approval_routed; draft stays in vault for manual
   330	    # consultant pickup. Concierge §1 readiness caveat captures this state.
   331	    hh_decision_output "drafts_only_mode" "tenant:${CTX_TENANT_SLUG}" \
   332	      "autosend-bridge-telegram package dist/ not present — D1-C mode active; drafts retained in vault for manual consultant pickup; build the package (pnpm --filter @ifos/autosend-bridge-telegram build) to enable D1-B send path"
   333	  fi
   334	fi
   335	

codex
REJECTED

1. False schema-before-code safety claim for `operator_telegram_chat_id`. Lines 53, 68, and 76 say the bridge is in function-arg mode only and that there are “no `tenant_adapters.config.operator_telegram_chat_id` read attempts” until v0.4 lands. The landed Concierge scaffold contradicts this: `agents/recruitment/concierge/context.sh` lines 27 and 118-120 instruct resolving `operator_telegram_chat_id` from `tenant_adapters.config` and even claim “no new schema needed,” while fixtures already carry `tenant_config.operator_telegram_chat_id` (`agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml` lines 36-38). Fix by either landing the v0.4 schema/migration first or removing all tenant_adapters/fixture references and documenting the interim source as env/function-arg only.

2. Incorrect allowlist citation/count. Line 53 says `validate_tenant_adapters_config_v0_3` has a “6-key allowlist” containing only `cash_conductor_last_run`, `concierge_last_poll`, `concierge_send_window`, `janitor_dedup_threshold`, the Janitor key, and `blocked_recipients`. The live migration allowlist is larger: `docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql` lines 432-442 also allow `tier_overrides`, `janitor_last_run`, `pii_retention_days`, `approval_routing`, `approval_timeouts`, and `sampling_rates`. Fix by distinguishing “v0.3 supplement declarations” from the actual trigger `allowed_keys` list and citing the live migration accurately.
tokens used
66,902
REJECTED

1. False schema-before-code safety claim for `operator_telegram_chat_id`. Lines 53, 68, and 76 say the bridge is in function-arg mode only and that there are “no `tenant_adapters.config.operator_telegram_chat_id` read attempts” until v0.4 lands. The landed Concierge scaffold contradicts this: `agents/recruitment/concierge/context.sh` lines 27 and 118-120 instruct resolving `operator_telegram_chat_id` from `tenant_adapters.config` and even claim “no new schema needed,” while fixtures already carry `tenant_config.operator_telegram_chat_id` (`agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml` lines 36-38). Fix by either landing the v0.4 schema/migration first or removing all tenant_adapters/fixture references and documenting the interim source as env/function-arg only.

2. Incorrect allowlist citation/count. Line 53 says `validate_tenant_adapters_config_v0_3` has a “6-key allowlist” containing only `cash_conductor_last_run`, `concierge_last_poll`, `concierge_send_window`, `janitor_dedup_threshold`, the Janitor key, and `blocked_recipients`. The live migration allowlist is larger: `docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql` lines 432-442 also allow `tier_overrides`, `janitor_last_run`, `pii_retention_days`, `approval_routing`, `approval_timeouts`, and `sampling_rates`. Fix by distinguishing “v0.3 supplement declarations” from the actual trigger `allowed_keys` list and citing the live migration accurately.
