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
session id: 019e8846-5b51-72d0-96b2-9b6412749e29
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

This decision doc ratifies via `.codex/ratification/review-architecture-decision.md` skill. Will be added to the next `--cluster F` (or future cluster) ratification run.

## Consequences

- **Concierge §9 Q1 RESOLVED** — strike from "open questions" list at next agent.md touch.
- **Cash Conductor §8 D1-pending fallback** — flips from "drafts-only if unresolved" to "orange-tier `xero_reminder_send_customer` writes are live once Concierge W10 ships the `autosend-bridge-telegram` package."
- **Concierge ratification §10** — `Founder Decision D1 RESOLVED` blocker now satisfied. Remaining Concierge Proposed → Accepted blockers per §10: Codex Round 4 Phase 2 (DONE), ADR-007 Accepted (PENDING founder Accept), founder approves §9 Q2-Q6 (PENDING).
- **No schema impact.** D1-B reuses `tenant_adapters.config` for the operator chat ID; no v0.4 supplement work added by this decision.
- **No additional API keys/signups for the founder vault.** Day-4 provisioning (`docs/runbooks/day-4-provisioning.md` §6.5) creates the `_secrets.env` SKELETON only (touched empty at mode 0600); the Telegram bot token is populated by founder bootstrap (NOT covered by Day-4 — see incident response below), and the per-tenant operator chat-id is populated by tenant onboarding (W10-13 build slice; see implementation surface item 5 above). Once both are in place, no recurring credentials work — the bot token doesn't rotate per send; the chat-id is per-tenant-stable.

---

*End of D1 decision doc.*

---

**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commit `669a4f4` + `9ec2bd6`); awaiting Codex ratification via `.codex/ratification/review-architecture-decision.md` skill (cluster G).

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
I’m checking the cited artefacts and schema references against the workspace before deciding. The main risk areas are status drift, schema impact claims, and citation accuracy.
exec
/bin/zsh -lc "nl -ba agents/_shared/escalation-codes.md | sed -n '330,365p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba docs/decisions/autosend-safety-policy.md | sed -n '1,220p'" in /Users/madsadmin/code/CortexOS
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

 succeeded in 0ms:
     1	# Auto-send safety policy
     2	
     3	**Status:** Proposed — pending Codex Day-7 ratification
     4	**Date:** 2026-05-18 (Week 0, Day 5)
     5	**Author:** Claude Code, with founder review pending
     6	**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
     7	**Surfaced by:** Master brief Day 5 spec; load-bearing for every `hh_decision_action` call across the v1.0 agent fleet.
     8	**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.
     9	
    10	---
    11	
    12	## §1 — Scope
    13	
    14	This policy governs **every agent action that produces a side effect outside the IFOS-internal data layer**. The internal data layer is:
    15	
    16	- The vault (`/vault/<tenant>/`) — markdown + YAML, IFOS-controlled
    17	- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
    18	- The pgvector indexes over the above
    19	- The cortextOS file bus and PM2 process tree
    20	
    21	**Actions inside the internal data layer are not governed by this policy** (they are governed by RLS + the master brief §3.3 vault/Postgres split + the decision_log append-only enforcement).
    22	
    23	**Actions that ARE governed:**
    24	
    25	1. Writes to any external system via MCP connector (Bullhorn, Companies House, Xero, Microsoft Graph, etc.) — every `tools.yaml`-declared write scope
    26	2. Sends to humans via any communication channel (email, SMS, Telegram, Slack, LinkedIn InMail, calendar invite, etc.) — both customer-facing and consultant-internal where the consultant is not the agent's directly-supervising user
    27	3. Reads from external systems that touch PII or have rate-limit/cost implications (LinkedIn profile lookups, Companies House director searches)
    28	4. Any action declared as side-effecting in `tools.yaml` for an agent, regardless of category
    29	
    30	**Out of scope:**
    31	
    32	- Read-only IFOS internal queries (entities, decision_log reads via context-assembly API)
    33	- Render-time renderer operations (writing rendered agent dirs to `${frameworkRoot}/orgs/<org>/agents/<name>/`)
    34	- Vault local writes by the agent's own validate.sh / context.sh / fixture runs
    35	- Codex ratification artefacts (read-only review)
    36	
    37	If an action's scope is ambiguous, default to **governed** and require classification.
    38	
    39	**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
    40	
    41	---
    42	
    43	## §2 — Tier model
    44	
    45	Four-tier traffic light. Every governed action falls into exactly one tier at every moment of execution. Tiers are properties of the **(action_type × tenant_override)** pair, not of the agent.
    46	
    47	### Green — auto-send allowed without review
    48	
    49	Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.
    50	
    51	**Default characteristics:** idempotent OR internal-to-tenant OR read-only against external systems with rate-limit budget remaining OR low-cost-to-reverse (e.g., add a Bullhorn tag that can be removed in <30s).
    52	
    53	### Yellow — auto-send allowed with sampled spot-check
    54	
    55	Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).
    56	
    57	**Default characteristics:** high-volume actions where systematic per-action review is too slow but where systematic blind trust is too risky; sampled review provides quality signal without operational drag.
    58	
    59	### Orange — requires human approval before send
    60	
    61	Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.
    62	
    63	**Default characteristics:** moderate-to-high cost-to-reverse OR customer-facing comms OR irreversible state changes.
    64	
    65	### Red — blocked entirely
    66	
    67	Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.
    68	
    69	**Default characteristics:** financial/legal/cross-tenant/PII boundaries; structural integrity of the IFOS multi-tenant model.
    70	
    71	---
    72	
    73	## §3 — Examples per tier across the v1.0 agent surface
    74	
    75	Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
    76	
    77	### Green examples (auto-send without review)
    78	
    79	| Agent | action_type | Why green |
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
   126	---
   127	
   128	## §4 — Integration with the `hh_decision_action` contract
   129	
   130	Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:
   131	
   132	- `hh_decision_trigger` — at session start; logs the trigger
   133	- `hh_decision_output` — when the agent produces its output artefact
   134	- `hh_decision_action` — when an action is taken (or blocked)
   135	
   136	The policy gates **the `hh_decision_action` call specifically**. Implementation lives in `agents/_shared/hook-helpers.sh` (Week-1 prerequisite per ADR-002 §"For Week 1 work"). The policy is the **specification** that hook-helpers.sh implements against.
   137	
   138	### Reference implementation (bash pseudocode for `_shared/hook-helpers.sh`)
   139	
   140	```bash
   141	# hh_decision_action — gate every side-effecting action through the policy
   142	# Args:
   143	#   $1 action_type   (enum from autosend-policy.yaml; see §3 for v1.0 set)
   144	#   $2 target        (entity reference, e.g., "candidate:john-smith")
   145	#   $3 payload_hash  (SHA-256 hex of the action payload)
   146	#   $4 payload_preview (human-readable summary, <=500 chars, NO raw PII)
   147	hh_decision_action() {
   148	  local action_type="$1"
   149	  local target="$2"
   150	  local payload_hash="$3"
   151	  local payload_preview="$4"
   152	
   153	  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
   154	  local tenant_slug="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
   155	  local agent_name="${CTX_AGENT_NAME:?CTX_AGENT_NAME unset}"
   156	
   157	  # 1. Policy lookup — read tier from the canonical policy table
   158	  local tier
   159	  tier=$(autosend_policy_lookup "$action_type") || {
   160	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
   161	    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_action_type"
   162	    return 1
   163	  }
   164	
   165	  # 2. Apply tenant override (elevation only; red is floor)
   166	  tier=$(autosend_apply_tenant_override "$tier" "$action_type" "$tenant_slug") || {
   167	    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
   168	    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "override_resolution_failed"
   169	    return 1
   170	  }
   171	
   172	  # 3. Tier dispatch
   173	  case "$tier" in
   174	    green)
   175	      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
   176	      return 0
   177	      ;;
   178	    yellow)
   179	      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
   180	      if autosend_should_sample "$action_type" "$tenant_slug"; then
   181	        autosend_spot_check_enqueue "$action_type" "$target" "$payload_hash" "$payload_preview" "$tenant_slug"
   182	      fi
   183	      return 0
   184	      ;;
   185	    orange)
   186	      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
   187	      autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW "$action_type" "$target" "$payload_hash" "$payload_preview"
   188	      # Blocks on cortextOS approval gate (master brief primitive 4). Returns 0 on approval, 1 on reject/timeout.
   189	      autosend_await_approval "$action_type" "$target" "$payload_hash"
   190	      return $?
   191	      ;;
   192	    red)
   193	      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
   194	      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
   195	      return 1
   196	      ;;
   197	    *)
   198	      # Fail-safe: unknown tier → red
   199	      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
   200	      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
   201	      return 1
   202	      ;;
   203	  esac
   204	}
   205	```
   206	
   207	### Where the policy check fires in the renderer pipeline
   208	
   209	The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).
   210	
   211	**Policy hot-reload:** if the policy file changes mid-session (rare), the agent does NOT pick it up until the next session boundary (cortextOS PTY restart). Material policy changes must wait for the next 71-hour boundary or trigger a deliberate restart. Documented as an operational footgun in §11 open questions.
   212	
   213	### `tools.yaml` declaration
   214	
   215	Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:
   216	
   217	```yaml
   218	# agents/recruitment/concierge/tools.yaml (excerpt)
   219	action_types:
   220	  - bullhorn_brief_read              # green

exec
/bin/zsh -lc 'rg -n "operator_telegram_chat_id|validate_tenant_adapters_config_v0_3|tenant_adapters|blocked_recipients|janitor" docs agents packages migrations -S' in /Users/madsadmin/code/CortexOS
 exited 2 in 0ms:
rg: migrations: No such file or directory (os error 2)
agents/_shared/README.md:161:Production rollout (other tenants) waits for Codex ratification of v0.2 + Diagnostic + Janitor verification of the schema against real Bullhorn data (master brief §6 Day 6 Q3 trigger from v0.1).
agents/_shared/hook-helpers.sh:312:# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
agents/_shared/hook-helpers.sh:419:# tenant override via tenant_adapters.config.sampling_rates.
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:37:    agent: janitor
agents/_shared/autosend-policy.yaml:71:  janitor_run_complete:
agents/_shared/autosend-policy.yaml:73:    agent: janitor
agents/_shared/autosend-policy.yaml:193:    agent: janitor
agents/_shared/autosend-policy.yaml:200:    agent: janitor
agents/_shared/autosend-policy.yaml:207:    agent: janitor
agents/_shared/autosend-policy.yaml:331:    agent: janitor
agents/_shared/autosend-policy.yaml:386:    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
agents/_shared/autosend-policy.yaml:393:    reason: "Recipient in tenant's blocked_recipients override list"
agents/_shared/autosend-policy.yaml:397:# Defaults applied when override fields are absent in tenant_adapters
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:8:# Partially addresses Round-8 Cat-β findings (Janitor + Scribe + Cash Conductor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 6 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:12:# (v0.3-supplement-0.1 amendment Day-20: original 3 v0.3 keys + 2 Janitor keys
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:13:# added closing Janitor R11 Finding 4 + blocked_recipients added closing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:14:# Sourcing Scout R8 Finding 1. blocked_recipients is pre-v0.3 origin
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:95:          Janitor/Scribe (which hold W) if a sourced candidate is promoted;
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:96:          Janitor uses for dedup (stronger match signal than name+email);
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:99:        source: IFOS-derived (Scribe/Janitor write to the candidate entity; Sourcing Scout surfaces match URLs in its shortlist artefact only; Janitor uses for dedup verification)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:102:          - Janitor: R   # W only via dedup-merge action
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:182:          confirming candidate started. Janitor flags ambiguous via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:184:        source: IFOS-derived (Scribe + Janitor)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:187:          - Janitor: R+W
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:278:#   - Janitor contact: R → R+W (dedup + field-backfill on contacts; same
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:280:#   - Janitor opportunity: none → R (reads opportunity context for cleanup)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:281:#   - Janitor placement: R → R+W (lifecycle-state cleanup writes —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:283:#   - Janitor timesheet: none → R (reads for placement-state inference)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:311:#   - Janitor recent_edit: + R access (was Concierge/canary/LoRA only — v0.2
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:313:#   - Janitor tone_rule: + R access (was Scribe/Cash Conductor/Concierge only
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:355:  #   gets R on linkedin_url (entity-level default), not the broader Janitor
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:356:  #   R+W on candidate.linkedin_url (Janitor.candidate is R+W at entity level
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:383:  janitor:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:413:    # (populated by Janitor + Scribe + Concierge from their Bullhorn
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:472:    v0_1_v1_0_agent_access: [Janitor (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:475:      - Janitor (R+W)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:485:    v0_1_v1_0_agent_access: [Janitor (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:488:      - Janitor (R+W)      # v0.3 UPGRADED — dedup + field-backfill writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:494:      v0.3 upgrades Janitor + Scribe to R+W (they write the new v0.3 fields
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:495:      preferred_channel + next_action_target_date; Janitor also dedup-merges).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:499:    v0_1_v1_0_agent_access: [Janitor (R), Scribe (R), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:501:      - Janitor (R)        # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:511:    v0_1_v1_0_agent_access: [Janitor (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:514:      - Janitor (R)        # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:520:      v0.1 opportunity is sparsely accessed (Janitor only); v0.3 broadens
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:526:    v0_1_v1_0_agent_access: [Janitor (R), Cash Conductor (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:528:      - Janitor (R+W)      # v0.3 UPGRADED — lifecycle-state cleanup writes
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:533:      v0.3 upgrades Janitor + Concierge to R+W (lifecycle-state writes per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:539:      - Janitor (R)        # v0.3 NEW — reads for placement-state inference
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:544:      v0.1 timesheet is Cash Conductor only. v0.3 grants R to Janitor +
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:549:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:552:      - Janitor (R+W)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:565:    v0_1_v1_0_agent_access: [Janitor (R+W), Scribe (R+W), Sourcing Scout (R), Concierge (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:567:      - Janitor (R+W)      # v0.1 unchanged
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:579:    v0_3_v1_0_agent_access: [Scribe (R), Concierge (R), voice-drift-canary (R), Diagnostic (R), Janitor (R), Cash Conductor (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:582:      §12 conversation opener; Janitor for tacit-note narratives; Cash
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:589:    v0_3_v1_0_agent_access: [Scribe (R), Cash Conductor (R), Concierge (R), Janitor (R), Diagnostic (R), Sourcing Scout (R)]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:591:      Janitor agent.md §7 calls hh_load_tone_rules filtered by
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:592:      applies_to_agents containing 'janitor' for tacit-note narrative
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:593:      voice-classification. Per Round-8 Cat-β finding for Janitor.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:603:      - Janitor (R)              # v0.3 NEW — tacit-note harvest per §4 Step 8
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:610:      for retraining queue). Janitor adds R for tacit-note harvest per
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:705:    janitor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:714:    janitor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:723:    janitor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:731:    # Janitor adds R for tacit-note harvest; Scribe/Cash Conductor/Sourcing
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:734:    janitor: R
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:741:    janitor: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:748:    janitor: none
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:755:# §4 — tenant_adapters.config keys (6 declarations: 5 v0.3-new + 1 pre-v0.3 canonicalised)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:758:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:759:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:762:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:808:  janitor_dedup_threshold:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:814:    read_by: [janitor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:821:      added Day-20 W4 bilateral pass closing Janitor R11 Codex Finding 4.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:823:  blocked_recipients:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:829:    set_by: [tenant-admin, janitor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:830:    read_by: [concierge, sourcing-scout, cash-conductor, janitor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:842:  janitor_last_run:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:845:    set_by: janitor
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:846:    read_by: [janitor]
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:848:      Janitor nightly cron updates at session-close (Step 12). Next run queries
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:852:      (Day-20) closing Janitor R11 Codex Finding 4.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:916:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:918:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:927:    2: Update agent.md files (Scribe + Janitor + Cash Conductor + Concierge)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:956:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:975:      A: Maintain 6 states; manually map at Janitor dedup time (Bullhorn → IFOS).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:991:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1003:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1018:  4-of-5 remaining agent.md scaffolds (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1021:  new + 2 Janitor + 1 blocked_recipients pre-v0.3 canonicalised). The
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1040:    - Janitor candidate.linkedin_url + recent_edit/tone_rule access valid
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1042:    - Concierge tenant_adapters.config field refs valid
agents/_shared/escalation-codes.md:128:- **Severity:** warn — Janitor dedup needs human approval
agents/_shared/escalation-codes.md:375:Source: v1.0 agent.md draft specs across Diagnostic, Janitor, Scribe, Sourcing Scout, Cash Conductor, Concierge
agents/_shared/escalation-codes.md:379:- **Trigger:** Agent's local Gate B metric thresholds missed for the per-agent window (e.g. Janitor dedup confidence <15% AND field-completeness uplift <10%; Diagnostic <30% discovery-call conversion rate; etc — see each agent.md §5)
agents/_shared/escalation-codes.md:395:- **Trigger:** Field extraction (Janitor backfill / Scribe call-summary / Sourcing CV-parse) returned confidence below per-field threshold (default 0.7); writing the field would risk bad data
agents/_shared/escalation-codes.md:426:- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
agents/_shared/escalation-codes.md:451:  - **Janitor:** placement record has ambiguous lifecycle markers (e.g. start_date present but no end_date AND no `active` flag AND no recent activity); Janitor cannot safely tag or update
agents/_shared/escalation-codes.md:455:- **Payload fields:** `agent_name`, `entity_type` (`placement` | `candidate_lifecycle_event`), `entity_id`, `ambiguity_class` (Janitor: e.g. `missing_end_date`, `stale_activity`; Concierge: e.g. `unknown_transition`, `out_of_taxonomy`), plus class-specific fields
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:35:  operator_telegram_chat_id: "operator-test-chat-id"
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:435:      the Diagnostic + Janitor agent builds verify the schema against real
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:23:- Telegram bot token from `_secrets.env` (existing per Day-4 provisioning); operator chat ID from `tenant_adapters.config.operator_telegram_chat_id` (canonical config key)
agents/recruitment/cash-conductor/cycle.sh:138:  # TODO(W7-8): provider-aware (tenant_adapters.config.accounting_provider)
agents/recruitment/cash-conductor/cycle.sh:242:    #      --operator-chat "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
agents/recruitment/cash-conductor/cycle.sh:337:# tenant_adapters.config.cash_conductor_last_run (declared in v0.3 supplement; validated
agents/recruitment/cash-conductor/cycle.sh:338:# by validate_tenant_adapters_config_v0_3 trigger landed 2026-05-31).
agents/recruitment/cash-conductor/cycle.sh:339:# TODO(W7-8): UPDATE tenant_adapters SET config = jsonb_set(config, '{cash_conductor_last_run}', '"<ISO>"')
docs/verticals/recruitment/vertical-schema.yaml:53:      - Janitor (R+W — sweep + normalisation + dedup-merge proposals per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:150:      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.
docs/verticals/recruitment/vertical-schema.yaml:158:      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:226:      - Janitor (R+W — orphan-link sweep + normalisation per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:261:        source: IFOS-derived (Janitor maintains)
docs/verticals/recruitment/vertical-schema.yaml:279:      - Client is read-heavy for v1.0 agents (Sourcing Scout context, Concierge relationship state); write access is Janitor-only.
docs/verticals/recruitment/vertical-schema.yaml:347:      - Janitor (R — status drift sweep per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:425:      - Brief is the most-read entity by Sourcing Scout (matches against candidates) and Concierge (lifecycle communications reference active brief). Janitor sweeps for status drift.
docs/verticals/recruitment/vertical-schema.yaml:434:      - Janitor (R — sweep for stale/orphan placements per bullhorn §4.1 A2)
docs/verticals/recruitment/vertical-schema.yaml:592:    v1_0_exercise: Janitor + Concierge use this link extensively for candidate placement history.
docs/verticals/recruitment/vertical-schema.yaml:682:  Janitor:
docs/verticals/recruitment/vertical-schema.yaml:736:# Verifies against real Bullhorn data at Week 3-4 Janitor build per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:745:    field_mapping_density: v0.1 covers 18 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn-integration-path.md §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:751:    field_mapping_density: v0.1 covers 10 fields (candidate-overlap subset + IR35 contractor-specific fields); full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:757:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:763:    field_mapping_density: v0.1 covers 10 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. v1.1 Triage expands contact-side coverage.
docs/verticals/recruitment/vertical-schema.yaml:768:    field_mapping_density: v0.1 covers 17 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A. Note Bullhorn customText1-25 fields are tenant-specific and require per-tenant adapter mapping not standard schema work.
docs/verticals/recruitment/vertical-schema.yaml:774:    field_mapping_density: v0.1 covers 11 fields; full Bullhorn field-density TBD pending Week 3-4 Janitor verification per bullhorn §4.1 Spec gap §4.1-A.
docs/verticals/recruitment/vertical-schema.yaml:805:    revisit_trigger: If Janitor build at Week 3-4 needs per-note structured querying (e.g., "all notes Concierge wrote about candidate X in last 90 days"), promote Note to entity_type='note' in v1.1; adapter layer handles migration.
docs/verticals/recruitment/vertical-schema.yaml:811:    revisit_trigger: Janitor build at Week 3-4 verifies against real Bullhorn data per bullhorn-integration-path.md §4.1 Spec gap §4.1-A and surfaces full required set.
docs/verticals/recruitment/vertical-schema.yaml:890:    expected_date: post Week 3-4 (after Janitor build verifies against real Bullhorn data)
docs/verticals/recruitment/vertical-schema.yaml:892:      Codex-ratified version. Field sets expanded per Janitor's real-Bullhorn-data findings (Q3 trigger). Possibly Note entity promoted to entity_type if Janitor surfaces query patterns (Q2 trigger). 2-3 revisions expected from v0.1.
docs/operations/bullhorn-outreach-emails.md:5:**Purpose:** Drop-in email drafts the founder sends to Bullhorn partnerships + developer support to resolve Sub-decisions A + B in `docs/decisions/bullhorn-integration-path.md`. Closes Risk #2 mitigation path; unblocks Janitor W5 build gate.
docs/operations/bullhorn-outreach-emails.md:17:**These don't block today.** They block **Janitor W5 build** (per kill-criterion §2 Trigger 3). You have ~5 weeks of runway. But send today/Monday because Bullhorn's response time is 2-5 business days, and we want the answers before Diagnostic W3-4 completes so Janitor W5 starts unblocked.
docs/operations/bullhorn-outreach-emails.md:44:> I'm Maddox Rigby, founder of Intel Force Ltd (UK). We're building Intel Force OS — an AI agent fleet for UK recruitment agencies that integrates with Bullhorn as the primary ATS. Three of our six v1.0 agents (Janitor for nightly data cleanup, Scribe for post-call structured write-back, Concierge for lifecycle event triggers) will read and write to Bullhorn on behalf of pilot tenants.
docs/operations/bullhorn-outreach-emails.md:74:- If they require marketplace membership before production access → Sub-decision A is **Marketplace**; need cost + timeline to assess against kill-criterion §2 Trigger 3 (Janitor W5 deadline).
docs/operations/bullhorn-outreach-emails.md:151:2. **Monday 2026-06-01** — second nudge with explicit deadline reference ("we're targeting Janitor build W5; need clarity by then")
docs/operations/bullhorn-outreach-emails.md:160:**Reference.** Two drop-in email drafts ready for founder to send. Expected wall-clock: 1 week for both responses. Outcome: Sub-decisions A + B flip Accepted; Risk #2 mitigated; Janitor W5 build unblocked.
agents/recruitment/cash-conductor/tools.yaml:24:  # Accounting providers (per-tenant — choose ONE via tenant_adapters.config.accounting_provider)
agents/recruitment/cash-conductor/context.sh:73:# tenant_adapters.config; defaults to xero + truelayer per Cash Conductor §9 Q1+Q2.
agents/recruitment/cash-conductor/context.sh:77:# FROM tenant_adapters WHERE tenant_slug = $CTX_TENANT_SLUG; honour defaults.
agents/recruitment/cash-conductor/context.sh:78:# v0.3 supplement §4 tenant_adapters_config_additions includes neither key yet;
docs/operations/goal-week-4-track-1.md:325:1. **`.agents/current-priorities.md`** — W4 Track 1 close section. List shipped artefacts. Update Open backlog: W4 Track 2 (Bullhorn-dependent agents — Janitor/Scribe) conditional on Bullhorn A+B Accepted; Cash Conductor full live test conditional on accounting/Open Banking commercial signups; Diagnostic live render gated on API keys.
docs/operations/goal-week-4-track-1.md:495:  - Janitor build (W5; depends on Bullhorn R+W)
docs/operations/goal-week-4-track-1.md:539:**Day 7 (2026-06-05) is the soft target. Day 9 (2026-06-07) is the hard cutoff** (W5 Janitor build starts then per master brief §8.2 if Bullhorn A+B has Accepted). If Day 9 hits without completion, escalate to founder review + scope-cut decision.
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type (registered in autosend-policy.yaml under §ORANGE; grep `^  xero_reminder_send_customer:` to verify); Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW — grep `^  xero_reminder_draft_internal:` to verify; internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (registered under §ORANGE — grep `^  xero_reminder_send_customer:`; consultant approval required before send). **Note on citation discipline:** explicit line numbers in `autosend-policy.yaml` shift across edits; this agent.md uses grep-anchors instead per the pattern established in xero R3 closure (commit `5228fa2`). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** if Founder Decision D1 is unresolved OR the Concierge autosend bridge has not shipped (both gated per §8), Cash Conductor v1.0 runs in **drafts-only** mode — it produces the yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT write the orange-tier `xero_reminder_send_customer` rows that open the send pipeline (per §8 fallback row).
agents/recruitment/cash-conductor/agent.md:57:- **Manual triggers (ifosctl below):** require operator OS account in the `ifos-operators` group; per-invocation `--tenant <slug>` is verified against the operator's tenant access list in `tenant_adapters` before execution. Founder + Hire #1 are the v1.0 ifosctl-authorized operators per master brief §8.2 line 604.
agents/recruitment/cash-conductor/agent.md:294:    → update tenant_adapters.config.cash_conductor_last_run = now()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:9:-- Closes Round-8 Cat-β findings across 4 agents (Janitor, Scribe, Cash Conductor,
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:419:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:426:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:434:    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:435:    'janitor_last_run',
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:453:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:492:  -- janitor_dedup_threshold: number in [0.75, 0.95] per supplement default 0.85
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:493:  IF c ? 'janitor_dedup_threshold' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:494:    IF jsonb_typeof(c->'janitor_dedup_threshold') != 'number' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:495:      RAISE EXCEPTION 'janitor_dedup_threshold must be number';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:497:    IF (c->>'janitor_dedup_threshold')::numeric < 0.75
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:498:       OR (c->>'janitor_dedup_threshold')::numeric > 0.95 THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:499:      RAISE EXCEPTION 'janitor_dedup_threshold out of [0.75, 0.95] range: %', c->>'janitor_dedup_threshold';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:503:  -- janitor_last_run: ISO-8601 timestamp string or null
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:504:  IF c ? 'janitor_last_run' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:505:    IF jsonb_typeof(c->'janitor_last_run') NOT IN ('string', 'null') THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:506:      RAISE EXCEPTION 'janitor_last_run must be ISO-8601 timestamp string or null';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:510:  -- blocked_recipients: array of strings (pre-v0.3 origin; canonicalised here).
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:514:  IF c ? 'blocked_recipients' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:515:    IF jsonb_typeof(c->'blocked_recipients') != 'array' THEN
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:516:      RAISE EXCEPTION 'blocked_recipients must be array';
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:518:    FOR elem IN SELECT * FROM jsonb_array_elements(c->'blocked_recipients') LOOP
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:520:        RAISE EXCEPTION 'blocked_recipients items must be strings; got %', jsonb_typeof(elem);
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:529:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:531:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:532:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:534:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/operations/w4-bilateral-pass-6-agent-md.md:36:| 2 | Janitor | 4 | All mechanical schema-citation fixes; cleanest pass. |
docs/operations/w4-bilateral-pass-6-agent-md.md:80:## 2. Janitor — `agents/recruitment/janitor/agent.md`
docs/operations/w4-bilateral-pass-6-agent-md.md:98:  - **Codex says:** "Lines 135-137 say Janitor queries the `recent_edit` v0.2 table directly, but v0.2 access lists only voice-drift-canary, Concierge, and LoRA; Janitor R access is added in v0.3 supplement §2. Fix the citation to v0.3 supplement and add v0.3 schema/migration ratification as a §8 prerequisite."
docs/operations/w4-bilateral-pass-6-agent-md.md:102:### Finding 4. `janitor_dedup_threshold` + `janitor_last_run` keys absent from schema supplement
docs/operations/w4-bilateral-pass-6-agent-md.md:104:  - **Codex says:** "Lines 42, 95, and 166 rely on `janitor_dedup_threshold` and `janitor_last_run`; `rg` finds these only in the v0.2-to-v0.3 migration allowlist, not in `vertical-schema.yaml` or the v0.3 supplement's `tenant_adapters_config_additions`. Fix by adding both keys with type/owner/read-write semantics to the schema supplement, then cite that schema section instead of only the migration allowlist."
docs/operations/w4-bilateral-pass-6-agent-md.md:105:  - **Likely:** **REJECT-CODEX** with rationale, OR small schema supplement edit. The migration allowlist IS the v0.3 supplement enforcement (per ADR-006 + the v0.3 trigger). But Codex's point is that they should also appear in the YAML schema definition (`tenant_adapters_config_additions`) for documentation completeness. Founder call: edit the YAML supplement to declare them explicitly, OR write disagreement claiming migration-allowlist is sufficient single-source-of-truth.
docs/operations/w4-bilateral-pass-6-agent-md.md:114:### Finding 1. False schema-status claim for `blocked_recipients`
docs/operations/w4-bilateral-pass-6-agent-md.md:116:  - **Codex says:** "It says 'the actual config-key SCHEMA registration is v0.4-supplement-pending' and that v0.3 only registers other keys, but `docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql` §5 allowlists `blocked_recipients` at line 397. Fix by removing the v0.4-pending claim for `blocked_recipients`; keep v0.4-pending only for `auto_source_on_brief_create`."
docs/operations/w4-bilateral-pass-6-agent-md.md:117:  - **Likely:** FIX-IN-PLACE. Remove v0.4-pending claim for `blocked_recipients`; keep it only for `auto_source_on_brief_create`. (Verify: v0.3 migration line 397 does include `blocked_recipients` in allowlist? Confirmed in our earlier read: "tier_overrides, blocked_recipients, janitor_dedup_threshold..." — yes.)
docs/operations/w4-bilateral-pass-6-agent-md.md:230:2. **Schema-citation hygiene** (Janitor #2, #3, #4; Sourcing Scout #1; Scribe #1) — v0.2/v0.3 supplement boundary is the single most-failed cross-reference. After this pass, recommend a CI grep that flags any `agent.md` field reference whose name doesn't appear in `vertical-schema.yaml` OR `vertical-schema.v0.3-supplement.yaml`.
docs/operations/w4-bilateral-pass-6-agent-md.md:232:3. **Catalogue completeness** (Diagnostic #2, Janitor #1, Scribe #5) — `escalation-codes.md` is the canonical mapping; agent.md narratives drift from it. After this pass, recommend a CI grep verifying every `ESC_*` reference in `agent.md` exists in the catalogue with at least the agent_name in `used_by`.
docs/operations/w4-day-20-founder-runbook.md:72:- ✓ `validate_tenant_adapters_config_v0_3` trigger present on `tenant_adapters`
docs/operations/w4-day-20-founder-runbook.md:87:The 11 tables: `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`, `cash_conductor_transactions`, `cash_conductor_invoices`.
docs/operations/w4-day-20-founder-runbook.md:109:2. Janitor (4 findings) — schema-citation cluster, mechanical
agents/recruitment/scribe/agent.md:82:Field names match canonical schema verbatim per `vertical-schema.yaml` + `vertical-schema.v0.3-supplement.yaml`. v0.3 supplement (Proposed; Day-19 commit `7b4f390` originally claimed RATIFIED but the supplement YAML's own status banner is `Status: Proposed`; the v0.3.1 amendment at Day-20 added Janitor + blocked_recipients keys and queued the supplement for re-ratification) defines the v0.3-tagged fields above (e.g. `headcount_growth_signal_text`, `satisfaction_signal`, `placement_status`, `week_1_status_vault_path` — which replaced the earlier draft name `week_1_status_note`, and `must_haves`/`nice_to_haves`/`deal_breakers` on Brief). Scribe agent.md will re-verify field-name accuracy against the supplement-as-RATIFIED state at W6 Day-1.
agents/recruitment/scribe/agent.md:259:Gate B doesn't block individual runs. Tracked monthly via day-30 metrics roll-up (similar to Janitor's day-30 report; Scribe metrics merge into the tenant's monthly executive summary).
agents/recruitment/scribe/agent.md:314:| Janitor ratified (Bullhorn auth substrate via W5 build) | W5 Codex Round | ⏸ |
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:61:-- §3 — Per-tenant retention override storage (tenant_adapters extension)
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:11:--   - Restores v0.2 tenant_adapters.config validation trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:87:-- §4 — Restore v0.2 tenant_adapters validation (drop v0.3 trigger)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:91:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:93:-- v0.2 trigger (if it existed) — currently no v0.2 validate_tenant_adapters
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:95:-- tenant_adapters config validation trigger.
packages/utilities/autosend-bridge-telegram/src/bridge.ts:47:  if (!input.operator_telegram_chat_id) {
packages/utilities/autosend-bridge-telegram/src/bridge.ts:48:    throw new BridgeInputError("operator_telegram_chat_id is required");
packages/utilities/autosend-bridge-telegram/src/bridge.ts:85:      chat_id: input.operator_telegram_chat_id,
agents/recruitment/sourcing-scout/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fix applied. R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`. R19 (today): adds `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:7:- `tenant_adapters.config.blocked_recipients` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist (key at line 398; allowlist block lines 396-409); canonical Postgres-backed v1.0 DNC source per ADR-002. Declared in `vertical-schema.v0.3-supplement.yaml` lines 810-827 (R19 added this declaration; no longer deferred).
agents/recruitment/sourcing-scout/agent.md:8:- `tenant_adapters.config.auto_source_on_brief_create` — v0.4-supplement-pending (not yet in any allowlist); the Bullhorn-webhook auto-source trigger code path is blocked until v0.4 lands.
agents/recruitment/sourcing-scout/agent.md:21:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:114:     + DNC list from `tenant_adapters.config.blocked_recipients` (Postgres-
agents/recruitment/sourcing-scout/agent.md:189:     (LinkedIn URL) — same fuzzy matcher as Janitor (confidence ≥0.85)
agents/recruitment/sourcing-scout/agent.md:196:   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
agents/recruitment/sourcing-scout/agent.md:202:     (the webhook auto-source trigger config), NOT to `blocked_recipients`.
agents/recruitment/sourcing-scout/agent.md:204:     `blocked_recipients` is now declared in `vertical-schema.v0.3-supplement.yaml`
agents/recruitment/sourcing-scout/agent.md:261:- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
agents/recruitment/sourcing-scout/agent.md:336:| Janitor ratified (Bullhorn-read substrate) | W5 Codex Round | ⏸ |
agents/recruitment/sourcing-scout/agent.md:348:| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
agents/recruitment/sourcing-scout/agent.md:369:| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
packages/utilities/autosend-bridge-telegram/src/types.ts:30:  /** Telegram chat ID for the tenant's operator (from tenant_adapters.config.operator_telegram_chat_id). */
packages/utilities/autosend-bridge-telegram/src/types.ts:31:  operator_telegram_chat_id: string;
agents/recruitment/janitor/README.md:1:# Janitor — directory README
agents/recruitment/janitor/README.md:27:Janitor W5 build slice gated on:
agents/recruitment/janitor/README.md:36:*End of Janitor README.*
agents/recruitment/janitor/agent.md:1:# Janitor — the wedge agent
agents/recruitment/janitor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority. R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4. R19 fixes (2026-05-25): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice.
agents/recruitment/janitor/agent.md:17:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). Auto-band Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks, no synchronous approval; review-band dedup merges (0.70–0.85 confidence, or ≥0.85 with Bullhorn activity in the last 90 days) are instead held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before write. Every write emits a per-write audit row to `decision_log` with `agent_name='janitor'`.
agents/recruitment/janitor/agent.md:26:# /etc/cron.daily/ifos-janitor → calls this script per tenant
agents/recruitment/janitor/agent.md:27:0 2 * * * sudo -u ifos_user /usr/local/bin/ifos-janitor.sh --tenant <slug>
agents/recruitment/janitor/agent.md:30:Resolved by cortextOS daemon → spawns Janitor in Tier-2 batch mode (no persistent PTY). Typical runtime per tenant: 15-45 min depending on Bullhorn corpus size.
agents/recruitment/janitor/agent.md:35:ifosctl janitor --tenant <slug> [--dry-run] [--report-only]
agents/recruitment/janitor/agent.md:42:- Brain UI "Run Janitor now" button → triggers via internal API
agents/recruitment/janitor/agent.md:43:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold` — declared in `vertical-schema.v0.3-supplement.yaml §4 tenant_adapters_config_additions.janitor_dedup_threshold`; enforced by `migrations/v0.2-to-v0.3.sql §5` validator allowlist)
agents/recruitment/janitor/agent.md:53:Located at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`. Eight sections:
agents/recruitment/janitor/agent.md:60:| 4 | **Tacit-note coverage** | Notes harvested from `recent_edit` table rows with `resolution='approved_after_edit'` (per v0.2-supplement.yaml recent_edit definition; v0.3 supplement §2a grants Janitor R access); attached to relevant Bullhorn entities; coverage rate over the 30-day window |
agents/recruitment/janitor/agent.md:61:| 5 | **Agent vs. consultant attribution** | Rows attributed to Janitor automated work vs consultant manual entry; supports the day-30 before/after narrative |
agents/recruitment/janitor/agent.md:74:Each write emits one `decision_log` row: `agent_name='janitor'`, `phase='action'`, `action_type` per the mapping above, `tier` per autosend-policy.yaml, payload includes source confidence + provenance.
agents/recruitment/janitor/agent.md:86:   → hh_decision_trigger("session_start", "janitor nightly cron")
agents/recruitment/janitor/agent.md:95:     opportunities created/modified since last Janitor run (last_run_at in
agents/recruitment/janitor/agent.md:96:     tenant_adapters.config.janitor_last_run — declared in vertical-schema
agents/recruitment/janitor/agent.md:97:     v0.3 supplement §4 tenant_adapters_config_additions.janitor_last_run;
agents/recruitment/janitor/agent.md:99:   → hh_decision_output("janitor_scan", "tenant:<slug>", "<N> entities scanned")
agents/recruitment/janitor/agent.md:139:     recent_edit definition; v0.3 supplement §2a grants Janitor R access):
agents/recruitment/janitor/agent.md:146:   → hh_decision_output("janitor_tacit_note_harvest", "tenant:<slug>",
agents/recruitment/janitor/agent.md:159:   → SELECT from decision_log WHERE agent_name='janitor' AND created_at >
agents/recruitment/janitor/agent.md:163:   → write to /vault/<tenant>/janitor-reports/day-30-<ISO-date>.md
agents/recruitment/janitor/agent.md:174:   → update tenant_adapters.config.janitor_last_run = now()
agents/recruitment/janitor/agent.md:175:   → hh_decision_action("janitor_run_complete", "tenant:<slug>", payload_hash, payload_preview)
agents/recruitment/janitor/agent.md:185:Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:201:`ESC_DUPLICATE_DETECTED` (catalogue §2.5) is NOT a Gate A failure code — per catalogue trigger it's the SUCCESS-path Telegram approval gate for dedup pairs that need human approval before merge: the 0.70–0.85 review band, plus any ≥0.85 pair where a record has Bullhorn activity in the last 90 days. Pairs ≥0.85 with no recent activity auto-merge (yellow tier, spot-check) and do NOT fire it. Sub-0.70 confidence pairs silently drop in the Step 3 algorithm; no ESC fire. `ESC_SCHEMA_VIOLATION` (catalogue line 163) is NOT used by Janitor — reserved for vertical-schema field-constraint violations at write-time.
agents/recruitment/janitor/agent.md:209:Gate B doesn't block the agent. The day-30 dedup + field-completeness improvement is Janitor's local Gate B metric per ULTRAPLAN A2 line 511 verbatim. It contributes evidence (alongside other agents' Gate-B metrics) to kill-criterion §2 Trigger 8 (average Gate-B revenue uplift after 3 completed pilots per `v1.0-kill-criterion.md` lines 158-166) — but Janitor does NOT directly claim Trigger 8 status. DSO improvement is Cash Conductor's territory per ULTRAPLAN A4 line 540, not Janitor's.
agents/recruitment/janitor/agent.md:211:Per catalogue `escalation-codes.md` ESC_GATE_B_MISS trigger (Janitor example: "dedup confidence <15% AND field-completeness uplift <10%"): `ESC_GATE_B_MISS` fires only when BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND completeness-improvement <10%) → flag for operator review (heuristic tuning may be needed; not a kill). Single-threshold misses are tracked in the day-30 report (§3 Output 1 row 6) and inform tenant-level quality review but do NOT fire ESC. Sensitivity choice: strict AND-trigger reduces false alarms; tightening to OR-trigger requires a catalogue amendment + re-ratification.
agents/recruitment/janitor/agent.md:228:| `ESC_GATE_B_MISS` | Per catalogue trigger: per-agent local Gate B metric threshold missed. For Janitor: BOTH thresholds miss for 3 consecutive runs (dedup-improvement <15% AND field-completeness-improvement <10%) per catalogue `ESC_GATE_B_MISS` Janitor example. Single-threshold misses do NOT fire (per §5 Gate B). Catalogue routing: operator_chat_id | warn | operator_chat_id |
agents/recruitment/janitor/agent.md:231:Janitor does NOT use:
agents/recruitment/janitor/agent.md:233:- `ESC_VOICE_DRIFT_TENANT` — fired by nightly voice-drift cron (per `escalation-codes.md` line 170-175 trigger: ≥N `ESC_VOICE_DRIFT` rows from same tenant in rolling 7d window). Janitor only fires the per-run `ESC_VOICE_DRIFT`; aggregate `_TENANT` rollup is handled by the canary not Janitor.
agents/recruitment/janitor/agent.md:234:- `ESC_AUTOSEND_BLOCKED` — that's for red-tier blocks (`escalation-codes.md` line 41); Janitor writes are yellow tier only
agents/recruitment/janitor/agent.md:235:- **OAuth-token revocation** — there is no separate `ESC_BULLHORN_OAUTH_REVOKED` catalogue code; revocation is folded into `ESC_BULLHORN_AUTH` via `payload.failure_type='revoked_401'` (per concierge §6 + catalogue). Janitor fires `ESC_BULLHORN_AUTH` (listed above) on any refresh/revocation failure
agents/recruitment/janitor/agent.md:236:- `ESC_SCHEMA_VIOLATION` (line 163) — that's for vertical-schema field-constraint violations at write-time; Janitor's Gate A failures map to `ESC_AGENT_OUTPUT_SHAPE` (output-shape constraint) instead, per the catalogue's intended-use distinction
agents/recruitment/janitor/agent.md:244:- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `janitor`** — surfaces rules like:
agents/recruitment/janitor/agent.md:249:- **`hh_load_recent_edits` last 30 days for `janitor` agent**: detects if consultants are heavily editing Janitor's tacit-note drafts. Per-run `ESC_VOICE_DRIFT` fires when the tacit-note voice classifier score is below 0.75 after 3 retries (Janitor emits per-run). Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` line 170-175 trigger (≥N `ESC_VOICE_DRIFT` rows from the same tenant within a rolling 7d window); Janitor does NOT fire `_TENANT` directly. Edit-distance metrics are tracked separately for analytics but do NOT fire ESC codes — they inform the canary's threshold tuning over time.
agents/recruitment/janitor/agent.md:257:Janitor build cannot start until ALL of the following are confirmed:
agents/recruitment/janitor/agent.md:277:**Until ALL ⏸ items resolve to ✅, W5 build slice does not start.** Per kill-criterion §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5): if Bullhorn auth not cleared by end of W5, Janitor + Scribe defer to W7-8 per ULTRAPLAN §10 Risk #2 contingency.
agents/recruitment/janitor/agent.md:289:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
agents/recruitment/janitor/agent.md:292:| Q4 | Tacit-note attribution — should notes attribute to "Intel Force OS Janitor" or just "Internal note"? Tenant brand preference. | Per-tenant config at first-pilot onboarding. |
agents/recruitment/janitor/agent.md:300:3. **Bullhorn webhook coverage is patchy** (per ULTRAPLAN A6 line 569 — Concierge note applies cross-agent). Janitor relies on polling not webhooks; safer for nightly cron pattern.
agents/recruitment/janitor/agent.md:321:*End of Janitor agent.md draft.*
docs/operations/codex-round-2-remediation-prompt.md:204:      to Accepted before Janitor (W5) build starts per
docs/operations/codex-round-2-remediation-prompt.md:205:      `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/operations/codex-round-2-remediation-prompt.md:219:  | Janitor W5 build | A+B Accepted (commercial conversations complete) | Pending |
docs/operations/codex-round-2-remediation-prompt.md:333:    per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/operations/codex-ratification-execution-plan.md:73:| `review-mcp-connector.md` | New MCP connector checklist | ~200 | Pre-Janitor-W5 (not yet needed) |
docs/operations/codex-ratification-execution-plan.md:352:- **Option α** — Start immediately. Rationale: 33 items are already queued; Q1 turning YES will only ADD items (Diagnostic + Janitor + downstream). The 34-item queue is largely about Week 0 design artefacts that won't change post-LOI. Get them ratified now while context is fresh.
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:21:  operator_telegram_chat_id: "987654321",
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:130:      proposeApproval({ ...validInput, operator_telegram_chat_id: "" }, { transport, decisions }),
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:21:  operator_telegram_chat_id: "987654321",
docs/operations/goal-week-3-polish-and-scaffold.md:7:**Master plan citations:** Master brief §8.2 (build wave 1 = Diagnostic + downstream sequence) + ULTRAPLAN §8.1 (per-agent specs A1-A6) + `sequencing-target.md` §3.1 (build waves ratified) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic must render cleanly by 2026-06-14) + Trigger 3 (Janitor Bullhorn W5 gate) + ADR-005 (Week-3 acceleration sequencing).
docs/operations/goal-week-3-polish-and-scaffold.md:52:5. **`agents/recruitment/janitor/agent.md`** exists. Status: Proposed. ~400 lines. Models on Diagnostic's structure. Cites master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 507-514 + Risk #2 + Trigger 3.
docs/operations/goal-week-3-polish-and-scaffold.md:61:- §3 Required sections / output shape (varies per agent; Diagnostic has 12 sections; others have shapes appropriate to their output — Janitor: day-30 report rows; Scribe: Bullhorn entity write payloads + tacit-note attachments; Cash Conductor: reconciliation rows; Sourcing Scout: ranked match list; Concierge: customer message drafts)
docs/operations/goal-week-3-polish-and-scaffold.md:288:### DAY 16 — Janitor agent.md scaffold (Step 8)
docs/operations/goal-week-3-polish-and-scaffold.md:290:#### Step 8 — `agents/recruitment/janitor/agent.md` (~2-3 hours)
docs/operations/goal-week-3-polish-and-scaffold.md:293:- ULTRAPLAN §8.1 A2 lines 507-514 (full Janitor spec)
docs/operations/goal-week-3-polish-and-scaffold.md:294:- master brief §8.2 line 596 (Janitor row: "Janitor, Week 5, Bullhorn MCP (R+W), First demoable inside-ATS result; day-30 before/after closes deals")
docs/operations/goal-week-3-polish-and-scaffold.md:295:- `bullhorn-integration-path.md` §4.1 (Janitor's Bullhorn entity surface)
docs/operations/goal-week-3-polish-and-scaffold.md:296:- `v1.0-kill-criterion.md` Trigger 3 (JANITOR-BULLHORN-AUTH-W5)
docs/operations/goal-week-3-polish-and-scaffold.md:297:- `vertical-schema.yaml` §3 agent_access_matrix Janitor row
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:311:- **§7 Voice + tone:** N/A (Janitor doesn't produce customer-facing output; all writes are internal data).
docs/operations/goal-week-3-polish-and-scaffold.md:324:Commit: `decision(pre-build): agents/recruitment/janitor/agent.md — output contract per ULTRAPLAN §8.1 A2`
docs/operations/goal-week-3-polish-and-scaffold.md:503:| Bullhorn A+B response arrives mid-week | Fold confirmed answers into Janitor / Scribe / Sourcing Scout / Concierge agent.md §8 (build prerequisites); do NOT start Bullhorn connector code (reserved for W4-5) |
docs/operations/goal-week-3-polish-and-scaffold.md:618:  Janitor (W5):           <N> lines | Codex verdict: <RATIFIED/REJECTED>
docs/operations/goal-week-3-polish-and-scaffold.md:631:  <SHA>  decision(pre-build): agents/recruitment/janitor/agent.md
docs/operations/goal-week-3-polish-and-scaffold.md:657:    - Janitor build (depends on Bullhorn R+W)
docs/operations/goal-week-3-polish-and-scaffold.md:685:| 4 | Bullhorn A+B response arrives with surprise terms (e.g., marketplace required + £25k/year) | Medium | Fold answer into Concierge / Janitor / Scribe / Sourcing Scout §8 build-prereq; surface kill-criterion Trigger 3 review |
packages/utilities/autosend-bridge-telegram/tests/message-format.test.ts:14:  operator_telegram_chat_id: "987654321",
docs/operations/decision-log.md:77:- **Third attempt: SUCCESS.** Migration applied cleanly (BEGIN…41 DDL…in-migration smoke "v0.3 migration smoke passed"…COMMIT). Post-flight verification confirmed: both Cash Conductor tables present and `postgres`-owned (Day-12 compliant); `validate_voice_scores` trigger replaced by `validate_entities_data_v0_3`; `validate_tenant_adapters_config_v0_3` present.
docs/operations/decision-log.md:91:- **The tenant_adapters config validator** enforces the allowlist including `blocked_recipients`, `janitor_dedup_threshold`, `concierge_send_window` — Sourcing Scout / Janitor / Concierge build slices land on a verified config surface.
docs/operations/decision-log.md:134:**RATIFIED (4):** diagnostic, janitor, scribe, concierge — each with minor advisories (2 closed; 1 was a false-positive about scribe ESC-catalogue line drift, verified at lines 324 + 441 are still accurate).
docs/operations/decision-log.md:145:| (advisories) | 2 (janitor §3 stale "new entries" wording; concierge §1 "deferred deferred" duplicate) | `316af0c` |
docs/operations/decision-log.md:166:| 6 agent.md (diagnostic, janitor, scribe, cash-conductor, sourcing-scout, concierge) | **RATIFIED** ✓ | — |
docs/operations/decision-log.md:182:   - **Janitor (4):** relative date→2026-05-25; §2.1→§2.2 cite; contractor dedup in §3; dedup approval model **[DECISION]**
docs/operations/decision-log.md:183:   - **Sourcing Scout (3):** blocked_recipients now-declared cite; recent_edit read removed (W-only); Gate A decision-log write
docs/operations/decision-log.md:188:   - **v0.3 supplement (3):** Sourcing Scout candidate/contractor R+W→R **[DECISION]**; client_contact_id derivation via entity_links; blocked_recipients element-string validation in migration
docs/operations/decision-log.md:192:1. **Janitor dedup approval model** — ≥0.85 + no-recent-activity auto-merges (yellow, spot-check); 0.70–0.85 band (or ≥0.85 with recent activity) → Telegram approval-gated via `ESC_DUPLICATE_DETECTED`; <0.70 dropped. Aligns to the ratified catalogue (defines `ESC_DUPLICATE_DETECTED` as "needs human approval").
docs/operations/decision-log.md:213:| ESC codes referenced ∈ escalation-codes.md | ✓ (3 are sanctioned W4-backlog proposals / changelog notes; janitor's `ESC_BULLHORN_OAUTH_REVOKED` disclaimer corrected → folded into `ESC_BULLHORN_AUTH` payload) |
docs/operations/decision-log.md:226:3. `bd3c145 fix(janitor-r12 + v0.3-supplement.0.1)` — Finding 4 closed via v0.3 supplement §4 amendment adding `janitor_dedup_threshold` + `janitor_last_run` declarations; agent.md citations updated. Findings 1+2+3 already in post-R11 commit `e5a2c74`. **v0.3 supplement amended — needs re-ratification**.
docs/operations/decision-log.md:227:4. `0e0d741 fix(sourcing-scout-r9)` — 3 R8 residuals already in `d1f4c53`; R9 polish: §10 three-state lifecycle (Proposed → Ratified-as-Scaffold → Accepted → In Force) + §1 Schema-key block rewrite + §4 Step 8 blocked_recipients cite corrected
docs/operations/decision-log.md:239:| Janitor | Pre-Build-Round-12-Bilateral-Applied | 4 | 0 (3 in `e5a2c74` + 1 via supplement) | Codex R13 re-ratification |
docs/operations/decision-log.md:250:- **Catalogue extended:** 24 → 52 ESC codes; 29 → 47 action_types; 2 new Postgres tables (cash_conductor_transactions + cash_conductor_invoices); 3 new tenant_adapters config keys
docs/operations/decision-log.md:256:  - Janitor: R11 post-v0.3 (4 baseline, 0 mechanical after R11 fix)
docs/operations/decision-log.md:358:- [ ] **R9**: Bullhorn OAuth refresh timing under load — Janitor W5 stress test
docs/operations/decision-log.md:360:- [ ] **R11**: tenant_eval_sets + tenant_adapters usage spec — Diagnostic W4 (first eval-set)
docs/operations/decision-log.md:361:- [ ] **R12**: entities.version optimistic-concurrency helper — Janitor W5 (first entity write)
docs/operations/decision-log.md:375:- ❌ Diagnostic W3-4 agent build (and all named v1.0 agent builds: Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/operations/decision-log.md:406:- `2340e24` (Step 8) Janitor agent.md (296 lines)
docs/operations/decision-log.md:426:| Janitor agent.md | REJECTED ~5-7 issues | Same |
docs/operations/decision-log.md:469:- Janitor build
docs/operations/decision-log.md:481:- **Step 8** (`2340e24`) — Janitor agent.md (296 lines) per ULTRAPLAN §8.1 A2 (W5 build wave)
docs/operations/decision-log.md:500:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: Proposed; ready for Codex Round 4 Phase 2
docs/operations/decision-log.md:506:| Janitor | W5 | A2 lines 501-514 |
docs/operations/decision-log.md:524:- Janitor build (depends on Bullhorn R+W)
docs/operations/decision-log.md:556:**ADR-005 ratifies the sequencing change** (commit `e578354`): Week 3 repurposed from Bullhorn-MCP-build to Diagnostic-end-to-end-build per ULTRAPLAN §10 Risk #2 contingency. Bullhorn-touching agents (Janitor W5+) gated on Bullhorn Sub-decisions A+B response (form submitted 2026-05-24) or 2026-06-10 force-fallback.
docs/operations/decision-log.md:812:- #7: Context-assembly API spec (Week 5+ Janitor)
docs/operations/decision-log.md:813:- #8: Bullhorn MCP connector code (Week 5+ Janitor)
docs/operations/decision-log.md:814:- #9: tenant_eval_sets / tenant_adapters usage spec (lazy, follows first use)
docs/operations/decision-log.md:936:  - Agent × Entity R/W matrix across all 6 v1.0 agents (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) — cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3
docs/operations/decision-log.md:937:  - Bullhorn mapping per entity with explicit "field-density TBD pending Week 3-4 Janitor verification per §4.1 Spec gap §4.1-A" flag
docs/operations/decision-log.md:943:- **Note as decision_log payload** for v0.1 (not separate entity_type) — promotion trigger named (Janitor Week 3-4 query patterns); avoids dual-storage problem
docs/operations/decision-log.md:944:- **Field enumeration minimal v1.0** — full Bullhorn field-density TBD per Week 3-4 Janitor verification; Day 6 establishes structure, not lockdown
docs/operations/decision-log.md:950:**Length:** 894 lines (vs 300-500 estimate). Master brief "every field, every relationship, every data source" framing justifies depth. v0.1 intentionally over-specifies; Week 3-4 Janitor verification likely trims based on real Bullhorn data.
docs/operations/decision-log.md:969:  - Per-tenant override §8: elevation only; red is absolute floor; `blocked_recipients` additive
docs/operations/decision-log.md:975:  - **Triggers 2-4** fold `sequencing-target.md` §6.6 three failure conditions verbatim (Diagnostic W3 KILL, Janitor Bullhorn W5 PIVOT, 2× scope-cut PAUSE)
docs/operations/decision-log.md:1026:Test ran as `ifos_app` over TCP+scram-sha-256 (NOT as postgres superuser which bypasses RLS). RLS + FORCE + `tenant_isolation` policy (USING + WITH CHECK) on all 5 data tables: `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`.
docs/operations/decision-log.md:1159:- **Day 3 ratification**: master brief §8.2 sequence ratified verbatim — Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 (Hire-#1-anchored) → Sourcing Scout W9 → Concierge W10-13
docs/RISK-REGISTER.md:11:| 2 | Bullhorn MCP build takes longer than 1 week | ~~High~~ → Medium (blast-radius reduced) | High | End of week 3 status not "core read endpoints working" | Week 0 Day 2 on Bullhorn auth research; contingency: defer Janitor & Scribe to weeks 7-8 | **Updated Day 13 (2026-05-24):** **Blast radius reduced** by ADR-005 (`docs/decisions/ADR-005-week-3-diagnostic-acceleration.md`). Bullhorn-touching agents (Janitor W5+) gated on A+B response or 2026-06-10 force-fallback. Bullhorn partnership form submitted 2026-05-24 via verified Marketo form at `https://www.bullhorn.com/become-a-partner/` (response 2-5 business days). Diagnostic shipped Day 13 without Bullhorn dependency — 4 of 6 v1.0 agents no longer blocked on this risk. Sub-decisions A (marketplace vs direct) and B (OAuth flow) remain **Proposed**. **Reduction trigger 1 (Medium → Low):** A and B flip to Accepted when commercial answers land. **Reduction trigger 2 (Low → Closed):** first Bullhorn write lands cleanly in Janitor agent build (master brief §12 tripwire "core read endpoints working" passes). |
docs/operations/goal-option-c-diagnostic-end-to-end.md:253:- **Consequences:** Janitor W5 build conditional on Bullhorn A+B Accepted. If A+B answer arrives after 2026-06-03, Janitor slips to W6+; if no answer by 2026-06-10, force Direct-API fallback per `bullhorn-integration-path.md` §1.4.
docs/operations/goal-option-c-diagnostic-end-to-end.md:409:  - [Proceed to Week-4 polish OR wait on Bullhorn response before Janitor W5?]
docs/operations/founder-manual-playbook-2026-05-31.md:20:**Why first:** unblocks all v0.3 schema usage (Cash Conductor tables, Janitor dedup config, blocked_recipients, etc.). Without this, every downstream W4 build is just writing code against schema that doesn't exist on the live database.
docs/operations/founder-manual-playbook-2026-05-31.md:244:When the response arrives, paste their answer (full body OK; no need to redact). I'll fold it into Janitor / Scribe / Sourcing Scout / Concierge §8 build-prerequisite rows.
agents/recruitment/concierge/tools.yaml:33:    purpose: "Bullhorn OAuth refresh + per-tenant token rotation (deferred to W7 Janitor bundle Track-2 per master brief §8.2)"
agents/recruitment/concierge/tools.yaml:205:#   bullhorn_oauth                     green               (W7 Janitor + Bullhorn partnership)
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:38:  operator_telegram_chat_id: "987654321"
docs/architecture/tenancy-invariants.md:12:IFOS is multi-tenant SaaS. Every tenant runs the same agent fleet (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge in v1.0) against their own data, isolated from every other tenant's data. **A single cross-tenant data leak is a catastrophic failure mode** — it breaches the GDPR contract, violates pilot LOI terms, and burns customer trust. There is no "minor" cross-tenant leak.
docs/architecture/tenancy-invariants.md:24:- **Tenant-data tables** (9 in v0.2): `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`. All have `tenant_slug` column + RLS policy.
docs/architecture/tenancy-invariants.md:45:  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
agents/recruitment/concierge/fixtures/01-primary.yaml:30:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/context.sh:5:#         with real provider config + tenant_adapters reads).
agents/recruitment/concierge/context.sh:24:#   - Refresh Microsoft Graph OR Gmail OAuth (per tenant_adapters.config.email_channel)
agents/recruitment/concierge/context.sh:27:#   - Resolve operator_telegram_chat_id from tenant_adapters.config
agents/recruitment/concierge/context.sh:35:#   CTX_OPERATOR_TELEGRAM_CHAT_ID        — tenant operator's Telegram chat ID
agents/recruitment/concierge/context.sh:81:# TODO(W10-13): SELECT config->>'email_channel' FROM tenant_adapters WHERE tenant_slug=$1
agents/recruitment/concierge/context.sh:109:# TODO(W10-13): resolve via tenant_adapters.config; default fallback chain.
agents/recruitment/concierge/context.sh:118:# TODO(W10-13): SELECT config->>'operator_telegram_chat_id' FROM tenant_adapters
agents/recruitment/concierge/context.sh:121:export CTX_OPERATOR_TELEGRAM_CHAT_ID="${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID:-STUB}"
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:35:  operator_telegram_chat_id: "987654321"
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:93:5. **Decide whether the 5 new agent.md scaffolds** (Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge) should ALL await the agent-bundle skill before Codex Round 4 Phase 2 — recommend yes, since they'll have the same structural issue.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:119:| Janitor | ~5-7 (count regex inflated; 56 numbered items including nested) | `logs/codex-ratification/20260524T102050Z-21293/` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:129:3. **Kill-criterion Trigger references** — multiple agent.md files cite kill-criterion triggers that don't match the trigger definition (Janitor cites Trigger 3 correctly; Concierge cites Trigger 5 in autosend context which IS Trigger 5 territory; Diagnostic mis-cited Trigger 8). Per-agent verification needed; not a uniform pattern.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:155:## Janitor Round-5 (remediation) — empirical confirmation of bilateral pattern
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:157:After all 6 Round-4-v2 issues remediated on Janitor (commit `2392af8`), Round-5 ratification returned REJECTED with **5 NEW findings** — none of the original 6 reappeared. New issues at Janitor session `20260524T103757Z-37420`:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:161:3. **§5 vs §6 ESC code contradiction:** §5 prose retains `ESC_SCHEMA_VIOLATION` reference even though §6 explicitly says Janitor doesn't use it. Mechanical fix missed by my Round-4-v2 remediation.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:163:5. **Trigger 8 framing — DSO claim:** Trigger 8 is revenue uplift after 3 pilots; DSO improvement is Cash Conductor's metric not Janitor's. My §5 prose conflated the two agents' Gate B narratives.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:184:## Janitor Round 6 (exceeds hard ceiling) — 4 more NEW findings, all different from Rounds 4-5
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:210:## Janitor Round 7 — 23+ unique issues; pattern definitively closed
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:212:After all 4 Round-6 issues remediated on Janitor (commit `1939d9b`), Round 7 returned REJECTED with **4 more new findings**, none from Rounds 4-6:
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:214:1. `operator_notify_telegram` + `janitor_run_complete` are unregistered hh_decision_action types — hook-helpers fails them to red via `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`. (Found because my Round-6 commit added those calls without registering them.)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:258:- Cat-3 (kill-criterion strip): Trigger 8 references removed from Diagnostic + Janitor + Cash Conductor; Sourcing Scout framed as local leading metric
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:262:- Schema field corrections: Janitor candidate.location line 124 + bullhorn_id; Scribe entity-fields canonical names + v0.3-supplement-pending flags; Cash Conductor vault-jsonl-cache → Postgres tables; Sourcing Scout passive → active+last_activity_at filter
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:273:| Janitor | 6 | `20260524T112807Z-81339` |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:289:- Janitor: `candidate.linkedin_url` not in schema
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:299:- `ESC_LIFECYCLE_STATE_UNKNOWN` — Concierge uses for taxonomy misses; catalogue defines for Janitor placement ambiguity. Resolution: widen.
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:308:- Janitor / Scribe / Cash Conductor / Sourcing Scout / Concierge: validate.sh + cycle.sh + tools.yaml + cleanup.sh do not exist yet — pre-build scaffolds per Cat-5 disposition
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:315:  - Janitor Step 1 auth refresh emits ESC without decision row
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:324:**Cumulative empirical:** 9 Codex rounds total (Round 4-v1, 4-v2, 5, 6, 7 on Diagnostic/Janitor + Round 8 across all 6). **55+ unique findings catalogued across rounds, ~10-12 fixed via Cat-α mechanical disposition in this bilateral session; rest queued.**
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:330:- Janitor: pre-build-scaffold; Round-8-reviewed; ~3 schema-supplement findings (Cat-β) + ~2 catalogue-widening (Cat-γ) queued
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:357:- `ESC_LIFECYCLE_STATE_UNKNOWN` — both Janitor placement + Concierge taxonomy out-of-bounds
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:371:| Janitor | 6 | 6 | 0 (different findings; 1 Cat-γ closed, 1 new) |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:417:2. **v0.3 vertical-schema supplement** — unblocks Janitor / Scribe / Cash Conductor / Concierge Cat-β items
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:427:| Janitor | Pre-Build-Round-9-Reviewed | 6 (Cat-β + Cat-γ residual) | v0.3 + bilateral consistency pass |
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
docs/architecture/architecture-cohesion-review.md:95:| A8 | **Bullhorn OAuth refresh-loop fires before token expiry under load.** Per-agent 8-min cycle vs 10-min TTL. | bullhorn-integration-path.md §4.5 + common-ats.json `auth_refresh_interval_seconds` | If the 2-min buffer is insufficient under network latency or rate-limit backoff, agent loses Bullhorn auth mid-write. Untested at scale; flagged at first Janitor build. |
docs/architecture/architecture-cohesion-review.md:149:| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
docs/architecture/architecture-cohesion-review.md:152:| G6 | **vault-concurrency.md `entities.version` enforcement is one-directional.** The doc names optimistic-concurrency UPDATE pattern but the helpers don't yet implement it (hook-helpers.sh has no entity-update path; that lands when an agent needs to write to `entities`). | Low (Janitor W5 will be first writer) | First entity-write helper at Janitor build adds version-check pattern. New ADR if pattern surfaces decisions. |
docs/architecture/architecture-cohesion-review.md:235:| R9 | A8: Bullhorn OAuth refresh timing under load | Low | First Janitor build stress test | Claude Code | Janitor W5 |
docs/architecture/architecture-cohesion-review.md:237:| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
docs/architecture/architecture-cohesion-review.md:238:| R12 | G6: entities.version optimistic-concurrency helper | Low | First entity-write helper at Janitor build | Claude Code | Janitor W5 |
agents/recruitment/concierge/agent.md:130:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:389:| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
agents/recruitment/concierge/agent.md:425:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
agents/recruitment/concierge/cycle.sh:290:    #      --operator-chat "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
agents/recruitment/concierge/cycle.sh:345:  #   if tenant_adapters.config.email_channel == 'microsoft-graph':
agents/recruitment/concierge/cycle.sh:375:  # TODO(W10-13): if tenant_adapters.config.concierge_state_advance_enabled:
agents/recruitment/concierge/cycle.sh:389:# TODO(W10-13): UPDATE tenant_adapters SET config = jsonb_set(config, '{concierge_last_run}', '"<ISO>"')
docs/architecture/agent-bundle-renderer-design.md:145:| `heartbeat` | cortextOS heartbeat cadence — periodic `update-heartbeat` writes to `${ctxRoot}/heartbeats/{name}.json` so the dashboard sees "alive" status | IFOS agents emit heartbeats too (the daemon's fast-checker writes them per `agent-process.ts:597-639` session timer), but the *cadence* and *what the agent does at each heartbeat* is specced per-agent in `agent.md` (Concierge always-on; Janitor cron-driven; etc.). The cortextOS-template `heartbeat/SKILL.md` is a default playbook — IFOS replaces with per-agent specifics |
docs/architecture/agent-bundle-renderer-design.md:767:**First production render:** the Diagnostic agent (master brief §8.2 A1) at Week 4 — this is also the first end-to-end proof that the renderer works against a real bundle. Subsequent renders for Janitor (Week 5), Scribe (Week 6), Cash Conductor (Weeks 7-8), Sourcing Scout (Week 9), and Concierge (Weeks 10-13) extend the validation surface.
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:114:- Other agents (Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) Gate A framings can follow the same per-agent ADR pattern (numbers assigned at authoring time, not pre-reserved here) if needed for their own Cat-ζ findings — though most other agents' Gate A is implementation-realistic at v0, so this may not be needed
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:30:**Recommended timing:** Week 9 (default; sequential with master brief §8.2). Pre-builds the bridge before Concierge W10-13 starts. Allows: Day 1-2 = bridge code + tests; Day 3 = live integration test on migration-test tenant; Day 4 (Concierge W10 start) = Concierge uses bridge from day 1. No timeline pressure on Diagnostic W3-4 or Janitor W5 (neither use orange tier action_types).
docs/architecture/cortexos-primitive-status.md:63:- §8.1 v1.0 build order: A2 Janitor and A3 Scribe are Tier-2 (cron / webhook) and do NOT depend on primitive 1.
docs/decisions/brain-ui-scope.md:150:- **Agent outputs in design partner's existing tools** — Bullhorn notes (Janitor + Scribe writes), Outlook / Gmail emails (Concierge auto-send drafts), Telegram approval messages (per cortextOS Primitive 5).
docs/architecture/vault-concurrency.md:20:- **Agent processes** (Janitor, Scribe, Sourcing Scout, Concierge per `sequencing-target.md` §2.2-§2.6) — write `wiki/compiled/{candidates,clients,placements,people}/*.md` and `wiki/raw/*/` ingest paths.
docs/architecture/vault-concurrency.md:185:The flock (§2) prevents two operations from racing the same file's read-then-write. The Postgres version check (§3) catches the rare case where flock acquisition succeeded sequentially but a *different* code path (e.g. cron-driven full-table update in Janitor's nightly sweep) updated the row without holding flock.
docs/architecture/second-brain-design.md:207:| `wiki/raw/ats-snapshots/` | one file per entity sync | JSON | `{epoch}-{bullhorn-entity-type}-{bullhorn-id}.json` | Janitor (v1.0) on nightly sweep | Janitor itself (diff vs previous), Concierge (v1.0) for entity reconciliation |
docs/architecture/second-brain-design.md:209:| `wiki/compiled/candidates/{slug}.md` | one file per Candidate | markdown with YAML frontmatter | `{slug}.md` — slug derived from `id` field per §2.2 | Scribe + Janitor (v1.0) | Concierge + Sourcing Scout (v1.0); Brain UI (v1.1) |
docs/architecture/second-brain-design.md:210:| `wiki/compiled/clients/{slug}.md` | one per Client | same | same | Janitor (v1.0) on first contact | Cash Conductor + Concierge (v1.0) |
docs/architecture/second-brain-design.md:213:| `wiki/compiled/people/{slug}.md` | one per Contact (client-side individual) | same | same | Scribe (v1.0) from call transcripts; Janitor (v1.0) from Bullhorn | Cash Conductor (v1.0), Concierge (v1.0) |
docs/architecture/second-brain-design.md:223:**v1.0 scope** for vault writes: only `_voice/`, `wiki/raw/inbox-emails/` (Cash Conductor), `wiki/raw/calls/` (Scribe), `wiki/raw/ats-snapshots/` (Janitor), `wiki/compiled/candidates/`, `wiki/compiled/clients/`, `wiki/compiled/placements/`, `wiki/compiled/people/`. Everything else is v1.1+ writes — but the **directories exist from Day 1** of tenant provisioning per Ultraplan §5.5 line 263 (`provision-tenant.sh {slug}` creates the full skeleton).
docs/architecture/second-brain-design.md:235:| Candidate | **v1.0** | Master brief §8.2 Janitor (A2), Scribe (A3), Sourcing Scout (A5), Concierge (A6) all require it |
docs/architecture/second-brain-design.md:236:| Client | **v1.0** | Janitor + Cash Conductor + Concierge all require it |
docs/architecture/second-brain-design.md:237:| Brief | **v1.0 (skeleton) / v1.1 (full)** | Sourcing Scout (v1.0 A5) needs to *read* a Brief to source against; Brief Decoder (v1.1 A8) is the producer. v1.0 writes minimal Briefs (manual entry or direct Bullhorn sync via Janitor); full lifecycle waits for v1.1 |
docs/architecture/second-brain-design.md:258:  - janitor:bullhorn-2026-05-15
docs/architecture/second-brain-design.md:263:bullhorn_id: 12345                                   # optional; external ATS reference (Janitor populates)
docs/architecture/second-brain-design.md:264:linkedin_url: https://linkedin.com/in/sarah-bowen    # optional; Janitor populates
docs/architecture/second-brain-design.md:274:{Janitor or Scribe one-paragraph summary, regenerated on each ingest}
docs/architecture/second-brain-design.md:305:companies_house_number: 12345678                     # optional; UK-specific; Janitor populates
docs/architecture/second-brain-design.md:424:| `search-by-relationship` | Janitor (v1.0): all Candidates linked to Brief X for dedup | v1.0 | `(from_id: str, link_type: str, tenant_id: str)` | `List[EntityRef]` | few seconds | Postgres `entity_graph` traversal; one-hop only in v1.0, multi-hop deferred to graph view v1.2 |
docs/architecture/second-brain-design.md:426:| `ingest-entity` | Scribe (v1.0): new Candidate from Bullhorn webhook; Janitor (v1.0): new Client on first contact; Concierge (v1.0): new Placement on placement event | v1.0 | `(entity_type: str, frontmatter: dict, body: str, tenant_id: str)` | `EntityRef` (with assigned id + slug) | few seconds | Slug collision check; atomic write to filesystem; Postgres `entity_graph` row written in same transaction; `hh_decision_trigger`/`hh_decision_output` called |
docs/architecture/second-brain-design.md:459:  - **Git:** **Spec gap 2.4-A.** Neither master brief nor Ultraplan specifies whether `/vault/{tenant}/` is also a git repo. Obsidian users typically git-init their vaults. **Recommendation:** yes — initialize `/vault/{tenant}/.git/` at tenant provisioning (Ultraplan §5.5 step 2). Founder gets free history, blame, and rollback via Obsidian Git plugin. Agents do NOT commit; the founder commits manually or via a scheduled cron run by Janitor's nightly sweep. **Blocks v1.0 build:** no — git init is one line in `provision-tenant.sh`; commit cadence can be decided in Week 1.
docs/architecture/second-brain-design.md:709:- t=0+50ms: Janitor calls `update-entity(candidate_sarah_bowen, "right_to_work_status", "verified")`. Blocks on the flock.
docs/architecture/second-brain-design.md:711:- t=0+301ms: Janitor acquires flock. Reads file (now contains Concierge's append). Reads Postgres (`updated_at = T1`). Computes new frontmatter. Writes file atomically. Postgres UPDATE `WHERE updated_at = T1` succeeds (`updated_at = T2`).
docs/architecture/second-brain-design.md:751:v1.0 agents per master brief §8.2: Diagnostic (no vault writes; sales-only), Janitor (heavy writes — nightly batch of thousands of Bullhorn entity updates), Scribe (per-call writes; ~30-60 min/day per consultant per Product Spec §2.2 R6), Cash Conductor (writes Placement updates on invoice events; reads heavily for invoice context), Sourcing Scout (read-heavy; produces drafts that the agent itself writes elsewhere), Concierge (per-lifecycle-event writes; reads candidate state on every inbound).
docs/architecture/second-brain-design.md:761:- `ingest-entity` — Janitor's nightly sweep ingests thousands of records; batching is the model. Per-record latency 100ms-1s is fine.
docs/architecture/second-brain-design.md:775:| Janitor | 1:5 | reads each Bullhorn entity once; writes many cleanup updates per sweep |
docs/architecture/second-brain-design.md:778:**Peak concurrent agents per tenant (v1.0):** 4-5 — Janitor (nightly batch but daytime cleanup tasks too), Scribe (webhook-driven per-call), Cash Conductor (always-on watcher), Sourcing Scout (request-response), Concierge (always-on). At Boutique-tier these all run in one PM2 process group per tenant; at Scale-tier the same.
docs/architecture/second-brain-design.md:950:3. **Postgres schema migration scripts** (Spec gap 2.4-B resolution — `entities` + `entity_links` split). Land as part of the Week 0 Day 4 infra task per master brief §6 Day 4 "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`". The §6 wording also needs the §3.4 rename: `entity_graph` → `entities` + `entity_links`. **Day 4 of Week 0** (so this week).
docs/architecture/second-brain-design.md:977:| **3.4-B** | Master brief §6 Day 4 (line 478) Postgres table list | Lists `entity_graph` as a single table | Update wording: "`tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`." Bundles with Day 4 provisioning. | **Tight** — Day 4 of Week 0 (this week). |
docs/decisions/2026-05-18-codex-ratification-manifest.md:130:| 7 | `agents/recruitment/janitor/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 596 + ULTRAPLAN §8.1 A2 lines 501-514 + Trigger 3 |
docs/decisions/2026-05-18-codex-ratification-manifest.md:145:| 2 | `agents/recruitment/janitor/agent.md` | **REJECTED** | ~5-7 real findings (count regex 56 inflated by nested lists) | `20260524T102050Z-21293` |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:20:**Counter:** Codex is applying the Day-7 single-sentence-test Q3 quality gate ("ATS decided + auth cleared") as if it were a Week-1 implementation gate. The Q3 gate is correct as a closing-of-Week-0 gate per master brief §6 line 502, and Q3 = NO is exactly why Week 0 EXTENDS per the Day-7 single-sentence-test result. But the Q3 gate governs **named v1.0 agent-build slices** (Diagnostic W3-4, Janitor W5, etc.), NOT Week-1 prerequisite code.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:33:The first agent that touches Bullhorn is **Janitor (W5)** per master brief §8.2 row 2. The Q3 gate IS load-bearing for Janitor — Sub-decisions A+B MUST flip to Accepted before Janitor build starts. The kill-criterion `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5) explicitly fires PIVOT if auth fails by end of W5; this is the formal gate.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:42:| Janitor build (W5) | A+B Accepted (commercial conversations complete) | Pending |
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:67:which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5)
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:68:build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5).
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:86:**Resolution update (2026-05-22):** [x] Incorporated via "Counter-argued + sharpen wording." The source decision now encodes the prereq-code-only gate and the W5 Janitor auth gate explicitly.
docs/decisions/autosend-safety-policy.md:17:- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
docs/decisions/autosend-safety-policy.md:75:Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).
docs/decisions/autosend-safety-policy.md:82:| Janitor | `bullhorn_candidate_tag` | Adds a tag with `checked_at` date; reversible in <30s; high volume |
docs/decisions/autosend-safety-policy.md:92:| Janitor | `bullhorn_candidate_dedupe` | 1-in-10 | Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review |
docs/decisions/autosend-safety-policy.md:111:| Janitor | `bullhorn_placement_terminate` | Marks placement as terminated; commercial/legal implications; reversible only via support ticket |
docs/decisions/autosend-safety-policy.md:123:| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
docs/decisions/autosend-safety-policy.md:124:| `send_to_blocked_recipient` | `blocked_recipient` | Recipient in tenant's `blocked_recipients` override list |
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
docs/decisions/autosend-safety-policy.md:427:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/decisions/autosend-safety-policy.md:437:    "blocked_recipients": [
docs/decisions/autosend-safety-policy.md:463:3. **`blocked_recipients`** is additive only. Recipients can be added; system-default red-list recipients cannot be removed. Pattern matching supported via `*` wildcards.
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:482:- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:526:  (d) any tier override defined in Tenant's tenant_adapters configuration
docs/decisions/autosend-safety-policy.md:539:  (c) breaches of Tenant's configured blocked_recipients list by the
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:599:| 4 | Multi-recipient sends (e.g., "send brief summary to 50 candidates") — per-recipient evaluation or batch evaluation? | §1 + §3 | Recommend **batch evaluated as worst-tier**: if any recipient is in blocked_recipients, the whole batch is red. If all green, batch is green. Mixed: batch is the highest tier among recipients. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:636:**For Week 5-13 (Janitor → Concierge).** Each agent's `tools.yaml` declares its action_types. The renderer per ADR-003 §4 validates declarations against this policy. Bullhorn-integration-path §4.1 + §6.3's Concierge Note auto-send sensitivity ("notes are immediately visible to clients and candidates in the Bullhorn UI") is materially mitigated: the canonical orange example in §3 ensures every Concierge Note write goes through approval at v1.0 (ad-hoc) and v1.1+ (policy-driven).
docs/decisions/sequencing-target.md:22:| A2 | Janitor | 5 | Bullhorn MCP (R+W) | "First demoable inside-ATS result; day-30 before/after closes deals" |
docs/decisions/sequencing-target.md:28:Master brief §6 Day 3 line 471 asks the Day-3 decision document to "confirm or revise" the Ultraplan §9 sequence. Ultraplan §9 (lines 717-801) carries the same six-agent order: Diagnostic → Janitor → Scribe → Cash Conductor → Sourcing Scout → Concierge.
docs/decisions/sequencing-target.md:34:- **C. Gating criteria between agents.** What "Janitor ready, move to Scribe" means concretely. Avoids the trap of "kinda-working" agents accumulating with no measurable transition discipline.
docs/decisions/sequencing-target.md:44:**Gating criteria prevent the agent-pile-up failure mode.** Without §C, the temptation is "Janitor is 80% working, let's start Scribe alongside while we polish Janitor." That sounds reasonable and is the wrong move — it splits attention, blocks Codex ratification (master brief §10.5 names every `agent.md` as always-ratify, which can't happen until the bundle is stable), and accumulates half-finished agents that all need rework before any can land in a tenant. Explicit gating criteria force serial transitions.
docs/decisions/sequencing-target.md:67:> "v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0" (master brief §12 Risk #4 row + Ultraplan §10 row #4 + Ultraplan §10 row #2 contingency "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1").
docs/decisions/sequencing-target.md:71:- **If Risk #2 (Bullhorn auth path) materialises** — defer Janitor + Scribe to weeks 7-8 (slip the Bullhorn-dependent agents by 2 weeks); push Concierge to v1.1.
docs/decisions/sequencing-target.md:74:Recommended sequence in §4 must remain **operationally coherent under both contingencies.** A sequence that breaks (e.g. one that ships Concierge before Janitor) would lose the Risk #2 contingency because dropping Janitor would orphan the already-shipped Concierge's data flow. The §4 recommendation explicitly validates against both contingencies.
docs/decisions/sequencing-target.md:80:Master brief §8.2 (line 605) and Ultraplan §9 (line 771-773) both place **Cash Conductor at Weeks 7-8 and Sourcing Scout at Week 9** — i.e. Cash Conductor before Sourcing Scout. The founder's Day-3 prompt for this document named "Option Alpha" as Diagnostic → Janitor → Scribe → **Sourcing Scout (W8) → Cash Conductor (W9)** → Concierge — i.e. Sourcing Scout *before* Cash Conductor. This is a minor divergence from the operative master brief.
docs/decisions/sequencing-target.md:105:### 2.2 — A2 Janitor
docs/decisions/sequencing-target.md:111:| 3. Risk de-risking | **High** | **First end-to-end exercise of Risk #2** (Bullhorn auth path per RISK-REGISTER). Closes Risk #2 reduction trigger 2 from `bullhorn-integration-path.md` §6.7: "first Bullhorn write lands cleanly in Week 3-4 Janitor agent build" → Risk #2 Medium → Low |
docs/decisions/sequencing-target.md:113:| 5. Dependencies | **Upstream: none.** **Downstream: load-bearing** — every subsequent Bullhorn-touching agent (Scribe W6, Sourcing Scout W9, Concierge W10-13) inherits the Bullhorn auth + refresh-loop + entity-mapping patterns Janitor establishes. Janitor must ship before its dependents | High criticality |
docs/decisions/sequencing-target.md:114:| 6. Tenant-onboarding readiness | **Medium** | Needs Bullhorn `client_id` + `client_secret` (commercial action per Day 2 §6.1) + per-tenant Bullhorn admin OAuth authorisation (the browser dance per Day 2 §3.1). First-pilot onboarding wizard Day 2 step (Product Spec §5.2) is the moment Janitor can be enabled per tenant |
docs/decisions/sequencing-target.md:116:**Readiness summary:** Janitor — second-most-important first agent after Diagnostic; first Bullhorn auth exercise (Risk #2 derisk); high commercial value via day-30 cleanup report per Product Spec §2.2 R9; downstream dependents (Scribe / Sourcing Scout / Concierge) inherit its Bullhorn pattern; ready Week 5 per master brief §8.2 line 602.
docs/decisions/sequencing-target.md:123:| 2. Substrate exercise | **Medium-High** | Exercises Bullhorn W (smaller surface than Janitor's R+W). First agent with external webhook trigger (Fathom / Fireflies). First exercise of voice-loader for **tacit-note tone-detection** per Ultraplan §8.1 line 523. Reuses Janitor's Bullhorn auth refresh-loop |
docs/decisions/sequencing-target.md:124:| 3. Risk de-risking | **Medium** | Reuses Janitor's Bullhorn auth path (doesn't re-derisk Risk #2). Surfaces new failure mode: **webhook-arrival-to-Bullhorn-write SLA** (5-min target per Ultraplan §8.1 line 521). Doesn't directly touch Risk #5 (renderer already proven by Diagnostic) or Risk #1 (still Tier 2) |
docs/decisions/sequencing-target.md:126:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Concierge consumes Scribe-generated Notes for context per `bullhorn-integration-path.md` §4.1 row 4 ("Note (prior-comms history)"). Scribe must ship before Concierge | Medium-High criticality |
docs/decisions/sequencing-target.md:127:| 6. Tenant-onboarding readiness | **Medium** | Needs Fathom or Fireflies OAuth + Bullhorn (already onboarded if Janitor shipped). Tacit-note taxonomy needs per-firm calibration in first 30 days of production per Ultraplan §8.1 line 527 |
docs/decisions/sequencing-target.md:129:**Readiness summary:** Scribe — webhook-driven, reuses Janitor's Bullhorn auth path, first voice-loader-for-tacit-note exercise, second-most-demoable per master brief §8.2 line 603; ready Week 6 per master brief §8.2 line 603 / Ultraplan §9 line 760.
docs/decisions/sequencing-target.md:144:**Readiness summary:** Cash Conductor — first Tier-1 always-on agent (Risk #1 first exercise: cortextOS Primitives 1+4+5); Hire-#1-anchored W7-8 per Ultraplan §9 line 766; independent of Bullhorn (no shared substrate with Janitor/Scribe path); ready Weeks 7-8 per master brief §8.2 line 604.
docs/decisions/sequencing-target.md:151:| 2. Substrate exercise | **Medium** | Reuses Bullhorn R from Janitor (no new Bullhorn substrate). New MCP integrations: LinkedIn via Proxycurl (rate-limited per Ultraplan §10 row #6), Reed, CV-Library. Source-abstraction layer per Ultraplan §8.1 line 555 designed to be reusable by Night Sourcer v1.1 |
docs/decisions/sequencing-target.md:152:| 3. Risk de-risking | **Medium** | **First exercise of LinkedIn rate-limit budget** per Ultraplan §10 Risk #6 ("LinkedIn rate limits via Proxycurl are tighter than expected"). Reuses Bullhorn auth from Janitor (doesn't re-derisk Risk #2). Tier 2 so doesn't touch Risk #1 primitives |
docs/decisions/sequencing-target.md:153:| 4. Commercial value | **Medium** | Per Product Spec §2.2 R5: "Shortlist in 15 minutes instead of by end of week." Less commercially load-bearing than Janitor/Scribe/Concierge — request-response not always-on, so less of a closing-demo asset. Sales narrative is "cuts intake-call-to-first-shortlist time from same-week to same-hour" |
docs/decisions/sequencing-target.md:154:| 5. Dependencies | **Upstream:** Janitor's Bullhorn auth pattern. **Downstream:** Night Sourcer (v1.1) reuses Sourcing Scout's multi-source layer per Ultraplan §8.1 line 555 ("Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it") | Medium criticality (v1.1 downstream) |
docs/decisions/sequencing-target.md:155:| 6. Tenant-onboarding readiness | **Medium** | Needs Bullhorn (already on if Janitor shipped) + LinkedIn (Proxycurl API key — single application-level key, not per-tenant) + Reed OAuth + CV-Library OAuth per tenant |
docs/decisions/sequencing-target.md:157:**Readiness summary:** Sourcing Scout — multi-source request-response agent; reuses Janitor's Bullhorn auth; first LinkedIn rate-limit exercise (Risk #6 surfacing); designed for Night Sourcer v1.1 reuse; ready Week 9 per master brief §8.2 line 605.
docs/decisions/sequencing-target.md:167:| 5. Dependencies | **Upstream:** Janitor (Bullhorn auth pattern), Scribe (Notes for context). **Downstream:** Triage (v1.1) hands off candidates to Concierge per master brief §8.2 line 606 + Ultraplan §8.2 line 578. Concierge MUST ship after Janitor + Scribe | Highest cross-agent dependency |
docs/decisions/sequencing-target.md:170:**Readiness summary:** Concierge — biggest v1.0 build (XL/4 weeks), flagship closing demo per master brief §8.2 line 606; first Primitive-2 exercise (71h context rotation); depends on Janitor + Scribe for Bullhorn auth + voice substrate already in place; ready Weeks 10-13 per master brief §8.2 line 606 / Ultraplan §9 line 774.
docs/decisions/sequencing-target.md:182:W5:   Janitor (A2)
docs/decisions/sequencing-target.md:189:**Why this ordering:** Diagnostic-first de-risks the substrate end-to-end (renderer + `_shared/` + decision_log) before any production-critical agent. Janitor second exercises Bullhorn auth (Risk #2) and establishes the auth-refresh-loop pattern that three downstream agents inherit. Scribe third reuses Janitor's Bullhorn path and adds voice-loader-for-tacit-notes — the voice substrate every later agent depends on. Cash Conductor at W7-8 is independent of the Bullhorn track (Xero/QuickBooks/Sage + Open Banking) AND first-exercises cortextOS Tier-1 Primitives 1+4+5 (Risk #1) — both make it Hire-#1-appropriate first work per Ultraplan §9 line 766. Sourcing Scout at W9 extends the multi-source pattern (LinkedIn rate-limit derisk per Risk #6). Concierge at W10-13 lands last with all dependencies (Bullhorn auth from Janitor; voice substrate from Scribe; Primitive 1 derisk from Cash Conductor; Primitive 2 first exercise its own).
docs/decisions/sequencing-target.md:193:- W5: Risk #2 (Bullhorn auth) — Janitor first writes. Reduction trigger 2 fires (Medium → Low per `bullhorn-integration-path.md` §6.7).
docs/decisions/sequencing-target.md:209:W9:   Janitor (A2)
docs/decisions/sequencing-target.md:219:1. **Concierge depends on Janitor** (Bullhorn auth pattern) and **Scribe** (voice substrate, Notes-for-context) per §2.6 row 5. Building Concierge at W5-8 before either dependency forces Janitor + Scribe primitives to be built inline within Concierge's bundle — XL build becomes 2XL.
docs/decisions/sequencing-target.md:229:W5:   Janitor (A2) — Risk #2 derisk
docs/decisions/sequencing-target.md:241:2. **Concierge XL = 4 weeks** per Ultraplan §8.1 line 568. W6-9 is 4 weeks, but with W6 partially overlapping Janitor's W5 finish — realistic Concierge ship is W7-W10, conflicting with Cash Conductor's W11 slot AND with the Hire #1 W7 anchor.
docs/decisions/sequencing-target.md:252:| 1. Implementation simplicity (smallest first) | **Wins** — Diagnostic (M) → Janitor (L) → Scribe (M) → Cash Conductor (L) → Sourcing Scout (L) → Concierge (XL): monotonically ascending until W10-13 | Loses — Concierge (XL) at W5-8 is largest agent second | Loses — Concierge (XL) at W6-9 likewise |
docs/decisions/sequencing-target.md:254:| 3. Risk de-risking | **Wins** — Risk #5 W4 (Diagnostic), Risk #2 W5 (Janitor), Risk #1 W7-8 (Cash Conductor) — three reduction triggers fire sequentially without coupling | Loses — Risk #1 pushed to W12-13 | Tied — Risk #1 W6-9 (Concierge), but coupled with Bullhorn substrate gaps |
docs/decisions/sequencing-target.md:256:| 5. Dependencies on other agents | **Wins** — Janitor's Bullhorn auth → Scribe reuses → Sourcing Scout reuses → Concierge reuses, all in dependency order | Loses — Concierge before Janitor + Scribe breaks the upstream chain | Loses — Concierge before Scribe breaks the upstream chain |
docs/decisions/sequencing-target.md:257:| 6. Tenant-onboarding readiness | **Wins** — Diagnostic deployable immediately (no Bullhorn); Janitor first-pilot wizard Day 2 enables Bullhorn track; Concierge last when all per-tenant config (voice corpus, nurture cadence) ready | Loses — Concierge tenant-onboarding hardest agent, demanded at W5-8 before pilot ready | Loses — Concierge tenant-onboarding demanded at W6-9 before pilot ready |
docs/decisions/sequencing-target.md:266:| **Risk #2 materialises** → defer Janitor + Scribe to W7-8, push Concierge to v1.1 | **Coherent.** Diagnostic W3-4 stands; Janitor + Scribe slip W7-8; Cash Conductor takes the W5-6 slot; Sourcing Scout at W9; Concierge cut. Hire #1 onboards onto Janitor instead of Cash Conductor — same scope-of-difficulty | Incoherent. Concierge already at W5-8 — can't be cut without 4 weeks of wasted XL build. Risk #2 contingency activation forces Concierge rewrite | Incoherent. Concierge at W6-9 — same wasted-build problem |
docs/decisions/sequencing-target.md:282:| 2 | W5 | **Janitor** (A2) | First Bullhorn auth + downstream-pattern-setter (Scribe, Sourcing Scout, Concierge inherit) |
docs/decisions/sequencing-target.md:292:Per §3.4 comparison table: Alpha wins 6/6 criteria (5 outright + 1 tied). Per §3.5 contingency-coherence: Alpha is the only sequence that survives **both documented contingency paths** from §1.4 cleanly — Risk #2 materialises (defer Janitor + Scribe to W7-8, push Concierge to v1.1) and Risk #4 materialises (drop Concierge + Sourcing Scout, founder solo). Options Beta and Gamma each force a Concierge rewrite if their respective trigger fires per §3.5.
docs/decisions/sequencing-target.md:303:- **Activation:** scope-cut contingency per §1.4 — defer Janitor + Scribe to W7-8 (slip Bullhorn-dependent agents by 2 weeks), push Concierge to v1.1 (cut from v1.0 entirely).
docs/decisions/sequencing-target.md:305:- **Cascade:** v1.0 ships as 4 agents (Diagnostic W3-4 + Janitor W7-8 + Scribe W7-8 + Cash Conductor W9-10) under this contingency. Sourcing Scout becomes the W11-12 closer; Concierge is v1.1.
docs/decisions/sequencing-target.md:312:- **Cascade:** v1.0 ships as Diagnostic + Janitor + Scribe + Cash Conductor only. Cash Conductor's three-accounting-API integration becomes founder solo work — likely extends to W8-9 instead of W7-8.
docs/decisions/sequencing-target.md:327:- Janitor-before-Scribe-before-Concierge dependency chain (Bullhorn auth + voice substrate must land in that order).
docs/decisions/sequencing-target.md:359:| **Diagnostic → Janitor** | **3 production-tenant runs across 3 different prospects** (per Ultraplan §8.1 line 499 Gate B target context — though that target is 30% discovery-call conversion, not run count) | Renderer + `_shared/voice-loader.sh` + `_shared/hook-helpers.sh` + decision_log all exercised end-to-end. No orchestration / inter-agent handoff (Diagnostic is standalone). `.rendered-by-ifos-renderer` marker present on all 3 rendered Diagnostic dirs |
docs/decisions/sequencing-target.md:360:| **Janitor → Scribe** | **5 nightly-sweep cycles across 2+ tenants** (one tenant week-1 + one tenant week-2 + 3 sweep nights minimum) | Bullhorn auth refresh-loop tested across at least 3 access-token-TTL boundaries (i.e. 30+ minutes of operation per cycle); rate-limit budget verified ≤ §4.4-allocation from `bullhorn-integration-path.md`; `ESC_BULLHORN_AUTH` never fires; day-30 before/after report template renders per Product Spec §2.2 R9 |
docs/decisions/sequencing-target.md:408:First exercise is Janitor at W5 per §4.1 row 2. **If Day 2 Sub-decisions A and B haven't flipped from Proposed to Accepted by start of W4** (per `bullhorn-integration-path.md` §1.3 commercial-blocker table), this is the natural blocker. Founder Sunday/Monday commercial conversations must land before W4 start to keep the Janitor W5 slot intact. Sub-decision C is already Accepted so the endpoint surface is buildable; the gate is auth path (A) and client_credentials foreclosure (B).
docs/decisions/sequencing-target.md:439:- **Janitor's first Bullhorn auth refresh fails by W5** (Risk #2 unmitigated; commercial path broken)
docs/decisions/sequencing-target.md:490:| Sequencing target | §4.1 | Master brief §8.2 sequence ratified verbatim: Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13 |
docs/decisions/v1.0-kill-criterion.md:73:### Trigger 3 — JANITOR-BULLHORN-AUTH-W5 (PIVOT)
docs/decisions/v1.0-kill-criterion.md:75:**Threshold:** Janitor agent cannot authenticate to Bullhorn via the documented OAuth flow (per `bullhorn-integration-path.md` §4.5 refresh-loop architecture) by end of Week 5 (2026-06-28). Authentication failure modes that trigger: (a) OAuth token endpoint returns non-2xx persistently; (b) refresh-loop architecture fails at 10-minute TTL boundary; (c) Bullhorn rate-limits IFOS's auth endpoint preventing pilot operations; (d) Bullhorn partnership programme requirement blocks production-tenant access.
docs/decisions/v1.0-kill-criterion.md:85:- **Option C:** ATS-agnostic with manual data sync. Reduces v1.0 to read-only agent operation against ATS export files; loses much of the Janitor + Concierge value but unblocks pilot acquisition.
docs/decisions/v1.0-kill-criterion.md:93:**Threshold:** Two instances of "scope cut" activations during v1.0 build. A scope cut is defined as **any founder-approved reduction from the ratified 6-agent v1.0 fleet** (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge per master brief §8.2). Examples that count as one activation: 6→5, 6→4, 6→3. The Risk #4 contingency (6→4 for solo-founder mitigation) counts as one activation; any *further* reduction triggers PAUSE.
docs/decisions/v1.0-kill-criterion.md:334:- The agent fleet of 6 named in master brief §8.2 (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge)
docs/decisions/v1.0-kill-criterion.md:375:**For Week 3-13 (v1.0 build).** Every agent build references this kill criterion. Diagnostic (W3-4) faces Trigger 2; Janitor (W5) faces Trigger 3; all agents from W3 onward face Triggers 5, 6, 9. The kill criterion is the operational definition of "are we still on-track" at each weekly review.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:55:- **Build decision: YES.** Bullhorn-first per master brief §8.2 + `docs/decisions/sequencing-target.md` §4.1 (Diagnostic W3-4 → Janitor W5 → Scribe W6 → Cash Conductor W7-8 → Sourcing Scout W9 → Concierge W10-13). Sub-decision C of `bullhorn-integration-path.md` (v1.0 endpoint surface, 4 agents, pull-only, refresh-loop architecture for 10-min token TTL) Accepted Day 2.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:103:- **Week 1 named agent-build slices DO NOT BEGIN.** Diagnostic W3-4, Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13 — all blocked.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:122:2. **All named v1.0 agent builds** (Janitor W5, Scribe W6, Cash Conductor W7-8, Sourcing Scout W9, Concierge W10-13) — same dependency chain.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:143:- Q1 = YES, Q3 = NO (accepted) → Week 0 closes by founder discretion; Week 1 starts with Risk #2 elevated; Diagnostic W3-4 begins under accepted risk; Janitor W5 contingent on Q3 clearing by then.
docs/decisions/ADR-003-agent-bundle-renderer.md:101:> git checkout -b agent/{name}                       # e.g. agent/janitor
docs/decisions/bullhorn-integration-path.md:23:**Sub-decision C — v1.0 endpoint surface.** Which Bullhorn endpoints each of the v1.0 agents (Janitor, Scribe, Sourcing Scout, Concierge — see §1.2) reads and writes, the cadence (real-time webhook vs scheduled poll vs ad-hoc request-response), and the rate-limit budget allocation. Ultraplan §8.1 specifies per-agent Bullhorn touches at lines 510 (Janitor: read-write), 522 (Scribe: write), 551 (Sourcing Scout: read for ATS passive matches), 564 (Concierge: read for state, write for activity log) — Sub-decision C consolidates these into one per-agent endpoint table and decides webhook-vs-poll per integration point.
docs/decisions/bullhorn-integration-path.md:34:| A2 Janitor | **Yes — read + write** (nightly cleanup sweep) | Master brief §8.2 line 602; Ultraplan §8.1 A2 line 507-510 |
docs/decisions/bullhorn-integration-path.md:40:**Four of six v1.0 agents directly touch Bullhorn.** The two that don't (Diagnostic, Cash Conductor) have independent paths. So Bullhorn integration timing gates ~67% of the v1.0 agent build. Per Ultraplan §10 row #2 contingency wording: "defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1" — that is the documented v1.0-scope cut if Bullhorn slips.
docs/decisions/bullhorn-integration-path.md:62:- **What ATS the first design partner uses.** If the first signed pilot is on Vincere or Voyager Infinity instead of Bullhorn, Sub-decision C's endpoint surface (and the Janitor / Concierge build order) needs revisiting per master brief §6 Day 2 Sub-decision and Ultraplan §9.1 sequencing.
docs/decisions/bullhorn-integration-path.md:95:**Status: Sub-decisions A+B can remain Proposed without blocking Week-1 PREREQ CODE** (renderer, `_shared/` helpers, schema, voice-loader — none of which reference Bullhorn). A+B MUST flip to Accepted before Janitor (W5) build starts per `v1.0-kill-criterion.md` §2 Trigger 3 (JANITOR-BULLHORN-AUTH-W5). A+B are NOT a Week-1 prereq gate; they ARE a W5 agent-build gate. Any Bullhorn connector/auth scaffold is blocked until Sub-decisions A+B are Accepted or explicitly scoped as non-auth test harness work.
docs/decisions/bullhorn-integration-path.md:105:| Janitor W5 build | A+B Accepted (commercial conversations complete) | Pending |
docs/decisions/bullhorn-integration-path.md:184:2. **Direct API access is technically sufficient for v1.0.** The public REST API documentation surveyed (Sections 2.1 and 2.2) names no entity-level scope gating for marketplace-tier vs direct-tier. The endpoint surface required by the four Bullhorn-touching v1.0 agents (Janitor R+W, Scribe W, Sourcing Scout R, Concierge R+W per §1.2) is fully addressable via documented direct-API REST endpoints — barring a commercially-gated discovery in §1.3 conversation that contradicts this.
docs/decisions/bullhorn-integration-path.md:194:| First design partner uses non-Bullhorn ATS — Vincere, Voyager Infinity, RecruiterPM, etc. (founder conversation 2 answer) | Bullhorn-first reframed as "Bullhorn second-tenant ATS"; this document's Sub-decisions A and C scope to the non-first-pilot timeline. v1.0 ATS anchor becomes the design partner's actual ATS; Janitor / Scribe / Concierge build order revisits in master brief §6 Day 3 sequencing decision. |
docs/decisions/bullhorn-integration-path.md:285:| **A2 Janitor** (R+W; master brief §8.2 line 602; Ultraplan §8.1 line 510) | Candidate (full sweep; identify stale, dup, incomplete-RTW); ClientCorporation (orphan-link sweep); JobOrder (status drift); Note (orphan / stale-tag sweep) | Note (cleanup metadata tags written back); Candidate field updates (status normalisation, dedup-merge proposals — human-approved per Ultraplan §8.1 line 514 gotcha); ClientCorporation field normalisation | **Cold/batch.** Nightly cron 02:00 tenant-local time per Ultraplan §8.1 A2 line 506; initial day-1 full sweep is the "wedge" demo per Product Spec §2.2 R9 | Event-driven within-sweep (per-record decisions); no real-time externalevent writes outside the sweep window | Dedup confidence ≥ 0.85 enforced per Ultraplan §8.1 line 511 Gate A; rate-limit 429 → `wait 1s then retry` per §2.2; `ESC_DUPLICATE_DETECTED` per master brief §8.1 Change 3 line 588 on human-review-required cases; `ESC_BULLHORN_AUTH` on token failures | Strict per-tenant: one tenant's Bullhorn corpToken per sweep run; never cross-tenant. Sweep parallelisable across tenants but each thread holds its own auth state |
docs/decisions/bullhorn-integration-path.md:292:**Spec gap §4.1-A:** master brief §8.2 does not enumerate Bullhorn entity types per agent — the master-brief column "Key dependency" names "Bullhorn MCP (R+W)" without specifying which entities. This table is the proposed default; verify against actual Bullhorn data shapes during the Week 3-4 Janitor build and revise if needed.
docs/decisions/bullhorn-integration-path.md:306:| Janitor Candidate sweep | Polling (full-table scan per sweep) | Nightly 02:00 | Initial sweep is bounded by per-tenant Candidate count; subsequent sweeps use `dateLastModified` filter to limit to changes-since-last-sweep |
docs/decisions/bullhorn-integration-path.md:307:| Janitor Note / ClientCorporation / JobOrder sweep | Polling | Nightly 02:00 | Same `dateLastModified` filter pattern |
docs/decisions/bullhorn-integration-path.md:334:| Janitor (nightly sweep) | 200-400 during active sweep window (concentrated 1-2 hour burst) | Burst-tolerant; bounded by tenant Candidate-count and `dateLastModified` filter efficiency |
docs/decisions/bullhorn-integration-path.md:394:Per §4 fully-technical analysis. Four Bullhorn-touching agents (Janitor, Scribe, Sourcing Scout, Concierge) with named entity reads/writes, cadences, error handling, per-tenant scoping. Polling-primary at v1.0 (Bullhorn public REST API is pull-only per §4.2; webhook upgrade is a v1.1+ marketplace-tier verification). Conservative rate-limit budget per §4.4 (revise when Bullhorn confirms actuals). Refresh-loop architecture per §4.5.
docs/decisions/bullhorn-integration-path.md:460:**Reduction trigger 2 (Medium → Low):** first Bullhorn write lands cleanly in Week 3-4 Janitor agent build (the master brief §12 / Ultraplan §10 row #2 tripwire test "core read endpoints working" passes).
docs/decisions/bullhorn-integration-path.md:513:| §4.1 entity types per agent (proposed default; master brief §8.2 silent on entity granularity) | Week 3-4 Janitor build reveals different — revise table |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:130:| ADR-007-Q1 | Should the 90% threshold be per-tenant configurable, or is 90% a v1.0 fixed bar? | Recommend fixed at v1.0; v1.1 add per-tenant override via `tenant_adapters.config.concierge_sla_threshold` (new key, v0.4-pending). |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:20:| 5 | Janitor (Bullhorn R+W) |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:43:| W5 Day 28+: Janitor build start | W5 Day 28+: **Conditional on Bullhorn Sub-decisions A+B Accepted** |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:52:6. **Documented contingency.** This is the milder version of ULTRAPLAN §10 Risk #2 row contingency: *"defer Janitor & Scribe to weeks 7-8, push Concierge to v1.1."* We're deferring only the Bullhorn-touching agents pending Bullhorn answer; Diagnostic stays on track.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:63:### Week 5 (Day 28+) — Janitor build conditional gating
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:65:| Bullhorn A+B state by Day 28 | Janitor action |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:67:| Both Accepted | Janitor build proceeds as ULTRAPLAN §8.2 specifies |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:68:| Either still Proposed | Janitor build deferred 1 week; Diagnostic polish + LinkedIn (Proxycurl) signed-up + W6 work pulled forward |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:69:| Bullhorn unresponsive past 2026-06-10 | Force Direct-API fallback per `bullhorn-integration-path.md` §1.4; Janitor scaffold begins; Bullhorn auth gated on first pilot raising support ticket |
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:73:- Scribe (W6) depends on Bullhorn write; same gating as Janitor
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:78:**Net effect of worst case (Bullhorn never responds + Direct-API forced):** Janitor + Scribe + Sourcing Scout + Concierge all slip ~1 week each; Cash Conductor (W7-8) unaffected; v1.0 ships in W14 instead of W13. Master brief §8.2 line 604 acknowledges this contingency.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:99:> "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` — per DATA-LAYER.md §2.2"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:103:> "Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per `docs/architecture/second-brain-design.md` §2.4.2)."
docs/runbooks/day-4-provisioning.md:60:**Master brief asserts (§6 Day 4 line 478):** "Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`"
docs/runbooks/day-4-provisioning.md:62:**ADR-002 Edit 3 + current-priorities.md (Open) state the corrected table list:** `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:783:-- tenant_adapters (per master brief §6 Day 4 line 478; tracks per-tenant adapter binding)
docs/runbooks/day-4-provisioning.md:784:CREATE TABLE tenant_adapters (
docs/runbooks/day-4-provisioning.md:795:GRANT SELECT, INSERT, UPDATE, DELETE ON tenant_adapters TO ifos_app;
docs/runbooks/day-4-provisioning.md:796:GRANT USAGE, SELECT ON SEQUENCE tenant_adapters_id_seq TO ifos_app;
docs/runbooks/day-4-provisioning.md:801:# Expected: six tables listed (tenants, entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters)
docs/runbooks/day-4-provisioning.md:908:\d tenant_adapters
docs/runbooks/day-4-provisioning.md:936:ALTER TABLE tenant_adapters ENABLE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:943:ALTER TABLE tenant_adapters FORCE ROW LEVEL SECURITY;
docs/runbooks/day-4-provisioning.md:971:CREATE POLICY tenant_isolation ON tenant_adapters
docs/runbooks/day-4-provisioning.md:1127:- [ ] §6.3 — Six tables exist: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`
docs/runbooks/day-4-provisioning.md:1248:17. **§7 — RLS isolation gate passed clean (5 of 5).** No-context = 0 ✓, own-tenant insert+select = 1 ✓, cross-tenant = 0 ✓, WITH CHECK adversarial INSERT rejected ✓, own-tenant unaffected = 1 ✓. RLS + FORCE on entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters (5 tables). `tenant_isolation` policy on all 5 with USING + WITH CHECK on `current_setting('app.current_tenant', true)`. Test ran as `ifos_app` over TCP+scram-sha-256 (NOT as postgres superuser, which would bypass RLS). Test data ROLLBACK'd; 2 seeded test tenants cleaned up.
docs/decisions/2026-05-31-d1-founder-decision.md:53:5. **Tenant config — schema-work pending.** The natural storage location for the per-tenant operator Telegram chat-id is `tenant_adapters.config`, BUT the v0.3 supplement's `validate_tenant_adapters_config_v0_3` trigger hard-fails on unknown keys per Rule 2 — and `operator_telegram_chat_id` is NOT currently in the 6-key allowlist (`cash_conductor_last_run`, `concierge_last_poll`, `concierge_send_window`, `janitor_dedup_threshold`, the 2026-05-31 Janitor key, `blocked_recipients`). Resolution path: **W10-13 Concierge build slice lands a v0.4 supplement** adding `operator_telegram_chat_id` to the allowlist (type: string; required: false; set_by: tenant-admin; read_by: concierge + cash-conductor for the autosend-bridge consumer). Until then, the bridge consumer (`@ifos/autosend-bridge-telegram`) takes the chat-id as a function argument rather than reading it from tenant_adapters — the function-arg shim is already in place per the package scaffold landed 2026-06-01 (commit `9b282d8`). This decision-doc does NOT block on the schema work; D1-B's APPROVAL is structural (Telegram vs cortextOS approval system vs no-autosend); the storage-location detail is a W10-13 implementation question.
docs/decisions/2026-05-31-d1-founder-decision.md:66:- **No schema impact.** D1-B reuses `tenant_adapters.config` for the operator chat ID; no v0.4 supplement work added by this decision.
docs/runbooks/tenant-lifecycle.md:250:  DELETE FROM tenant_adapters   WHERE tenant_slug='<slug>';
docs/runbooks/pii-purge-operational-pattern.md:33:Per-tenant override via `tenant_adapters.config.pii_retention_days` — range [30, 365]. Allows enterprise tenants to extend retention via TOS amendment + advisor signoff.
docs/runbooks/pii-purge-operational-pattern.md:134:Per-tenant override via `tenant_adapters.config.pii_retention_days`:
docs/runbooks/pii-purge-operational-pattern.md:137:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/runbooks/pii-purge-operational-pattern.md:198:| P2 | tenant_adapters override read not yet implemented in script (uses single --retention-days CLI arg) | First tenant requests extended retention |
docs/build-brief/00-MASTER-BRIEF.md:348:1. **Ingest (`kb-add`).** An agent (Scribe, Triage, Janitor, etc.) drops a raw artefact into `raw/{category}/`. Ingest writes the file with provenance frontmatter (`source: scribe-agent`, `ingested_at: ...`, `tenant_id: ...`).
docs/build-brief/00-MASTER-BRIEF.md:358:   provenance: [scribe-agent:call-2026-05-16-1432, janitor:bullhorn-2026-05-15]
docs/build-brief/00-MASTER-BRIEF.md:470:- [ ] Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per ADR-002 Edit 3 + `docs/architecture/second-brain-design.md` §2.4.2).
docs/build-brief/00-MASTER-BRIEF.md:596:| 2 | Janitor | 5 | Bullhorn MCP (R+W) | First demoable inside-ATS result; day-30 before/after closes deals |
docs/build-brief/00-MASTER-BRIEF.md:604:**Do not build out of order.** Diagnostic before Janitor (no Bullhorn dependency). Janitor before Scribe (batch easier than webhook-driven). Cash Conductor at week 7–8 because Hire #1 is assumed to start week 7 (verify, don't assume).
docs/build-brief/00-MASTER-BRIEF.md:611:git checkout -b agent/{name}                       # e.g. agent/janitor
docs/build-brief/00-MASTER-BRIEF.md:663:        │ (raw + compiled)│                  │ RLS-isolated           │                  │ tenant_adapters    │
docs/build-brief/00-MASTER-BRIEF.md:679:        │   v1.0 (6):  Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge              │
docs/build-brief/00-MASTER-BRIEF.md:844:| 2 | Bullhorn MCP build takes longer than 1 week | End of week 3 status not "core read endpoints working" | Pre-emptive: Week 0 day 2 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/specs/ULTRAPLAN.md:44:Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.
docs/specs/ULTRAPLAN.md:184:- `ESC_DUPLICATE_DETECTED` — Janitor found a high-confidence dedup candidate requiring human review
docs/specs/ULTRAPLAN.md:239:- Scheduled agents (Janitor, Reporting, Spec Pitcher) run as cron jobs *also* under the tenant's OS user.
docs/specs/ULTRAPLAN.md:423:| Janitor | 30-day before/after report shows ≥15% dedup, ≥10% field-completeness improvement | The day-30 report IS the Gate B measurement |
docs/specs/ULTRAPLAN.md:501:#### A2. The Janitor — the wedge agent
docs/specs/ULTRAPLAN.md:686:| Janitor | | ✓ | | | | ✓ | | | | | |
docs/specs/ULTRAPLAN.md:757:### Weeks 5–6 — Janitor + Scribe
docs/specs/ULTRAPLAN.md:759:- Week 5: Janitor agent; day-30 before/after report template; CI fixtures
docs/specs/ULTRAPLAN.md:762:Milestone: Janitor produces an audit report against a real Bullhorn (the first pilot's, ideally). Scribe processes 10 real calls.
docs/specs/ULTRAPLAN.md:799:4. Janitor's Workflow F (the day-30 before/after report) — can be manually compiled for the first tenant
docs/specs/ULTRAPLAN.md:818:| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Pre-emptive: spend week 0 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
docs/specs/ULTRAPLAN.md:824:| 8 | First pilot's Bullhorn data is too messy for Janitor's dedup confidence threshold | Medium | Medium | <5% dedup proposed in week 6 trial run | Lower threshold to 0.7 for the initial cleanup; ship the day-30 report regardless |
docs/specs/ULTRAPLAN.md:829:| 13 | The Bullhorn API rate limits prevent Janitor from completing its initial sweep on day 1 | Medium | Medium | First sweep takes >24 hours | Initial sweep runs in batches over 3 days; communicate to tenant explicitly |
docs/specs/_archive-build-handoff.md:253:Confirm or revise Ultraplan §9's assumption: **close the first three pilots fastest**. That means Janitor and Cash Conductor close demos before Triage absorbs the development heat. Revise only if a hire's signed or a different pilot dynamic emerges.
docs/specs/_archive-build-handoff.md:328:git checkout -b agent/bullhorn-mcp        # or agent/janitor, agent/scribe, etc.
docs/specs/_archive-build-handoff.md:331:mkdir -p agents/janitor/tests/fixtures/{01-primary,02-edge-case-merged-duplicates,99-voice-drift-canary}
docs/specs/_archive-build-handoff.md:378:| 2 | **Janitor** | 5 | Bullhorn MCP (read + write) | First demoable inside-the-ATS result; day-30 before/after report closes deals |
docs/specs/_archive-build-handoff.md:386:**Do not build out of order.** The Ultraplan §9 sequence is deliberate: Diagnostic before Janitor because Diagnostic needs no Bullhorn, and Bullhorn is the critical path. Janitor before Scribe because Janitor is a one-shot batch (easier first agent) and Scribe is webhook-driven (harder runtime integration). Cash Conductor in week 7–8 because Hire #1 is assumed to start week 7 (per user memory — verify, don't assume).
docs/specs/PRODUCT-SPEC.md:137:#### R9. The Janitor — the database becomes an asset
docs/specs/PRODUCT-SPEC.md:242:| **Solo** (1–4 fee earners) | £499 | Janitor + 1 always-on agent (drafts-only) + Scribe | "Pay back the year inside one extra placement. Save 10+ hours/week of inbox and admin drag." |
docs/specs/PRODUCT-SPEC.md:243:| **Boutique** (5–10 fee earners) | £1,495 | Janitor, Scribe, Triage (auto-send), Concierge, Sourcing Scout (daytime), Cash Conductor, Client Hunter (digest) | "2–4 additional placements/year from never-lost candidates. £40k–£80k of working capital unlocked via faster cash. 20+ hours/week of operational time back." |
docs/specs/PRODUCT-SPEC.md:279:        │   The Scribe captures    │    │  The Janitor keeps it    │
docs/specs/PRODUCT-SPEC.md:344:- Janitor runs against the ATS — produces the day-1 cleanup report.
docs/specs/PRODUCT-SPEC.md:430:**1. Every agent now has a quantified revenue story, not just a time-saved story.** The internal business plan and the 24/7 directive had revenue stories for some agents (Cash Conductor, Client Hunter, T5) but not all. Triage was pitched on responsiveness; here it's pitched on "2–4 additional placements/year per consultant from never-lost candidates". Janitor was pitched on database hygiene; here it's pitched on "one reactivated dormant-but-clean candidate per month covers the tier price".
docs/specs/PRODUCT-SPEC.md:458:- **No free pilots beyond the structured 14-day Janitor cleanup trial.** Free pilots train customers to expect free.
docs/specs/PRODUCT-SPEC.md:472:- The Janitor (the wedge agent; lowest risk, highest visible value)
docs/specs/PRODUCT-SPEC.md:530:9. **The Janitor** — "Your sourcing runs become 3× more productive against clean data."

codex
The central inconsistency is now clear: the implementation surface explicitly says a v0.4 schema supplement is required for `operator_telegram_chat_id`, while Consequences says there is no schema impact. I’m doing one more pass for any independent blockers so the rejection is complete but not padded.
exec
/bin/zsh -lc "nl -ba docs/decisions/2026-05-31-d1-founder-decision.md | sed -n '1,120p'" in /Users/madsadmin/code/CortexOS
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
    59	This decision doc ratifies via `.codex/ratification/review-architecture-decision.md` skill. Will be added to the next `--cluster F` (or future cluster) ratification run.
    60	
    61	## Consequences
    62	
    63	- **Concierge §9 Q1 RESOLVED** — strike from "open questions" list at next agent.md touch.
    64	- **Cash Conductor §8 D1-pending fallback** — flips from "drafts-only if unresolved" to "orange-tier `xero_reminder_send_customer` writes are live once Concierge W10 ships the `autosend-bridge-telegram` package."
    65	- **Concierge ratification §10** — `Founder Decision D1 RESOLVED` blocker now satisfied. Remaining Concierge Proposed → Accepted blockers per §10: Codex Round 4 Phase 2 (DONE), ADR-007 Accepted (PENDING founder Accept), founder approves §9 Q2-Q6 (PENDING).
    66	- **No schema impact.** D1-B reuses `tenant_adapters.config` for the operator chat ID; no v0.4 supplement work added by this decision.
    67	- **No additional API keys/signups for the founder vault.** Day-4 provisioning (`docs/runbooks/day-4-provisioning.md` §6.5) creates the `_secrets.env` SKELETON only (touched empty at mode 0600); the Telegram bot token is populated by founder bootstrap (NOT covered by Day-4 — see incident response below), and the per-tenant operator chat-id is populated by tenant onboarding (W10-13 build slice; see implementation surface item 5 above). Once both are in place, no recurring credentials work — the bot token doesn't rotate per send; the chat-id is per-tenant-stable.
    68	
    69	---
    70	
    71	*End of D1 decision doc.*
    72	
    73	---
    74	
    75	**Status update:** Accepted on 2026-05-31 by founder-delegated arbitration (D1-B over D1-A and D1-C); package scaffold `@ifos/autosend-bridge-telegram` landed 2026-06-01 (commit `9b282d8`); consumer wiring landed on both Cash Conductor (commit `076e231`) and Concierge (commit `669a4f4` + `9ec2bd6`); awaiting Codex ratification via `.codex/ratification/review-architecture-decision.md` skill (cluster G).

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '755,855p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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
   836	      Postgres, NOT vault markdown. Pre-v0.3 origin (the migration validator
   837	      `v0.2-to-v0.3.sql §5 allowlist` has accepted this key since v0.1); the
   838	      schema declaration in v0.3 supplement is added Day-20 W4 bilateral pass
   839	      closing Sourcing Scout R8 Codex Finding 1 (the key was load-bearing
   840	      across 4 agents but undeclared in any YAML).
   841	
   842	  janitor_last_run:
   843	    type: timestamp
   844	    required: false
   845	    set_by: janitor
   846	    read_by: [janitor]
   847	    notes: |
   848	      Janitor nightly cron updates at session-close (Step 12). Next run queries
   849	      Bullhorn for entities created/modified since this timestamp. The migration
   850	      validator (v0.2-to-v0.3.sql §5 allowlist) already accepts this key; this
   851	      declaration is the canonical schema authority added in W4 bilateral pass
   852	      (Day-20) closing Janitor R11 Codex Finding 4.
   853	
   854	  # diagnostic_per_claim_sample_rate DEFERRED to future W4-polish ADR
   855	  # (per ADR-006 Tier 2 + §5 deferred_to_future_adr). v0.3 does not

exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/fixtures/01-primary.yaml | sed -n '1,70p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Cash Conductor fixture — 01-primary (happy path)
     2	#
     3	# Tests the canonical flow per agent.md §3 + §4:
     4	#   Open Banking transaction → exact-amount + invoice-reference match
     5	#   (Stage 1 confidence 0.98) → auto reconciliation write (yellow tier
     6	#   accounting_reconciliation_write) → chase generation pass identifies
     7	#   one overdue invoice at position 1 → chase draft generated + queued
     8	#   to Concierge approval bridge (if autosend-bridge-telegram present)
     9	#   OR drafts-only mode (if bridge absent — per D1-B agent.md §1 caveat).
    10	#
    11	# Per agent.md §5 Gate A: all G1-G7 checks pass on the generated chase draft.
    12	#
    13	# Status: Proposed (W4 Day-26 SKELETON; W7-8 build slice wires the real
    14	#         package calls + verifies fixture expectations against actual outputs).
    15	
    16	fixture_id: 01-primary
    17	description: Happy path — Stage-1 exact match auto-write + 1 chase draft position-1
    18	tenant_slug: migration-test
    19	agent: cash-conductor
    20	expected_gate_a: PASS
    21	expected_exit_code: 0
    22	
    23	invocation:
    24	  command: ifosctl cash-conductor reconcile
    25	  flags:
    26	    - --mode
    27	    - webhook
    28	    - --tenant
    29	    - migration-test
    30	
    31	# Tenant accounting + Open Banking provider config (per context.sh hydration)
    32	tenant_config:
    33	  accounting_provider: xero
    34	  open_banking_provider: truelayer
    35	  operator_telegram_chat_id: "operator-test-chat-id"
    36	
    37	# Mocked Open Banking transaction (TrueLayer response shape)
    38	mocked_open_banking:
    39	  transactions:
    40	    - transaction_id: tl-tx-fix-001
    41	      timestamp: "2026-05-20T10:30:00Z"
    42	      amount: 1500.00          # EXACT match to invoice INV-FIX-001 below
    43	      currency: GBP
    44	      description: "ACME RECRUITMENT LTD"
    45	      reference: "INV-FIX-001"  # invoice-reference in memo
    46	
    47	# Mocked Xero invoices response
    48	mocked_accounting:
    49	  open_invoices:
    50	    - InvoiceID: inv-fix-aaa-001
    51	      InvoiceNumber: INV-FIX-001
    52	      Status: AUTHORISED
    53	      Date: "2026-05-01"
    54	      DueDate: "2026-05-31"
    55	      Total: 1500.00
    56	      AmountDue: 1500.00       # matches transaction amount EXACTLY
    57	      Contact: { ContactID: c-acme, Name: "Acme Recruitment Ltd" }
    58	      Reference: "INV-FIX-001"
    59	
    60	# Expected behaviour
    61	expected:
    62	  reconciliation_pass:
    63	    stage_1_2_matches: 1
    64	    stage_3_flagged: 0
    65	    stage_4_ambiguous: 0
    66	    stage_5_unmatched: 0
    67	  payment_writes:
    68	    - invoice_id: inv-fix-aaa-001
    69	      action_type: accounting_reconciliation_write
    70	      tier: yellow

codex
I found a second load-bearing problem tied to the same schema gap: an existing Cash Conductor fixture already carries the undeclared key in tenant config. That means this is not just a future storage-location detail; code/fixtures are already assuming the field before schema declaration.
exec
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/agent.md | sed -n '1,120p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Cash Conductor — the FD's evenings back
     2	
     3	**Status:** Proposed.
     4	**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R17 closed §8 sibling files + D1/bridge prereqs + §3 audit-row signatures (4-row chase lifecycle sequence). R19 fixes (2026-05-24): split draft body out of decision_log payload into vault path (per ADR-002 vault/Postgres split), recent_edit schema R access cite correction, Stage 3 ESC code disambiguation. Awaits Q1 LOI + accounting + Open Banking commercial signups + Founder Decision D1 resolved + autosend bridge built (Concierge W10) + W7 build slice.
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
    18	> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type (registered in autosend-policy.yaml under §ORANGE; grep `^  xero_reminder_send_customer:` to verify); Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW — grep `^  xero_reminder_draft_internal:` to verify; internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (registered under §ORANGE — grep `^  xero_reminder_send_customer:`; consultant approval required before send). **Note on citation discipline:** explicit line numbers in `autosend-policy.yaml` shift across edits; this agent.md uses grep-anchors instead per the pattern established in xero R3 closure (commit `5228fa2`). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** if Founder Decision D1 is unresolved OR the Concierge autosend bridge has not shipped (both gated per §8), Cash Conductor v1.0 runs in **drafts-only** mode — it produces the yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT write the orange-tier `xero_reminder_send_customer` rows that open the send pipeline (per §8 fallback row).
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

exec
/bin/zsh -lc 'rg -n "autosend_bridge_telegram|operator_telegram_chat_id|CTX_OPERATOR_TELEGRAM_CHAT_ID|proposeApproval|approval" agents/recruitment/cash-conductor agents/recruitment/concierge packages/utilities -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
agents/recruitment/concierge/cycle.sh:24:#   @ifos/autosend-bridge-telegram — D1-B Telegram approval shim (Concierge OWNS Step 11)
agents/recruitment/concierge/cycle.sh:34:#   gated by autosend-bridge approval per D1-B founder decision.
agents/recruitment/concierge/cycle.sh:269:# item 2 verbatim: "Concierge cycle.sh Step 11 — calls proposeApproval for
agents/recruitment/concierge/cycle.sh:285:    # 1. proposeApproval — @ifos/autosend-bridge-telegram proposeApproval API:
agents/recruitment/concierge/cycle.sh:290:    #      --operator-chat "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
agents/recruitment/concierge/cycle.sh:295:    #    APPROVAL_ID=$(printf '%s' "${PROPOSE_JSON}" | jq -r .approval_id)
agents/recruitment/concierge/cycle.sh:298:    # 2. Emit concierge_approval_routed audit row (R19 registration):
agents/recruitment/concierge/cycle.sh:300:    #    hh_decision_action "concierge_approval_routed" \
agents/recruitment/concierge/cycle.sh:307:    #      --approval-id "${APPROVAL_ID}" \
agents/recruitment/concierge/cycle.sh:316:    #        hh_decision_output "approval_rejected" \
agents/recruitment/concierge/cycle.sh:318:    #          "approval_id:${APPROVAL_ID}; decided_by:${DECIDED_BY}" ;;
agents/recruitment/concierge/cycle.sh:324:    #          "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:14400; approval_id:${APPROVAL_ID}" ;;
agents/recruitment/concierge/cycle.sh:329:    # DO NOT emit concierge_approval_routed; draft stays in vault for manual
agents/recruitment/concierge/cycle.sh:337:# Step 12 — Send execution (orange tier; ONLY fires post-Step-11 approval)
agents/recruitment/concierge/context.sh:27:#   - Resolve operator_telegram_chat_id from tenant_adapters.config
agents/recruitment/concierge/context.sh:35:#   CTX_OPERATOR_TELEGRAM_CHAT_ID        — tenant operator's Telegram chat ID
agents/recruitment/concierge/context.sh:118:# TODO(W10-13): SELECT config->>'operator_telegram_chat_id' FROM tenant_adapters
agents/recruitment/concierge/context.sh:121:export CTX_OPERATOR_TELEGRAM_CHAT_ID="${IFOS_FORCE_OPERATOR_TELEGRAM_CHAT_ID:-STUB}"
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:3:# Adversarial. Tests the D1-B approval-bridge timeout path. Concierge
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:4:# generates a clean draft (passes Gate A G1-G5), posts proposeApproval to
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:22:description: Operator never replies to proposeApproval → outcome=timeout → ESC_APPROVAL_BRIDGE_TIMEOUT warn + Step 12 send NOT executed
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:38:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:82:    proposeApproval_returns:
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:83:      approval_id: "fixture-canary-99-deadbeefcafe"
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:98:        - approval_id: fixture-canary-99-deadbeefcafe
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:107:  approval_bridge:
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:108:    proposeApproval_invoked: true
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:135:      action_type: concierge_approval_routed
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:136:      payload_contains: "approval_id:fixture-canary-99-deadbeefcafe"
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:141:    Operator missed the 4-hour approval window. Per agent.md §6 row 11 +
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:146:    approval on deadline expiry; no Step 12 send execution; explicit warn
agents/recruitment/concierge/tools.yaml:79:  # Customer-facing email transport (orange tier — only fires post-approval)
agents/recruitment/concierge/tools.yaml:122:  - id: autosend_bridge_telegram_propose
agents/recruitment/concierge/tools.yaml:124:    api: proposeApproval
agents/recruitment/concierge/tools.yaml:125:    purpose: "Post orange-tier candidate-comms approval request to operator Telegram chat (D1-B founder decision)"
agents/recruitment/concierge/tools.yaml:126:    action_type: concierge_approval_routed  # ORANGE-adjacent metadata row per agent.md §6 + Step 11 hh_decision_action call; REGISTERED in autosend-policy.yaml per R19 fix
agents/recruitment/concierge/tools.yaml:135:  - id: autosend_bridge_telegram_await
agents/recruitment/concierge/tools.yaml:199:#   concierge_approval_routed          orange-adjacent     [R19 registration fix]
agents/recruitment/concierge/README.md:14:The customer-comms agent. Highest-stakes v1.0 agent (XL complexity, 4 weeks build). 12 lifecycle events × 2 recipient roles = 24+ comms-template variants per tenant. Orange-tier autosend per `autosend-safety-policy.yaml` — consultant approval mandatory before send.
agents/recruitment/concierge/README.md:36:- D1-A: bridge to cortextOS approval system (most powerful; ~3 days dev)
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type (registered in autosend-policy.yaml under §ORANGE; grep `^  xero_reminder_send_customer:` to verify); Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW — grep `^  xero_reminder_draft_internal:` to verify; internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (registered under §ORANGE — grep `^  xero_reminder_send_customer:`; consultant approval required before send). **Note on citation discipline:** explicit line numbers in `autosend-policy.yaml` shift across edits; this agent.md uses grep-anchors instead per the pattern established in xero R3 closure (commit `5228fa2`). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** if Founder Decision D1 is unresolved OR the Concierge autosend bridge has not shipped (both gated per §8), Cash Conductor v1.0 runs in **drafts-only** mode — it produces the yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT write the orange-tier `xero_reminder_send_customer` rows that open the send pipeline (per §8 fallback row).
agents/recruitment/cash-conductor/agent.md:96:### Output 2 — Payment-chase drafts (yellow tier internal; Cash Conductor INITIATES the orange-tier customer send via Concierge approval bridge)
agents/recruitment/cash-conductor/agent.md:98:For invoices >7 days overdue with no reconciliation match, Cash Conductor drafts a chase email. The draft itself is a yellow-tier internal output (`xero_reminder_draft_internal`); when Cash Conductor decides to send, it WRITES the orange-tier `hh_decision_action("xero_reminder_send_customer", ...)` row (Cash Conductor owns this action_type — grep `^  xero_reminder_send_customer:` in `agents/_shared/autosend-policy.yaml` to verify it's registered there under §ORANGE) which OPENS the orange approval flow — Concierge then handles the autosend-bridge routing + actual transport (Microsoft Graph / Gmail). Cash Conductor owns the action_type; Concierge handles the approval + transport mechanics.
agents/recruitment/cash-conductor/agent.md:112:expected_send_window: orange-tier approval expected within 24h
agents/recruitment/cash-conductor/agent.md:121:When Cash Conductor decides to actually send (after Gate A passes), it writes a third row: `phase='action'`, `action_type='xero_reminder_send_customer'` (orange tier per autosend-policy.yaml lookup; grep `^  xero_reminder_send_customer:` to verify; Cash Conductor owns this action_type) — this row OPENS the orange-tier approval bridge. Concierge then handles the approval + transport. After Concierge confirms send, Cash Conductor receives the webhook + writes a fourth row: `phase='output'`, `output_type='cash_conductor_chase_sent_recorded'`, recording state-mutation completion (no action_type; this is a state-marker output).
agents/recruitment/cash-conductor/agent.md:143:| 4 | **Chase pipeline** | Active chase drafts by position 1-3; pending consultant approval; sent-but-no-response |
agents/recruitment/cash-conductor/agent.md:251:10. Chase-draft queue to Concierge (opens orange-tier approval bridge)
agents/recruitment/cash-conductor/agent.md:259:      Conductor owns this action_type and OPENS the orange-approval-bridge;
agents/recruitment/cash-conductor/agent.md:269:      role is approval-bridge + transport, not action-row authorship.
agents/recruitment/cash-conductor/agent.md:353:| `ESC_AUTOSEND_ORANGE_PENDING` | Chase draft awaiting consultant approval — heartbeat at ≥50% of declared timeout (per catalogue §2.9 trigger) | info | operator_chat_id (gentle reminder; no oncall CC) |
agents/recruitment/cash-conductor/tools.yaml:131:  #   - proposeApproval: state-changing; emits ORANGE decision_log row
agents/recruitment/cash-conductor/tools.yaml:137:  - id: autosend_bridge_telegram_propose
agents/recruitment/cash-conductor/tools.yaml:139:    api: proposeApproval
agents/recruitment/cash-conductor/tools.yaml:140:    purpose: "Post orange-tier chase-send approval request to operator Telegram chat (D1-B founder decision)"
agents/recruitment/cash-conductor/tools.yaml:150:  - id: autosend_bridge_telegram_await
agents/recruitment/concierge/fixtures/01-primary.yaml:7:# proposeApproval posts to operator Telegram; operator approves at +5min;
agents/recruitment/concierge/fixtures/01-primary.yaml:30:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/fixtures/01-primary.yaml:77:  approval_bridge:
agents/recruitment/concierge/fixtures/01-primary.yaml:107:      action_type: concierge_approval_routed   # orange-adjacent metadata
agents/recruitment/concierge/fixtures/01-primary.yaml:109:      action_type: gmail_outlook_send_to_candidate   # orange tier post-approval
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:8:#   to Concierge approval bridge (if autosend-bridge-telegram present)
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:35:  operator_telegram_chat_id: "operator-test-chat-id"
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:35:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:94:  approval_bridge:
agents/recruitment/concierge/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (2026-05-24): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) **Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3** — the agent.md Status-flip blocker on the ADR side is now CLOSED. Remaining Proposed → Accepted blockers: Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + W10 build slice (see §10).
agents/recruitment/concierge/agent.md:9:**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).
agents/recruitment/concierge/agent.md:17:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:183:     (highest voice-classifier bar; mandatory consultant approval per autosend-policy)
agents/recruitment/concierge/agent.md:234:      D1-A (bridge to cortextOS approval system): POST internal API
agents/recruitment/concierge/agent.md:235:      D1-B (lightweight Telegram shim): send approval prompt to operator
agents/recruitment/concierge/agent.md:238:    → ESC_APPROVAL_BRIDGE_TIMEOUT if no approval within the policy timeout
agents/recruitment/concierge/agent.md:241:    → hh_decision_action("concierge_approval_routed",
agents/recruitment/concierge/agent.md:243:      "d1_path:<A|B|C>; bridge_target:<approval_id_or_vault_path>")
agents/recruitment/concierge/agent.md:245:12. (After operator approval) Send execution — orange-tier
agents/recruitment/concierge/agent.md:341:| `ESC_APPROVAL_BRIDGE_TIMEOUT` | No consultant approval within the policy timeout (default PT4H per escalation-codes.md lines 348-353 + autosend-policy.yaml (grep `^  gmail_outlook_send_to_candidate:` or `^  bullhorn_note_customer_visible:` to verify the orange-tier `timeout` field; default `PT4H`)) | warn | operator + tenant-admin |
agents/recruitment/concierge/agent.md:345:| `ESC_AUTOSEND_ORANGE_PENDING` | Draft awaiting approval (info — heartbeat reminder when ≥50% of timeout elapsed) | info | (logged) |
agents/recruitment/concierge/agent.md:428:| Q6 | Send-as-is rate (Gate B ≥60%) — measurement requires consultant to differentiate "approve" from "edit-and-approve". Brain UI v1.0 has no such control yet. Telegram-based approval? | Telegram-based for v1.0: `/approve <draft-id>` vs `/approve-edit <draft-id> <revised-body>`. Brain UI v1.1+ adds inline edit UX. |
agents/recruitment/cash-conductor/cycle.sh:29:#      per autosend-policy.yaml line 263; Concierge handles approval-bridge transport
agents/recruitment/cash-conductor/cycle.sh:208:# Step 10 — Chase-draft queue to Concierge (opens orange-tier approval bridge)
agents/recruitment/cash-conductor/cycle.sh:211:# line 263; Concierge handles autosend-bridge-telegram approval routing + transport.
agents/recruitment/cash-conductor/cycle.sh:219:  # send-approval path fires.
agents/recruitment/cash-conductor/cycle.sh:236:    # 1. proposeApproval — posts to operator Telegram, returns approval-id +
agents/recruitment/cash-conductor/cycle.sh:237:    #    deadline. Package: @ifos/autosend-bridge-telegram (proposeApproval).
agents/recruitment/cash-conductor/cycle.sh:242:    #      --operator-chat "${CTX_OPERATOR_TELEGRAM_CHAT_ID}" \
agents/recruitment/cash-conductor/cycle.sh:247:    #    APPROVAL_ID=$(printf '%s' "${PROPOSE_JSON}" | jq -r .approval_id)
agents/recruitment/cash-conductor/cycle.sh:255:    #      "approval_id:${APPROVAL_ID}; expires_at:${EXPIRES_AT_ISO}; position:${CHASE_POSITION}; vault:${DRAFT_PATH}"
agents/recruitment/cash-conductor/cycle.sh:261:    #      --approval-id "${APPROVAL_ID}" \
agents/recruitment/cash-conductor/cycle.sh:272:    #        hh_decision_output "approval_rejected" "invoice:${INVOICE_ID}" \
agents/recruitment/cash-conductor/cycle.sh:273:    #          "approval_id:${APPROVAL_ID}; decided_by:${DECIDED_BY}; rationale:operator_rejected" ;;
agents/recruitment/cash-conductor/cycle.sh:280:    #          "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:14400; approval_id:${APPROVAL_ID}" ;;
packages/utilities/autosend-bridge-telegram/src/index.ts:4:// orange-tier autosend gating via Telegram operator approval.
packages/utilities/autosend-bridge-telegram/src/index.ts:7:  proposeApproval,
packages/utilities/autosend-bridge-telegram/src/types.ts:6:/** Default approval window per ESC_APPROVAL_BRIDGE_TIMEOUT (escalation-codes.md lines 348-353). */
packages/utilities/autosend-bridge-telegram/src/types.ts:30:  /** Telegram chat ID for the tenant's operator (from tenant_adapters.config.operator_telegram_chat_id). */
packages/utilities/autosend-bridge-telegram/src/types.ts:31:  operator_telegram_chat_id: string;
packages/utilities/autosend-bridge-telegram/src/types.ts:45:  /** Unique approval-id, also embedded as `[ID:<id>]` in the Telegram message. */
packages/utilities/autosend-bridge-telegram/src/types.ts:46:  approval_id: string;
packages/utilities/autosend-bridge-telegram/src/types.ts:56:  approval_id: string;
packages/utilities/autosend-bridge-telegram/src/types.ts:74: * postgres approvals table; the bridge polls it.
packages/utilities/autosend-bridge-telegram/src/types.ts:78:  approval_id: string;
packages/utilities/autosend-bridge-telegram/src/types.ts:86:  /** Posts the approval message; returns the Telegram message ID for traceability. */
packages/utilities/autosend-bridge-telegram/src/types.ts:90:/** Injectable decision-source — production = postgres approvals table; tests = in-memory map. */
packages/utilities/autosend-bridge-telegram/src/types.ts:92:  /** Returns the decision for a given approval-id if one has landed; null otherwise. */
packages/utilities/autosend-bridge-telegram/src/types.ts:93:  fetchDecision(approval_id: string): Promise<PendingDecision | null>;
packages/utilities/autosend-bridge-telegram/src/types.ts:106:  /** Override of the approval-id generator (defaults to crypto.randomUUID). */
packages/utilities/autosend-bridge-telegram/README.md:3:Telegram approval-bridge for orange-tier autosend gating. Backs the **D1-B founder decision** (`docs/decisions/2026-05-31-d1-founder-decision.md`) — consumed by **Concierge `cycle.sh` Step 11** + **Cash Conductor `cycle.sh` Step 10**.
packages/utilities/autosend-bridge-telegram/README.md:11:The autosend safety policy (`agents/_shared/autosend-policy.yaml`) classifies every outbound action into one of four tiers — green / yellow / orange / red. **Orange** actions (e.g. `gmail_outlook_send_to_candidate`, `xero_reminder_send_customer`) require **human approval before transport**. The agent proposes; the operator approves or rejects via Telegram; the agent then either sends or discards.
packages/utilities/autosend-bridge-telegram/README.md:17:| D1-A — cortextOS approval system + Brain UI rich-panel | weeks of build | Right v1.1+ answer; too expensive for v1.0 |
packages/utilities/autosend-bridge-telegram/README.md:29:  proposeApproval,
packages/utilities/autosend-bridge-telegram/README.md:35:### `proposeApproval(input, deps): Promise<ProposeApprovalResult>`
packages/utilities/autosend-bridge-telegram/README.md:39:- Renders an approval message that contains `[ID:<approval_id>]` (the load-bearing token the Telegram bot parser uses to match `/approve <id>` and `/reject <id>` replies), the action type, the target, a ≤500-char draft preview, the vault path for the full draft, the expiry timestamp, and the operator commands.
packages/utilities/autosend-bridge-telegram/README.md:40:- Returns `{approval_id, posted_at_iso, expires_at_iso}`.
packages/utilities/autosend-bridge-telegram/README.md:41:- The agent layer is expected to record `approval_id` + `expires_at_iso` on the originating `decision_log` row before calling `awaitApprovalDecision`.
packages/utilities/autosend-bridge-telegram/README.md:65:  decisions: DecisionSource;      // production: postgres `approvals` table reader
packages/utilities/autosend-bridge-telegram/README.md:76:- `decisions` from a small postgres reader over the `approvals` table that the Telegram bot command-handler writes to on every `/approve` / `/reject` reply
packages/utilities/autosend-bridge-telegram/README.md:95:If the underlying state changes between proposal and approval — e.g. a Cash Conductor chase is proposed at 15:00, the customer pays at 15:30, the operator approves at 15:45 — the **agent layer** (not this package) must detect that the action no longer applies and emit `ESC_AUTOSEND_RACE` with `race_class: state_change_cancellation` instead of executing the transport. This package is intentionally state-agnostic.
packages/utilities/autosend-bridge-telegram/README.md:101:1. Register the action_type in `agents/_shared/autosend-policy.yaml` at orange severity (with the required approval-window, escalation routing, etc).
packages/utilities/autosend-bridge-telegram/README.md:106:If you skip step 2 the call fails fast with `BridgeInputError` at runtime — by design. The list is enumerated rather than `string` so a typo doesn't quietly post an unauthorised approval.
packages/utilities/autosend-bridge-telegram/README.md:118:- `proposeApproval`: posting + payload shape + input validation + transport failure
packages/utilities/autosend-bridge-telegram/src/errors.ts:7:    public readonly approval_id?: string,
packages/utilities/autosend-bridge-telegram/src/errors.ts:49:  constructor(approval_id: string, timeout_seconds: number) {
packages/utilities/autosend-bridge-telegram/src/errors.ts:51:      `approval timed out after ${timeout_seconds}s without operator reply`,
packages/utilities/autosend-bridge-telegram/src/errors.ts:52:      approval_id,
packages/utilities/autosend-bridge-telegram/src/message-format.ts:1:// Message-template rendering for the Telegram approval proposal.
packages/utilities/autosend-bridge-telegram/src/message-format.ts:6:// The `[ID:<approval_id>]` token is load-bearing: the Telegram bot command
packages/utilities/autosend-bridge-telegram/src/message-format.ts:22:  approval_id: string,
packages/utilities/autosend-bridge-telegram/src/message-format.ts:27:    `[ID:${approval_id}]`,
packages/utilities/autosend-bridge-telegram/src/message-format.ts:41:    `Reply  /approve ${approval_id}  to send,  /reject ${approval_id}  to discard.`,
packages/utilities/autosend-bridge-telegram/package.json:5:  "description": "IFOS Telegram approval-bridge — proposeApproval() + awaitApprovalDecision() for orange-tier autosend gating. Per D1-B founder decision (docs/decisions/2026-05-31-d1-founder-decision.md). Consumed by Concierge cycle.sh Step 11 + Cash Conductor cycle.sh Step 10.",
packages/utilities/autosend-bridge-telegram/src/bridge.ts:3:// production wiring (Telegram Bot API + postgres approvals table) for the
packages/utilities/autosend-bridge-telegram/src/bridge.ts:41:      `action_type "${input.action_type}" not registered for the approval bridge ` +
packages/utilities/autosend-bridge-telegram/src/bridge.ts:47:  if (!input.operator_telegram_chat_id) {
packages/utilities/autosend-bridge-telegram/src/bridge.ts:48:    throw new BridgeInputError("operator_telegram_chat_id is required");
packages/utilities/autosend-bridge-telegram/src/bridge.ts:63: * returns the approval-id + deadline. Caller is expected to record the result
packages/utilities/autosend-bridge-telegram/src/bridge.ts:64: * (approval-id, expires_at) on the originating `decision_log` row and then
packages/utilities/autosend-bridge-telegram/src/bridge.ts:65: * call `awaitApprovalDecision(approval_id)` (typically in the same tick).
packages/utilities/autosend-bridge-telegram/src/bridge.ts:67:export async function proposeApproval(
packages/utilities/autosend-bridge-telegram/src/bridge.ts:76:  const approval_id = generate();
packages/utilities/autosend-bridge-telegram/src/bridge.ts:81:  const text = renderApprovalMessage(input, approval_id, expires_at_iso);
packages/utilities/autosend-bridge-telegram/src/bridge.ts:85:      chat_id: input.operator_telegram_chat_id,
packages/utilities/autosend-bridge-telegram/src/bridge.ts:90:      `Telegram postMessage failed for approval ${approval_id}; ` +
packages/utilities/autosend-bridge-telegram/src/bridge.ts:96:  return { approval_id, posted_at_iso, expires_at_iso };
packages/utilities/autosend-bridge-telegram/src/bridge.ts:113:  if (!input.approval_id) throw new BridgeInputError("approval_id is required");
packages/utilities/autosend-bridge-telegram/src/bridge.ts:119:  // got it from proposeApproval), trust it; otherwise fall back to the default
packages/utilities/autosend-bridge-telegram/src/bridge.ts:121:  // already-posted approval, e.g. on agent restart).
packages/utilities/autosend-bridge-telegram/src/bridge.ts:131:    const decision = await deps.decisions.fetchDecision(input.approval_id);
packages/utilities/autosend-bridge-telegram/src/bridge.ts:162:    throw new BridgeTimeoutError(input.approval_id, timeout_seconds);
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:8:  proposeApproval,
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:21:  operator_telegram_chat_id: "987654321",
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:34:    const proposed = await proposeApproval(validInput, deps);
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:37:      approval_id: proposed.approval_id,
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:45:        approval_id: proposed.approval_id,
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:63:    const proposed = await proposeApproval(validInput, deps);
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:65:      approval_id: proposed.approval_id,
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:72:      { approval_id: proposed.approval_id, expires_at_iso: proposed.expires_at_iso },
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:86:    const proposed = await proposeApproval(validInput, deps);
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:95:          approval_id: id,
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:106:        approval_id: proposed.approval_id,
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:124:    const proposed = await proposeApproval(
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:131:        approval_id: proposed.approval_id,
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:152:    const proposed = await proposeApproval(
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:159:        approval_id: proposed.approval_id,
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:177:    const proposed = await proposeApproval(
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:185:          approval_id: proposed.approval_id,
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:201:    const proposed = await proposeApproval(validInput, deps);
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:203:      approval_id: proposed.approval_id,
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:210:      { approval_id: proposed.approval_id, expires_at_iso: proposed.expires_at_iso },
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:220:  it("rejects empty approval_id", async () => {
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:224:      awaitApprovalDecision({ approval_id: "" }, { transport, decisions }),
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:233:        { approval_id: "abc", expires_at_iso: "not-an-iso-date" },
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:8:  proposeApproval,
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:21:  operator_telegram_chat_id: "987654321",
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:28:describe("proposeApproval — posting + payload shape", () => {
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:29:  it("posts to the operator chat and returns a stable approval_id", async () => {
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:34:    const r = await proposeApproval(validInput, {
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:41:    expect(r.approval_id).toBe("11111111-2222-3333-4444-555555555555");
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:48:  it("embeds the [ID:<approval_id>] token at the head of the message body", async () => {
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:53:    const r = await proposeApproval(validInput, {
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:61:    expect(firstLine).toBe(`[ID:${r.approval_id}]`);
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:70:    const r = await proposeApproval(validInput, {
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:78:    expect(body).toContain(`/approve ${r.approval_id}`);
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:79:    expect(body).toContain(`/reject ${r.approval_id}`);
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:88:    const r = await proposeApproval(
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:101:    const r = await proposeApproval(validInput, { transport, decisions, clock });
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:109:describe("proposeApproval — input validation", () => {
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:114:      proposeApproval(
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:127:      proposeApproval({ ...validInput, tenant_slug: "" }, { transport, decisions }),
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:130:      proposeApproval({ ...validInput, operator_telegram_chat_id: "" }, { transport, decisions }),
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:133:      proposeApproval({ ...validInput, draft_preview: "" }, { transport, decisions }),
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:141:      proposeApproval({ ...validInput, timeout_seconds: 0 }, { transport, decisions }),
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:144:      proposeApproval({ ...validInput, timeout_seconds: -10 }, { transport, decisions }),
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:149:describe("proposeApproval — transport failures", () => {
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:156:      proposeApproval(validInput, { transport, decisions }),
packages/utilities/autosend-bridge-telegram/tests/message-format.test.ts:14:  operator_telegram_chat_id: "987654321",
packages/utilities/autosend-bridge-telegram/tests/message-format.test.ts:22:    const body = renderApprovalMessage(base, "approval-xyz", "2026-06-01T19:00:00.000Z");
packages/utilities/autosend-bridge-telegram/tests/message-format.test.ts:24:    expect(firstLine).toBe("[ID:approval-xyz]");
packages/utilities/autosend-bridge-telegram/tests/message-format.test.ts:28:    const body = renderApprovalMessage(base, "approval-xyz", "2026-06-01T19:00:00.000Z");
packages/utilities/autosend-bridge-telegram/tests/message-format.test.ts:35:    expect(body).toContain("/approve approval-xyz");
packages/utilities/autosend-bridge-telegram/tests/message-format.test.ts:36:    expect(body).toContain("/reject approval-xyz");
packages/utilities/autosend-bridge-telegram/tests/message-format.test.ts:43:      "approval-xyz",
packages/utilities/autosend-bridge-telegram/tests/test-helpers.ts:68:      store.set(d.approval_id, d);
packages/utilities/autosend-bridge-telegram/tests/test-helpers.ts:70:    async fetchDecision(approval_id) {
packages/utilities/autosend-bridge-telegram/tests/test-helpers.ts:71:      fetches.push(approval_id);
packages/utilities/autosend-bridge-telegram/tests/test-helpers.ts:72:      return store.get(approval_id) ?? null;

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/agent.md | sed -n '1,130p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
     1	# Concierge — no candidate ghosted
     2	
     3	**Status:** Proposed.
     4	**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (2026-05-24): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) **Accepted 2026-05-31 (founder-arbitrated) + Codex RATIFIED at Round 3** — the agent.md Status-flip blocker on the ADR side is now CLOSED. Remaining Proposed → Accepted blockers: Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + W10 build slice (see §10).
     5	**Date:** 2026-05-24.
     6	**Author:** Founder (Maddox) + Claude Code.
     7	**Build wave:** v1.0 W10-13 per master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 line 559 (master brief says W10-13 = 4 weeks; ULTRAPLAN says W9-10 = 2 weeks; master brief authoritative — the XL complexity flag in ULTRAPLAN A6 line 568 corroborates the 4-week duration).
     8	**Build complexity:** XL (4 weeks) per ULTRAPLAN A6 line 568 — "the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)".
     9	**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).
    10	
    11	---
    12	
    13	## §1 — Output contract (one-paragraph screenshot)
    14	
    15	Per master brief §1 Rule 1, the output contract is the load-bearing first thing. Read this in isolation; everything else in this document supports it.
    16	
    17	> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
    18	
    19	---
    20	
    21	## §2 — Invocation surface
    22	
    23	### Lifecycle webhook (v1.0 primary)
    24	
    25	```http
    26	# Bullhorn placement state-change webhook → Concierge handler
    27	POST https://<tenant>.ifos.app/agents/concierge/webhook
    28	Authorization: Bearer <bullhorn-shared-secret>
    29	Content-Type: application/json
    30	
    31	{
    32	  "event_type": "placement.state_changed" | "candidate.state_changed",
    33	  "entity_id": "<bullhorn-id>",
    34	  "from_state": "interview_scheduled",
    35	  "to_state": "interview_completed",
    36	  "timestamp": "<ISO>"
    37	}
    38	```
    39	
    40	Bullhorn webhook coverage is patchy per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha — see Step 1 polling fallback.
    41	
    42	### Cron (polling fallback + time-elapsed nurture)
    43	
    44	```bash
    45	# Every 5 min: poll Bullhorn for missed state transitions
    46	*/5 * * * * sudo -u ifos_user /usr/local/bin/ifos-concierge.sh --tenant <slug> --mode poll
    47	# Daily 09:00 UTC: time-elapsed nurture sweeps (7d / 30d / 90d check-ins)
    48	0 9 * * * sudo -u ifos_user /usr/local/bin/ifos-concierge.sh --tenant <slug> --mode nurture-sweep
    49	```
    50	
    51	### Manual (debugging)
    52	
    53	```bash
    54	ifosctl concierge generate --tenant <slug> --candidate <id> --event <event-type>
    55	ifosctl concierge replay --tenant <slug> --webhook-id <id>
    56	```
    57	
    58	### v1.1+ surfaces (deferred)
    59	
    60	- agent-identity email adapter (deferred) integration (agent-identity sends for non-rejection comms)
    61	- Brain UI lifecycle-event timeline viewer per candidate
    62	- Per-tenant comms-type taxonomy customisation
    63	
    64	---
    65	
    66	## §3 — Output shape
    67	
    68	One output per lifecycle event: an email draft (yellow tier `concierge_email_draft` per autosend-policy.yaml; only the customer-facing SEND is orange tier — `gmail_outlook_send_to_candidate` / `bullhorn_note_customer_visible` / `twilio_sms_send` / `calendar_invite_send` per channel). 12 lifecycle events × per-tenant comms-template variants:
    69	
    70	| # | Event | Comms type | Recipient | Tone |
    71	|---|---|---|---|---|
    72	| 1 | Application received | Acknowledgement | Candidate | Warm, professional, sets expectations on response timeline |
    73	| 2 | Interview booked | Prep | Candidate | Practical (date, time, format, interviewers) + role context |
    74	| 3 | Interview completed | Debrief | Candidate | Thank-you + next-step clarity OR "we'll be in touch by X" |
    75	| 4 | Offer extended | Placement-positive | Candidate | Excited, clear on terms, addressee-resolution-critical |
    76	| 5 | Offer accepted | Placement-confirm | Candidate + Client (separate drafts) | Reassurance + practical next steps |
    77	| 6 | Rejected (post-interview) | Rejection | Candidate | THE HARDEST CASE per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) — respectful, specific, leaves door open |
    78	| 7 | Withdrawn (candidate-initiated) | Acknowledgement | Candidate | Respectful, no pressure, leaves door open |
    79	| 8 | On-hold | Status-update | Candidate | Honest about timeline, sets expectations on next update |
    80	| 9 | Start date confirmed | Placement-pre-start | Candidate + Client | Practical (HR forms, IT setup, day-1 logistics) |
    81	| 10 | 7-day check-in (post-start) | Nurture-check-in | Candidate | "How's it going? Any blockers?" — short, low-pressure |
    82	| 11 | 30-day check-in | Nurture-check-in | Candidate + Client | Slightly longer; both sides; reads for placement-risk signals |
    83	| 12 | 90-day check-in | Nurture-check-in + relationship | Candidate + Client | Establishes ongoing relationship; offers "is there anyone in your network looking?" |
    84	
    85	Draft structure per event:
    86	
    87	```yaml
    88	draft_id: <uuid>
    89	event_type: <one of 12 above>
    90	candidate_id: <bullhorn-id>
    91	placement_id: <bullhorn-id or null>
    92	recipient: <candidate-email | client-contact-email>
    93	recipient_role: candidate | client_contact
    94	subject: <subject line; voice-classified>
    95	body_markdown: <body; voice-classified>
    96	voice_score: <0-1>
    97	addressee_resolution_check: passed | failed
    98	attached_documents: <list — e.g., feedback summary, prep guide, comms history>
    99	escalation_position: 1-3 (for sensitive sends like rejection)
   100	expected_send_window: <ISO; respects sending-hours per tenant config>
   101	```
   102	
   103	Each draft: `decision_log` row with `agent_name='concierge'`, `phase='output'`, `action_type='concierge_email_draft'` (registered yellow tier per autosend-policy.yaml), `tier='yellow'`, payload includes `event_type` + `voice_score` + `recipient` + `escalation_position` (event-type is a payload field, not part of action_type — keeps action_type stable across 12 lifecycle events).
   104	
   105	The actual SEND is a separate orange-tier action_type:
   106	- `gmail_outlook_send_to_candidate` (orange tier per autosend-policy.yaml §ORANGE) when channel=email
   107	- `bullhorn_note_customer_visible` (orange tier; canonical orange per autosend-policy.yaml §ORANGE) when channel=Bullhorn note with isExternal=true
   108	- `twilio_sms_send` (orange tier per autosend-policy.yaml §ORANGE) when channel=SMS (v1.1+)
   109	- `calendar_invite_send` (orange tier per autosend-policy.yaml §ORANGE) when event includes calendar attachment
   110	
   111	Consultant approves via autosend-bridge (D1 path) → orange-tier send executes → Bullhorn activity-log entry written post-send.
   112	
   113	---
   114	
   115	## §4 — Workflow
   116	
   117	15 steps. Per master brief §8.1 Change 2, every step that produces output OR takes action MUST call `hh_decision_*` from `agents/_shared/hook-helpers.sh`.
   118	
   119	```
   120	0. Session start (webhook OR poll OR cron)
   121	   → context.sh hydrates: tenant config + Bullhorn auth refresh +
   122	     Microsoft Graph / Gmail auth + agent-identity email adapter (deferred) (if v1.1+ enabled) +
   123	     voice corpus + tone rules + recent_edits + tenant comms-template
   124	     library + addressee-resolution data
   125	   → hh_decision_trigger("session_start", "<webhook|poll|cron-nurture>")
   126	
   127	1. Source detection (mode-dependent)
   128	   → mode=webhook: parse Bullhorn payload → resolve entity + state transition
   129	   → mode=poll: query Bullhorn for placements/candidates with state_changed_at
   130	     > tenant_adapters.config.concierge_last_poll AND not in decision_log

codex
REJECTED

1. Schema impact is contradicted inside the artefact. Line 53 says `operator_telegram_chat_id` is not in the v0.3 allowlist and requires a v0.4 supplement; line 66 says “No schema impact” and “no v0.4 supplement work added.” This violates honest signal and Rule 2. Fix line 66 to state the schema dependency and make v0.4 a required downstream consequence.

2. Schema-before-code is not satisfied for the accepted implementation state. Line 53 admits the key is schema-work pending, while line 75 says the package scaffold and both Cash Conductor + Concierge consumer wiring have already landed. That means consumers exist before the declared `tenant_adapters.config.operator_telegram_chat_id` schema support. Fix by landing the v0.4 schema supplement first, or mark all consumer wiring as function-arg/env-only and remove tenant_adapters usage until schema exists.

3. Broken internal reference. Line 67 says “see incident response below,” but there is no incident-response section below the Consequences section; the artefact ends at lines 71-75. Remove the reference or add the cited section with the actual bootstrap/secret-handling procedure.

4. Ratification status tracking is inconsistent. Line 59 says the doc will be added to the next `--cluster F` or future cluster; line 75 says it is awaiting cluster G. This is a status/queue accuracy issue in a ratification artefact. Replace both with one exact current ratification queue value.
tokens used
62,175
REJECTED

1. Schema impact is contradicted inside the artefact. Line 53 says `operator_telegram_chat_id` is not in the v0.3 allowlist and requires a v0.4 supplement; line 66 says “No schema impact” and “no v0.4 supplement work added.” This violates honest signal and Rule 2. Fix line 66 to state the schema dependency and make v0.4 a required downstream consequence.

2. Schema-before-code is not satisfied for the accepted implementation state. Line 53 admits the key is schema-work pending, while line 75 says the package scaffold and both Cash Conductor + Concierge consumer wiring have already landed. That means consumers exist before the declared `tenant_adapters.config.operator_telegram_chat_id` schema support. Fix by landing the v0.4 schema supplement first, or mark all consumer wiring as function-arg/env-only and remove tenant_adapters usage until schema exists.

3. Broken internal reference. Line 67 says “see incident response below,” but there is no incident-response section below the Consequences section; the artefact ends at lines 71-75. Remove the reference or add the cited section with the actual bootstrap/secret-handling procedure.

4. Ratification status tracking is inconsistent. Line 59 says the doc will be added to the next `--cluster F` or future cluster; line 75 says it is awaiting cluster G. This is a status/queue accuracy issue in a ratification artefact. Replace both with one exact current ratification queue value.
