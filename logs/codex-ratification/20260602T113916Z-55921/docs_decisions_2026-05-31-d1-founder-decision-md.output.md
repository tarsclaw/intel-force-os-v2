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
session id: 019e8821-7f72-7d83-9233-50456b26a11d
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
5. **Tenant config** — `tenant_adapters.config.operator_telegram_chat_id` — already supported by the existing Telegram surface; no new schema needed.

---

## Codex ratification

This decision doc ratifies via `.codex/ratification/review-architecture-decision.md` skill. Will be added to the next `--cluster F` (or future cluster) ratification run.

## Consequences

- **Concierge §9 Q1 RESOLVED** — strike from "open questions" list at next agent.md touch.
- **Cash Conductor §8 D1-pending fallback** — flips from "drafts-only if unresolved" to "orange-tier `xero_reminder_send_customer` writes are live once Concierge W10 ships the `autosend-bridge-telegram` package."
- **Concierge ratification §10** — `Founder Decision D1 RESOLVED` blocker now satisfied. Remaining Concierge Proposed → Accepted blockers per §10: Codex Round 4 Phase 2 (DONE), ADR-007 Accepted (PENDING founder Accept), founder approves §9 Q2-Q6 (PENDING).
- **No schema impact.** D1-B reuses `tenant_adapters.config` for the operator chat ID; no v0.4 supplement work added by this decision.
- **No additional API keys/signups.** Telegram bot token already in `_secrets.env` per Day-4 provisioning.

---

*End of D1 decision doc.*

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
I’ll verify the cited sections and schema/helper claims against the repo before returning the ratification verdict.
exec
/bin/zsh -lc "sed -n '1,220p' docs/decisions/autosend-safety-policy.md" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
# Auto-send safety policy

**Status:** Proposed — pending Codex Day-7 ratification
**Date:** 2026-05-18 (Week 0, Day 5)
**Author:** Claude Code, with founder review pending
**Master brief §:** §6 Day 5 (line 485) + §8.1 Change 2 (`hh_decision_*` contract) + §3.2 (adapter boundary)
**Surfaced by:** Master brief Day 5 spec; load-bearing for every `hh_decision_action` call across the v1.0 agent fleet.
**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.

---

## §1 — Scope

This policy governs **every agent action that produces a side effect outside the IFOS-internal data layer**. The internal data layer is:

- The vault (`/vault/<tenant>/`) — markdown + YAML, IFOS-controlled
- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
- The pgvector indexes over the above
- The cortextOS file bus and PM2 process tree

**Actions inside the internal data layer are not governed by this policy** (they are governed by RLS + the master brief §3.3 vault/Postgres split + the decision_log append-only enforcement).

**Actions that ARE governed:**

1. Writes to any external system via MCP connector (Bullhorn, Companies House, Xero, Microsoft Graph, etc.) — every `tools.yaml`-declared write scope
2. Sends to humans via any communication channel (email, SMS, Telegram, Slack, LinkedIn InMail, calendar invite, etc.) — both customer-facing and consultant-internal where the consultant is not the agent's directly-supervising user
3. Reads from external systems that touch PII or have rate-limit/cost implications (LinkedIn profile lookups, Companies House director searches)
4. Any action declared as side-effecting in `tools.yaml` for an agent, regardless of category

**Out of scope:**

- Read-only IFOS internal queries (entities, decision_log reads via context-assembly API)
- Render-time renderer operations (writing rendered agent dirs to `${frameworkRoot}/orgs/<org>/agents/<name>/`)
- Vault local writes by the agent's own validate.sh / context.sh / fixture runs
- Codex ratification artefacts (read-only review)

If an action's scope is ambiguous, default to **governed** and require classification.

**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".

---

## §2 — Tier model

Four-tier traffic light. Every governed action falls into exactly one tier at every moment of execution. Tiers are properties of the **(action_type × tenant_override)** pair, not of the agent.

### Green — auto-send allowed without review

Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='green'` is written.

**Default characteristics:** idempotent OR internal-to-tenant OR read-only against external systems with rate-limit budget remaining OR low-cost-to-reverse (e.g., add a Bullhorn tag that can be removed in <30s).

### Yellow — auto-send allowed with sampled spot-check

Side effects allowed. The action proceeds immediately. A `decision_log` row with `phase='action'` and `payload.tier='yellow'` is written. Additionally, a sampling check fires (1-in-N per `action_type`; default N=10). On sampling, the action is enqueued for **human spot-check review** by the tenant operator within 24 hours of execution. Spot-check disagreement triggers retrospective review of the policy tier classification (potential tier elevation via tenant override).

**Default characteristics:** high-volume actions where systematic per-action review is too slow but where systematic blind trust is too risky; sampled review provides quality signal without operational drag.

### Orange — requires human approval before send

Side effects blocked at agent layer. The agent halts at `hh_decision_action` invocation. A `decision_log` row with `phase='action'` and `payload.tier='orange'` is written. `ESC_AUTOSEND_NEEDS_REVIEW` fires (see §5). The cortextOS approval gate (primitive 4 per master brief §2.4) opens, Telegram bot notifies the tenant's designated approver (primitive 5), agent blocks until human resolves with `approve` / `reject` / `escalate-up`. Approval grants single-execution authority for the specific action_type + target + payload_hash — not a standing authorisation.

**Default characteristics:** moderate-to-high cost-to-reverse OR customer-facing comms OR irreversible state changes.

### Red — blocked entirely

Side effects refused. Agent does not get the chance to invoke. `decision_log` row with `phase='gating_failed'` and `payload.tier='red'` is written. `ESC_AUTOSEND_BLOCKED` fires (see §5). The agent must take a different code path or abort. **Red tier cannot be relaxed by tenant override.** Red is the floor for tier overrides per §8.

**Default characteristics:** financial/legal/cross-tenant/PII boundaries; structural integrity of the IFOS multi-tenant model.

---

## §3 — Examples per tier across the v1.0 agent surface

Six v1.0 agents per master brief §8.2: Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge. Each action below has a v1.0 default tier; tenant overrides can elevate (see §8).

### Green examples (auto-send without review)

| Agent | action_type | Why green |
|---|---|---|
| Diagnostic | `diagnostic_report_render` | Internal artefact write; no external comms; idempotent (re-render overwrites) |
| Janitor | `bullhorn_candidate_tag` | Adds a tag with `checked_at` date; reversible in <30s; high volume |
| Scribe | `bullhorn_note_internal` | Writes to internal-only Bullhorn note section (`isExternal: false`); visible only to consultant; non-customer-facing |
| Sourcing Scout | `linkedin_profile_cache` | Stores profile snapshot to `/vault/<tenant>/wiki/raw/`; no external send; no rate-limit cost |
| Cash Conductor | `xero_query_invoices` | Read-only against Xero; rate-limited via Xero's own quotas; no side effect |
| Concierge | `bullhorn_brief_read` | Read of inbound brief; idempotent; no comms |

### Yellow examples (auto-send with spot-check sampling)

| Agent | action_type | Sample rate | Why yellow |
|---|---|---|---|
| Janitor | `bullhorn_candidate_dedupe` | 1-in-10 | Merges duplicate candidate records; reversible but high-volume; merge quality needs ongoing review |
| Scribe | `bullhorn_note_append_summary` | 1-in-20 | Appends to candidate record; visible to consultant only; high-volume; format quality needs review |
| Sourcing Scout | `linkedin_connection_request` | 1-in-5 | Outbound LinkedIn action subject to rate limits + reputation effects; sample for tone + targeting accuracy |
| Cash Conductor | `xero_reminder_draft_internal` | 1-in-10 | Generates reminder draft visible to consultant; not yet sent; format + tone needs review |
| Concierge | `bullhorn_note_draft_internal` | 1-in-10 | Drafts a Bullhorn Note for consultant review (not yet sent); high-volume; voice drift candidate |

### Orange examples (per-action human approval)

| Agent | action_type | Why orange |
|---|---|---|
| **Concierge** | **`bullhorn_note_customer_visible`** | **CANONICAL ORANGE.** Writes a Bullhorn Note with `isExternal: true` (or equivalent) that becomes visible to the customer's full team in their CRM. Single send is irreversible (note remains in audit trail even if deleted). Source: `bullhorn-integration-path.md` §4.1 (establishes Concierge produces Notes on every lifecycle-event communication) + §6.3 (explicit sensitivity framing: "Note creation is the most sensitive auto-send because notes are immediately visible to clients and candidates in the Bullhorn UI"). |
| Concierge | `gmail_outlook_send_to_candidate` | Outbound email to candidate; customer-facing; reputation effects |
| Concierge | `twilio_sms_send` | Outbound SMS; high-trust channel; cost-per-send; irreversible |
| Concierge | `calendar_invite_send` | Creates calendar event with attendee notification; visible to attendee |
| Scribe | `email_summary_to_customer` | Outbound email summarising call to customer; customer-facing; format-sensitive |
| Cash Conductor | `xero_reminder_send_customer` | Outbound payment reminder to customer; reputation + collection risk |
| Diagnostic | `diagnostic_email_send` | Outbound diagnostic report to prospect; sales-stage outreach; reputation |
| Diagnostic | `diagnostic_calendar_invite` | Books intro call with prospect; reputation + scheduling friction |
| Sourcing Scout | `linkedin_inmail_send` | Outbound InMail (paid credit); cost-per-send; customer-facing |
| Janitor | `bullhorn_placement_terminate` | Marks placement as terminated; commercial/legal implications; reversible only via support ticket |

### Red examples (blocked entirely; `ESC_AUTOSEND_BLOCKED`)

| action_type | block_reason | Why red |
|---|---|---|
| `xero_payment_initiate` | `payment_action` | Payment transfer; financial-bearing; never auto-send in v1.0 |
| `stripe_charge_initiate` | `payment_action` | Charges a card; financial-bearing |
| `subscription_modify` | `billing_modification` | Changes tenant's IFOS subscription; structurally distinct from agent work |
| `legal_document_generate` | `legal_artefact` | Offer letters, employment contracts; legal-binding |
| `pii_export_outside_tenant_geography` | `pii_geographic_breach` | PII transmitted outside tenant's declared data residency (e.g., GDPR boundary breach) |
| `cross_tenant_data_send` | `cross_tenant_violation` | Sending tenant-A data to tenant-B recipient; structurally enforced by RLS but red-listed for defence-in-depth |
| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
| `send_to_blocked_recipient` | `blocked_recipient` | Recipient in tenant's `blocked_recipients` override list |

---

## §4 — Integration with the `hh_decision_action` contract

Per master brief §8.1 Change 2 and ADR-003 Decision 3 §2.1, every agent run emits three `decision_log` rows via:

- `hh_decision_trigger` — at session start; logs the trigger
- `hh_decision_output` — when the agent produces its output artefact
- `hh_decision_action` — when an action is taken (or blocked)

The policy gates **the `hh_decision_action` call specifically**. Implementation lives in `agents/_shared/hook-helpers.sh` (Week-1 prerequisite per ADR-002 §"For Week 1 work"). The policy is the **specification** that hook-helpers.sh implements against.

### Reference implementation (bash pseudocode for `_shared/hook-helpers.sh`)

```bash
# hh_decision_action — gate every side-effecting action through the policy
# Args:
#   $1 action_type   (enum from autosend-policy.yaml; see §3 for v1.0 set)
#   $2 target        (entity reference, e.g., "candidate:john-smith")
#   $3 payload_hash  (SHA-256 hex of the action payload)
#   $4 payload_preview (human-readable summary, <=500 chars, NO raw PII)
hh_decision_action() {
  local action_type="$1"
  local target="$2"
  local payload_hash="$3"
  local payload_preview="$4"

  # Required context vars from CTX_* (set by context.sh per ADR-003 §2.1 + master brief §8.1 Change 1)
  local tenant_slug="${CTX_TENANT_SLUG:?CTX_TENANT_SLUG unset}"
  local agent_name="${CTX_AGENT_NAME:?CTX_AGENT_NAME unset}"

  # 1. Policy lookup — read tier from the canonical policy table
  local tier
  tier=$(autosend_policy_lookup "$action_type") || {
    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "policy_lookup_failed"
    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_action_type"
    return 1
  }

  # 2. Apply tenant override (elevation only; red is floor)
  tier=$(autosend_apply_tenant_override "$tier" "$action_type" "$tenant_slug") || {
    autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "override_resolution_failed"
    autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "override_resolution_failed"
    return 1
  }

  # 3. Tier dispatch
  case "$tier" in
    green)
      autosend_emit_decision_log "action" "green" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
      return 0
      ;;
    yellow)
      autosend_emit_decision_log "action" "yellow" "$action_type" "$target" "$payload_hash" "$payload_preview" ""
      if autosend_should_sample "$action_type" "$tenant_slug"; then
        autosend_spot_check_enqueue "$action_type" "$target" "$payload_hash" "$payload_preview" "$tenant_slug"
      fi
      return 0
      ;;
    orange)
      autosend_emit_decision_log "action" "orange" "$action_type" "$target" "$payload_hash" "$payload_preview" "approval_pending"
      autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW "$action_type" "$target" "$payload_hash" "$payload_preview"
      # Blocks on cortextOS approval gate (master brief primitive 4). Returns 0 on approval, 1 on reject/timeout.
      autosend_await_approval "$action_type" "$target" "$payload_hash"
      return $?
      ;;
    red)
      autosend_emit_decision_log "gating_failed" "red" "$action_type" "$target" "$payload_hash" "$payload_preview" "red_tier_classification"
      autosend_escalate ESC_AUTOSEND_BLOCKED "$action_type" "$target" "$payload_hash" "red_tier_classification"
      return 1
      ;;
    *)
      # Fail-safe: unknown tier → red
      autosend_emit_decision_log "gating_failed" "fail-safe-red" "$action_type" "$target" "$payload_hash" "$payload_preview" "unknown_tier:$tier"
      autosend_escalate ESC_AUTOSEND_POLICY_LOOKUP_FAILED "$action_type" "$target" "$payload_hash" "unknown_tier:$tier"
      return 1
      ;;
  esac
}
```

### Where the policy check fires in the renderer pipeline

The policy is read at runtime, not at render time. The renderer (per ADR-003) copies `agents/_shared/` (including `hook-helpers.sh` and `autosend-policy.yaml`) into the rendered agent directory. The agent's runtime sources `hook-helpers.sh`, which reads `autosend-policy.yaml` on first `hh_decision_action` invocation per session and caches the policy table in memory for the session lifetime (~71 hours per cortextOS context rotation).

**Policy hot-reload:** if the policy file changes mid-session (rare), the agent does NOT pick it up until the next session boundary (cortextOS PTY restart). Material policy changes must wait for the next 71-hour boundary or trigger a deliberate restart. Documented as an operational footgun in §11 open questions.

### `tools.yaml` declaration

Every agent's `tools.yaml` declares which `action_type` values it may invoke. The tier mapping for each declared `action_type` is fixed by this policy. Example excerpt for Concierge:

```yaml
# agents/recruitment/concierge/tools.yaml (excerpt)
action_types:
  - bullhorn_brief_read              # green

exec
/bin/zsh -lc 'rg -n "autosend-safety-policy|ESC_APPROVAL_BRIDGE_TIMEOUT|operator_telegram_chat_id|tenant_adapters|ghosted-rate|D1|Q1|D1-pending|Telegram surface|primitive #5" docs agents packages -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
packages/agents-runtime/_shared/common-accounting.json:30:      "description": "Default Cash Conductor cadence; tenant-overridable per autosend-safety-policy §6 tenant-override discipline."
agents/_shared/autosend-policy.yaml:3:# Source of truth: docs/decisions/autosend-safety-policy.md §3 + §4.
agents/_shared/autosend-policy.yaml:6:# tenant_adapters.config.tier_overrides (§8).
agents/_shared/autosend-policy.yaml:104:    reason: "Internal audit row recorded by Concierge cycle.sh Step 11 when an approval is routed via the autosend-bridge (per Founder Decision D1 path A/B/C). Payload carries d1_path + bridge_target (approval_id or vault path). Not an external send; the actual send is a downstream orange-tier action_type with its own row."
agents/_shared/autosend-policy.yaml:380:    reason: "Send via adapter not declared in this tenant's tenant_adapters row + tools.yaml"
agents/_shared/autosend-policy.yaml:391:# Defaults applied when override fields are absent in tenant_adapters
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:11:# auxiliary tables + 6 tenant_adapters.config keys + v0.2 entity-access amendments).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:755:# §4 — tenant_adapters.config keys (6 declarations: 5 v0.3-new + 1 pre-v0.3 canonicalised)
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:758:# tenant_adapters.config is JSONB; validation via
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:759:# validate_tenant_adapters_config_v0_3 trigger in migration §5. Hard-fail
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:762:tenant_adapters_config_additions:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:833:      send refusal (autosend-safety-policy §5 red-tier action_type
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:916:      CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3() —
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:918:      v0.3 keys. Trigger attached to tenant_adapters table (migration §5).
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:947:  Q1_employment_type_enum_completeness:
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:956:        Per-tenant overrides via tenant_adapters.config.employment_type_extensions
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:991:      C: Per-tenant retention override in tenant_adapters.config.
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1003:    question: validate_tenant_adapters_config_v0_3 trigger behavior on unknown keys?
docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml:1042:    - Concierge tenant_adapters.config field refs valid
packages/agents-runtime/_shared/common-notifications.json:25:      "description": "Primary surface for orange-tier approval gates per autosend-safety-policy §4."
packages/agents-runtime/_shared/common-notifications.json:49:      "description": "4h default per autosend-safety-policy §5 ESC_AUTOSEND_NEEDS_REVIEW; timeout converts orange-tier to ESC_AUTOSEND_NEEDS_REVIEW row."
packages/agents-runtime/_shared/common-vault.json:36:      "description": "Queue directory written by autosend_spot_check_enqueue per autosend-safety-policy §4."
agents/_shared/README.md:12:| `autosend-policy.yaml` | Runtime tier table — 29 action_types per autosend-safety-policy §3 | 3 |
agents/_shared/README.md:58:### 7 `autosend_*` helpers (autosend-safety-policy §4)
agents/_shared/README.md:70:## Auto-send tier dispatch (autosend-safety-policy §4)
agents/_shared/README.md:84:Per autosend-safety-policy §6 + plan §Phase 3 acceptance criterion #5: `autosend_await_approval` blocks for `timeout_seconds` (4h default from `autosend-policy.yaml` `defaults.approval_timeout`). PM2 + cortextOS primitive 1 keep the agent process alive during the block. Inter-agent bus-messaging to a 4h-blocked agent is fire-and-forget from the sender's perspective (cortextOS bus delivers asynchronously); blocked agent processes deferred messages when approval resolves.
agents/_shared/README.md:123:4. Founder runs the kill-criterion Trigger 5 query (autosend-safety-policy §7):
agents/_shared/README.md:173:All five sit downstream of already-ratified `autosend-safety-policy.md` + `master brief §8.1` + `agent-bundle-renderer-design.md` + `vertical-schema.v0.2-supplement.yaml` (Phase 4). No new master-brief edits required.
agents/_shared/README.md:177:- `docs/decisions/autosend-safety-policy.md` — full tier model + §4 reference impl
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:384:  Q11_voice_corpus_chunk_storage:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:393:  Q12_tone_rule_severity_block_path:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:403:  Q13_recent_edit_retention_under_GDPR:
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:415:      per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml:448:      Q11/Q12/Q13 resolved. recent_edit purge policy implemented if Q13=B/C. Brain UI v1.1 surfaces retraining queue. tone_rule examples_positive/examples_negative actively cross-referenced by Gate A.
agents/_shared/escalation-codes.md:13:The payload template established by `agent-bundle-renderer-design.md` §4 + ratified in `autosend-safety-policy.md` §5:
agents/_shared/escalation-codes.md:31:Source: `docs/decisions/autosend-safety-policy.md` §5
agents/_shared/escalation-codes.md:339:Source: `docs/decisions/autosend-safety-policy.md` §5 extensions; runtime orchestration semantics
agents/_shared/escalation-codes.md:348:#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
agents/_shared/escalation-codes.md:426:- **Trigger:** Outbound recipient matches tenant's Do-Not-Contact list (loaded from tenant_adapters config); attempted send refused before transport
agents/_shared/hook-helpers.sh:4:# helpers per master brief §8.1 Change 2 + autosend-safety-policy §4.
agents/_shared/hook-helpers.sh:285:# 7 autosend_* helpers (autosend-safety-policy §4)
agents/_shared/hook-helpers.sh:312:# Reads tenant_adapters.config.tier_overrides from Postgres. v1.0 v0.1 fallback:
agents/_shared/hook-helpers.sh:419:# tenant override via tenant_adapters.config.sampling_rates.
docs/verticals/recruitment/vertical-schema.yaml:12:#       + autosend-safety-policy.md §3 (action_type references)
docs/verticals/recruitment/vertical-schema.yaml:75:        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
docs/verticals/recruitment/vertical-schema.yaml:155:      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
docs/verticals/recruitment/vertical-schema.yaml:614:      v0.1 captures the PRIMARY decision-maker only. Real-world recruiting often has multiple decision-makers per brief (hiring manager + HR + occasionally CTO/CFO/CEO). The N:1 cardinality is the simplifying v0.1 assumption. Multi-decision-maker panels deferred to v1.1 Triage per Q10 — when v1.1 lands, brief_decision_maker may flip to M:N with role-in-panel metadata (chair, technical-evaluator, hr-lead, budget-approver, etc.) on entity_links.metadata.
docs/verticals/recruitment/vertical-schema.yaml:616:    v1_1_plus_notes: v1.1 Inbound Triage expands to multi-contact panel modelling per Q10.
docs/verticals/recruitment/vertical-schema.yaml:666:# Cross-referenced to bullhorn-integration-path.md §4.1 + autosend-safety-policy.md §3.
docs/verticals/recruitment/vertical-schema.yaml:797:  Q1_contractor_entity_type:
docs/verticals/recruitment/vertical-schema.yaml:851:  Q10_panel_hiring_modelling:
docs/verticals/recruitment/vertical-schema.yaml:858:  Q11_lifecycle_stage_enum_migration:
docs/verticals/recruitment/vertical-schema.yaml:866:  Q12_source_field_schema:
docs/verticals/recruitment/vertical-schema.yaml:886:      Structural cut. 8 entities + 10 relationships + agent-access matrix + Bullhorn mapping. Minimal field sets (10-20 per entity). 12 open questions catalogued (Q1, Q4 resolved at Day 6; Q2, Q3, Q5-Q12 deferred with named triggers).
docs/verticals/recruitment/vertical-schema.yaml:898:      Triage expansion (Q5 contact decision-authority granularity, Q10 panel hiring). Skill taxonomy decision (Q8). Multi-client contact decision (Q9). Umbrella company entity promotion candidate (Q7). Opportunity entity exercise begins.
packages/harness/cortextos/package-lock.json:500:      "integrity": "sha512-56hiAJPhwQ1R4i+21FVF7V8kSD5zZTdHcVuRFMW0hn753vVfQN8xlx4uOPT4xoGH0Z/oVATuR82AiqSTDIpaHg==",
packages/harness/cortextos/package-lock.json:1014:      "integrity": "sha512-/I5AS4cIroLpslsmzXfwbe5OmWvSsrFuEw3mwvbQ1kDxJ822hFHIx+vsN/TAzNVyepI/j/GSzrtCIwQPeKCLIg==",
packages/harness/cortextos/package-lock.json:1373:      "integrity": "sha512-RMxFhJwc9fSXP6PqmAz4cbv3kAyvD1etJFjTx4ONqFP9DkTkXsAMU4v3Vyc5BgzC+anz7nS/9tp4obsKfqkDHg==",
packages/harness/cortextos/package-lock.json:1990:      "integrity": "sha512-gX8LrtNEI5hq8DVUfRQMbr5lpaS4nMIWV+7XEbXk2b8kiQIizgnlr12B4dA3ZEx3308ze0O4Q1R+cHts8kyUJg==",
packages/harness/cortextos/package-lock.json:2128:      "integrity": "sha512-NXYBzinNrblfraPGyrbPoD19C1h9lfI/1mzgWYvXUTe414Gz/X1FD2XBZSZM7rRTrMA8JL3OtAaGifrIKhQ5yQ==",
packages/harness/cortextos/package-lock.json:2744:      "integrity": "sha512-9u/XQ1pvrQtYyMpZe7DXKv2p5CNvyVwzUB6uhLAnQwHMSgKMBR62lc7AHljaeteeHXn11XTAaLLUVZYVZyuRBQ==",
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:9:#   OR drafts-only mode (if bridge absent — per D1-B agent.md §1 caveat).
agents/recruitment/cash-conductor/fixtures/01-primary.yaml:35:  operator_telegram_chat_id: "operator-test-chat-id"
docs/architecture/tenancy-invariants.md:24:- **Tenant-data tables** (9 in v0.2): `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`. All have `tenant_slug` column + RLS policy.
docs/architecture/tenancy-invariants.md:45:  Expected: 9 rows (entities, entity_links, decision_log, tenant_eval_sets, tenant_adapters, voice_corpus, voice_corpus_chunks, tone_rule, recent_edit).
docs/architecture/tenancy-invariants.md:249:| Q1 | Should T4 be promoted to structural via stored-procedure wrappers (so app code physically cannot INSERT without `SET LOCAL`)? | If Day-9 tenancy audit reveals an app-code path forgot the guard, AND the cost of T11 catching the leak is unacceptable (e.g., partial writes). |
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:16:--   - JSONB validation trigger for tenant_adapters.config: 3 new keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:419:-- §5 — tenant_adapters.config validation trigger (new keys)
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:426:CREATE OR REPLACE FUNCTION validate_tenant_adapters_config_v0_3()
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:437:    -- autosend-safety-policy.md keys
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:453:      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:529:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:531:CREATE TRIGGER validate_tenant_adapters_config_v0_3
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:532:  BEFORE INSERT OR UPDATE ON tenant_adapters
docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql:534:  EXECUTE FUNCTION validate_tenant_adapters_config_v0_3();
docs/architecture/architecture-cohesion-review.md:125:- **autosend-safety-policy.md** §7 says `payload_preview` MUST exclude raw PII (max 500 chars, no names/phones/emails)
docs/architecture/architecture-cohesion-review.md:149:| G3 | **`tenant_eval_sets` + `tenant_adapters` usage is unspecified.** Day-4 §6.3 creates the tables but no doc says when/how they're written. | Low (Week-4 Diagnostic eval-set dependency; lazy spec OK) | Spec follows first use — Diagnostic W4 build adds the first eval-set + the spec for it. Codex Round-1 issue #9 already flagged this. |
docs/architecture/architecture-cohesion-review.md:154:| G8 | **Auto-send v1.0 enforcement gap.** autosend-policy.yaml defines 4 tiers; v1.0 ships green+red only; canonical orange action_types (bullhorn_note_customer_visible etc.) have no v1.0 enforcement path. | High (Concierge W10 dependency) | Founder Decision D1 in `2026-05-20-codex-round-1-founder-decisions.md`. Block Concierge build until resolved. |
docs/architecture/architecture-cohesion-review.md:228:| R2 | G8: Autosend v1.0 tier enforcement | High | Founder Decision D1 | Founder | Pre-Concierge W10 |
docs/architecture/architecture-cohesion-review.md:237:| R11 | G3: tenant_eval_sets + tenant_adapters usage spec | Low | Codex Round-1 issue #9 deferred (lazy spec) | Claude Code | Diagnostic W4 (first eval-set) |
docs/architecture/architecture-cohesion-review.md:257:1. Founder Decisions D1 + D2 + D3 resolve before Concierge W10 + first pilot LOI signing
docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql:97:-- HNSW index for cosine-distance ANN queries (Q11 default A: store both)
agents/recruitment/cash-conductor/cycle.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
agents/recruitment/cash-conductor/cycle.sh:30:#      per D1-B Telegram shim — docs/decisions/2026-05-31-d1-founder-decision.md)
agents/recruitment/cash-conductor/cycle.sh:138:  # TODO(W7-8): provider-aware (tenant_adapters.config.accounting_provider)
agents/recruitment/cash-conductor/cycle.sh:209:# Reference: agent.md §4 Step 10 + D1-B (2026-05-31 founder decision).
agents/recruitment/cash-conductor/cycle.sh:225:    # Bridge package PRESENT — route each draft through the D1-B Telegram shim.
agents/recruitment/cash-conductor/cycle.sh:226:    # Per D1-B doc §"Implementation surface" items 1 + 3 (Cash Conductor consumer).
agents/recruitment/cash-conductor/cycle.sh:275:    #        # ESC_APPROVAL_BRIDGE_TIMEOUT per agents/_shared/escalation-codes.md
agents/recruitment/cash-conductor/cycle.sh:280:    #          "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:14400; approval_id:${APPROVAL_ID}" ;;
agents/recruitment/cash-conductor/cycle.sh:288:      "autosend-bridge-telegram package dist/ not present — drafts retained in vault for manual consultant pickup; build the package (pnpm --filter @ifos/autosend-bridge-telegram build) to enable the D1-B send path"
agents/recruitment/cash-conductor/cycle.sh:294:# Reference: agent.md §4 Step 11 + D1-B doc §"Implementation surface".
agents/recruitment/cash-conductor/cycle.sh:337:# tenant_adapters.config.cash_conductor_last_run (declared in v0.3 supplement; validated
agents/recruitment/cash-conductor/cycle.sh:338:# by validate_tenant_adapters_config_v0_3 trigger landed 2026-05-31).
agents/recruitment/cash-conductor/cycle.sh:339:# TODO(W7-8): UPDATE tenant_adapters SET config = jsonb_set(config, '{cash_conductor_last_run}', '"<ISO>"')
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:61:-- §3 — Per-tenant retention override storage (tenant_adapters extension)
docs/verticals/recruitment/migrations/v0.2-to-v0.3-pii-purge.sql:64:-- amendment. Storage is reserved at tenant_adapters.config.pii_retention_days
docs/architecture/agent-bundle-renderer-design.md:117:| _(no IFOS source)_ | `orgs/<org>/agents/<name>/goals.json` | **Synthesis (empty placeholder)** | None | Materialised as `{ "focus": "", "goals": [], "bottleneck": "", "updated_at": "", "updated_by": "" }` per `add-agent.ts:131-140`. Rationale: cortextOS's analyst / orchestrator workflows may read this file via their own bootstrap; absent it, some cortextOS skills throw. Cost of creating it is zero. Per Q1.5 / §2.2 below, IFOS agents do NOT invoke those skills, so the file is dead weight — but harmless dead weight that maintains daemon-side compatibility |
docs/architecture/cortexos-kb-surface-investigation.md:106:   - Q1: What does cortextOS itself depend on its KB for? (Analyst theta-wave skill, autoresearch, etc. — read template skills.)
agents/recruitment/cash-conductor/tools.yaml:24:  # Accounting providers (per-tenant — choose ONE via tenant_adapters.config.accounting_provider)
agents/recruitment/cash-conductor/tools.yaml:128:  # Autosend bridge (D1-B Telegram shim per 2026-05-31 founder decision;
agents/recruitment/cash-conductor/tools.yaml:133:  # Per D1-B doc §"Implementation surface" item 4: declare the capability on
agents/recruitment/cash-conductor/tools.yaml:140:    purpose: "Post orange-tier chase-send approval request to operator Telegram chat (D1-B founder decision)"
agents/recruitment/cash-conductor/tools.yaml:160:        escalation: ESC_APPROVAL_BRIDGE_TIMEOUT  # warn-tier per escalation-codes.md lines 348-353; routes operator_chat_id + ifos_oncall_chat_id; action converts to manual reconciliation
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:11:--   - Restores v0.2 tenant_adapters.config validation trigger
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:87:-- §4 — Restore v0.2 tenant_adapters validation (drop v0.3 trigger)
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:90:DROP TRIGGER IF EXISTS validate_tenant_adapters_config_v0_3 ON tenant_adapters;
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:91:DROP FUNCTION IF EXISTS validate_tenant_adapters_config_v0_3();
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:93:-- v0.2 trigger (if it existed) — currently no v0.2 validate_tenant_adapters
docs/verticals/recruitment/migrations/v0.3-to-v0.2.sql:95:-- tenant_adapters config validation trigger.
agents/recruitment/cash-conductor/validate.sh:13:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is the
agents/recruitment/scribe/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed schema field-name corrections + Step 3+7 decision-log additions + Ringover v1.1+ scoping + autosend cite split + ESC_PROVIDER_FETCH_FAIL v1.0 scope annotation. R19 fixes (today): v0.3 supplement RATIFIED claim corrected (supplement is Proposed not RATIFIED per its own status banner), `scribe_gate_a_fail` renamed to existing `validate_gate_a_fail`, ESC_BULLHORN_OAUTH_REVOKED reference removed (not in catalogue), ESC_SCRIBE_SLA_MISS threshold aligned to catalogue. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Fathom/Fireflies commercial signup + W6 build slice.
agents/recruitment/scribe/agent.md:237:Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Scribe's `validate.sh` enforces:
agents/recruitment/scribe/agent.md:315:| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
agents/recruitment/scribe/agent.md:336:**Status:** Proposed. Awaits Bullhorn A+B + Fathom/Fireflies + Q1 LOI + W6 build slice start.
agents/recruitment/scribe/agent.md:342:| Q1 | Fathom vs Fireflies — first-mover provider for v1.0? Both have UK presence; Fathom has tighter Bullhorn ecosystem ties; Fireflies has broader transcript model coverage. | Commercial decision; depends on first pilot tenant's existing tooling. |
agents/recruitment/scribe/agent.md:364:- Founder approves §9 Q1 (Fathom vs Fireflies) + Q3 (taxonomy) + Q4 (webhook timeout)
packages/utilities/web-scraper/pnpm-lock.yaml:52:    resolution: {integrity: sha512-c0uX9VAUBQ7dTDCjq+wdyGLowMdtR/GoC2U5IYk/7D1H1JYC0qseD7+11iMP2mRLN9RcCMRcjC4YMclCzGwS/A==}
packages/utilities/web-scraper/pnpm-lock.yaml:430:    resolution: {integrity: sha512-Z0gOTd75VvXqyq7nsl93zwahcTROgqvuAcYDUr+vOv8uHhNSKROyU961kgtCD1e95IqPKSQKH7tBTslnS3tA8A==}
packages/utilities/web-scraper/pnpm-lock.yaml:472:    resolution: {integrity: sha512-56hiAJPhwQ1R4i+21FVF7V8kSD5zZTdHcVuRFMW0hn753vVfQN8xlx4uOPT4xoGH0Z/oVATuR82AiqSTDIpaHg==}
packages/utilities/web-scraper/pnpm-lock.yaml:962:    resolution: {integrity: sha512-JFNbkD1Svwe0KvGi8GOeLcP4kAWQ609twvCdcHxq1oSL8svv39ZuSvajcD8B+5D0eL4+s1Is2D/O6KN3qcTeRA==}
agents/recruitment/cash-conductor/context.sh:73:# tenant_adapters.config; defaults to xero + truelayer per Cash Conductor §9 Q1+Q2.
agents/recruitment/cash-conductor/context.sh:77:# FROM tenant_adapters WHERE tenant_slug = $CTX_TENANT_SLUG; honour defaults.
agents/recruitment/cash-conductor/context.sh:78:# v0.3 supplement §4 tenant_adapters_config_additions includes neither key yet;
agents/recruitment/janitor/README.md:3:**Status:** Proposed (Day-16 pre-W5-build scaffold; awaits Bullhorn A+B + Q1 LOI + W5 build slice).
agents/recruitment/janitor/README.md:29:- First pilot tenant onboarded (per Q1 LOI signing)
packages/utilities/autosend-bridge-telegram/src/index.ts:3:// Per D1-B founder decision (docs/decisions/2026-05-31-d1-founder-decision.md):
agents/recruitment/cash-conductor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R17 closed §8 sibling files + D1/bridge prereqs + §3 audit-row signatures (4-row chase lifecycle sequence). R19 fixes (today): split draft body out of decision_log payload into vault path (per ADR-002 vault/Postgres split), recent_edit schema R access cite correction, Stage 3 ESC code disambiguation. Awaits Q1 LOI + accounting + Open Banking commercial signups + Founder Decision D1 resolved + autosend bridge built (Concierge W10) + W7 build slice.
agents/recruitment/cash-conductor/agent.md:18:> **Cash Conductor produces THREE outputs continuously:** (1) real-time invoice ↔ bank-deposit reconciliation rows written to the tenant's accounting system (Xero / QuickBooks / Sage per tenant config), (2) yellow-tier payment-chase email drafts (sampled spot-check) + orange-tier `xero_reminder_send_customer` action rows initiated by Cash Conductor — Cash Conductor owns the action_type per autosend-policy.yaml line 263; Concierge handles the approval bridge + transport (not action-row authorship). Cash Conductor never executes the SMTP/Graph send directly; Concierge does the transport, and (3) a weekly cash-flow Markdown report at `/vault/<tenant>/cash-conductor-reports/weekly-<ISO-date>.md` (generated Monday 06:00 UTC). NO direct Bullhorn API dependency — Cash Conductor operates against the tenant's accounting + Open Banking stack (no Bullhorn endpoint calls). It DOES read cached Bullhorn placement + client_contact rows from Postgres for addressee-resolution integrity (per ESC_ADDRESSEE_MISMATCH catalogue §2.10 — Cash Conductor verifies invoice addressee matches Bullhorn placement client OR Xero contact). The cached Bullhorn rows are populated by Janitor + Scribe + Concierge from their direct Bullhorn endpoint paths; Cash Conductor never calls Bullhorn directly. Per ADR-005 strategic-value rationale: Cash Conductor is unaffected by Bullhorn API slips because it only reads the cache. Gate A hard-fails any chase draft that doesn't reference the correct invoice number AND correct amount AND correct contact (per ULTRAPLAN A4 line 538). Gate A also blocks any chase for an invoice paid in last 24 hours (per ULTRAPLAN A4 line 538 verbatim). Gate B success threshold: tenant DSO at month-3 ≥ 12 days lower than month-0 baseline (per ULTRAPLAN A4 line 539) — the FD-tier closer metric. Chase drafts are yellow-tier `xero_reminder_draft_internal` (per `agents/_shared/autosend-policy.yaml` lines 188-193 — internal draft sampled for spot-check); the customer-facing send routed via Concierge is orange-tier `xero_reminder_send_customer` (per `agents/_shared/autosend-policy.yaml` lines 263-268; consultant approval required before send). Reconciliation writes are yellow-tier (`accounting_reconciliation_write` per autosend-policy.yaml; registered as part of 2026-05-24 bilateral catalogue extension). **v1.0 readiness caveat:** if Founder Decision D1 is unresolved OR the Concierge autosend bridge has not shipped (both gated per §8), Cash Conductor v1.0 runs in **drafts-only** mode — it produces the yellow-tier `xero_reminder_draft_internal` rows + vault drafts but does NOT write the orange-tier `xero_reminder_send_customer` rows that open the send pipeline (per §8 fallback row).
agents/recruitment/cash-conductor/agent.md:57:- **Manual triggers (ifosctl below):** require operator OS account in the `ifos-operators` group; per-invocation `--tenant <slug>` is verified against the operator's tenant access list in `tenant_adapters` before execution. Founder + Hire #1 are the v1.0 ifosctl-authorized operators per master brief §8.2 line 604.
agents/recruitment/cash-conductor/agent.md:209:   → spot-check sampling per autosend-safety-policy.yaml yellow tier
agents/recruitment/cash-conductor/agent.md:260:      operator (D1 path per Founder Decision)
agents/recruitment/cash-conductor/agent.md:293:    → update tenant_adapters.config.cash_conductor_last_run = now()
agents/recruitment/cash-conductor/agent.md:307:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Cash Conductor's `validate.sh` enforces (per ULTRAPLAN A4 line 538 verbatim):
agents/recruitment/cash-conductor/agent.md:386:| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
agents/recruitment/cash-conductor/agent.md:404:| **Founder Decision D1 (autosend orange-tier path) RESOLVED** — blocking for Cash Conductor's xero_reminder_send_customer action_type | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` D1 (currently Proposed) | ⏸ |
agents/recruitment/cash-conductor/agent.md:405:| **Autosend bridge implementation** (per D1 outcome) — Concierge W10 build delivers; blocking for orange-tier send writes | Concierge W10 build slice (~2 days for D1-A; less for D1-B/C) | ⏸ |
agents/recruitment/cash-conductor/agent.md:406:| Fallback: if D1 + bridge not ready by W7-8, Cash Conductor v1.0 downgrades to drafts-only (yellow-tier `xero_reminder_draft_internal` only; no orange-tier `xero_reminder_send_customer` writes until D1 resolves + bridge ships) | v1.0 contingency | n/a |
agents/recruitment/cash-conductor/agent.md:414:**Status:** Proposed. Awaits Q1 LOI + accounting + Open Banking commercial signups + W7-8 build slice start.
agents/recruitment/cash-conductor/agent.md:420:| Q1 | First-tenant accounting choice — Xero / QuickBooks / Sage? Affects which connector is W7-prio-1. | Tenant onboarding; depends on first pilot tenant's existing stack. |
agents/recruitment/cash-conductor/agent.md:444:- Founder approves §9 Q1 + Q2 + Q4 + Q7 + Q8
agents/recruitment/sourcing-scout/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fix applied. R9 added §10 three-state lifecycle clarification (Proposed → Ratified-as-Scaffold → Accepted → In Force; ratification ≠ acceptance per agent-bundle skill) + §4 Step 8 + Schema-key block rewrite for `blocked_recipients`. R19 (today): adds `blocked_recipients` declaration to v0.3 supplement §4 tenant_adapters_config_additions per Codex Finding 1. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Proxycurl + Reed + CV-Library commercial signups + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:7:- `tenant_adapters.config.blocked_recipients` — registered in `migrations/v0.2-to-v0.3.sql §5` validator allowlist (key at line 398; allowlist block lines 396-409); canonical Postgres-backed v1.0 DNC source per ADR-002. Declared in `vertical-schema.v0.3-supplement.yaml` lines 810-827 (R19 added this declaration; no longer deferred).
agents/recruitment/sourcing-scout/agent.md:8:- `tenant_adapters.config.auto_source_on_brief_create` — v0.4-supplement-pending (not yet in any allowlist); the Bullhorn-webhook auto-source trigger code path is blocked until v0.4 lands.
agents/recruitment/sourcing-scout/agent.md:21:> **Sourcing Scout ingests a brief description (free-text role description + optional Bullhorn brief_id reference) and produces a ranked list of 5-15 passive candidate matches aggregated from FOUR sources** (Bullhorn ATS passive-match read; LinkedIn via Proxycurl; Reed.co.uk API; CV-Library API). Output is a Markdown report at `/vault/<tenant>/sourcing-scout-reports/<brief-slug>-<ISO-date>.md` containing the ranked candidates, per-candidate match rationale (≥50 words each per Gate A), confidence score [0,1], contact method, and source attribution. Typical runtime: 60-120 seconds per brief. Triggered via Brain UI button OR Telegram command (`@ifos_bot scout <brief-id>`). Bullhorn "new brief" webhook auto-source (per ULTRAPLAN A5 line 547) is DEFERRED to v1.1+ — blocked on `auto_source_on_brief_create` config key landing in a v0.4 supplement. Gate A hard-fails any run that returns <5 OR >15 candidates, any candidate without a working contact method, any rationale <50 words, OR any candidate matching the tenant's DNC list (`tenant_adapters.config.blocked_recipients` — Postgres-backed per ADR-002; per ULTRAPLAN A5 line 552 wording "do not contact in tenant vault" is interpreted per v0.3 supplement as the Postgres-backed config key, not a vault markdown file — ADR-002 vault/Postgres split puts structured state in Postgres). Gate B success threshold: ≥6 of 10 candidates advance past first consultant review (per ULTRAPLAN A5 line 553 — shared target with Night Sourcer v1.1). Source-abstraction layer designed for Night Sourcer reuse (per ULTRAPLAN A5 line 555 gotcha).
agents/recruitment/sourcing-scout/agent.md:114:     + DNC list from `tenant_adapters.config.blocked_recipients` (Postgres-
agents/recruitment/sourcing-scout/agent.md:196:   → load tenant DNC list from `tenant_adapters.config.blocked_recipients`
agents/recruitment/sourcing-scout/agent.md:256:Per master brief §8.1 Change 2 + autosend-safety-policy §4. Sourcing Scout's `validate.sh` enforces (per ULTRAPLAN A5 line 552 verbatim):
agents/recruitment/sourcing-scout/agent.md:261:- **"no candidate flagged 'do not contact' in tenant config"** (DNC scan against `tenant_adapters.config.blocked_recipients` Postgres-stored list per ADR-002 vault/Postgres split)
agents/recruitment/sourcing-scout/agent.md:337:| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
agents/recruitment/sourcing-scout/agent.md:348:| Tenant DNC list populated in `tenant_adapters.config.blocked_recipients` (Postgres-backed structured state per ADR-002 vault/Postgres split) | Tenant onboarding | ⏸ |
agents/recruitment/sourcing-scout/agent.md:361:**Status:** Proposed. Awaits Bullhorn A+B + 3 commercial signups (Proxycurl + Reed + CV-Library) + Q1 LOI + W9 build slice.
agents/recruitment/sourcing-scout/agent.md:367:| Q1 | All three external sources required for v1.0? Reed + CV-Library are UK-recruitment-specific; Proxycurl is LinkedIn-via-API. Could v1.0 ship with Bullhorn + Proxycurl only (2 sources)? | Founder strategic. Recommend 3 sources minimum for 5-15 candidate Gate A coverage; Reed if tenant focused on perm; CV-Library if tenant focused on contract. |
agents/recruitment/sourcing-scout/agent.md:369:| Q3 | DNC list source — tenant_adapters.config.blocked_recipients (Postgres-stored, already-registered config key), with v1.1 derivation from Bullhorn candidate.status='do_not_contact'? | v1.0: tenant-admin manages via tenant_adapters.config.blocked_recipients (per ADR-002 vault/Postgres split — structured state in Postgres). v1.1: auto-sync from Bullhorn candidate.status='do_not_contact'. |
agents/recruitment/sourcing-scout/agent.md:394:   - Founder approves §9 Q1 (3 sources vs 2) + Q3 (DNC source) + Q5 (Gate B UX)
packages/utilities/autosend-bridge-telegram/src/bridge.ts:47:  if (!input.operator_telegram_chat_id) {
packages/utilities/autosend-bridge-telegram/src/bridge.ts:48:    throw new BridgeInputError("operator_telegram_chat_id is required");
packages/utilities/autosend-bridge-telegram/src/bridge.ts:85:      chat_id: input.operator_telegram_chat_id,
packages/utilities/autosend-bridge-telegram/src/bridge.ts:91:        `agent layer should surface ESC_AGENT_TOOL_FAILURE, not ESC_APPROVAL_BRIDGE_TIMEOUT`,
packages/utilities/autosend-bridge-telegram/src/bridge.ts:102: * the discriminated-union surface in the D1-B doc); if `throwOnTimeout` is set
agents/recruitment/janitor/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R11 closed Gate A ESC routing + recent_edit citation + v0.3 supplement §2a authority. R12 added schema declaration for `janitor_dedup_threshold` + `janitor_last_run` in v0.3 supplement §4. R19 fixes (2026-05-25): autosend-policy citation, contractor dedup scope alignment, Step 8 audit row, ESC_GATE_B_MISS catalogue alignment. Awaits Q1 LOI + Bullhorn Sub-decisions A+B Accepted + W5 build slice.
agents/recruitment/janitor/agent.md:17:> **Janitor produces TWO outputs per nightly cron run:** (1) a Markdown day-30 cleanup report at `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md` documenting all data-hygiene actions taken in the prior 30 days, and (2) a stream of yellow-tier writes to the tenant's Bullhorn ATS that (a) merge high-confidence duplicate candidate AND contractor records (separate entity types per vertical-schema.yaml §1; same fuzzy-matcher per §4 Steps 3-4), (b) backfill missing field values via Companies House enrichment, and (c) attach tacit notes harvested from `recent_edit.resolution='approved_after_edit'` rows (v0.3 supplement §2a grants Janitor R access). Cron fires at 02:00 UTC daily; the day-30 report regenerates on the 1st of each month rolling. Gate A hard-fails any merge proposal with confidence <0.85 (per ULTRAPLAN A2 line 510). Gate B success threshold: the day-30 report shows ≥15% dedup rate improvement AND ≥10% field-completeness improvement vs the day-0 baseline established at first pilot LOI signing (per ULTRAPLAN A2 line 511). Auto-band Bullhorn writes are yellow-tier per `agents/_shared/autosend-policy.yaml` runtime (policy rationale at `docs/decisions/autosend-safety-policy.md`) — sampled spot-checks, no synchronous approval; review-band dedup merges (0.70–0.85 confidence, or ≥0.85 with Bullhorn activity in the last 90 days) are instead held for synchronous Telegram approval via `ESC_DUPLICATE_DETECTED` before write. Every write emits a per-write audit row to `decision_log` with `agent_name='janitor'`.
agents/recruitment/janitor/agent.md:43:- Tenant-admin override for dedup confidence threshold (default 0.85; per-tenant via `tenant_adapters.config.janitor_dedup_threshold` — declared in `vertical-schema.v0.3-supplement.yaml §4 tenant_adapters_config_additions.janitor_dedup_threshold`; enforced by `migrations/v0.2-to-v0.3.sql §5` validator allowlist)
agents/recruitment/janitor/agent.md:96:     tenant_adapters.config.janitor_last_run — declared in vertical-schema
agents/recruitment/janitor/agent.md:97:     v0.3 supplement §4 tenant_adapters_config_additions.janitor_last_run;
agents/recruitment/janitor/agent.md:112:   → same algorithm as candidates; separate entity_type per Q1 Day-6 resolution
agents/recruitment/janitor/agent.md:174:   → update tenant_adapters.config.janitor_last_run = now()
agents/recruitment/janitor/agent.md:185:Per master brief §8.1 Change 2 + `docs/decisions/autosend-safety-policy.md` §4 (policy rationale; runtime YAML is `agents/_shared/autosend-policy.yaml`). Janitor's `validate.sh` enforces:
agents/recruitment/janitor/agent.md:263:| First pilot tenant onboarded (provision-tenant.sh) | Post Q1-LOI | ⏸ Founder action; Trigger 1 fires 2026-06-03 if no LOI |
agents/recruitment/janitor/agent.md:283:**Status:** Proposed. Awaits Bullhorn A+B Accepted + Q1 LOI + W5 build slice start.
agents/recruitment/janitor/agent.md:289:| Q1 | Dedup confidence threshold default — 0.85 per ULTRAPLAN A2 line 510, but should this be per-tenant overridable via `tenant_adapters.config.janitor_dedup_threshold`? | Founder review at agent.md ratification. Recommend: default 0.85; per-tenant override [0.75, 0.95]. |
agents/recruitment/janitor/agent.md:310:- Founder approves §9 open questions Q1 + Q2 + Q4 + Q5 + Q6
packages/utilities/autosend-bridge-telegram/src/types.ts:3:// Mirrors the D1-B founder-decision implementation surface
packages/utilities/autosend-bridge-telegram/src/types.ts:6:/** Default approval window per ESC_APPROVAL_BRIDGE_TIMEOUT (escalation-codes.md lines 348-353). */
packages/utilities/autosend-bridge-telegram/src/types.ts:30:  /** Telegram chat ID for the tenant's operator (from tenant_adapters.config.operator_telegram_chat_id). */
packages/utilities/autosend-bridge-telegram/src/types.ts:31:  operator_telegram_chat_id: string;
packages/utilities/autosend-bridge-telegram/src/types.ts:40:  /** ID of the originating decision_log row (used by ESC_APPROVAL_BRIDGE_TIMEOUT payload). */
agents/recruitment/diagnostic/fixtures/02-edge-case-no-online-footprint.yaml:10:# Reading order: agent.md §3 + agent.md §9 Q1-Q6 open questions.
packages/utilities/autosend-bridge-telegram/src/errors.ts:2:// agents/_shared/escalation-codes.md §2 + the D1-B decision doc.
packages/utilities/autosend-bridge-telegram/src/errors.ts:28: * ESC_APPROVAL_BRIDGE_TIMEOUT — that one fires only when the message went out
packages/utilities/autosend-bridge-telegram/src/errors.ts:41: * ESC_APPROVAL_BRIDGE_TIMEOUT (escalation-codes.md lines 348-353; warn tier;
docs/build-brief/00-MASTER-BRIEF.md:415:| **v1.2 — the graph** | Q1 2027 | `graphify/*`, `/brain/graph`, cytoscape rendering — becomes the closing demo |
docs/build-brief/00-MASTER-BRIEF.md:470:- [ ] Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per ADR-002 Edit 3 + `docs/architecture/second-brain-design.md` §2.4.2).
docs/build-brief/00-MASTER-BRIEF.md:477:- [ ] `docs/decisions/autosend-safety-policy.md` — categorical list of what may auto-send vs draft-only per tier, standing-authorisation contract per agent, escalation cascade, pilot-agreement liability language
docs/build-brief/00-MASTER-BRIEF.md:663:        │ (raw + compiled)│                  │ RLS-isolated           │                  │ tenant_adapters    │
docs/_archive-build-pack/03-ARCHITECTURE.md:506:Alternative: all-Cloudflare (Pages + Workers + R2 + D1) — possible if daemon moves to a separate Fly.io / fly machine and the dashboard stays simple. See `08-OPEN-DECISIONS.md` §6.
docs/architecture/second-brain-design.md:86:The Q1 finding that "no IFOS-owned agent calls kb-*" assumed IFOS agents are NOT scaffolded from cortextOS's base template. That assumption needs verification, because if `cortextos-ifos add-agent` is the path IFOS uses, the inherited `.claude/skills/` tree pulls `knowledge-base` and `memory` skills in by default, and those skills DO call `kb-*`.
docs/architecture/second-brain-design.md:106:24 skills. Of these, **`knowledge-base/SKILL.md`** calls `kb-query / kb-ingest / kb-collections / kb-setup` (Q1.1 inventory), and **`memory/SKILL.md`** calls `kb-ingest` for heartbeat memory re-ingestion (analyst memory SKILL.md:107).
docs/architecture/second-brain-design.md:416:The `decision_log` finding from Q1.4 is load-bearing here: every write operation triggers `hh_decision_*` calls per master brief §8.1 Change 2 (lines 170-173). The `entity-history` operation reads from the Postgres `decision_log` table, **not** from a separate per-entity history file. This is why the master brief's `_decisions/` directory in Ultraplan §5.1 is a spec gap (2.1-B) — there are two candidates for "where history lives" and only one of them is in the master brief.
docs/architecture/second-brain-design.md:613:Per Q1.5, **zero use of cortextOS's `kb-*` surface by IFOS-owned agents in v1.0 or v1.1.** cortextOS's mmrag.py + ChromaDB + Gemini-embedding stack stays in place under `$HOME/.cortextos/ifos-v2/orgs/<org>/knowledge-base/` for any cortextOS-template agent that happens to be scaffolded in `ifos-v2` (debug, probe, worker spawn).
docs/architecture/second-brain-design.md:792:- **Q1.5:** cortextOS KB untouched. The wiki is a parallel system.
docs/architecture/second-brain-design.md:906:1. **Master brief §3.1 (submodule boundary).** The §3.1 exception is "shadow four `bus/kb-*.sh` points." Per Q1.5 we don't shadow those — but the **pattern** §3.1 authorises (parallel `bus-overrides/` directory housing shell wrappers that match cortextOS's bus convention) is exactly what Option α uses. We use the boundary's *vocabulary* without exercising its kb-* exception. Option β would require introducing a new vertical surface (MCP server alongside daemon and dashboard) that §3.1 doesn't anticipate. Option γ would require modifying the renderer's skill-installation path, contradicting §1.7's R2 recommendation.
docs/architecture/second-brain-design.md:950:3. **Postgres schema migration scripts** (Spec gap 2.4-B resolution — `entities` + `entity_links` split). Land as part of the Week 0 Day 4 infra task per master brief §6 Day 4 "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`". The §6 wording also needs the §3.4 rename: `entity_graph` → `entities` + `entity_links`. **Day 4 of Week 0** (so this week).
docs/architecture/second-brain-design.md:976:| **3.4-A** | Master brief §5.5 (lines 416-420) v1.0 brain wording | Says "shadow four files" — incorrect per Q1.5 | Rewrite per §3.4 of this design: "9 `wiki-*.sh` parallel wrappers + Postgres entities/entity_links/decision_log + pgvector voice." Bundles with ADR-002 atomic correction commit. | No — wording change, not work change. |
docs/architecture/second-brain-design.md:977:| **3.4-B** | Master brief §6 Day 4 (line 478) Postgres table list | Lists `entity_graph` as a single table | Update wording: "`tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`." Bundles with Day 4 provisioning. | **Tight** — Day 4 of Week 0 (this week). |
agents/recruitment/diagnostic/README.md:27:## Why this directory exists at Day 11 (pre-Q1 LOI)
agents/recruitment/diagnostic/README.md:49:- ⏸ Q1 design partner LOI signed
packages/utilities/autosend-bridge-telegram/package.json:5:  "description": "IFOS Telegram approval-bridge — proposeApproval() + awaitApprovalDecision() for orange-tier autosend gating. Per D1-B founder decision (docs/decisions/2026-05-31-d1-founder-decision.md). Consumed by Concierge cycle.sh Step 11 + Cash Conductor cycle.sh Step 10.",
docs/specs/ULTRAPLAN.md:54:I do not have a status report on CortexOS readiness (this is Q1, deferred). The build plan assumes each primitive has the following minimum viable state by start of v1.0 Sprint 1. If reality is worse than this, the sprint plan in §9 slips and we say so honestly.
docs/specs/ULTRAPLAN.md:562:- **CortexOS primitives required:** Persistent PTY (#1), context rotation (#2), approval gates (#4), Telegram surface (#5)
docs/specs/ULTRAPLAN.md:709:3. **Telegram** — 16 of 18. Comes free with CortexOS if primitive #5 works.
docs/specs/ULTRAPLAN.md:864:- [ ] Auto-Send Safety Policy artefact drafted (Q11). **Owner:** Maddox. **Output:** `auto-send-safety-policy.md`.
docs/specs/ULTRAPLAN.md:865:- [ ] v1.0 kill criterion documented (Q12). **Owner:** Maddox. **Output:** `v1-kill-criterion.md`.
packages/utilities/autosend-bridge-telegram/README.md:3:Telegram approval-bridge for orange-tier autosend gating. Backs the **D1-B founder decision** (`docs/decisions/2026-05-31-d1-founder-decision.md`) — consumed by **Concierge `cycle.sh` Step 11** + **Cash Conductor `cycle.sh` Step 10**.
packages/utilities/autosend-bridge-telegram/README.md:13:The D1 founder decision evaluated three options:
packages/utilities/autosend-bridge-telegram/README.md:17:| D1-A — cortextOS approval system + Brain UI rich-panel | weeks of build | Right v1.1+ answer; too expensive for v1.0 |
packages/utilities/autosend-bridge-telegram/README.md:18:| **D1-B — Telegram `/approve`/`/reject` commands** (chosen) | <1 day | Reuses cortextOS primitive #5 (Telegram surface); ships in W10–13 |
packages/utilities/autosend-bridge-telegram/README.md:19:| D1-C — manual vault polling | none | Concierge fails Gate B (ghosted-rate <5%); non-starter |
packages/utilities/autosend-bridge-telegram/README.md:21:Audit chain is identical to D1-A: same `decision_log` rows fire (orange action → operator approve/reject → transport action). The Telegram interaction is the **trigger**, not the audit substrate. v1.1+ can add D1-A as an option without replacing D1-B.
packages/utilities/autosend-bridge-telegram/README.md:86:| Operator never replies before `expires_at` | `outcome: "timeout"` or `BridgeTimeoutError` | `ESC_APPROVAL_BRIDGE_TIMEOUT` (warn; operator + ifos_oncall; PT4H default) |
packages/utilities/autosend-bridge-telegram/README.md:89:`ESC_APPROVAL_BRIDGE_TIMEOUT` lives at `agents/_shared/escalation-codes.md` lines 348-353. Recovery: action converts to manual reconciliation; operator handles offline.
packages/utilities/autosend-bridge-telegram/README.md:137:- D1-B decision: `docs/decisions/2026-05-31-d1-founder-decision.md`
packages/utilities/autosend-bridge-telegram/README.md:139:- Escalation catalogue: `agents/_shared/escalation-codes.md` §2.6 (`ESC_APPROVAL_BRIDGE_TIMEOUT`) + §2.7 (`ESC_AUTOSEND_RACE`)
docs/operations/goal-overnight-2026-05-31.md:9:- W3 contracts ratified (8/9 + R3 fix); ADR-007 Accepted; D1-B taken.
agents/recruitment/diagnostic/validate.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh
docs/specs/_archive-build-handoff.md:272:`docs/auto-send-safety-policy.md` (Q11 from the Ultraplan's source Q&A):
docs/specs/_archive-build-handoff.md:278:`docs/v1-kill-criterion.md` (Q12):
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:20:Public API (per D1-B decision doc §"Implementation surface"):
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:23:- Telegram bot token from `_secrets.env` (existing per Day-4 provisioning); operator chat ID from `tenant_adapters.config.operator_telegram_chat_id` (canonical config key)
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:24:- Default timeout `PT4H` per `escalation-codes.md` lines 348-353 (`ESC_APPROVAL_BRIDGE_TIMEOUT`)
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:27:≥12 vitest (scaffold + config + propose + await with poll-mock + timeout + reject path + concurrent same-approval-id idempotency). Live Telegram tests gated `BRIDGE_LIVE_TESTS=true`. Zero credential interpolations in errors. README documents D1-B precedent + Concierge W10 integration contract + Cash Conductor `cycle.sh` Step 10 wiring.
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:44:Ask: deviation from D1-B decision doc · deviation from agent.md output contract · commercial signup · live API call · ratified-artefact edit · ECC package install · Codex disagreement.
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:21:  operator_telegram_chat_id: "987654321",
packages/utilities/autosend-bridge-telegram/tests/propose-approval.test.ts:130:      proposeApproval({ ...validInput, operator_telegram_chat_id: "" }, { transport, decisions }),
docs/operations/codex-round-2-autonomous-prompt.md:97:For autosend-safety-policy.md (Tier 1 item #6) and v0.2 supplement (item 
docs/operations/codex-round-2-autonomous-prompt.md:98:#14): these have founder-decision-bound issues (D1, D3). If the content 
docs/operations/codex-round-2-autonomous-prompt.md:253:4. **DO NOT make founder decisions.** Items like D1 (autosend orange tier), 
docs/operations/codex-round-2-autonomous-prompt.md:304:- A replacement for any founder decision (D1-D5 are surfaced, not decided)
docs/specs/PRODUCT-SPEC.md:412:- **CortexOS layer:** PM2, agent process supervision, file bus, Telegram surface, approval gates, context rotation, orchestrator template.
docs/specs/PRODUCT-SPEC.md:480:### 9.2 v1.1 (Q4 2026 → Q1 2027) — the always-on suite at full strength
packages/utilities/autosend-bridge-telegram/tests/await-decision.test.ts:21:  operator_telegram_chat_id: "987654321",
agents/recruitment/diagnostic/agent.md:160:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` (Accepted; Day 19 founder-arbitrated). Diagnostic's `validate.sh` enforces the following SPEC.
agents/recruitment/diagnostic/agent.md:226:| Q1 design partner LOI signed | Risk #3 + kill-criterion §2 Trigger 1 | ⏸ Jack's lane |
agents/recruitment/diagnostic/agent.md:244:**Status:** Proposed. Awaits Q1 LOI + first pilot tenant onboarded + Codex RATIFIED verdict + first production render.
agents/recruitment/diagnostic/agent.md:252:| Q1 | Is "12 sections" the right number? Ultraplan §8.1 A1 says "12 required sections" but doesn't enumerate. This document proposes a 12-section list (§3); founder may want to revise. | Founder reviews §3 table; can split/merge sections. Lands as Edit in next commit. |
docs/operations/founder-manual-playbook-2026-05-31.md:248:## 🔴 PRIORITY 5 — Q1 LOI status with Jack (~5 min)
docs/operations/founder-manual-playbook-2026-05-31.md:381:| D1 decision doc | `docs/decisions/2026-05-31-d1-founder-decision.md` |
packages/utilities/autosend-bridge-telegram/tests/message-format.test.ts:14:  operator_telegram_chat_id: "987654321",
docs/operations/codex-ratification-guide.md:257:Run after live migration + Q1 LOI close.
docs/operations/codex-ratification-guide.md:478:The execution plan §9 names three options for when to start ratification (α = now, β = after Q1, γ = hybrid). Founder bias is γ.
docs/operations/goal-week-3-polish-and-scaffold.md:26:9. **`docs/decisions/autosend-safety-policy.md`** §2-§4 (4-tier model + 29 action types) + §10 (pilot-agreement liability)
docs/operations/goal-week-3-polish-and-scaffold.md:56:9. **`agents/recruitment/concierge/agent.md`** exists. Status: Proposed. Cites master brief §8.2 line 599 + ULTRAPLAN §8.1 A6 lines 561-570 + autosend-safety-policy §4 (orange tier) + Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:109:| Tenant onboarding outside migration-test | Single-tenant scope; production tenant onboarding happens post-Q1-LOI |
docs/operations/goal-week-3-polish-and-scaffold.md:305:- **§1 Output contract:** nightly cleanup sweep across pilot tenant's Bullhorn data. Writes (a) day-30 before/after report Markdown to `/vault/<tenant>/janitor-reports/day-30-<ISO-date>.md`; (b) field-level Bullhorn writes (deduplication, field completeness fixes, tacit-note attachment). All writes Tier 1 yellow per autosend-safety-policy.
docs/operations/goal-week-3-polish-and-scaffold.md:416:- `autosend-safety-policy.md` §4 (orange-tier model) + §3 (29 action types — Concierge's are bullhorn_note_customer_visible, candidate_state_change_email, etc.)
docs/operations/goal-week-3-polish-and-scaffold.md:417:- `2026-05-20-codex-round-1-founder-decisions.md` §D1 (autosend orange-tier decision)
docs/operations/goal-week-3-polish-and-scaffold.md:424:- **§1 Output contract:** monitors Bullhorn placement-state transitions (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → day-7-check-in → day-30-check-in → day-90-check-in); generates customer-facing communication drafts at each lifecycle event; orange-tier autosend per Founder Decision D1 (bridge-vs-shim).
docs/operations/goal-week-3-polish-and-scaffold.md:425:- **§3 Output shape:** message drafts (email / Bullhorn note customer-visible / SMS as configured); decision-log audit row per send; orange-tier spot-check sampling at 1-in-N rate per autosend-safety-policy §4.
docs/operations/goal-week-3-polish-and-scaffold.md:426:- **§4 Workflow:** ~15 steps. Bullhorn poll every 5 min → detect state transition → fetch context (candidate + client + placement entities) → identify message template → LLM draft → voice classifier ≥0.75 → tone-rule check → tier classification → autosend bridge call (per D1 decision) → audit row.
docs/operations/goal-week-3-polish-and-scaffold.md:427:- **§5 Gate A:** validate.sh hard-fails on missing approval-bridge auth (if D1-A bridge), voice classifier <0.75, tone-rule block-severity hit, schema violation, orange-tier-spot-check sample selected.
docs/operations/goal-week-3-polish-and-scaffold.md:429:- **§6 Escalation codes:** ESC_AUTOSEND_BLOCKED, ESC_VOICE_DRIFT, ESC_TONE_RULE_VIOLATION, ESC_APPROVAL_BRIDGE_TIMEOUT, ESC_BULLHORN_AUTH, ESC_LIFECYCLE_STATE_UNKNOWN.
docs/operations/goal-week-3-polish-and-scaffold.md:431:- **§8 Build prerequisites:** D1 autosend orange-tier decision RESOLVED + Bullhorn MCP R+W + voice classifier microservice live + approval bridge built (per D1 outcome) + tenant tone_rule table seeded.
docs/operations/goal-week-3-polish-and-scaffold.md:661:  - <list any open D1/D2/D3 decisions surfaced during Week 3>
docs/operations/founder-legal-setup-guide.md:229:> Would you provide a quote? Happy to share more about our autosend-safety-policy on a call.
docs/RISK-REGISTER.md:12:| 3 | First design partner not signed by end of Week 0 | **High** (status escalated Day 5; **MATERIALISED Day 7** as single-sentence-test Q1 = NO) | High | **Kill criterion Trigger 1 fires end-of-day 2026-06-03 if no signed LOI by then** (per `docs/decisions/v1.0-kill-criterion.md` §2 Trigger 1; calendar: 10 calendar days from today 2026-05-24) | Sales conversations start before Week 0; do NOT begin agent code until first LOI lands | **Updated Day 13 (2026-05-24):** **Sales artefact now exists** — Diagnostic v0 end-to-end pipeline live (commits `800a265` → `fd38254`); produces a 12-section Markdown report for any UK firm name. Master brief §8.2 line 595 named Diagnostic as "sales tool — needed before any other agent matters" — that tool is now real. Jack's Q1 pitch can pivot from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm — and the full version is in your pilot"). **Risk #3 mitigation path strengthened**, status unchanged pending actual LOI signature. 10-day window to Trigger 1 fire. |
docs/RISK-REGISTER.md:21:| 5 | **Renderer-not-built** — without ADR-003 + the IFOS bundle renderer code, no IFOS agent can run because the daemon reads from `orgs/<org>/agents/<name>/` but the v2 bundle lives at `agents/recruitment/<name>/` | High (severity unchanged; staged-ladder mid-stage) | High | Week-4 Diagnostic render fails or doesn't run | **Updated Day 8 (2026-05-20):** **Renderer code shipped.** `packages/agent-renderer/` complete at `3c16d35` — 8 TypeScript source files, 30 Vitest unit tests all green, end-to-end render verified against test fixture (`outcome=rendered`, 10 files, ~23ms), `cortextos-ifos list-agents` discoverAgents() smoke confirms daemon-discovery works, Risk #1 stress test 10-iter stable, goals.json drift-check NO DRIFT at pinned SHA c21fbfe. `_shared/` runtime: hook-helpers.sh + autosend-policy.yaml + voice-loader.sh all shellcheck-clean + 29 Bash tests passing (`e6e9df1` + `fe56e93`). Vertical-schema v0.2 voice corpus substrate + migration SQL (`45b59e0`). **Risk #5 stays at High** per the staged ladder: ADR-003 line 145 requires BOTH "renderer code committed" (now ✓) AND "Diagnostic agent renders cleanly (Week 4)" for High → Medium. Diagnostic bundle does not yet exist (gated on Q1 design partner LOI per Risk #3). When Diagnostic first renders cleanly at W4, severity drops to Medium. Three implementation deviations flagged for ADR-004 ratification: (a) CLI-name divergence (`ifos-render-agent` standalone vs `cortextos-ifos render-agent` per ADR-003 §3.3.1; submodule read-only boundary prevents the latter); (b) `_shared/` symlink target counting error in ADR-003 §3.3.3 (spec says `../../_shared`, correct is `../../../_shared` — 3 vs 4 levels); (c) phantom `_shared` listing in upstream `cortextos-ifos list-agents` (renderer correctness unaffected; cosmetic). **Owner:** Claude Code Day 8 commit chain shipped; founder for Diagnostic-build green-light when Q1 turns YES. |
docs/RISK-REGISTER.md:56:- 2026-05-22 (Day 11 evening) — **Codex Round-2 remediation applied + Round 3 verified.** Fixes wrap all identified `SET LOCAL` calls in explicit transactions and make `recent_edit.original_text` nullable before PII purge; Risks #11 and #12 moved to mitigated. Founder-domain D1/D2/D3 remain open and are explicitly annotated in the affected artefacts.
docs/RISK-REGISTER.md:64:- 2026-05-18 (Day 5) — **Day 5 decision artefacts shipped: `docs/decisions/autosend-safety-policy.md` + `docs/decisions/v1.0-kill-criterion.md` (both Status: Proposed).** Auto-send safety policy specifies 4-tier traffic light (green/yellow/orange/red), `hh_decision_action` integration per ADR-003 §2.1, 3 new `ESC_AUTOSEND_*` codes (`ESC_AUTOSEND_NEEDS_REVIEW`, `ESC_AUTOSEND_BLOCKED`, `ESC_AUTOSEND_POLICY_LOOKUP_FAILED`), pilot-agreement liability placeholder (legal review required before first LOI), v1.0 ships green+red only / yellow+orange phased to v1.1. Kill criterion specifies 10 binary triggers spanning design-partner gap (Trigger 1 = Week-3 PAUSE), renderer build (Trigger 2 = W3 KILL), Bullhorn auth (Trigger 3 = W5 PIVOT), scope cuts (Trigger 4 from sequencing-target §6.6), autosend miscategorisations (Trigger 5), unit economics + infra cost (Triggers 6+7 = PIVOT), Gate B revenue (Trigger 8 = KILL per master brief example), cortextOS primitive stability (Trigger 9), PII leakage (Trigger 10 = unilateral KILL). **Risk #3 escalated from Medium to High** — zero design partners in pipeline as of Day 5; original "conversation 1" assumption invalidated. **Risk #7 edit count revised from 9 to 10** with new Edit 10 (master brief §6 Day 5 lines 484-485 path drift `docs/` root → `docs/decisions/`). Codex Day-7 queue grows from 15 to 17 (both Day-5 artefacts).
docs/RISK-REGISTER.md:65:- 2026-05-20 (Day 9 evening) — **Architecture + tenancy verification slice complete.** 3 commits (`5c3fa66` + `c4348aa` + this commit). 4 new artefacts: tenancy-invariants.md (Reference; 12 invariants T1-T12 single source of truth), run-tenancy-audit.sh (multi-tenant adversarial smoke), architecture-cohesion-review.md (8-artefact cohesion + 14 remediation items + 4-boundary adversarial walk), tenant-lifecycle.md (Provision/Operate/Suspend/Offboard/Migrate). All 4 master-brief §3 boundaries verified HOLD at current artefact set. 3 of 5 contradictions in the ratified artefact set RESOLVED via ADR-004 + Day-8 remediation; 1 RESOLVED via consolidation in tenancy-invariants.md; 1 OPEN pending Founder Decision D3 (PII retention). 8 implicit assumptions documented; 3 catastrophic-if-false verified empirically. No new risks added — cohesion review's 14 remediation items + lifecycle's 8 gaps are all variance bounded by existing risks (#5 renderer + #10 PII + others) or low-severity lazy specs. Foundation deemed sound for Diagnostic build conditional on founder-decision bundle (D1+D2+D3) + Codex Round 2 closure + live tenancy audit pass.
docs/RISK-REGISTER.md:66:- 2026-05-20 (Day 8 evening) — **Codex ratification Round 1 complete + remediation landed.** 16 artefacts reviewed (Cluster A+B+C); 2 RATIFIED (ADR-004, brain-ui-scope); 14 REJECTED. Remediation commit `2b287d3` incorporates 13 of 14 rejections (Bucket 1 cosmetic + Bucket 2 ADR-004 back-propagation + Bucket 3 structural). 2 disagreement docs filed (`codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md` + `codex-disagreement-2026-05-20-bullhorn-week-1-gate.md`). 5 founder decisions surfaced (D1-D5 in `2026-05-20-codex-round-1-founder-decisions.md`). **NEW Risk #10 candidate surfaced by Codex** (recent_edit raw PII retention vs UK GDPR Art. 5(1)(e) data minimisation) — see Risk #10 below. Manifest queue updated with per-artefact Round-1 verdicts (`docs/decisions/2026-05-18-codex-ratification-manifest.md` §1.5). Round 2 expected to take 14 REJECTED → 0-2 REJECTED.
docs/RISK-REGISTER.md:67:- 2026-05-20 (Day 8) — **Week-1 product-code slice (plan `bubbly-snuggling-lantern.md`) shipped end-to-end in a single session.** 8 commits on `origin/main` (a279226 → 67a2320), ~6,500 lines across 50+ files, 59 passing tests (30 Vitest renderer + 29 Bash helpers/loader). All 5 phases landed: (1) renderer prereqs + ESC catalogue, (2) `packages/agent-renderer/` TS scaffold, (3) `hook-helpers.sh` + `autosend-policy.yaml`, (4) vertical-schema v0.2 voice corpus supplement + migration SQL, (5) `voice-loader.sh`. **Risk #5 status update: renderer code committed (✓);** Risk #5 stays at High per ADR-003 line 145 staged ladder (requires BOTH "renderer code committed" AND "Diagnostic agent renders cleanly at W4" for High → Medium). Diagnostic bundle still blocked by Risk #3 / Q1 design-partner LOI. Three ADR-003 implementation deviations flagged for ADR-004 ratification: CLI-name divergence + symlink target counting error + phantom `_shared` listing in upstream `list-agents`. 4 of 11 Day-7-honest-read gaps fully closed (#1 voice schema, #2 preamble, #3 common schemas, #4 autosend policy YAML); 2 side-effect closed (#6 ESC catalogue, partial #10 phase enum); 5 explicitly deferred with named owner + trigger. **Codex Day-7 queue grows from 21 to 33 items** (12 new artefacts: 8 common-*.json + preamble + ESC catalogue + renderer scaffold + autosend YAML + hook-helpers + voice-loader + 2 test harnesses + v0.2 supplement + 2 migration SQL files). Live VPS smoke tests + Phase 5 migration execution remain pending (Path A founder action; documented in `agents/_shared/README.md §"Live integration test"` + `§"Phase 5 live migration"`). No new risks surfaced from the 5-phase slice.
docs/RISK-REGISTER.md:68:- 2026-05-20 (Day 7) — **Week 0 EXTENDS per master brief §6 line 502.** Single-sentence test 3 of 5 YES (`docs/decisions/2026-05-18-day-7-single-sentence-test.md`): Q1 NO (design partner gap; Risk #3 materialised); Q2 YES with caveat (primitive 1 flaky-under-load); Q3 NO (auth path designed not cleared; Sub-decisions A+B Proposed pending commercial); Q4 YES (renderer scoped); Q5 YES (vertical schema shipped). **Risk #3 status MATERIALISED** — kill criterion Trigger 1 (DESIGN-PARTNER-BY-WEEK-2 PAUSE) is 14 calendar days from today (fires 2026-06-03). Week 1 named agent-build slices (Diagnostic W3-4 + 5 downstream) BLOCKED. Extension protocol per single-sentence-test §5: Week-1 prereq 3 (`_shared/` helpers) + `.codex/ratification/` skills build (Day-1 task gap surfaced) + Bullhorn commercial outreach + renderer scaffold continue; named agent-build slices blocked. **Atomic-correction commit landed today at `0e5b2b4`** — master brief reconciliation, 11 of 12 edits applied (Edit 11 dropped per founder decision: already-executed live SQL migration is its own audit trail; Edit 12 = ADR-002 Edit 3 added at Day-7 grounding). Master brief fully reconciled. **Risk #7 closed for atomic-correction commit** — 11 edits batch-applied at `0e5b2b4`; only remaining items are post-Codex-ratification iterations if Codex flags any of the 11 edits or two side effects (Edit 1 col 4 reframe + Edit 4 row merge). Codex Day-7 ratification queue at 21 items + 1 commit; **execution deferred** to extension period per Option C (skills not yet built + Q1 unblocker required first). `gstack` dev-tool installed Day 7 morning (`f5d2956` + `ce4bb33`) — meta-tooling for development; not part of IFOS product per `.agents/learnings/gstack-pin.md`.
docs/operations/codex-round-2-handoff.md:16:Round 1 ran against the pre-remediation artefact set and rejected 14 of 16. Round 2 runs against the **post-remediation** artefact set + new artefacts that landed in commits `2b287d3` (Codex Round-1 remediation) + `5c3fa66`+`c4348aa`+`e1ff40f` (architecture+tenancy) + `783c496` (D5 skill softening) + `20e78d7`+`95e7d4a` (D1 + D3 preparation).
docs/operations/codex-round-2-handoff.md:22:3. **12 NEW artefacts** queued since Round 1 — tenancy-invariants, architecture-cohesion-review, tenant-lifecycle, 2 disagreement docs, founder briefing, D1 spec, D3 prep, 2 migration SQL files, audit script + cron script. None have been Codex-reviewed yet.
docs/operations/codex-round-2-handoff.md:77:| 6 | `docs/decisions/autosend-safety-policy.md` | tier contradiction + legal placeholder | LIKELY REJECT — these are founder-decision-bound (D1/D2/D3) and content unchanged |
docs/operations/codex-round-2-handoff.md:87:**Likely outcomes:** 11-12 of 14 RATIFY. Items #6 (autosend tier contradiction) and #14 (PII retention) are founder-decision-bound (D1/D3); Codex may RATIFY-with-advisory or REJECT pending decisions.
docs/operations/codex-round-2-handoff.md:211:  docs/decisions/autosend-safety-policy.md
docs/operations/codex-round-2-handoff.md:288:**Sub-case 2a: Same issue as Round 1** — incorporation didn't actually fix the root cause. Escalate to founder; reopen as a fresh issue. Likely candidates: autosend-safety-policy (D1 + D3 unresolved); v0.2 supplement (D3 unresolved).
docs/operations/codex-round-2-handoff.md:395:5. **D1 timing decision** (Week 9 default vs insert-now) — ~5 min decision
docs/operations/goal-week-4-track-1.md:5:**Master plan citations:** Master brief §8.2 (build wave W4 Cash Conductor MCP connectors) + ULTRAPLAN §8.1 A4 (Cash Conductor spec lines 531-545) + ADR-005 (Week-3 acceleration → Cash Conductor pulled forward to W4 substrate) + `agents/recruitment/cash-conductor/agent.md` §8 build dependencies + `docs/decisions/2026-05-31-d1-founder-decision.md` (D1-B resolved) + `v1.0-kill-criterion.md` Trigger 2 (Diagnostic live render by 2026-06-14).
docs/operations/goal-week-4-track-1.md:7:**Builds on:** Week-3 close (`docs/operations/goal-week-3-polish-and-scaffold.md`; 8/9 Codex-RATIFIED + 1 fix-applied at commit `fbcb61e`); D1-B decision (`docs/decisions/2026-05-31-d1-founder-decision.md`).
docs/operations/goal-week-4-track-1.md:20:6. **`docs/decisions/2026-05-31-d1-founder-decision.md`** (D1-B Telegram shim — affects Cash Conductor `xero_reminder_send_customer` flow)
docs/operations/goal-week-4-track-1.md:48:5. **`agents/recruitment/cash-conductor/cycle.sh`** exists; 14 steps per agent.md §4. Wires to the 3 connectors above + the D1-B `autosend-bridge-telegram` package (built separately at Concierge W10; cycle.sh degrades gracefully when absent — drafts-only mode per agent.md §1 readiness caveat).
docs/operations/goal-week-4-track-1.md:52:9. **`agents/recruitment/cash-conductor/tools.yaml`** exists; declares: `xero_oauth`, `quickbooks_oauth`, `open_banking_truelayer`, `open_banking_plaid_uk`, `telegram_notify`, `autosend_bridge_telegram` (per D1-B).
docs/operations/goal-week-4-track-1.md:108:| `autosend-bridge-telegram` package | Reserved for Concierge W10 build slice per D1-B doc §"Implementation surface"; Cash Conductor cycle.sh degrades gracefully when absent (drafts-only mode) |
docs/operations/goal-week-4-track-1.md:272:- `agents/recruitment/cash-conductor/cycle.sh` — 14 steps; wires the 3 connectors above + the autosend-bridge-telegram package (graceful degradation when absent per D1-B + agent.md §1 readiness caveat — drafts-only when bridge missing)
docs/operations/goal-week-4-track-1.md:392:- D1-B implementation choices that materially differ from `2026-05-31-d1-founder-decision.md` §"Implementation surface"
docs/operations/goal-week-4-track-1.md:453:  cycle.sh:                14 steps; D1-B graceful degradation tested
docs/operations/goal-week-4-track-1.md:490:  ✓ D1-B (2026-05-31 decision) — autosend bridge approach baked into cycle.sh
docs/operations/goal-week-4-track-1.md:502:  - Q1 LOI (Item 7 — Jack's lane; Trigger 1 fires 2026-06-03)
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:3:# Adversarial. Tests the D1-B approval-bridge timeout path. Concierge
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:10:# cycle.sh Step 11 MUST surface ESC_APPROVAL_BRIDGE_TIMEOUT (warn-tier;
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:22:description: Operator never replies to proposeApproval → outcome=timeout → ESC_APPROVAL_BRIDGE_TIMEOUT warn + Step 12 send NOT executed
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:38:  operator_telegram_chat_id: "987654321"
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:94:    - code: ESC_APPROVAL_BRIDGE_TIMEOUT
agents/recruitment/concierge/fixtures/99-bridge-timeout-canary.yaml:139:      payload_contains: "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:14400"
packages/agent-renderer/README.md:120:- **Telegram-down hang for orange-tier autosend** (autosend-safety-policy §5) is a Phase-3 concern in `hook-helpers.sh` `autosend_await_approval`, not a renderer concern. Documented for completeness.
agents/recruitment/concierge/fixtures/01-primary.yaml:30:  operator_telegram_chat_id: "987654321"
docs/operations/codex-round-2-remediation-prompt.md:218:  | Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (sequencing-target §2.1) | Awaits Q1 LOI |
docs/operations/codex-round-2-remediation-prompt.md:297:  FLAG 1 — autosend-safety-policy.md tier contradiction
docs/operations/codex-round-2-remediation-prompt.md:301:  > **Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0
docs/operations/codex-round-2-remediation-prompt.md:303:  > says v1.0 ships green + red only. These are contradictory until D1
docs/operations/codex-round-2-remediation-prompt.md:305:  > decisions.md` §D1 for options + Claude's recommended path (D1-B with
docs/operations/codex-round-2-remediation-prompt.md:307:  > Until D1 resolves, treat this policy as "Proposed for D1-B; subset
docs/operations/codex-round-2-remediation-prompt.md:311:  FLAG 2 — autosend-safety-policy.md legal placeholder
docs/operations/codex-round-2-remediation-prompt.md:325:  In §6 Q13 (the PII retention open question), update the v0_2_default
docs/operations/codex-round-2-remediation-prompt.md:333:    per-tenant override [30, 365] via tenant_adapters.config.pii_retention_days.
docs/operations/codex-round-2-remediation-prompt.md:413:  D1 / D2 / D3" rather than RATIFIED/REJECTED.
docs/operations/codex-round-2-remediation-prompt.md:448:  Disposition: "Founder-escalated pending D1 / D2 / D3."
docs/operations/codex-round-2-remediation-prompt.md:457:  - Update backlog: R15 + R16 marked closed; D1+D2+D3 elevated to "blocks
docs/operations/codex-round-2-remediation-prompt.md:473:        docs/decisions/autosend-safety-policy.md \
docs/operations/codex-round-2-remediation-prompt.md:496:  pending D1 / D2 / D3.
docs/operations/codex-round-2-remediation-prompt.md:515:    - autosend-safety-policy.md §1 + §10: D1 + D2/D3 blocker annotations
docs/operations/codex-round-2-remediation-prompt.md:516:    - vertical-schema.v0.2-supplement.yaml §6 Q13: indefinite retention
docs/operations/codex-round-2-remediation-prompt.md:542:  Founder-escalated: 3 items (D1, D2+D3 bundle)
docs/operations/codex-round-2-remediation-prompt.md:549:  - Resolve D1 autosend orange-tier v1.0 path
docs/operations/codex-round-2-remediation-prompt.md:626:- FLAG 1: autosend-safety-policy.md §1 D1 annotation
docs/operations/codex-round-2-remediation-prompt.md:627:- FLAG 2: autosend-safety-policy.md §10 D2+D3 annotation
docs/operations/codex-round-2-remediation-prompt.md:628:- FLAG 3: vertical-schema.v0.2-supplement.yaml §6 Q13 indefinite-retention block
docs/operations/codex-round-2-remediation-prompt.md:640:- Touch the 3 founder-decision-bound items beyond annotations (D1 needs you; D2/D3 bundle waits on SeedLegals)
docs/operations/decision-log.md:48:| 5 | D1 decision | ✅ D1-B taken |
docs/operations/decision-log.md:50:| 7 | Q1 LOI (Jack) | ⏸ **Trigger 1 fires 2026-06-03 (≤2 days)** |
docs/operations/decision-log.md:77:- **Third attempt: SUCCESS.** Migration applied cleanly (BEGIN…41 DDL…in-migration smoke "v0.3 migration smoke passed"…COMMIT). Post-flight verification confirmed: both Cash Conductor tables present and `postgres`-owned (Day-12 compliant); `validate_voice_scores` trigger replaced by `validate_entities_data_v0_3`; `validate_tenant_adapters_config_v0_3` present.
docs/operations/decision-log.md:91:- **The tenant_adapters config validator** enforces the allowlist including `blocked_recipients`, `janitor_dedup_threshold`, `concierge_send_window` — Sourcing Scout / Janitor / Concierge build slices land on a verified config surface.
docs/operations/decision-log.md:101:| 5 | Founder Decision D1 | ✅ D1-B taken (commit `8d9acc2`) |
docs/operations/decision-log.md:103:| 7 | Q1 LOI (Jack) | ⏸ Trigger 1 fires **2026-06-03 (3 days)** |
docs/operations/decision-log.md:116:| 5 | Founder Decision D1 (autosend orange-tier) | **DELEGATED + TAKEN: D1-B (Telegram shim)** | `docs/decisions/2026-05-31-d1-founder-decision.md` |
docs/operations/decision-log.md:118:| 7 | Q1 LOI (Jack's lane) | PENDING — Trigger 1 fires 2026-06-03 | n/a (founder coordinates Jack) |
docs/operations/decision-log.md:126:- D1-B is the autosend orange-tier path for v1.0; Concierge W10 build slice will deliver the `packages/utilities/autosend-bridge-telegram/` package per the decision doc §"Implementation surface".
docs/operations/decision-log.md:250:- **Catalogue extended:** 24 → 52 ESC codes; 29 → 47 action_types; 2 new Postgres tables (cash_conductor_transactions + cash_conductor_invoices); 3 new tenant_adapters config keys
docs/operations/decision-log.md:277:4. **D1 founder decision (autosend orange-tier path A/B/C)** — still pending. Blocks Concierge build slice.
docs/operations/decision-log.md:301:Single-sentence test result 3 of 5 YES (Q1 NO + Q3 NO + Q2/Q4/Q5 YES). Week 0 extends per master brief §6 line 502. **Week 1 named agent-build slices DO NOT BEGIN until at minimum Q1 turns YES.**
docs/operations/decision-log.md:303:### Highest-leverage (Q1 unblocker)
docs/operations/decision-log.md:305:- [ ] **Design-partner outreach.** The SINGLE Q1 unblocker. Founder-side work; warm-path strategy when targets named; cold-path templates drafted now possible. Without this, kill criterion Trigger 1 fires 2026-06-03 (14 days from today 2026-05-20) and Week 0 escalates to PAUSE.
docs/operations/decision-log.md:329:### Highest-leverage (Q1 unblocker — Jack's lane)
docs/operations/decision-log.md:331:- [ ] **Design-partner outreach.** The SINGLE Q1 unblocker for Week 1 named-agent-build slices. Co-founder Jack owns. Without this, kill criterion Trigger 1 fires 2026-06-03 (14 days from 2026-05-20).
docs/operations/decision-log.md:339:- [ ] **R2 = D1**: Autosend v1.0 tier enforcement — pre-Concierge W10 blocker; choose D1-B bridge path or D1-C manual/ad-hoc path
docs/operations/decision-log.md:360:- [ ] **R11**: tenant_eval_sets + tenant_adapters usage spec — Diagnostic W4 (first eval-set)
docs/operations/decision-log.md:367:**14 remediation items + 8 lifecycle gaps = 22 backlog entries.** None block current work; all named triggers + owners. 3 are pre-LOI founder decisions already surfaced via D1-D3.
docs/operations/decision-log.md:376:- ✅ Codex Round 1 + Round 2 + Round 3 remediation execution complete for the Week-0 close subset; remaining blockers are founder decisions D1/D2/D3.
docs/operations/decision-log.md:447:- **Founder Decision D1** (autosend orange-tier) — required before Concierge W10 build
docs/operations/decision-log.md:535:5. **Founder Decision D1** (autosend orange-tier path) — required before Concierge W10 build slice; recommend D1-B Telegram shim for v1.0 ship per Concierge §9 Q1
docs/operations/decision-log.md:663:**Why now:** master brief §1 Rule 1 "Output before architecture" + ADR-003 agent bundle v2 pattern + zero blocking dependency on founder-side D1/D2/D3 + zero blocking dependency on pilot tenant. Output contract is self-contained spec.
docs/operations/decision-log.md:673:- Founder-decision-bound items annotated only: autosend D1, legal D2/D3, vertical-schema D3 retention
docs/operations/decision-log.md:683:- D1: choose autosend orange-tier v1.0 path
docs/operations/decision-log.md:693:- Tier 3: **3/8 RATIFIED**; D5 disagreement ratified, Bullhorn disagreement rejected, D1/D3 bridge/purge artefacts need rework
docs/operations/decision-log.md:700:- D1 autosend orange-tier v1.0 path
docs/operations/decision-log.md:724:**Verdict from architecture-cohesion-review §9:** foundation is sound for Diagnostic build, conditional on (1) D1+D2+D3 resolve before Concierge W10 + first LOI; (2) Phase 2.2 documentation lands (✓); (3) Codex Round 2 + remediation closes (✓); (4) live VPS tenancy audit confirms 12 invariants.
docs/operations/decision-log.md:727:- D1 — autosend v1.0 tier enforcement (~30 min; Concierge scope)
docs/operations/decision-log.md:731:- D1/D2/D3 founder decisions before affected product/legal gates close
docs/operations/decision-log.md:767:- `2026-05-20-codex-round-1-founder-decisions.md` — 5 founder decisions surfaced (D1-D5):
docs/operations/decision-log.md:768:  - D1: autosend v1.0 tier enforcement (Concierge W10-13 scope)
docs/operations/decision-log.md:795:- 3 entities (voice_corpus + tone_rule + recent_edit), 1 HNSW pgvector index (voice_samples_embedded), 6 score fields, 2 relationships. Q11/Q12/Q13 open questions added; Q13 (GDPR retention) explicitly tagged for external-advisor review.
docs/operations/decision-log.md:814:- #9: tenant_eval_sets / tenant_adapters usage spec (lazy, follows first use)
docs/operations/decision-log.md:888:   - `docs/RISK-REGISTER.md` Risk #3 updated with Week 0 extension active + Q1 unblocker path
docs/operations/decision-log.md:890:**Q1 unblocker:** design partner LOI by 2026-06-03 (14 calendar days). Single structural unblocker for Week 1 named agent-build slices.
docs/operations/decision-log.md:892:**Q3 unblocker independent of Q1:** Bullhorn commercial conversations (founder-side; reduces Risk #2 to Medium; doesn't unblock Week 1 alone).
docs/operations/decision-log.md:916:  - `docs/decisions/autosend-safety-policy.md`: 1 fix (cyber insurance budget reference)
docs/operations/decision-log.md:936:  - Agent × Entity R/W matrix across all 6 v1.0 agents (Diagnostic, Janitor, Scribe, Cash Conductor, Sourcing Scout, Concierge) — cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3
docs/operations/decision-log.md:938:  - 12 open questions: Q1 (contractor entity_type) + Q4 (system agents non-entity) RESOLVED inline; Q2/Q3/Q5-Q12 DEFERRED with named revisit triggers
docs/operations/decision-log.md:962:- **`docs/decisions/autosend-safety-policy.md`** (658 lines, 11 sections):
docs/operations/decision-log.md:970:  - 11 open questions catalogued (Q1-Q10 + Day-5 founder decisions on Q3/Q5/Q6)
docs/operations/decision-log.md:1026:Test ran as `ifos_app` over TCP+scram-sha-256 (NOT as postgres superuser which bypasses RLS). RLS + FORCE + `tenant_isolation` policy (USING + WITH CHECK) on all 5 data tables: `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`.
docs/operations/decision-log.md:1116:10. **Day-5 path drift (NEW Day 5 2026-05-18)** — Master brief §6 Day 5 lines 484-485: paths `docs/auto-send-safety-policy.md` and `docs/v1-kill-criterion.md` → `docs/decisions/autosend-safety-policy.md` and `docs/decisions/v1.0-kill-criterion.md` per repo convention since Day 0 (matching ADR-001/-002/-003 + bullhorn + sequencing-target + brain-ui-scope). Source: Day-5 autosend policy header + kill criterion header.
docs/operations/decision-log.md:1125:Per master brief §10.6 first ratification run — Day 7 added items 20 + 21 + the landed atomic-correction commit `0e5b2b4`. Total: 21 items + 1 commit. **Execution deferred** to Week 0 extension period (skills + Q1 unblocker both required first). See `docs/decisions/2026-05-18-codex-ratification-manifest.md` §3 + §4 for the gap + schedule.
docs/operations/decision-log.md:1142:16. **`docs/decisions/autosend-safety-policy.md`** (Status: Proposed) — NEW Day 5 morning 2026-05-18
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:291:- Cash Conductor: `cash_conductor_transactions` + `cash_conductor_invoices` Postgres tables; `tenant_adapters.config.cash_conductor_last_run` field
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:292:- Concierge: `tenant_adapters.config.concierge_last_poll` + `tenant_adapters.config.concierge_send_window` fields
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:337:1. v0.3 vertical-schema supplement (Scribe entity fields + Cash Conductor Postgres tables + Concierge tenant_adapters fields + Janitor candidate.linkedin_url)
docs/decisions/codex-disagreement-2026-05-24-diagnostic-gate-a.md:431:| Concierge | Pre-Build-Round-9-Reviewed | 5 (Cat-β tenant_adapters fields + Gate A interpretation residual + Cat-ε missing decision-log + vault-before-Gate-A flow) | v0.3 + bilateral consistency pass 2 |
agents/recruitment/concierge/fixtures/02-edge-case-rejection-voice-drift.yaml:35:  operator_telegram_chat_id: "987654321"
docs/operations/w4-bilateral-pass-6-agent-md.md:38:| 4 | Cash Conductor | 3 | Blocked partially by D1 (W4 #4) — pre-resolve docs-only items. |
docs/operations/w4-bilateral-pass-6-agent-md.md:104:  - **Codex says:** "Lines 42, 95, and 166 rely on `janitor_dedup_threshold` and `janitor_last_run`; `rg` finds these only in the v0.2-to-v0.3 migration allowlist, not in `vertical-schema.yaml` or the v0.3 supplement's `tenant_adapters_config_additions`. Fix by adding both keys with type/owner/read-write semantics to the schema supplement, then cite that schema section instead of only the migration allowlist."
docs/operations/w4-bilateral-pass-6-agent-md.md:105:  - **Likely:** **REJECT-CODEX** with rationale, OR small schema supplement edit. The migration allowlist IS the v0.3 supplement enforcement (per ADR-006 + the v0.3 trigger). But Codex's point is that they should also appear in the YAML schema definition (`tenant_adapters_config_additions`) for documentation completeness. Founder call: edit the YAML supplement to declare them explicitly, OR write disagreement claiming migration-allowlist is sufficient single-source-of-truth.
docs/operations/w4-bilateral-pass-6-agent-md.md:144:### Finding 2. Concierge/D1 dependency under-specified
docs/operations/w4-bilateral-pass-6-agent-md.md:145:  - **Cite:** §8 line 380; cross-ref §4 lines 235-253 + line 244 (D1)
docs/operations/w4-bilateral-pass-6-agent-md.md:146:  - **Codex says:** "Line 380 says Cash Conductor only depends on Concierge `agent.md` being Accepted, but lines 235-253 require Concierge to receive drafts, run the approval bridge, transport sends, and callback; line 244 also cites the unresolved D1 path. Add Founder Decision D1 resolved + autosend bridge/Concierge transport availability as explicit prerequisites, or rewrite §4 to use the existing shared autosend approval helper without Concierge."
docs/operations/w4-bilateral-pass-6-agent-md.md:147:  - **Likely:** FIX-IN-PLACE. Add to §8 prereqs: (a) D1 resolved, (b) Concierge autosend-bridge live. Note: D1 is W4 queue #4 — this finding documents the dependency in the agent.md but does NOT block ratification of the scaffold (Status will be Proposed→Pre-Build pending D1).
docs/operations/w4-bilateral-pass-6-agent-md.md:182:  - **Codex says:** "Line 16 cites `autosend-safety-policy.yaml` and line 214 cites `autosend-safety-policy §4`, but the runtime YAML in the repo is `agents/_shared/autosend-policy.yaml`; `autosend-safety-policy` exists as a decision `.md`, not YAML. Replace the YAML citation with `agents/_shared/autosend-policy.yaml` and cite the decision doc only when referring to policy rationale."
docs/operations/w4-bilateral-pass-6-agent-md.md:183:  - **Likely:** FIX-IN-PLACE. Replace `autosend-safety-policy.yaml` → `agents/_shared/autosend-policy.yaml` (runtime) where mechanical; keep `autosend-safety-policy §4` where it's the decision-doc rationale citation, but fix to `docs/decisions/autosend-safety-policy.md §4`.
packages/agent-renderer/templates/claude-md-preamble.md:63:Auto-send tier policy per `_shared/autosend-policy.yaml`. Tenant override file (if present): `/vault/{{tenant_slug}}/_config/autosend-overrides.yaml` — read by `autosend_apply_tenant_override` per `docs/decisions/autosend-safety-policy.md` §4.
docs/operations/seedlegals-engagement-queries.md:68:> 1. **Service scope:** SaaS-delivered AI agent fleet for UK recruitment agencies (Bullhorn ATS integration; bounded action set defined in autosend-safety-policy attached as Appendix A).
docs/operations/seedlegals-engagement-queries.md:164:- Q1 LOI could land before legal templates exist → founder signs without legal cover
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:120:- Aggregate metric writes to `decision_log.payload` via key landing in autosend-safety-policy §7 supplement (concrete key name specified there, not in this ADR)
docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md:138:| Q1 | Default sample rate for Tier 2 spot-check? Recommend 1-in-10 (~10% of reports validated per-claim) for first pilot; adjust based on early signal | Founder review at first-pilot W4 polish landing |
docs/operations/w4-day-20-founder-runbook.md:72:- ✓ `validate_tenant_adapters_config_v0_3` trigger present on `tenant_adapters`
docs/operations/w4-day-20-founder-runbook.md:87:The 11 tables: `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `voice_corpus`, `voice_corpus_chunks`, `tone_rule`, `recent_edit`, `cash_conductor_transactions`, `cash_conductor_invoices`.
docs/operations/w4-day-20-founder-runbook.md:111:4. Cash Conductor (3 findings) — depends on D1 decision documentation
docs/operations/w4-day-20-founder-runbook.md:129:## Step C (deferred to next session) — Future ADR + D1 decision
docs/operations/w4-day-20-founder-runbook.md:132:before Concierge agent.md can flip Status to Accepted. D1 founder decision
packages/harness/cortextos/dashboard/package-lock.json:69:      "integrity": "sha512-KVw6qIiCTUQhByfTd78h2yD1/00waTmm9uy/R7Ck/ctUyAPj+AEDLkQIdJW0T8+qGgj3j5bpNKK7Q3G+LedJWg==",
packages/harness/cortextos/dashboard/package-lock.json:514:      "integrity": "sha512-YA6Ma2KsCdGb+WC6UpBVFJGXL58MDA6oyONbjyF/+5sBgxY/dwkhLogbMT2GXXyU84/IhRw/2D1Os1B/giz+BQ==",
packages/harness/cortextos/dashboard/package-lock.json:559:      "integrity": "sha512-FwpKqZbPz14AITp1CVgf4AjhKPe1OeeVKSBMdgD10zbFlj3QSWelmtCMLi2+/PFZZcIm3l87G7rwtCZJwHyXWA==",
packages/harness/cortextos/dashboard/package-lock.json:643:      "integrity": "sha512-bR9e6o2BDB12jzN/gIbjHa5wLJ4UjD1CB9pM7ehlc0ddk6EBz+yYS1EV2MF55/HUxrHcB/hehAyt5vhsA3hx7w==",
packages/harness/cortextos/dashboard/package-lock.json:2729:      "integrity": "sha512-Kd6kAHTA6/nUpp8mySPqj3en3dm0tdMIgbttnQ1xFMVpufoj+ADi8pXLBsd4xzTRHQa7t/Jv8W5UnCuW4kuWMQ==",
packages/harness/cortextos/dashboard/package-lock.json:2850:      "integrity": "sha512-/I5AS4cIroLpslsmzXfwbe5OmWvSsrFuEw3mwvbQ1kDxJ822hFHIx+vsN/TAzNVyepI/j/GSzrtCIwQPeKCLIg==",
packages/harness/cortextos/dashboard/package-lock.json:3594:      "integrity": "sha512-asx5hIG9Qmf/1oStypjanR7iKTv0gXQ1Ov/jfrX6kS/EO0OFni8orbmGCn0672NHR3kXHwpAwR+B368ZGN/2rA==",
packages/harness/cortextos/dashboard/package-lock.json:3768:      "integrity": "sha512-doNSZEVJsWEu4htiVC+PR6NpM+pa+a4ClH9INRWOWCUzMst/VA9c4gXq92F8GUD1rwhNvRLkgjfYtFXegXQF7A==",
packages/harness/cortextos/dashboard/package-lock.json:4113:      "integrity": "sha512-mJ5vuDaIZ+l/acv01sHoXfpnyrNKOk/3aDoEdLO/Xtn9HuZlDD6jKxHlkN8ZhWyLJsRBxfv9GYM2utQ1SChKew==",
packages/harness/cortextos/dashboard/package-lock.json:4186:      "integrity": "sha512-nRcz5Il4ln0kMhfL8S3hLkxI85BXs3o8EYoattsJNdsX4YUU89iOkVn7g0VHSRxFuVMdM4Q1jEpIId1Ihim/Uw==",
packages/harness/cortextos/dashboard/package-lock.json:4341:      "integrity": "sha512-5cvg6CtKwfgdmVqY1WIiXKc3Q1bkRqGLi+2W/6ao+6Y7gu/RCwRuAhGEzh5B4KlszSuTLgZYuqFqo5bImjNKng==",
packages/harness/cortextos/dashboard/package-lock.json:4618:      "integrity": "sha512-p6Fx8B7b7ZhL/gmUsAy0D15WhvDccw3mnGNbZpi3pmeJdxtWsj2jEaI4Y6oo3XiHfzuSgPwKc04MYt6KgvC/wA==",
packages/harness/cortextos/dashboard/package-lock.json:4759:      "integrity": "sha512-Lyf3aK28zpsD1yQMiiHD4RvVb6UdMoo8xzG2XzFIfR9luPzOpcBlAsT/qfB1XWS1bxWT+UtE4WmQgsp297FYOA==",
packages/harness/cortextos/dashboard/package-lock.json:4794:      "integrity": "sha512-RKshQI1R3YQ+n9YJz2QQ147P66ELpa1FQEg20Dk8oW9t2KgLbpDLLp9aGZ7y8WHSshDknG0bknqGw5/tyCs5tw==",
packages/harness/cortextos/dashboard/package-lock.json:4847:      "integrity": "sha512-9ZLprWS6EENmhEOpjCYW2c8VkmOvckIJZfkr7rBW6dObmfgJ/L1GpSYW5Hpo9lDz4D1+n0Ckz8rU7FwHDQiG/w==",
packages/harness/cortextos/dashboard/package-lock.json:4858:      "integrity": "sha512-yQbXgO/OSZVD2IsiLlro+7Hf6Q18EJrKSEsdoMzKePKXct3gvD8oLcOQdIzGupr5Fj+EDe8gO/lxc1BzfMpxvA==",
packages/harness/cortextos/dashboard/package-lock.json:5191:      "integrity": "sha512-YVGIj2kamLSTxw6NsZjoBxfSwsn0ycdesmc4p+Q21c5zPuZ1pl+NfxVdxPtdHvmNVOQ6XSYG4AUtyt/Fi7D16Q==",
packages/harness/cortextos/dashboard/package-lock.json:5301:      "integrity": "sha512-yki5XnKuf750l50uGTllt6kKILY4nQ1eNIQatoXEByZ5dWgnKqbnqmTrBE5B4N7lrMJKQ2ytWMiTO2o0v6Ew/w==",
packages/harness/cortextos/dashboard/package-lock.json:5310:      "integrity": "sha512-D76uU73ulSXrD1UXF4KE2TMxVVwhsnCgfAyTg9k8P6KGZjlXKrOLe4dJQKI3Bxi5wjesZoFXJWElNWBjPZMbhg==",
packages/harness/cortextos/dashboard/package-lock.json:5420:      "integrity": "sha512-zg/chbXyeBtMQ1LbD/WSoW2DpC3I0mpmPdW+ynRTj/x2DAWYrIY7qeZIHidozwV24m4iavr15lNwIwLxRmOxhA==",
packages/harness/cortextos/dashboard/package-lock.json:5799:      "integrity": "sha512-ypdmJU/TbBby2Dxibuv7ZLW3Bs1QEmM7nHjEANfohJLvE0XVujisn1qPJcZxg+qDucsr+bP6fLD1rPS3AhJ7EQ==",
packages/harness/cortextos/dashboard/package-lock.json:5951:      "integrity": "sha512-+h1lkLKhZMTYjog1VEpJNG7NZJWcuc2DDk/qsqSTRRCOXiLjeQ1d1/udrUGhqMxUgAlwKNZ0cf2uqan5GLuS2A==",
packages/harness/cortextos/dashboard/package-lock.json:6276:      "integrity": "sha512-ob/2LcVVaVGCYN+r14cnwnoDPUufjiYgSqRhiFD0Q1iI4Odora5RE8Iv1D24hAz5oMophRGkGz+yuvQmmUMnMw==",
packages/harness/cortextos/dashboard/package-lock.json:7323:      "integrity": "sha512-EykJT/Q1KjTWctppgIAgfSO0tKVuZUjhgMr17kqTumMl6Afv3EISleU7qZUzoXDFTAHTDC4NOoG/ZxU3EvlMPQ==",
packages/harness/cortextos/dashboard/package-lock.json:8207:      "integrity": "sha512-RHxMLp9lnKHGHRng9QFhRCMbYAcVpn69smSGcq3f36xjgVVWThj4qqLbTLlq7Ssj8B+fIQ1EuCEGI2lKsyQeIw==",
packages/harness/cortextos/dashboard/package-lock.json:8330:      "integrity": "sha512-/sM3dO2FOzXjKQhJuo0Q173wf2KOo8t4I8vHy6lF9poUp7bKT0/NHE8fPX23PwfhnykfqnC2xRxOnVw5XuGIaA==",
packages/harness/cortextos/dashboard/package-lock.json:8496:      "integrity": "sha512-MbjN408fEndfiQXbFQ1vnd+1NoLDsnQW41410oQBXiyXDMYH5z505juWa4KUE1LqxRC7DgOgZDbKLxHIwm27hA==",
packages/harness/cortextos/dashboard/package-lock.json:8523:      "integrity": "sha512-NXYBzinNrblfraPGyrbPoD19C1h9lfI/1mzgWYvXUTe414Gz/X1FD2XBZSZM7rRTrMA8JL3OtAaGifrIKhQ5yQ==",
packages/harness/cortextos/dashboard/package-lock.json:8812:      "integrity": "sha512-Bz5mupy2SVbPHURB98VAcw+aHh4vRV5IPNhILUCsOzRmsTmSQ17jIuqopAentWoehktxGd9e/hbIXq980/1QJg==",
packages/harness/cortextos/dashboard/package-lock.json:8917:      "integrity": "sha512-yI7BeItCLZJTXikmK4KNUGCKoGzSvbKlfCvw44bU4fXAL6v3gYS4uHD1jzsLkfwODYwI6Drw5Tu9Z5ulDe0TSg==",
packages/harness/cortextos/dashboard/package-lock.json:9021:      "integrity": "sha512-Lbgzdk0h4juoQ9fCKXW4by0UJqj+nOOrI9MJ1sSj4nI8aI2eo1qmvQEie4VD1glsS250n15LsWsYtCugiStS5A==",
packages/harness/cortextos/dashboard/package-lock.json:9092:      "integrity": "sha512-gKLcREMhtuZRwRAfqP3RFW+TK4JqApVBtOIftVgjuABpAtpxhPGaDcfvbhNvD0B8iD1oUr/txX35NjcaY6Ns/A==",
packages/harness/cortextos/dashboard/package-lock.json:9447:      "integrity": "sha512-haREypq7xkM7ErfgIyA0z+Bj4AGKlMSdlQE2jvJo6huWD1EdkKYV+G/T4nq0YEF2vgTT8kqMFKo1uHn950r4SQ==",
packages/harness/cortextos/dashboard/package-lock.json:9529:      "integrity": "sha512-8u/hfXFRBD1O0hPUjioLhoWFHRmt6tKA4/vZPyckBr18l1KE9uHrFaFaUi8MDRTpi4uak2goyPTSNJLXX2k2Hw==",
packages/harness/cortextos/dashboard/package-lock.json:10139:      "integrity": "sha512-vYt7UD1U9Wg6138shLtLOvdAu+8DsC/ilFtEVHcH+wydcSpNE20AfSOduf6MkRFahL5FY7X1oU7nKVZFtfq8Fg==",
packages/harness/cortextos/dashboard/package-lock.json:10365:      "integrity": "sha512-9u/XQ1pvrQtYyMpZe7DXKv2p5CNvyVwzUB6uhLAnQwHMSgKMBR62lc7AHljaeteeHXn11XTAaLLUVZYVZyuRBQ==",
packages/harness/cortextos/dashboard/package-lock.json:10566:      "integrity": "sha512-uyDrIlUEH37cinabq0AX4QbgV4HbFZ/gqoiunWQ1UqBtRvTTytwhNYjE++pO/MjPTZL5KQCf2bEoJ/BJNVQ5Kw==",
packages/harness/cortextos/dashboard/package-lock.json:10785:      "integrity": "sha512-1gnZf7DFcoIcajTjTwjwuDjzuz4PPcY2StKPlsGAQ1+YH20IRVrBaXSWmdjowTJ6u8Rc01PoYOGHXfP1mYcZNQ==",
packages/harness/cortextos/dashboard/package-lock.json:12141:      "integrity": "sha512-7rKUyy33Q1yc98pQ1DAmLtwX109F7TIfWlW1Ydo8Wl1ii1SeHieeh0HHfPeL2fMXK6z0s8ecKs9frCuLJvndBg==",
packages/harness/cortextos/dashboard/package-lock.json:12203:      "integrity": "sha512-EPD5q1uXyFxJpCrLnCc1nHnq3gOa6DZBocAIiI2TaSCA7VCJ1UJDMagCzIkXNsUYfD1daK//LTEQ8xiIbrHtcw==",
packages/harness/cortextos/dashboard/package-lock.json:12566:      "integrity": "sha512-K4jVyjnBdgvc86Y6BkaLZEN933SwYOuBFkdmBu9ZfkcAbdVbpITnDmjvZ/aQjRXQrv5EPkTnD1s39GiiqbngCw==",
packages/harness/cortextos/dashboard/package-lock.json:12585:      "integrity": "sha512-LYfpUkmqwl0h9A2HL09Mms427Q1RZWuOHsukfVcKRq9q95iQxdw0ix1JQrqbcDR9PH1QDwf5Qo8OZb5lksZ8Xg==",
packages/harness/cortextos/dashboard/package-lock.json:12741:      "integrity": "sha512-7dSzzRQ++CKnNI/krKnYRV7JKKPUXMEh61soaHKg9mrWEhzFWhFnxPxGl+69cD1Ou63C13NUPCnmIcrvqCuM6w==",
agents/recruitment/concierge/cycle.sh:9:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: every step that
agents/recruitment/concierge/cycle.sh:24:#   @ifos/autosend-bridge-telegram — D1-B Telegram approval shim (Concierge OWNS Step 11)
agents/recruitment/concierge/cycle.sh:34:#   gated by autosend-bridge approval per D1-B founder decision.
agents/recruitment/concierge/cycle.sh:266:# Step 11 — Autosend-bridge routing (D1-B Telegram path)
agents/recruitment/concierge/cycle.sh:267:# Reference: agent.md §4 Step 11 + D1-B founder decision (2026-05-31) +
agents/recruitment/concierge/cycle.sh:271:# or timeout, fires ESC_APPROVAL_BRIDGE_TIMEOUT (timeout) or records rejection
agents/recruitment/concierge/cycle.sh:320:    #        # ESC_APPROVAL_BRIDGE_TIMEOUT per agents/_shared/escalation-codes.md
agents/recruitment/concierge/cycle.sh:324:    #          "ESC_APPROVAL_BRIDGE_TIMEOUT; timeout_seconds:14400; approval_id:${APPROVAL_ID}" ;;
agents/recruitment/concierge/cycle.sh:328:    # Bridge package ABSENT — D1-C graceful degradation (drafts-only).
agents/recruitment/concierge/cycle.sh:332:      "autosend-bridge-telegram package dist/ not present — D1-C mode active; drafts retained in vault for manual consultant pickup; build the package (pnpm --filter @ifos/autosend-bridge-telegram build) to enable D1-B send path"
agents/recruitment/concierge/cycle.sh:345:  #   if tenant_adapters.config.email_channel == 'microsoft-graph':
agents/recruitment/concierge/cycle.sh:375:  # TODO(W10-13): if tenant_adapters.config.concierge_state_advance_enabled:
agents/recruitment/concierge/cycle.sh:385:# SLA tracking. Checks ghosted-rate (any candidate with no Concierge action
agents/recruitment/concierge/cycle.sh:389:# TODO(W10-13): UPDATE tenant_adapters SET config = jsonb_set(config, '{concierge_last_run}', '"<ISO>"')
docs/operations/codex-ratification-execution-plan.md:130:| 8 | autosend-safety-policy | `docs/decisions/autosend-safety-policy.md` | A |
docs/operations/codex-ratification-execution-plan.md:346:### Gate: Q1 design partner LOI status
docs/operations/codex-ratification-execution-plan.md:348:Per Day-7 manifest §4 + §6 of this plan: Codex ratification execution was deferred pending Week 0 close. Week 0 closes when single-sentence-test Q1 = YES (design partner LOI signed). **Current state:** Q1 = NO; Week 0 EXTENDING; kill-criterion Trigger 1 fires 2026-06-03.
docs/operations/codex-ratification-execution-plan.md:352:- **Option α** — Start immediately. Rationale: 33 items are already queued; Q1 turning YES will only ADD items (Diagnostic + Janitor + downstream). The 34-item queue is largely about Week 0 design artefacts that won't change post-LOI. Get them ratified now while context is fresh.
docs/operations/codex-ratification-execution-plan.md:353:- **Option β** — Wait for Q1 = YES. Rationale: master brief §10.6 framed first ratification run as Day 7; once-Week-0-closes implies the design-partner LOI exists. Some artefacts (Bullhorn integration Sub-decisions A+B) genuinely change post-commercial-conversations.
docs/operations/codex-ratification-execution-plan.md:354:- **Option γ** — Start the **invariant cluster** (A + B + C) now; defer code-cluster (E) until Q1 = YES. Architecture + reference designs + schema are spec-driven and don't shift with commercial conversations. Code review is cheap to redo if helpers change. Compromise of α + β.
docs/operations/codex-ratification-execution-plan.md:356:**Founder bias documented (carry-forward from Day-7 manifest):** Option C (deferred) was chosen at Day-7. With the Day-8 5-phase slice landed, **revise to Option γ** — start clusters A + B + C this week; defer clusters D-I until Q1 + the live VPS migration both complete.
docs/operations/codex-ratification-execution-plan.md:373:Phase 1-4 are 1-2 sessions of focused work. Phases 6-9 land after live migration + Q1 LOI. Phase 10 is lazy.
docs/operations/codex-ratification-execution-plan.md:444:**Next ratification run** (post-Q1, post-live-migration): clusters D-I, ~6 hours of work.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:11:## D1 — Auto-send v1.0 tier enforcement (orange-tier behavior)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:14:- `docs/decisions/autosend-safety-policy.md` §3 (defines 4 tiers + classifies 10 action_types as orange)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:15:- `docs/decisions/autosend-safety-policy.md` §9 (says "v1.0 ships green + red only")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:22:- **D1-A: Become red in v1.0** — refuse all orange action_types entirely. Concierge can't send customer-visible Bullhorn Notes at all in v1.0. Diagnostic can't send outbound emails. Cash Conductor can't send payment reminders. **Reduces Concierge to draft-only voice-classified output that the consultant manually copies.** Concierge's pitch becomes "drafts that pass voice gate" instead of "auto-send with approval gate".
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:23:- **D1-B: Implement orange approval gate in v1.0** — adds ~1 week to Concierge build (W10-13 → W10-14) to wire `autosend_await_approval` through cortextOS primitive 4 + Telegram bot. Concierge's pitch is whole.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:24:- **D1-C: Ship orange-as-red default + manual override** — orange action_types refused by default in v1.0, but per-action manual approval via founder's Telegram bot allowed as escape hatch. Pragmatic; aligns with autosend §9 "orange handled outside the policy pipeline" wording. **Closest to current artefact wording but explicit about the manual surface.**
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:26:**Claude's recommendation (initial briefing, Day 8):** D1-C. v1.0 ships with orange-as-red default + documented manual approval path. Concierge demo pitch becomes "voice-classified drafts that the operator can approve in Telegram"; doesn't promise full auto-send-with-policy in v1.0. v1.1 implements full orange approval gate.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:28:**Claude's recommendation (Day-11 update, post implementation-spec investigation):** **D1-B.** Investigation surfaced that the "~1 week extra" cost was overestimated — cortextOS Primitive 4 (`createApproval` + `updateApproval` in `packages/harness/cortextos/src/bus/approval.ts`) already implements the Telegram fan-out + button-press routing. IFOS-side work is a thin bridge: 2 file watchers + a small Postgres state table. Realistic effort: 2-3 days. See `docs/decisions/autosend-approval-bridge-spec.md` for the full implementation surface (10 acceptance criteria, 6 risks, 600 lines TypeScript scaffold + tests).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:32:**Alternative timing:** Insert as next IFOS Claude slice now (post-Diagnostic-build, ~Week 8). Marginal benefit: D1 becomes a closed item earlier; bridge gets stress-tested before Concierge needs it. Cost: 2-3 days inserted before Concierge.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:34:**Cost of deferral:** Concierge W10 build risks slipping if bridge isn't ready. Concrete delay: ~3 days. Risk #2 (Bullhorn) is the bigger blocker for Concierge (auth path); D1 is downstream of that.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:36:**D1 Concrete recommendation:** Schedule for Week 9 (default). Founder explicitly approves D1-B; bridge spec ratifies through Codex Round 2; bridge implementation slice authored Week 9.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:44:- `docs/decisions/autosend-safety-policy.md` §10 ("Pilot-agreement liability language placeholder — counsel-reviewed")
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:53:- **D2-B: Defer to first pilot LOI signing window** — risky; if Q1 LOI lands before D2-A advisor is engaged, founder is choosing between (a) signing without legal cover, or (b) delaying LOI signing.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:65:- `docs/verticals/recruitment/vertical-schema.v0.2-supplement.yaml` §6 Q13 (UK GDPR retention question)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:68:**Codex's framing:** "`recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker."
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:142:| **D1** (autosend v1.0 tier) | This week | Concierge build scope (W10-13) |
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:147:**Recommended order:** D5 (quickest, unblocks Round 2) → D1 (Concierge planning) → D2 + D3 (legal bundle) → D4 (no-rush).
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:158:## D1 — Resolution (2026-05-XX)
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:160:Founder picks D1-C: ship orange-as-red default + manual override.
docs/decisions/2026-05-20-codex-round-1-founder-decisions.md:167:OR open a follow-on ADR if the decision warrants more substantive recording (e.g., ADR-005 for D1; ADR-006 for D2 + D3 bundle).
docs/operations/goal-w4-day-26-2026-06-01.md:21:9. Cash Conductor bundle skeletons — `cycle.sh` (14-step per agent.md §4) + `validate.sh` (Gate A per §5) + `tools.yaml`. Fixtures + `context.sh` + `cleanup.sh` deferred. Drafts-only graceful degradation when `autosend-bridge-telegram` absent (D1-B doc).
docs/operations/goal-option-c-diagnostic-end-to-end.md:267:- Risk #3 (Q1 LOI): note that Diagnostic-as-sales-tool now has empirical artefact for the Q1 pitch
docs/operations/goal-option-c-diagnostic-end-to-end.md:366:6. **Be the kind of artefact you'd be happy to forward to Jack to use in his Q1 pitch**
docs/operations/goal-option-c-diagnostic-end-to-end.md:407:  - [Approve report? Forward to Jack for Q1 pitch?]
agents/recruitment/concierge/README.md:14:The customer-comms agent. Highest-stakes v1.0 agent (XL complexity, 4 weeks build). 12 lifecycle events × 2 recipient roles = 24+ comms-template variants per tenant. Orange-tier autosend per `autosend-safety-policy.yaml` — consultant approval mandatory before send.
agents/recruitment/concierge/README.md:20:- `tools.yaml` — Bullhorn R+W + Microsoft Graph + Gmail + voice classifier + autosend bridge (per D1 outcome)
agents/recruitment/concierge/README.md:35:**Founder Decision D1 (autosend orange-tier path) MUST be resolved before W10 build starts.** Per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Three options:
agents/recruitment/concierge/README.md:36:- D1-A: bridge to cortextOS approval system (most powerful; ~3 days dev)
agents/recruitment/concierge/README.md:37:- D1-B: lightweight Telegram shim (recommended for v1.0 ship; ~1 day dev)
agents/recruitment/concierge/README.md:38:- D1-C: no autosend; manual consultant pickup (0 dev; ships fastest but worst UX)
agents/recruitment/concierge/tools.yaml:115:  # Autosend bridge (D1-B Telegram shim per 2026-05-31 founder decision;
agents/recruitment/concierge/tools.yaml:116:  # package scaffold landed 2026-06-01 at commit 9b282d8). Per D1-B doc
agents/recruitment/concierge/tools.yaml:125:    purpose: "Post orange-tier candidate-comms approval request to operator Telegram chat (D1-B founder decision)"
agents/recruitment/concierge/tools.yaml:129:    optional: true  # cycle.sh Step 11 checks for the package dist/; falls back to drafts-only mode if absent (per D1-C graceful degradation)
agents/recruitment/concierge/tools.yaml:145:        escalation: ESC_APPROVAL_BRIDGE_TIMEOUT  # warn-tier per escalation-codes.md lines 348-353; routes operator + tenant-admin per agent.md §6 row 11; action converts to manual reconciliation
agents/recruitment/concierge/validate.sh:14:# Per master brief §8.1 Change 2 + autosend-safety-policy §4: validate.sh is
packages/agent-renderer/pnpm-lock.yaml:64:    resolution: {integrity: sha512-c0uX9VAUBQ7dTDCjq+wdyGLowMdtR/GoC2U5IYk/7D1H1JYC0qseD7+11iMP2mRLN9RcCMRcjC4YMclCzGwS/A==}
packages/agent-renderer/pnpm-lock.yaml:442:    resolution: {integrity: sha512-Z0gOTd75VvXqyq7nsl93zwahcTROgqvuAcYDUr+vOv8uHhNSKROyU961kgtCD1e95IqPKSQKH7tBTslnS3tA8A==}
packages/agent-renderer/pnpm-lock.yaml:484:    resolution: {integrity: sha512-56hiAJPhwQ1R4i+21FVF7V8kSD5zZTdHcVuRFMW0hn753vVfQN8xlx4uOPT4xoGH0Z/oVATuR82AiqSTDIpaHg==}
packages/agent-renderer/pnpm-lock.yaml:1008:    resolution: {integrity: sha512-JFNbkD1Svwe0KvGi8GOeLcP4kAWQ609twvCdcHxq1oSL8svv39ZuSvajcD8B+5D0eL4+s1Is2D/O6KN3qcTeRA==}
agents/recruitment/concierge/context.sh:5:#         with real provider config + tenant_adapters reads).
agents/recruitment/concierge/context.sh:24:#   - Refresh Microsoft Graph OR Gmail OAuth (per tenant_adapters.config.email_channel)
agents/recruitment/concierge/context.sh:27:#   - Resolve operator_telegram_chat_id from tenant_adapters.config
agents/recruitment/concierge/context.sh:81:# TODO(W10-13): SELECT config->>'email_channel' FROM tenant_adapters WHERE tenant_slug=$1
agents/recruitment/concierge/context.sh:109:# TODO(W10-13): resolve via tenant_adapters.config; default fallback chain.
agents/recruitment/concierge/context.sh:115:# Step 5 — Operator routing (Telegram chat ID for autosend-bridge per D1-B)
agents/recruitment/concierge/context.sh:118:# TODO(W10-13): SELECT config->>'operator_telegram_chat_id' FROM tenant_adapters
agents/recruitment/concierge/context.sh:119:# WHERE tenant_slug=$1 (per D1-B doc §"Implementation surface" item 5 — already
agents/recruitment/concierge/context.sh:120:# supported by existing Telegram surface; no new schema needed).
docs/decisions/autosend-approval-bridge-spec.md:6:**Surfaced by:** Founder Decision D1 (`docs/decisions/2026-05-20-codex-round-1-founder-decisions.md`) + Codex Round 1 autosend rejection issue 2
docs/decisions/autosend-approval-bridge-spec.md:308:- Unblocks Concierge build (W10-13) — without this, Concierge can only ship as drafts-only (D1-A) which loses the demo value prop
docs/decisions/codex-disagreement-2026-05-20-decision-doc-shape-on-audits.md:74:Both artefacts remain marked REJECTED in the manifest queue table pending founder D5 resolution. Neither blocks any current work (audit findings + runbook procedures are still binding regardless of Codex verdict). Recommended decision window: this week, before Q1 LOI process accelerates other priorities.
agents/recruitment/concierge/agent.md:4:**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (today): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) drafted at `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md`; Concierge Status flip Proposed → Accepted requires ADR-007 RATIFIED. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + ADR-007 RATIFIED + W10 build slice.
agents/recruitment/concierge/agent.md:9:**Tier:** Tier 1 (persistent state across candidate lifecycle) per ULTRAPLAN A6 line 560. Uses cortextOS primitives #1 (Persistent PTY), #2 (context rotation), #4 (approval gates), #5 (Telegram surface).
agents/recruitment/concierge/agent.md:17:> **Concierge is the customer-comms agent — it makes sure no candidate is ghosted.** It monitors lifecycle events across the candidate journey in Bullhorn (interview-booked → interview-completed → offer-extended → offer-accepted → placement-confirmed → start-date-confirmed → 7-day-check-in → 30-day-check-in → 90-day-check-in, plus rejection / withdrawal / on-hold branches) and produces customer-facing email drafts (acknowledgement, prep, debrief, rejection, placement, check-ins ×6) at each event. Each draft is written to vault at `/vault/<tenant>/concierge-drafts/<draft_id>.md` (canonical narrative source per ADR-002 vault/Postgres split); approval routes through the autosend-bridge (Founder Decision D1 path) and on approval the send executes via tenant's Microsoft Graph OR Gmail (per-tenant config; agent-identity email adapter deferred to v1.1+). Drafts are yellow-tier `concierge_email_draft` (registered in `agents/_shared/autosend-policy.yaml` under §YELLOW; internal, voice-classified, sample-spot-checked); the customer-facing send is orange-tier — `gmail_outlook_send_to_candidate` (§ORANGE) or `bullhorn_note_customer_visible` (§ORANGE canonical) depending on channel. Gate A hard-fails any draft with voice classifier below the position-specific threshold (≥0.75 standard / ≥0.82 sensitive) OR any draft with incorrect addressee resolution (per ULTRAPLAN A6 line 566 — "no candidates emailed under another's name"). The 30-minute draft SLA is per ULTRAPLAN A6 line 566 (as amended in R19 alongside ADR-007) a **Gate B leading metric at 90%, not a Gate A hard-fail** — polling-fallback detection latency would otherwise block legitimate drafts. Per-draft SLA misses fire `ESC_CONCIERGE_SLA_MISS`; aggregate <90% fires `ESC_GATE_B_MISS`. This agent.md matches the amended line. ADR-007 (Concierge Gate A 30-min SLA hybrid) is **Accepted (founder-arbitrated 2026-05-31)** + Codex RATIFIED at Round 3; the ULTRAPLAN amendment is permanent. The §10 Proposed → Accepted blocker for this agent is now satisfied on the ADR side; remaining production-readiness gates per §10 still apply (pilot LOI, Bullhorn A+B, autosend-bridge-telegram package shipped per D1-B, etc.). Gate B success thresholds (all three now in ULTRAPLAN A6 line 567 as amended): <5% candidate-ghosted rate + ≥60% send-as-is rate on drafts + ≥90% 30-min SLA hit rate (the SLA metric added per ADR-007). This is the highest-stakes v1.0 agent — every send is customer-facing; voice quality on rejections is the hardest test case (per ULTRAPLAN A6 §gotchas (line numbers vary; see live file) gotcha). XL build complexity (4 weeks) reflects the state-machine surface area + comms-type breadth + cortextOS primitive integration depth.
agents/recruitment/concierge/agent.md:111:Consultant approves via autosend-bridge (D1 path) → orange-tier send executes → Bullhorn activity-log entry written post-send.
agents/recruitment/concierge/agent.md:130:     > tenant_adapters.config.concierge_last_poll AND not in decision_log
agents/recruitment/concierge/agent.md:232:11. Autosend-bridge routing (D1 path)
agents/recruitment/concierge/agent.md:233:    → per Founder Decision D1 (final selection at W10 design):
agents/recruitment/concierge/agent.md:234:      D1-A (bridge to cortextOS approval system): POST internal API
agents/recruitment/concierge/agent.md:235:      D1-B (lightweight Telegram shim): send approval prompt to operator
agents/recruitment/concierge/agent.md:236:      D1-C (no autosend in v1.0): draft to vault for manual consultant pickup
agents/recruitment/concierge/agent.md:238:    → ESC_APPROVAL_BRIDGE_TIMEOUT if no approval within the policy timeout
agents/recruitment/concierge/agent.md:240:      lines 348-353; looked up per action_type, not hardcoded) (D1-A/B)
agents/recruitment/concierge/agent.md:269:    → check ghosted-rate metric (any candidate with no Concierge action in
agents/recruitment/concierge/agent.md:270:      14 days post-state-change → contributes to ghosted-rate)
agents/recruitment/concierge/agent.md:271:    → if ghosted-rate >5% for tenant in 30-day rolling: ESC_GATE_B_MISS
agents/recruitment/concierge/agent.md:282:Per master brief §8.1 Change 2 + autosend-safety-policy §4 + ULTRAPLAN A6 line 566 (interpreted per bilateral-disposition Cat-5):
agents/recruitment/concierge/agent.md:327:| `ESC_APPROVAL_BRIDGE_TIMEOUT` | No consultant approval within the policy timeout (default PT4H per escalation-codes.md lines 348-353 + autosend-policy.yaml lines 235-239) | warn | operator + tenant-admin |
agents/recruitment/concierge/agent.md:376:| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
agents/recruitment/concierge/agent.md:377:| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
agents/recruitment/concierge/agent.md:384:| **Founder Decision D1 (autosend orange-tier path)** RESOLVED | Founder decision; awaits review of D1-A/B/C spec | ⏸ |
agents/recruitment/concierge/agent.md:385:| Autosend bridge built (per D1 outcome) | W10 build start (~2 days for D1-A; less for D1-B/C) | ⏸ |
agents/recruitment/concierge/agent.md:403:**Status:** Proposed. Awaits Bullhorn A+B + per-tenant email-provider signups + D1 founder decision + Q1 LOI + W10-13 build slice.
agents/recruitment/concierge/agent.md:409:| Q1 | **D1 founder decision (autosend orange-tier path)** — A (bridge to cortextOS), B (Telegram shim), C (no autosend; manual). Concierge ABSOLUTELY needs this resolved before build. | Founder decision per `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1. Recommend D1-B (Telegram shim) for v1.0 ship; D1-A as v1.1 upgrade. |
agents/recruitment/concierge/agent.md:411:| Q3 | Sending hours per tenant — should Concierge respect tenant's "no sends after 6pm" or "no weekend sends" policies? Per-tenant config? | Per-tenant config in `tenant_adapters.config.concierge_send_window` (default: M-F 09:00-17:00 tenant-timezone). |
agents/recruitment/concierge/agent.md:418:| Q10 | 90-day check-in (event 12) — relationship-building tone. Should Concierge also surface "anyone in your network looking?" referral request? | Founder review with first pilot consultant + tenant brand voice. Recommend: opt-in via tenant config. |
agents/recruitment/concierge/agent.md:436:- **Founder Decision D1 RESOLVED** (Q1 above) — without this, Concierge build cannot start
docs/decisions/2026-05-18-codex-ratification-manifest.md:31:| 16 | `docs/decisions/autosend-safety-policy.md` | Proposed | Verify 4-tier model + 29 action_types + 3 ESC codes + §10 pilot-agreement liability placeholder; flag legal-review requirement before first pilot LOI |
docs/decisions/2026-05-18-codex-ratification-manifest.md:36:**Plus this manifest itself (#20)** and **Day-7 single-sentence test artefact (#21)** join the queue on commit. Original Day-7 close total: **21 items**. Current manifest state after Round 3 remediation: **43+ queued/registered items; 24 RATIFIED in the 26-item Round-2/Round-3 slice, 2 artefacts founder-escalated pending D1/D2/D3, and the rest deferred/not yet in the Round-2 slice.**
docs/decisions/2026-05-18-codex-ratification-manifest.md:57:Autonomous Round 2 ratification reviewed 26 artefacts across the re-ratification, Day-9, and Day-11 queues. Remediation commits referenced by the protocol: `2b287d3` (Round-1 incorporation), `5c3fa66` + `c4348aa` (architecture+tenancy), `783c496` (D5 skill softening), and `20e78d7` + `95e7d4a` (D1/D3 prep). Result: **17 RATIFIED / 9 REJECTED**. Full report: `logs/codex-ratification/round-2-autonomous/SUMMARY.md`.
docs/decisions/2026-05-18-codex-ratification-manifest.md:66:| 6 | `docs/decisions/autosend-safety-policy.md` | REJECTED | Open: see SUMMARY.md §4 for founder action. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:81:| 21 | `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` | RATIFIED | First ratification on Round 2; RATIFIED with D1/D2/D3 advisory. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:90:Round 3 remediated the Round-2 rejection set. Mechanical fixes were incorporated in this remediation commit; founder-domain items were annotated and escalated without Codex making D1/D2/D3 decisions. Result for the corrected subset: **10 RATIFIED / 0 REJECTED of 10**. Full report: `logs/codex-ratification/round-3-remediation/SUMMARY.md`.
docs/decisions/2026-05-18-codex-ratification-manifest.md:95:| 2 | `docs/decisions/autosend-safety-policy.md` | FOUNDER-ESCALATED | Founder-escalated pending D1 / D2 / D3; annotations added only. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:134:| 11 | `agents/recruitment/concierge/agent.md` | Proposed | `review-architecture-decision.md` | master brief §8.2 line 600 + ULTRAPLAN §8.1 A6 lines 557-570 + autosend §4 orange tier + D1 founder decision (note drift: ULTRAPLAN says W9-10, master brief says W10-13) |
docs/decisions/2026-05-18-codex-ratification-manifest.md:185:| 16 | autosend-safety-policy.md | REJECTED (3 issues) | Issues 1+2 (tier contradiction) → **Founder Decision D1** in `2026-05-20-codex-round-1-founder-decisions.md`. Issue 3 (legal placeholder) → **Founder Decision D2 + D3** in same briefing. No inline incorporation; founder picks. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:194:**Round-1 totals:** 16 reviewed | **2 RATIFIED** (ADR-004 + brain-ui-scope) | **14 REJECTED** | **13 of 14 incorporated** at commit `2b287d3` | **2 disagreement docs filed** | **5 founder decisions surfaced** (D1-D5).
docs/decisions/2026-05-18-codex-ratification-manifest.md:245:| **Build `.codex/ratification/*.md` skills** | Week 0 extension period (concurrent with Q1 design-partner work) | 2-3 person-days. 7 skill files per master brief §10.2; each follows the "RATIFIED / REJECTED with numbered issues" output contract. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:246:| **Run first ratification** | When Week 0 closes is achievable (i.e., Q1 turns YES OR founder declares Week 0 closed with accepted risks) | Per-artefact mean cost 20-30 min per master brief §10.6; 17 substantive artefacts ≈ 6-8 hours total. Plus follow-up commits per the round-trip protocol (master brief §10.3 ≤2 round-trips). |
docs/decisions/2026-05-18-codex-ratification-manifest.md:290:| 16 | `autosend-safety-policy.md` §10 pilot-agreement liability | Placeholder — legal review required before first pilot LOI | Pre-LOI legal review (commercial / regulatory). Codex can ratify the placeholder shape but cannot substitute for legal counsel. |
docs/decisions/2026-05-18-codex-ratification-manifest.md:302:2. **What's blocking** (`.codex/ratification/*.md` skills not built; Q1 design-partner gap → Week 0 extending).
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:50:4. **De-risks the Q1 pitch.** Master brief §8.2 line 595 explicitly names Diagnostic as the "sales tool." Jack's Q1 pitch goes from abstract ("AI for recruitment") to concrete ("here's a Diagnostic for your firm") once we have one real artefact.
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:76:- Concierge (W10-13) touches Bullhorn read+write; same gating + needs D1 autosend decision
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:85:- Q1 LOI gate (Jack's lane; Trigger 1 fires 2026-06-03 if no LOI)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:86:- Founder commercial workstream (Bullhorn + SeedLegals + Q1)
docs/decisions/ADR-005-week-3-diagnostic-acceleration.md:118:| Does the Diagnostic v0 produce reports good enough to send Jack for Q1 pitch? | Iteration loop in W3 polish (Step 7 + follow-ups). Quality gate: founder approval after running against 5-10 real firms. |
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:21:The subsequent design pass (`docs/architecture/second-brain-design.md`) went further. Q1.4 found that **no IFOS agent calls `kb-*`** — the IFOS Agent Bundle v2 (master brief §8.1) has no `MEMORY.md`, no heartbeat memory file, and uses Postgres `decision_log` for the persistence role cortextOS's KB fills. The §3.4 seam was designed to shadow calls our agents don't make. Q3 evaluated three interface options against the post-design constraints (§3.2 rubric) and recommended Option α — a parallel `packages/brain/bus-overrides/wiki-*.sh` surface with no shadowing of cortextOS's bus.
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:99:> "Postgres 16 installed. Tables: `tenants`, `entity_graph`, `entity_relationships`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` — per DATA-LAYER.md §2.2"
docs/decisions/ADR-002-brain-system-as-parallel-not-shadow.md:103:> "Postgres 16 installed. Tables: `tenants`, `entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters` (the single `entity_graph` of the earlier framing is split into `entities` + `entity_links` per `docs/architecture/second-brain-design.md` §2.4.2)."
docs/decisions/ADR-004-renderer-implementation-deviations.md:144:**For Risk #5 (renderer-not-built).** Severity unchanged at High per ADR-003 line 145 staged ladder ("Drops to Medium once renderer code is committed AND the Diagnostic agent renders cleanly (Week 4)"). The Phase-2 commit `3c16d35` satisfies the first condition; the second condition (Diagnostic render) is gated on Q1 design-partner LOI. ADR-004 closes a stylistic gap (3 deviations) but does not change risk severity.
docs/decisions/codex-disagreement-2026-05-20-bullhorn-week-1-gate.md:41:| Diagnostic build (W3-4) | None — Diagnostic doesn't touch Bullhorn | Awaits Q1 LOI |
docs/decisions/autosend-safety-policy.md:8:**Path drift logged:** Master brief §6 Day 5 line 485 specifies `docs/auto-send-safety-policy.md` (docs/ root). This artefact lives at `docs/decisions/autosend-safety-policy.md` per repo convention since Day 0 (matching ADR-001/-002/-003, bullhorn-integration-path, sequencing-target, brain-ui-scope). Recorded as **Edit 10** in atomic-correction manifest.
docs/decisions/autosend-safety-policy.md:17:- The Postgres data tables (`entities`, `entity_links`, `decision_log`, `tenant_eval_sets`, `tenant_adapters`, `tenants`) — IFOS-controlled, RLS-isolated
docs/decisions/autosend-safety-policy.md:39:**Founder Decision D1 pending (Codex Round 2 rejection).** The v1.0 tier semantics in this document define orange as approval-gated. §9 says v1.0 ships green + red only. These are contradictory until D1 resolves. See `docs/decisions/2026-05-20-codex-round-1-founder-decisions.md` §D1 for options + Claude's recommended path (D1-B with the bridge spec at `docs/decisions/autosend-approval-bridge-spec.md`). Until D1 resolves, treat this policy as "Proposed for D1-B; subset In Force for green + red only".
docs/decisions/autosend-safety-policy.md:123:| `unauthorised_adapter_send` | `unauthorized_adapter` | Send via an adapter not declared in this tenant's `tenant_adapters` row + `tools.yaml` |
docs/decisions/autosend-safety-policy.md:260:3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
docs/decisions/autosend-safety-policy.md:264:**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
docs/decisions/autosend-safety-policy.md:354:| Tenant config (`tenant_adapters` row) corrupted or missing for `adapter_name='autosend_policy'` | `autosend_apply_tenant_override` returns non-zero | Use policy defaults (no override); log warning to `decision_log.payload.override_applied='none-tenant_config_missing'`; continue | Tenant config repaired; agent picks up override on next session |
docs/decisions/autosend-safety-policy.md:404:2. **"What was the policy tier for action_type X at time of send T?"** — `payload->>'policy_version_sha'` references the git SHA of the policy file at execution. Combined with `git show <sha>:docs/decisions/autosend-safety-policy.md` reconstructs the policy state at send time. This is the source of truth for `§10` liability allocation.
docs/decisions/autosend-safety-policy.md:424:Tenants can elevate tier classification via the `tenant_adapters` table per Day 4 §6.3:
docs/decisions/autosend-safety-policy.md:427:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/autosend-safety-policy.md:482:- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
docs/decisions/autosend-safety-policy.md:487:- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
docs/decisions/autosend-safety-policy.md:510:docs/decisions/autosend-safety-policy.md in the IFOS code repository)
docs/decisions/autosend-safety-policy.md:526:  (d) any tier override defined in Tenant's tenant_adapters configuration
docs/decisions/autosend-safety-policy.md:554:of docs/decisions/autosend-safety-policy.md in the decision_log row's
docs/decisions/autosend-safety-policy.md:597:| 2 | Policy file format — YAML in vault per tenant, mirrored to Postgres for query? Or single YAML at repo root + tenant overrides in DB? | §4 + §8 | Recommend single repo-root YAML (`agents/_shared/autosend-policy.yaml`) + tenant_adapters override layer. ADR-005 confirms. |
docs/decisions/autosend-safety-policy.md:624:Remaining open questions (Q1 action_type enum format, Q2 policy file format, Q4 multi-recipient batching, Q7 policy version pinning, Q8 spot-check disagreement feedback, Q9 cross-action coupling, Q10 Telegram SLA instrumentation) deferred for ADR-005 + Week-1+ work.
docs/decisions/2026-05-31-d1-founder-decision.md:1:# Founder Decision D1 — autosend orange-tier path
docs/decisions/2026-05-31-d1-founder-decision.md:4:**Decision:** **D1-B — Telegram shim** for v1.0; D1-A as v1.1+ upgrade.
docs/decisions/2026-05-31-d1-founder-decision.md:7:**Supersedes:** the "D1 founder decision" line item in `2026-05-20-codex-round-1-founder-decisions.md` and the open-question rows in:
docs/decisions/2026-05-31-d1-founder-decision.md:8:- `agents/recruitment/concierge/agent.md` §9 Q1
docs/decisions/2026-05-31-d1-founder-decision.md:9:- `agents/recruitment/cash-conductor/agent.md` §8 (D1-pending fallback row)
docs/decisions/2026-05-31-d1-founder-decision.md:15:Per `docs/decisions/autosend-safety-policy.md` §4, orange-tier action_types (customer-facing sends like `xero_reminder_send_customer`, `gmail_outlook_send_to_candidate`, `bullhorn_note_customer_visible`) require **synchronous consultant approval** before the send executes. The agent drafts; the consultant says yes; the transport fires; an audit row records the full chain.
docs/decisions/2026-05-31-d1-founder-decision.md:21:| **D1-A** Bridge to cortextOS approval system | Concierge POSTs to an internal cortextOS approval API; operator approves in Brain UI; bridge calls back | ~2 days build (~3 days if approval-API doesn't yet exist) | Architecturally clean; reuses cortextOS primitive #4 (approval gates); UX in Brain UI is consistent with other approval flows | Brain UI v1.0 approval UX not yet built; depends on cortextOS approval-API stability; tightest coupling to upstream |
docs/decisions/2026-05-31-d1-founder-decision.md:22:| **D1-B** Lightweight Telegram shim | Concierge posts to operator's tenant-bound Telegram chat: `[ID:<x>] APPROVE drafted email to <recipient>? /approve <ID> or /reject <ID>`; Concierge polls Telegram or receives webhook; on approve → transport executes | <1 day build | Reuses cortextOS primitive #5 (Telegram surface) already in place; consultants are on Telegram already; lowest engineering cost; clean audit chain (every approve/reject = `decision_log` row); works the same for Cash Conductor + Concierge | Approval UX is a chat reply rather than a rich panel; per-draft attachment preview is just a 200-char text snippet + vault path; consultant must read the vault Markdown if they want to see the full draft body before approving |
docs/decisions/2026-05-31-d1-founder-decision.md:23:| **D1-C** No autosend; manual pickup | Concierge writes the draft to vault; sets `requires_consultant_action=true`; no notification; consultant manually polls vault and copies drafts to outbound | 0 days build (already supported by drafts-to-vault flow) | Zero risk of incorrect autosend; zero new build | UX is brutal; consultants miss drafts; defeats Concierge's "no candidate ghosted" promise; effectively kills Concierge as a v1.0 differentiator |
docs/decisions/2026-05-31-d1-founder-decision.md:27:## Decision: D1-B (Telegram shim)
docs/decisions/2026-05-31-d1-founder-decision.md:29:**Why D1-B wins for v1.0:**
docs/decisions/2026-05-31-d1-founder-decision.md:31:1. **Cost-aligned to v1.0 scope.** D1-A's clean architecture is the right *v1.1+* answer once Brain UI matures; for v1.0 ship, D1-B's <1-day build matches the W10-13 Concierge slice budget.
docs/decisions/2026-05-31-d1-founder-decision.md:32:2. **Reuses an already-built primitive.** cortextOS primitive #5 (Telegram surface) is in place; operators already receive escalation notifications there. Adding `/approve <ID>` / `/reject <ID>` commands extends an existing surface rather than introducing a new one.
docs/decisions/2026-05-31-d1-founder-decision.md:33:3. **Audit chain is identical to D1-A.** Both paths emit the same `decision_log` rows (`xero_reminder_send_customer` orange action → operator approve/reject → transport `gmail_outlook_send_to_candidate` action). The Telegram interaction is the trigger, not the audit substrate.
docs/decisions/2026-05-31-d1-founder-decision.md:34:4. **D1-C kills Concierge's value.** Manual vault polling means missed drafts means ghosted candidates means Concierge fails its Gate B (`ghosted-rate <5%`). Non-starter.
docs/decisions/2026-05-31-d1-founder-decision.md:38:**v1.1+ upgrade path (queued, not blocking):** D1-A bridge to cortextOS approval system + Brain UI rich-panel approval surface. The D1-B Telegram path stays available as a fallback (e.g., operator on the move, away from a desk). v1.1+ adds the *option* of D1-A, doesn't replace D1-B.
docs/decisions/2026-05-31-d1-founder-decision.md:49:   - Timeout default `PT4H` per `escalation-codes.md` `ESC_APPROVAL_BRIDGE_TIMEOUT` lines 348-353.
docs/decisions/2026-05-31-d1-founder-decision.md:50:2. **Concierge `cycle.sh` Step 11** — calls `proposeApproval` for orange-tier drafts; on `approved`, proceeds to Step 12 transport; on `rejected` or `timeout`, fires `ESC_APPROVAL_BRIDGE_TIMEOUT` (timeout) or records rejection in `decision_log` (rejected).
docs/decisions/2026-05-31-d1-founder-decision.md:53:5. **Tenant config** — `tenant_adapters.config.operator_telegram_chat_id` — already supported by the existing Telegram surface; no new schema needed.
docs/decisions/2026-05-31-d1-founder-decision.md:63:- **Concierge §9 Q1 RESOLVED** — strike from "open questions" list at next agent.md touch.
docs/decisions/2026-05-31-d1-founder-decision.md:64:- **Cash Conductor §8 D1-pending fallback** — flips from "drafts-only if unresolved" to "orange-tier `xero_reminder_send_customer` writes are live once Concierge W10 ships the `autosend-bridge-telegram` package."
docs/decisions/2026-05-31-d1-founder-decision.md:65:- **Concierge ratification §10** — `Founder Decision D1 RESOLVED` blocker now satisfied. Remaining Concierge Proposed → Accepted blockers per §10: Codex Round 4 Phase 2 (DONE), ADR-007 Accepted (PENDING founder Accept), founder approves §9 Q2-Q6 (PENDING).
docs/decisions/2026-05-31-d1-founder-decision.md:66:- **No schema impact.** D1-B reuses `tenant_adapters.config` for the operator chat ID; no v0.4 supplement work added by this decision.
docs/decisions/2026-05-31-d1-founder-decision.md:71:*End of D1 decision doc.*
docs/decisions/v1.0-kill-criterion.md:8:**Path drift logged:** Master brief §6 Day 5 line 486 specifies `docs/v1-kill-criterion.md` (docs/ root). This artefact lives at `docs/decisions/v1.0-kill-criterion.md` per repo convention. Recorded as **Edit 10** in atomic-correction manifest (shared with autosend-safety-policy.md path drift).
docs/decisions/v1.0-kill-criterion.md:113:**Source:** `docs/decisions/autosend-safety-policy.md` §5 + §10; Risk #3 in `docs/RISK-REGISTER.md` (LUKS manual unlock has higher impact but autosend miscategorisation has higher frequency).
docs/decisions/v1.0-kill-criterion.md:235:**Must-fill before first pilot LOI signs.** The pilot agreement may reference an external advisor for dispute resolution per `autosend-safety-policy.md` §10 placeholder language. Founder identifies and engages within Weeks 1-2.
docs/decisions/v1.0-kill-criterion.md:349:- Adds yellow + orange autosend tiers per `autosend-safety-policy.md` §9
docs/decisions/v1.0-kill-criterion.md:387:**For atomic-correction manifest.** Edit 10 (shared with autosend-safety-policy.md) adds the path drift correction. Manifest grows from 9 to 10.
packages/mcp-connectors/companies-house/pnpm-lock.yaml:48:    resolution: {integrity: sha512-c0uX9VAUBQ7dTDCjq+wdyGLowMdtR/GoC2U5IYk/7D1H1JYC0qseD7+11iMP2mRLN9RcCMRcjC4YMclCzGwS/A==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:426:    resolution: {integrity: sha512-Z0gOTd75VvXqyq7nsl93zwahcTROgqvuAcYDUr+vOv8uHhNSKROyU961kgtCD1e95IqPKSQKH7tBTslnS3tA8A==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:468:    resolution: {integrity: sha512-56hiAJPhwQ1R4i+21FVF7V8kSD5zZTdHcVuRFMW0hn753vVfQN8xlx4uOPT4xoGH0Z/oVATuR82AiqSTDIpaHg==}
packages/mcp-connectors/companies-house/pnpm-lock.yaml:954:    resolution: {integrity: sha512-JFNbkD1Svwe0KvGi8GOeLcP4kAWQ609twvCdcHxq1oSL8svv39ZuSvajcD8B+5D0eL4+s1Is2D/O6KN3qcTeRA==}
docs/decisions/2026-05-18-day-7-single-sentence-test.md:30:### Q1 — Design partner pilot Q3 2026 LOI?
docs/decisions/2026-05-18-day-7-single-sentence-test.md:59:  - **Design partner #1 conversation 2** (ATS confirmation): not had. The design partner gap from Q1 means we cannot confirm pilot #1 actually uses Bullhorn vs a different ATS.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:79:- **Depth:** 89 canonical fields, 10 entity_links relationships, agent × entity R/W matrix across all 6 v1.0 agents (cross-referenced to `bullhorn-integration-path.md` §4.1 + `autosend-safety-policy.md` §3), Bullhorn mapping per entity, 12 open questions catalogued (Q1+Q4 resolved inline; Q2/Q3/Q5-Q12 deferred with named revisit triggers).
docs/decisions/2026-05-18-day-7-single-sentence-test.md:104:- **Week 0 status:** Extending. Closes when (a) Q1 turns YES (design partner LOI) AND (b) Q3 turns YES or is accepted-with-risk via founder decision.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:112:1. **Week-1 prerequisite 3** — `agents/_shared/voice-loader.sh` + `agents/_shared/hook-helpers.sh`. Full implementation surface specified across Day-5 `autosend-safety-policy.md` §4 + ADR-002 §"For Week 1 work" + `vault-concurrency.md` §3.1. 3 `hh_decision_*` contracts + 7 `autosend_*` helpers + ESC catalogue (ESC_BULLHORN_AUTH + ESC_RENDERER_FAILED + 5×ESC_VAULT_* + 3×ESC_AUTOSEND_*). Estimated 3-5 person-days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:115:4. **Design-partner outreach** — the SINGLE Q1 unblocker. Founder-side work; warm-path strategy when targets named, cold-path templates draftable now if founder identifies prospect list. **This is the highest-leverage extension work.**
docs/decisions/2026-05-18-day-7-single-sentence-test.md:117:6. **Renderer implementation per ADR-003** — ALLOWED in code repo but agent-build slices (Diagnostic et al.) DO NOT start until Q1 turns YES. Renderer can scaffold independently.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:121:1. **Diagnostic W3-4 agent build** — blocked; requires Q1=YES.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:132:- When Q1 turns YES, single-sentence test re-runs.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:136:**Q3 unblocker independent of Q1:**
docs/decisions/2026-05-18-day-7-single-sentence-test.md:138:Bullhorn commercial conversations (`partnerships@bullhorn.com`, Bullhorn dev support) flip Sub-decisions A+B Proposed → Accepted regardless of Q1 status. These conversations don't unblock Week 1 alone but they reduce Risk #2 from High to Medium and tighten the auth-path readiness.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:140:**Other Q1-conditional unblockers:**
docs/decisions/2026-05-18-day-7-single-sentence-test.md:142:- Q1 + Q3 = YES → Week 0 cleanly closes; Week 1 starts; Diagnostic W3-4 build begins.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:143:- Q1 = YES, Q3 = NO (accepted) → Week 0 closes by founder discretion; Week 1 starts with Risk #2 elevated; Diagnostic W3-4 begins under accepted risk; Janitor W5 contingent on Q3 clearing by then.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:149:- Remaining window for Q1 to turn YES: 14 calendar days.
docs/decisions/2026-05-18-day-7-single-sentence-test.md:155:[Founder reflection to be written manually — not a Claude Code output. Section reserved for Maddox to write directly: why Q1 is NO, what the plan is, whether the plan is realistic, what changes in week-of-extension execution vs. what was assumed in Days 0-6.]
docs/decisions/2026-05-18-day-7-single-sentence-test.md:161:**Accepted (factual recording).** Recorded in `.agents/current-priorities.md` Day 7 Shipped section. Risk #3 in `docs/RISK-REGISTER.md` updated to reflect Week 0 extension active + Q1 unblocker path. Codex Day-7 ratification manifest produced as Deliverable 3 (sibling artefact in this commit).
docs/decisions/bullhorn-integration-path.md:104:| Diagnostic W3-4 build | None — Diagnostic doesn't touch Bullhorn (`sequencing-target.md` §2.1) | Awaits Q1 LOI |
docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md:130:| ADR-007-Q1 | Should the 90% threshold be per-tenant configurable, or is 90% a v1.0 fixed bar? | Recommend fixed at v1.0; v1.1 add per-tenant override via `tenant_adapters.config.concierge_sla_threshold` (new key, v0.4-pending). |
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
docs/runbooks/operational-hygiene-protocol.md:164:| **Decision artefact** | Per tier/trigger/option × support | 30-60 lines (incl. examples + escalation) | autosend-safety-policy.md (4 tiers + 29 action_types + 3 ESC codes + 11 sections ≈ 650 lines) |
docs/runbooks/operational-hygiene-protocol.md:260:Audit of citation accuracy across 4 main committed artefacts: Day-4 runbook, autosend-safety-policy.md, v1.0-kill-criterion.md, vertical-schema.yaml. Plus state files: RISK-REGISTER.md, current-priorities.md.
docs/runbooks/operational-hygiene-protocol.md:275:| `docs/decisions/autosend-safety-policy.md` | 1 | Same cost-target replacement for the cyber-insurance budget reference |
docs/runbooks/tenant-lifecycle.md:250:  DELETE FROM tenant_adapters   WHERE tenant_slug='<slug>';
docs/runbooks/pii-purge-operational-pattern.md:33:Per-tenant override via `tenant_adapters.config.pii_retention_days` — range [30, 365]. Allows enterprise tenants to extend retention via TOS amendment + advisor signoff.
docs/runbooks/pii-purge-operational-pattern.md:134:Per-tenant override via `tenant_adapters.config.pii_retention_days`:
docs/runbooks/pii-purge-operational-pattern.md:137:INSERT INTO tenant_adapters (tenant_slug, adapter_name, config, enabled)
docs/runbooks/pii-purge-operational-pattern.md:198:| P2 | tenant_adapters override read not yet implemented in script (uses single --retention-days CLI arg) | First tenant requests extended retention |
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:564:          { question: 'Q1', options: ['A', 'B'] },
packages/harness/cortextos/tests/unit/daemon/fast-checker.test.ts:598:          { question: 'Q1', options: ['A'] },

exec
/bin/zsh -lc "sed -n '1,220p' docs/verticals/recruitment/vertical-schema.yaml" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
# IFOS recruitment vertical schema v0.1
# ============================================================================
# Layered above the Day-4 generic primitives:
#   - entities (id, tenant_slug, entity_type, entity_id, data JSONB, version, ...)
#   - entity_links (..., source_entity_type, source_entity_id, target_entity_type, target_entity_id, link_type, ...)
#   - decision_log (..., agent_name, phase, payload JSONB, ...)
# This file specifies the recruitment-domain entity_type + link_type slugs
# and the JSON Schema shape of entities.data per entity_type.
#
# Source: master brief §6 Day 6 line 490 (8 core entities)
#       + bullhorn-integration-path.md §4.1 (per-agent endpoint requirements)
#       + autosend-safety-policy.md §3 (action_type references)
#       + Day-4 runbook §6.3 (canonical Postgres schema)
#       + Day-5 v1.0-kill-criterion.md (Trigger 1 acquisition-by-2026-06-03)
# ============================================================================

vertical: recruitment
version: v0.1
status: Proposed
date: 2026-05-18
author: founder (Maddox), Day-6 draft via Claude Code
codex_ratification_queue_position: 18

non_goals:
  - System agent names (e.g., `_renderer` per ADR-003 + Day-5 schema migration) are NOT entity_types in this schema. They appear in `decision_log.agent_name` only. This schema covers tenant-domain entities; system-internal agents are out of scope.
  - cortextOS substrate entities (PM2 process records, file-bus messages, approval gate entries) are NOT modelled here. They live in cortextOS's own state per master brief §2.4.
  - Vault-internal artefacts (markdown pages, frontmatter, wiki-links) are NOT entity_types. The vault is the source of truth for narrative content; this schema is the source of truth for structured state. See master brief §3.3 vault/Postgres split.

# ============================================================================
# §1 — Entity definitions
# ============================================================================
# Each entity below specifies:
#   - description: 1-2 sentence definition in the IFOS canonical vocabulary
#   - bullhorn_source: the Bullhorn entity (and any status filter) this maps from
#   - v1_0_agent_access: agents from master brief §8.2 that touch this entity in v1.0
#   - canonical_fields: minimal v1.0 working set (10-20 fields per master brief §6 Day 6 "Every field" intent, scoped to v1.0 agent reach per Q3 decision)
#   - notes: anything entity-specific worth flagging
#
# Field types follow JSON Schema conventions: type = string | integer | number | boolean | array | object | (ISO 8601) timestamp / date
# `required: true` means the entity cannot be persisted without this field set; `required: false` means nullable.
# `source: Bullhorn.<Entity>.<field>` means sourced from Bullhorn at ingest;
# `source: IFOS-derived` means computed/written by IFOS code (e.g., voice_classifier_score).
# ============================================================================

entities:

  # --------------------------------------------------------------------------
  candidate:
    description: |
      An individual person being considered for permanent placement. The most heavily-touched entity in v1.0 — every agent except Diagnostic and Cash Conductor reads or writes Candidate state.
    bullhorn_source: Bullhorn.Candidate (where status != 'contractor'; see entity `contractor` for the contractor sub-case)
    v1_0_agent_access:
      - Janitor (R+W — sweep + normalisation + dedup-merge proposals per bullhorn §4.1 A2)
      - Scribe (R+W — field updates from call transcripts per bullhorn §4.1 A3)
      - Sourcing Scout (R — passive matching per bullhorn §4.1 A5)
      - Concierge (R+W — lifecycle state per bullhorn §4.1 A6)
    canonical_fields:
      bullhorn_id:
        type: integer
        required: true
        source: Bullhorn.Candidate.id
        notes: Adapter-layer primary key for Bullhorn round-trip. Stable across ingests.
      first_name:
        type: string
        required: true
        source: Bullhorn.Candidate.firstName
      last_name:
        type: string
        required: true
        source: Bullhorn.Candidate.lastName
      email:
        type: string
        required: false
        source: Bullhorn.Candidate.email
        notes: May be nullable for candidates added via LinkedIn lookup pre-contact. Subject to autosend-safety-policy.md §7 payload_preview PII rules — `payload_preview` must mask.
      phone:
        type: string
        required: false
        source: Bullhorn.Candidate.phone
      mobile:
        type: string
        required: false
        source: Bullhorn.Candidate.mobile
      status:
        type: string
        required: true
        source: Bullhorn.Candidate.status
        enum: [active, archived, do_not_contact, placed, contractor_promoted]
        notes: |
          "contractor_promoted" = candidate whose status flipped to contractor; row gets duplicated as entity_type="contractor" via adapter layer.
      owner_user_id:
        type: integer
        required: false
        source: Bullhorn.Candidate.owner.id
        notes: Bullhorn user (consultant) who owns this candidate record.
      date_added_at:
        type: timestamp
        required: true
        source: Bullhorn.Candidate.dateAdded
      date_last_modified_at:
        type: timestamp
        required: true
        source: Bullhorn.Candidate.dateLastModified
      current_role:
        type: string
        required: false
        source: Bullhorn.Candidate.occupation
      current_employer:
        type: string
        required: false
        source: Bullhorn.Candidate.companyName
      desired_role:
        type: string
        required: false
        source: IFOS-derived (Scribe extracts from call transcripts per bullhorn §4.1 A3)
      salary_expectation_min:
        type: number
        required: false
        source: IFOS-derived (Scribe extraction; GBP annual)
      salary_expectation_max:
        type: number
        required: false
        source: IFOS-derived (GBP annual)
      location:
        type: string
        required: false
        source: Bullhorn.Candidate.address.city
        notes: Free-text city/region for v0.1. Structured location pending v1.1.
      willing_to_relocate:
        type: boolean
        required: false
        source: IFOS-derived (Scribe extracts per Ultraplan §8.1 A3)
      notice_period_weeks:
        type: integer
        required: false
        source: IFOS-derived (Scribe extracts)
      source:
        type: string
        required: false
        enum: [linkedin, referral, bullhorn_existing, direct_application, sourcing_scout, other]
        source: IFOS-derived (set by Sourcing Scout at first-touch)
      voice_classifier_score:
        type: number
        required: false
        source: IFOS-derived (Concierge voice classifier per Ultraplan §8.1 A6 Gate A; range [0, 1])
        notes: |
          Concierge gate threshold ≥ 0.75 per bullhorn §4.1. **Bounded [0.0, 1.0] enforced by the `validate_voice_scores` PL/pgSQL trigger** that lands via the v0.2 migration at `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` §7. v0.1 declares the field shape; v0.2 enforces the bound. Insertion attempts with out-of-range values raise `EXCEPTION` and reject the write.
    notes:
      - PII handling — fields email, phone, mobile, location are PII per UK GDPR Art. 4(1). Autosend-policy.md §7 `payload_preview` rules apply.
      - The full Bullhorn Candidate field set has 50+ fields plus customText1-25; v0.1 covers the minimal working set. Full enumeration TBD per bullhorn-integration-path.md §4.1 Spec gap §4.1-A at Week 3-4 Janitor build.

  # --------------------------------------------------------------------------
  contractor:
    description: |
      A person engaged on contract or temporary terms (vs. permanent placement). Distinct entity_type per Day-6 founder Q1 decision — separated from `candidate` for query clarity, IR35 first-class, and autosend policy distinguishing contractor vs candidate action_types.
    bullhorn_source: Bullhorn.Candidate where status='contractor' (or equivalent — Bullhorn's status taxonomy varies; adapter layer translates)
    v1_0_agent_access:
      - Janitor (R+W — status normalisation; ensures Bullhorn Candidate.status='contractor' maps cleanly to IFOS entity_type='contractor' per bullhorn §4.1 A2)
      - Scribe (R+W — same as candidate; contractor calls produce same Note pattern)
      - Sourcing Scout (R — passive matching includes contractor pool per Ultraplan §8.1 A5)
      - Concierge (R+W — lifecycle state; week-1/month-1 check-ins differ for contractors per Product Spec §2.2 R7)
    canonical_fields:
      # Inherits candidate fields conceptually; below are the additional contractor-specific fields.
      # Full implementation: adapter layer materialises both candidate-overlap fields AND contractor-specific fields in entities.data.
      # Schema notes: see candidate canonical_fields for the shared base set.
      bullhorn_id:
        type: integer
        required: true
        source: Bullhorn.Candidate.id
        notes: Same Bullhorn record as the candidate version; IFOS entity_id differs (`contractor:` prefix) to distinguish.
      first_name:
        type: string
        required: true
        source: Bullhorn.Candidate.firstName
      last_name:
        type: string
        required: true
        source: Bullhorn.Candidate.lastName
      email:
        type: string
        required: false
        source: Bullhorn.Candidate.email
      mobile:
        type: string
        required: false
        source: Bullhorn.Candidate.mobile
      ir35_status:
        type: string
        required: true
        enum: [inside_ir35, outside_ir35, undetermined, exempt_small_business]
        source: IFOS-derived (Concierge captures from intake call; v2.0 T4 IR35 agent owns)
        notes: Pilot-agreement liability per autosend-policy.md §10 — incorrect IR35 classification is a tenant liability event. T4 IR35 agent (v2.0) is the canonical owner.
      day_rate_min:
        type: number
        required: false
        source: IFOS-derived (Scribe extracts from call; GBP per day)
      day_rate_max:
        type: number
        required: false
        source: IFOS-derived (GBP per day)
      umbrella_company:
        type: string
        required: false
        source: IFOS-derived (Concierge captures; v1.1+ may promote to entity_type='umbrella_company' if multi-contractor patterns emerge)
        notes: v0.1 free-text. v1.1 entity-promotion candidate if Concierge surfaces shared-umbrella-company queries.
      availability_weeks:
        type: integer
        required: false
        source: IFOS-derived (when can contractor start, in weeks from now)
      current_engagement_end_date:
        type: date
        required: false
        source: IFOS-derived
        notes: When contractor's current placement ends; Concierge schedules follow-up communications around this date.
    notes:
      - IR35 classification is regulatory-bearing; v0.1 captures the field but T4 IR35 agent (v2.0 per master brief §9) is the canonical reasoner.
      - Contractor lifecycle differs from candidate — relevant to Concierge nurture cadence per Product Spec §2.2 R7 (week-1 check-in for permanent; weekly check-in for contractor through engagement).
      - Adapter layer responsibility: if Bullhorn.Candidate.status changes to/from 'contractor', adapter materialises both entity_type rows in entities table with appropriate entity_links for placement continuity.

  # --------------------------------------------------------------------------

exec
/bin/zsh -lc "sed -n '330,365p' agents/_shared/escalation-codes.md" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:

#### `ESC_SEND_FAIL`
- **Severity:** warn — distinct from auth/rate-limit; the send itself failed at the protocol layer
- **Trigger:** External send (Gmail / Outlook / Twilio / Telegram-to-customer) returned 5xx or transport error after retry budget
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `channel` (`gmail` | `outlook` | `twilio` | `telegram`), `recipient_id_hash`, `error_class`, `attempts_made`

### 2.9 — Auto-send orchestration (4 codes)
Source: `docs/decisions/autosend-safety-policy.md` §5 extensions; runtime orchestration semantics

#### `ESC_AUTOSEND_ORANGE_PENDING`
- **Severity:** info — distinct from ESC_AUTOSEND_NEEDS_REVIEW (which is the initial queue event)
- **Trigger:** Orange-tier action has been pending operator response for ≥50% of declared `timeout` (heartbeat reminder before bridge timeout)
- **Phase:** `action`
- **Routing:** `operator_chat_id` (gentle reminder; no oncall)
- **Payload fields:** `original_decision_log_id`, `action_type`, `time_pending_seconds`, `timeout_seconds`, `time_remaining_seconds`

#### `ESC_APPROVAL_BRIDGE_TIMEOUT`
- **Severity:** warn — orange action's approval window expired without response
- **Trigger:** Orange-tier action exceeded its `timeout` (default PT4H) without operator approve/reject
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id` AND `ifos_oncall_chat_id` (operator absent + commitment may need rerouting)
- **Payload fields:** `original_decision_log_id`, `action_type`, `timeout_seconds`, `target`, `payload_preview`
- **Recovery:** action converts to manual reconciliation; operator handles offline

#### `ESC_AUTOSEND_RACE`
- **Severity:** warn — concurrency / state-change race
- **Trigger:** A send is about to fire when the underlying state has changed in a way that should suppress it. Two canonical use cases:
  - **Duplicate-payload race:** two agents attempted to send the same `payload_hash` within same tenant within `race_window_seconds` (default 60s); second attempt detected by `decision_log` UPSERT-conflict; second wins-suppressed (first sends; idempotency by payload_hash)
  - **State-change race (Cash Conductor):** payment received between chase-draft and chase-send window; the invoice is no longer overdue when the orange-tier approval fires; chase cancelled (do NOT send) per Cash Conductor §4 Step 12
- **Phase:** `gating_failed`
- **Routing:** `operator_chat_id`
- **Payload fields:** `race_class` (`duplicate_payload` | `state_change_cancellation`), `payload_hash`, class-specific: duplicate → `first_agent_name`, `second_agent_name`, `time_delta_ms`, `action_type`; state-change → `entity_id`, `state_before`, `state_after`, `time_delta_ms`
- **Recovery:** duplicate → second suppressed; state-change → cancelled draft logged; no operator action required beyond informational review


codex
The first pass found a likely schema/config mismatch around the Telegram chat key, so I’m checking the exact live schema supplement and the cited agent sections before deciding.
exec
/bin/zsh -lc "nl -ba docs/decisions/2026-05-31-d1-founder-decision.md | sed -n '1,90p'" in /Users/madsadmin/code/CortexOS
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
    53	5. **Tenant config** — `tenant_adapters.config.operator_telegram_chat_id` — already supported by the existing Telegram surface; no new schema needed.
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
    67	- **No additional API keys/signups.** Telegram bot token already in `_secrets.env` per Day-4 provisioning.
    68	
    69	---
    70	
    71	*End of D1 decision doc.*

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/migrations/v0.2-to-v0.3.sql | sed -n '426,462p'" in /Users/madsadmin/code/CortexOS
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
   446	BEGIN
   447	  IF c IS NULL THEN
   448	    RETURN NEW;
   449	  END IF;
   450	
   451	  FOR k IN SELECT jsonb_object_keys(c) LOOP
   452	    IF NOT (k = ANY(allowed_keys)) THEN
   453	      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
   454	    END IF;
   455	  END LOOP;
   456	
   457	  -- v0.3 type validations
   458	  -- diagnostic_per_claim_sample_rate DEFERRED to W4-polish ADR; not validated
   459	  -- in v0.3 (also not in allowlist above, so it would fail-fast anyway)
   460	
   461	  IF c ? 'concierge_send_window' THEN
   462	    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN

exec
/bin/zsh -lc "nl -ba docs/verticals/recruitment/vertical-schema.v0.3-supplement.yaml | sed -n '755,850p'" in /Users/madsadmin/code/CortexOS
exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/agent.md | sed -n '1,240p'" in /Users/madsadmin/code/CortexOS
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

 succeeded in 0ms:
     1	# Concierge — no candidate ghosted
     2	
     3	**Status:** Proposed.
     4	**Build state:** Day-20 W4 bilateral pass + R19 substantive fixes applied. R4 closed yellow draft tier + Step 7 decision-log + ULTRAPLAN line citation cleanup. R19 fixes (today): `concierge_approval_routed` action_type registered in autosend-policy.yaml, Gate B 90% citation corrected to ADR-007 (was incorrectly attributed to ULTRAPLAN A6 line 567), voice threshold position-specific Gate A enforcement. ADR-007 (Concierge Gate A 30-min SLA hybrid) drafted at `docs/decisions/ADR-007-concierge-gate-a-30min-sla-hybrid.md`; Concierge Status flip Proposed → Accepted requires ADR-007 RATIFIED. Awaits Q1 LOI + Bullhorn Sub-decisions A+B + Microsoft Graph / Gmail per-tenant signup + Founder Decision D1 autosend orange-tier path + ADR-007 RATIFIED + W10 build slice.
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
   131	     (anti-duplicate)
   132	   → mode=nurture-sweep: query Bullhorn placements for time-elapsed events
   133	     (7d/30d/90d post-start with no concierge action in last 14d)
   134	   → ESC_LIFECYCLE_STATE_UNKNOWN if state transition not in 12-event taxonomy
   135	   → hh_decision_output("lifecycle_event_detected",
   136	     "<entity_type>:<bullhorn_id>", "<from>→<to>")
   137	
   138	2. Anti-duplicate guard
   139	   → query decision_log for prior `concierge_email_draft` row for same
   140	     (candidate_id, payload.event_type) in last 24h with phase IN
   141	     ('output', 'action') — if a prior draft was emitted AND either sent OR
   142	     is still pending consultant action, the new event is a duplicate trigger
   143	   → if found AND send-completed: skip (true duplicate)
   144	   → if found BUT prior draft never sent (no `gmail_outlook_send_to_candidate`
   145	     follow-up action row): allow the new draft attempt (per Q7 disposition)
   146	   → hh_decision_output("anti_duplicate_check", "<entity_type>:<bullhorn_id>",
   147	     "<duplicate_status>")
   148	
   149	3. Bullhorn context fetch
   150	   → bullhorn.get_candidate(candidate_id) → name, current state, comms history
   151	   → bullhorn.get_placement(placement_id) → role, client, dates
   152	   → bullhorn.get_client(client_id) → company name, primary contact
   153	   → bullhorn.get_contact(contact_id) → name, email
   154	   → ESC_RATE_LIMIT_HIT on Bullhorn 429 (payload.upstream='bullhorn');
   155	     ESC_BULLHORN_AUTH on auth fail
   156	   → ESC_AGENT_OUTPUT_SHAPE if critical Bullhorn context fields missing
   157	     (no email, no name) — Concierge cannot produce its declared output
   158	     shape (lifecycle-event draft) without a resolvable target candidate.
   159	     NOTE: ESC_CANDIDATE_DATA_INCOMPLETE is reserved for Sourcing Scout
   160	     shortlist completeness per catalogue §2.10.
   161	   → hh_decision_output("bullhorn_context_fetched",
   162	     "candidate:<bullhorn_id>", "fields_present:<N>")
   163	
   164	4. Addressee resolution (Gate A critical)
   165	   → recipient = candidate.email OR client_contact.email per event_type
   166	   → verify recipient matches the candidate_id whose lifecycle is changing
   167	     (NOT another candidate's email — per ULTRAPLAN A6 line 566 verbatim
   168	     "correct addressee resolution; no candidates emailed under another's name")
   169	   → ESC_ADDRESSEE_MISMATCH if check fails (blocking); draft aborted
   170	   → hh_decision_output("addressee_resolved", "candidate:<bullhorn_id>",
   171	     "recipient_role:<role>")
   172	
   173	5. Comms-template selection
   174	   → tenant comms-template library at /vault/<slug>/concierge-templates/
   175	   → per event_type: select template; per recipient_role: candidate vs client
   176	   → fallback: shared/common-comms-templates.yaml if tenant has no override
   177	   → hh_decision_output("template_selected", "<event_type>:<recipient_role>",
   178	     "template_id:<id>")
   179	
   180	6. Sensitive-event escalation routing
   181	   → if event_type=rejection (event 6) OR event_type=withdrawal (event 7)
   182	     OR (event_type=on-hold AND placement value >£10k): set escalation_position=3
   183	     (highest voice-classifier bar; mandatory consultant approval per autosend-policy)
   184	   → else: escalation_position=1 (standard orange tier)
   185	   → hh_decision_output("escalation_position_set", "candidate:<bullhorn_id>",
   186	     "position:<N>")
   187	
   188	7. LLM draft generation
   189	   → prompt = (event context + candidate state history + voice corpus
   190	     ANN-matched on event_type + tone rules filtered for concierge +
   191	     comms-template structure)
   192	   → output = email body + subject + recommended_send_time
   193	   → write to /vault/<tenant>/concierge-drafts/<draft_id>.md
   194	   → hh_decision_output("concierge_draft_rendered",
   195	     "candidate:<bullhorn_id>:<event_type>", "vault_path:<path>; voice_score:<N>; words:<N>")
   196	   → ESC_VOICE_DRIFT if classifier score below the escalation_position-specific
   197	     threshold (position 1 ≥0.75; position 2 ≥0.78; position 3 ≥0.82 per Step 8)
   198	     after 3 retries — the position is set in Step 6 and is the per-draft Gate A
   199	     threshold. Generic <0.75 floor would understate position 2-3 sensitivity.
   200	
   201	8. Voice + tone validation
   202	   → voice classifier scores the draft
   203	   → minimum threshold by escalation_position:
   204	     position 1: ≥0.75
   205	     position 2: ≥0.78
   206	     position 3 (rejections / sensitive): ≥0.82
   207	   → tone-rule check (block-severity rules → ESC_TONE_RULE_VIOLATION)
   208	   → on success: hh_decision_action("concierge_email_draft",
   209	     "<candidate_bullhorn_id>:<event_type>", payload_hash, payload_preview);
   210	     tier=yellow per autosend-policy.yaml
   211	
   212	9. SLA timing check (Gate B leading metric — NOT Gate A hard-fail)
   213	   → elapsed = now() - event_timestamp
   214	   → if elapsed > 30 minutes: ESC_CONCIERGE_SLA_MISS (warn; aggregate to Gate B)
   215	     → hh_decision_output("concierge_sla_miss",
   216	       "candidate:<bullhorn_id>:<event_type>",
   217	       "elapsed_seconds:<N>; ESC_CONCIERGE_SLA_MISS; aggregated_to_gate_b_90pct")
   218	       — mandatory audit row per master brief §8.1 Change 2 (phase=output;
   219	       no tiered action_type required — this is an internal status marker)
   220	   → per ULTRAPLAN A6 line 566 (as amended by ADR-007): the 30-min draft SLA is
   221	     a Gate B leading metric (90% of drafts within 30 min), not a per-draft hard
   222	     fail (legitimate polling-fallback delays would otherwise block drafts)
   223	
   224	10. PII boundary check
   225	    → no PII from other candidates referenced in body
   226	    → no PII from competitor clients referenced
   227	    → no compensation specifics outside what's already in candidate's record
   228	    → ESC_PII_LEAKAGE_RISK on hit (blocking)
   229	    → hh_decision_output("pii_check_passed", "candidate:<bullhorn_id>",
   230	     "result:passed")
   231	
   232	11. Autosend-bridge routing (D1 path)
   233	    → per Founder Decision D1 (final selection at W10 design):
   234	      D1-A (bridge to cortextOS approval system): POST internal API
   235	      D1-B (lightweight Telegram shim): send approval prompt to operator
   236	      D1-C (no autosend in v1.0): draft to vault for manual consultant pickup
   237	    → per autosend-policy.yaml: orange-tier; consultant approves
   238	    → ESC_APPROVAL_BRIDGE_TIMEOUT if no approval within the policy timeout
   239	      (default PT4H per autosend-policy.yaml lines 235-239 + escalation-codes.md
   240	      lines 348-353; looked up per action_type, not hardcoded) (D1-A/B)

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
/bin/zsh -lc "nl -ba agents/recruitment/cash-conductor/agent.md | sed -n '300,390p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
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

exec
/bin/zsh -lc 'rg -n "Telegram bot token|TELEGRAM|telegram.*_secrets|_secrets.env" docs/runbooks/day-4-provisioning.md docs -S' in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
docs/runbooks/day-4-provisioning.md:828:### §6.5 — Tightening 2: `_secrets.env` vault skeleton and `provision-tenant.sh`
docs/runbooks/day-4-provisioning.md:840:# - empty _secrets.env at mode 0600
docs/runbooks/day-4-provisioning.md:871:# _secrets.env at mode 0600 — per ADR-003 §2.1-C
docs/runbooks/day-4-provisioning.md:872:touch "$VAULT_ROOT/_secrets.env"
docs/runbooks/day-4-provisioning.md:873:chmod 0600 "$VAULT_ROOT/_secrets.env"
docs/runbooks/day-4-provisioning.md:1099:# Per-tenant .gitignore — _secrets.env never gets committed
docs/runbooks/day-4-provisioning.md:1134:- [ ] §8.3 — `/vault` is a git repo with `.gitignore` excluding `_secrets.env`
docs/architecture/tenancy-invariants.md:128:### T8 — Rendered `_secrets.env` is `chmod 0600`
docs/operations/goal-overnight-2026-05-31.md:30:2. OAuth refresh idempotency — concurrent-refresh safety; no torn `_secrets.env` writes.
docs/operations/goal-w4-day-26-afternoon-2026-06-01.md:23:- Telegram bot token from `_secrets.env` (existing per Day-4 provisioning); operator chat ID from `tenant_adapters.config.operator_telegram_chat_id` (canonical config key)
docs/architecture/vault-concurrency.md:441:The `entities.version` column is a new Day-4 tightening — joins the three already on the list per `sequencing-target.md` §6.5 (entity_graph split + `_secrets.env` + `decision_log.phase` enum extension). Day-4 task now has **4 consolidated tightenings**.
docs/architecture/architecture-cohesion-review.md:64:| ADR-003 | spec gap §2.1-C (_secrets.env) | Day-4 §6.5 provisioning + renderer envFile.ts | ✓ landed Day-4 + Phase 2 |
docs/architecture/architecture-cohesion-review.md:199:  - **A:** Helpers write to `/vault/<tenant>/decision-log.jsonl` (fallback mode) — that's structured. BUT it's an audit trail that replays into Postgres, not the source of truth. Vault `_voice/`, `_config/`, `_brand/`, `_playbooks/` are content (markdown). Vault `spot-checks/` is markdown notes. Vault `_secrets.env` is config (Path D). ✓ Mostly clean.
docs/operations/bullhorn-outreach-emails.md:129:- Refresh-token rotation behaviour determines `packages/mcp-connectors/bullhorn/src/auth.ts` design. If single-use rotation → atomic refresh logic with lock around `_secrets.env`. If long-lived → simpler.
docs/runbooks/day-4-provisioning.md:828:### §6.5 — Tightening 2: `_secrets.env` vault skeleton and `provision-tenant.sh`
docs/runbooks/day-4-provisioning.md:840:# - empty _secrets.env at mode 0600
docs/runbooks/day-4-provisioning.md:871:# _secrets.env at mode 0600 — per ADR-003 §2.1-C
docs/runbooks/day-4-provisioning.md:872:touch "$VAULT_ROOT/_secrets.env"
docs/runbooks/day-4-provisioning.md:873:chmod 0600 "$VAULT_ROOT/_secrets.env"
docs/runbooks/day-4-provisioning.md:1099:# Per-tenant .gitignore — _secrets.env never gets committed
docs/runbooks/day-4-provisioning.md:1134:- [ ] §8.3 — `/vault` is a git repo with `.gitignore` excluding `_secrets.env`
docs/_archive-build-pack/06-BUILD-PLAN.md:50:- Wire Telegram bot token via `.env.local`
docs/architecture/agent-bundle-renderer-design.md:91:`CTX_INSTANCE_ID`, `CTX_ROOT`, `CTX_FRAMEWORK_ROOT`, `CTX_AGENT_NAME`, `CTX_ORG`, `CTX_AGENT_DIR`, `CTX_PROJECT_ROOT`, plus backward-compat `CRM_AGENT_NAME` and `CRM_TEMPLATE_ROOT`. Optional based on tenant config: `CTX_TELEGRAM_CHAT_ID`, `CTX_TIMEZONE`, `TZ`, `CTX_ORCHESTRATOR_AGENT`.
docs/architecture/agent-bundle-renderer-design.md:116:| _(no IFOS source)_ | `orgs/<org>/agents/<name>/.env` | **Synthesis** | (1) `tools.yaml` MCP server list (declares which credentials are needed: `BULLHORN_OAUTH_TOKEN`, `MS_GRAPH_TOKEN`, etc.); (2) `/vault/{tenant-slug}/_secrets.env` — spec gap §2.1-C (Ultraplan §5.1 doesn't enumerate this file but it's the natural place for per-tenant credentials); (3) the agent's per-bot Telegram credentials from the same secrets file (`BOT_TOKEN`, `CHAT_ID`, `ALLOWED_USER`) per cortextOS Primitive 5 contract | All MCP server tokens declared in `tools.yaml` resolve to a non-empty value; `BOT_TOKEN` matches `/^\d+:[A-Za-z0-9_-]+$/` per `agent-manager.ts:218`; `ALLOWED_USER` is numeric per `agent-manager.ts:224`; file written `chmod 0600` (credentials) |
docs/architecture/agent-bundle-renderer-design.md:125:- **§2.1-C:** Ultraplan §5.1 line 220 names `_voice/`, `_playbooks/`, `_decisions/`, `_config.yaml` under `/vault/{tenant}/` but does not enumerate `_secrets.env`. Recommended resolution: add `_secrets.env` to the per-tenant vault skeleton; created at tenant provisioning (Ultraplan §5.5 line 263 `provision-tenant.sh {slug}` step 2). Mode `0600` owned by `ifos-tenant-{slug}`. Per Master Brief §3.3 "structured data lives in Postgres" applies to entity data; per-tenant *secrets* are the canonical exception that lives on the filesystem.
docs/architecture/agent-bundle-renderer-design.md:423:    "ESC_VOICE_DRIFT": "<acme operator chat id from _secrets.env>"
docs/architecture/agent-bundle-renderer-design.md:428:**`.env` (synthesised from `/vault/acme/_secrets.env` + `tools.yaml` MCP server list):**
docs/architecture/agent-bundle-renderer-design.md:539:- **Per-tenant secrets:** `/vault/<tenant>/_secrets.env` per spec gap §2.1-C resolution (added to `provision-tenant.sh` skeleton).
docs/architecture/agent-bundle-renderer-design.md:763:| `_secrets.env` added to `provision-tenant.sh` skeleton (per spec gap §2.1-C) | Claude Code | Day 4 of Week 0 (alongside the Postgres provisioning) |
docs/architecture/agent-bundle-renderer-design.md:830:- `_secrets.env` added to `provision-tenant.sh` skeleton — Day 4 of Week 0 (alongside the Postgres `entity_graph` rename per ADR-002 Edit 3).
docs/operations/goal-week-4-track-1.md:41:1. **`packages/mcp-connectors/xero/`** exists; modeled on companies-house. Capabilities: `oauth_refresh`, `list_open_invoices`, `list_payments`, `get_invoice`, `write_payment_received`. Fixture-first; ≥15 vitest passing; OAuth scaffold accepts real credentials from `_secrets.env` but tests use fixtures. README documents the Xero rate-limit (60 calls/min per tenant; 5000/day; documented at https://developer.xero.com/documentation/guides/oauth2/limits).
docs/operations/goal-week-4-track-1.md:61:12. **`scripts/run-diagnostic-smoke.sh`** exists. Takes `--firm "<name>" [--sector <sector>]`; sets the env vars (`IFOS_REPO_ROOT`, `CTX_AGENT_DIR`, `CTX_TENANT_SLUG`, `IFOS_VAULT_ROOT`); reads `COMPANIES_HOUSE_API_KEY` + `ANTHROPIC_API_KEY` from `~/.ifos-local-vault/migration-test/_secrets.env`; runs `bash agents/recruitment/diagnostic/cycle.sh`; on success copies the report to `docs/artefacts/diagnostic-<firm-slug>-<ISO-date>.md` and prints the vault path. Single command for the founder.
docs/operations/goal-week-4-track-1.md:121:| Step 12 (Diagnostic live smoke) | `COMPANIES_HOUSE_API_KEY` + `ANTHROPIC_API_KEY` | Founder registers self-service; saves to `~/.ifos-local-vault/migration-test/_secrets.env` mode 0600; replies "key saved"; key NEVER pasted in chat |
docs/operations/goal-week-4-track-1.md:123:| Live connector tests (deferred per §2) | Xero dev key / QB sandbox / TrueLayer dev key | Founder commercial signups (items 8-10); same `_secrets.env` save protocol |
docs/operations/goal-week-4-track-1.md:132:**NEVER** ask the founder to paste any key. **NEVER** echo a key after they confirm. **NEVER** commit `_secrets.env`. **NEVER** include keys in commit messages or error logs.
docs/operations/goal-week-4-track-1.md:164:2. **OAuth refresh idempotency** — if the connector handles OAuth, refresh must be safe to call concurrently AND must use atomic token rotation (no torn writes to `_secrets.env`).
docs/operations/goal-week-4-track-1.md:182:# Reads CH + Anthropic keys from ~/.ifos-local-vault/migration-test/_secrets.env
docs/operations/goal-week-4-track-1.md:428:3. **OAuth refresh atomic.** Concurrent-refresh test must demonstrate no torn writes to `_secrets.env`.
docs/operations/founder-manual-playbook-2026-05-31.md:108:echo 'COMPANIES_HOUSE_API_KEY=<paste-key-here>' >> ~/.ifos-local-vault/migration-test/_secrets.env
docs/operations/founder-manual-playbook-2026-05-31.md:109:chmod 600 ~/.ifos-local-vault/migration-test/_secrets.env
docs/operations/founder-manual-playbook-2026-05-31.md:124:echo 'ANTHROPIC_API_KEY=<paste-key-here>' >> ~/.ifos-local-vault/migration-test/_secrets.env
docs/operations/founder-manual-playbook-2026-05-31.md:133:grep -oE '^[A-Z_]+=' ~/.ifos-local-vault/migration-test/_secrets.env
docs/operations/founder-manual-playbook-2026-05-31.md:280:- Note the **Client ID** + **Client Secret** somewhere safe; don't save them to `_secrets.env` yet — we'll do that when the Xero MCP connector lands
docs/operations/founder-manual-playbook-2026-05-31.md:302:echo 'PROXYCURL_API_KEY=<key>' >> ~/.ifos-local-vault/migration-test/_secrets.env
docs/operations/founder-manual-playbook-2026-05-31.md:379:| Secrets file (mode 0600) | `~/.ifos-local-vault/migration-test/_secrets.env` |
docs/operations/goal-option-c-diagnostic-end-to-end.md:91:- **Do NOT** put API keys in chat OR commit them; they go to `/vault/migration-test/_secrets.env` mode 0600 only
docs/operations/goal-option-c-diagnostic-end-to-end.md:104:2. State: "Founder action needed: register for Companies House API key at https://developer.company-information.service.gov.uk/ (free, 5 min). Save the key as: `echo 'COMPANIES_HOUSE_API_KEY=<your-key>' >> /vault/migration-test/_secrets.env && chmod 600 /vault/migration-test/_secrets.env`. Confirm when done; do NOT paste the key into chat."
docs/operations/goal-option-c-diagnostic-end-to-end.md:108:**NEVER** ask the founder to paste the key. **NEVER** echo the key after they confirm. **NEVER** commit `_secrets.env`.
docs/operations/goal-option-c-diagnostic-end-to-end.md:177:STOP. Output to founder: "Step 4 — please register for Companies House API key at https://developer.company-information.service.gov.uk/. Save to /vault/migration-test/_secrets.env via SSH. Do NOT paste the key in chat. Confirm when saved."
docs/operations/goal-option-c-diagnostic-end-to-end.md:183:With the API key in `/vault/migration-test/_secrets.env`:
docs/operations/goal-option-c-diagnostic-end-to-end.md:226:source /vault/migration-test/_secrets.env
docs/runbooks/tenant-lifecycle.md:84:# Step 5: Generate _secrets.env (Path D — credentials NEVER enter chat)
docs/runbooks/tenant-lifecycle.md:86:cat > /vault/${SLUG}/_secrets.env <<INNER
docs/runbooks/tenant-lifecycle.md:88:TELEGRAM_BOT_TOKEN=<provided>
docs/runbooks/tenant-lifecycle.md:89:TELEGRAM_CHAT_ID=<provided>
docs/runbooks/tenant-lifecycle.md:90:TELEGRAM_ALLOWED_USER=<provided>
docs/runbooks/tenant-lifecycle.md:92:chmod 600 /vault/${SLUG}/_secrets.env
docs/runbooks/tenant-lifecycle.md:131:- `/vault/<slug>/` exists with mode 700 + `_secrets.env` chmod 600
docs/operations/decision-log.md:489:- **Step 2** ⏸ — Companies House API key registration (founder self-service; ~15 min); save to `/vault/migration-test/_secrets.env` mode 0600
docs/operations/decision-log.md:490:- **Step 4** ⏸ — Anthropic API key registration; same `_secrets.env` save protocol; required for LLM-driven §12 conversation opener
docs/operations/decision-log.md:531:1. **Step 2 (~15 min):** Register Companies House API key at https://developer.company-information.service.gov.uk/; save to `_secrets.env`; reply "CH key saved"
docs/operations/decision-log.md:532:2. **Step 4 (~5 min):** Register/use Anthropic API key at https://console.anthropic.com/; save to `_secrets.env`; reply "Anthropic key saved"
docs/operations/decision-log.md:564:- Save key to `/vault/migration-test/_secrets.env` mode 0600 (Path A; never enters chat)
docs/operations/decision-log.md:830:- Synthesis pipeline: agent.md→CLAUDE.md (preamble + token substitution + body marker replacement), config.schema.json→config.json (Ajv 2020-12 + 8 common-*.json $refs + {tenant_slug} default resolution), _secrets.env→.env (chmod 0600, filtered by tools.yaml required_env)
docs/operations/decision-log.md:1014:2. **Tightening 2** (ADR-003 §2.1-C): `provision-tenant.sh` installed at `/usr/local/bin/` (1521 bytes, mode 0755, syntax-OK) with `_secrets.env` skeleton (mode 0600 owned by `ifos-tenant-{slug}`).
docs/_supplementary/PRD-autonomous-agent.md:411:3. Copy the bot token → set as `TELEGRAM_BOT_TOKEN` in `.env`
docs/_supplementary/PRD-autonomous-agent.md:412:4. Message yourself, go to `https://api.telegram.org/bot{TOKEN}/getUpdates`, copy your `chat.id` → set as `TELEGRAM_CHAT_ID` in `.env`
docs/_supplementary/PRD-autonomous-agent.md:422:UPDATES=$(curl -s "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/getUpdates?offset=-10&limit=10")
docs/_supplementary/PRD-autonomous-agent.md:423:MESSAGES=$(echo $UPDATES | jq -r '.result[].message | select(.chat.id == '${TELEGRAM_CHAT_ID}') | .text' 2>/dev/null)
docs/_supplementary/PRD-autonomous-agent.md:449:  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendVideo" \
docs/_supplementary/PRD-autonomous-agent.md:450:    -F chat_id="${TELEGRAM_CHAT_ID}" \
docs/_supplementary/PRD-autonomous-agent.md:456:  curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
docs/_supplementary/PRD-autonomous-agent.md:457:    -d chat_id="${TELEGRAM_CHAT_ID}" \
docs/_supplementary/PRD-autonomous-agent.md:2494:TELEGRAM_BOT_TOKEN=...
docs/_supplementary/PRD-autonomous-agent.md:2495:TELEGRAM_CHAT_ID=...        # Your personal Telegram chat ID
docs/decisions/2026-05-18-codex-ratification-manifest.md:29:| 14 | Day-4 Postgres provisioning artefact | Embedded in #12 | Same review as #12 + verify 4 consolidated tightenings (entity_graph split, _secrets.env, decision_log.phase, entities.version) |
docs/operations/goal-week-3-polish-and-scaffold.md:124:| Step 2 | Companies House API key | Founder registers self-service at `https://developer.company-information.service.gov.uk/`; saves to `/vault/migration-test/_secrets.env` (VPS) OR `~/.ifos-local-vault/migration-test/_secrets.env` (local). NEVER pasted in chat. |
docs/operations/goal-week-3-polish-and-scaffold.md:125:| Step 6 | Claude API key (Anthropic) for §12 LLM-driven opener | Founder uses existing key OR registers new at `https://console.anthropic.com/`. Saves to same `_secrets.env`. NEVER in chat. |
docs/operations/goal-week-3-polish-and-scaffold.md:135:**NEVER** ask the founder to paste the key. **NEVER** echo the key after they confirm. **NEVER** commit `_secrets.env`. **NEVER** include keys in commit messages, error logs, or comments.
docs/operations/goal-week-3-polish-and-scaffold.md:173:> echo 'COMPANIES_HOUSE_API_KEY=<your-key>' | sudo tee -a /vault/migration-test/_secrets.env > /dev/null
docs/operations/goal-week-3-polish-and-scaffold.md:174:> sudo chmod 600 /vault/migration-test/_secrets.env
docs/operations/goal-week-3-polish-and-scaffold.md:181:> echo 'COMPANIES_HOUSE_API_KEY=<your-key>' > ~/.ifos-local-vault/migration-test/_secrets.env
docs/operations/goal-week-3-polish-and-scaffold.md:182:> chmod 600 ~/.ifos-local-vault/migration-test/_secrets.env
docs/operations/goal-week-3-polish-and-scaffold.md:220:5. Update `cycle.sh` to require `ANTHROPIC_API_KEY` from `_secrets.env` (same pattern as `COMPANIES_HOUSE_API_KEY`).
docs/operations/goal-week-3-polish-and-scaffold.md:312:- **§8 Build prerequisites:** Bullhorn MCP connector wired (W3 conditional; W4-5 if A+B answered) + first pilot tenant with Bullhorn corpToken in `_secrets.env`.
docs/operations/goal-week-3-polish-and-scaffold.md:376:- **§8 Build prerequisites:** Xero MCP connector (W4 build) + QuickBooks MCP + Sage MCP + Open Banking via TrueLayer (or similar; founder commercial signup) + tenant accounting credentials in `_secrets.env`.
docs/decisions/ADR-003-agent-bundle-renderer.md:47:- **Synthesis (3):** `agent.md` → `CLAUDE.md` (with cortextOS preamble wrapper); `config.schema.json` → `config.json` (materialised via per-tenant `_config.yaml` + common-*.json $refs); `(no source)` → `.env` (from `_secrets.env` + tools.yaml MCP server list).
docs/decisions/ADR-003-agent-bundle-renderer.md:143:**For Week 1 work.** Renderer implementation is the load-bearing Week-1 deliverable. ADR-003 lands; renderer code follows in Weeks 1-2 per design §5.2. Eight prerequisite items tabled in §5.2 with owner + target week. Two of those prerequisites (`packages/agent-renderer/templates/claude-md-preamble.md` per spec gap §2.1-A; `packages/agents-runtime/_shared/common-*.json` per spec gap §2.1-B) are part of the renderer's own scaffolding effort. Two more (`_secrets.env` added to `provision-tenant.sh` skeleton per §2.1-C; Postgres `decision_log` live per master brief §6 Day 4) land at Day 4 of Week 0. First production render is the Diagnostic agent (master brief §8.2 A1) at Week 4.
docs/decisions/ADR-003-agent-bundle-renderer.md:145:**For Week 0 remaining (Day 2 through Day 7).** ADR-003 doesn't unblock or block any remaining Week 0 work directly. Day 2 (Bullhorn integration path), Day 3 (sequencing + Brain UI scope), Day 4 (Postgres provisioning with `entities` + `entity_links` split per ADR-002 Edit 3 + `_secrets.env` skeleton), Day 5 (auto-send safety policy + kill criterion), Day 6 (vertical schema v0.1), Day 7 (single-sentence test + first Codex ratification) all proceed independently. The renderer is queued for Codex Day-7 review but does not gate Day 7's other reviews.
docs/decisions/2026-05-31-d1-founder-decision.md:67:- **No additional API keys/signups.** Telegram bot token already in `_secrets.env` per Day-4 provisioning.
docs/decisions/autosend-safety-policy.md:464:4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
docs/decisions/sequencing-target.md:55:| 2 | **Substrate exercise** | Fraction of Week-1-2 substrate (renderer / `_shared/voice-loader.sh` / `_shared/hook-helpers.sh` / Postgres `decision_log` / `_secrets.env` / Bullhorn auth refresh-loop) the agent exercises | Higher substrate exercise = more value as smoke test for the substrate, but also higher risk of substrate-bug-attributed-to-agent confusion |
docs/decisions/sequencing-target.md:101:| 6. Tenant-onboarding readiness | **High** | Runnable from end of Week 2 with renderer + `_shared/` + Postgres decision_log. No vault `_secrets.env` complexity (no per-tenant Bullhorn OAuth needed), no wiki API needed. Single-tenant deployable immediately |
docs/decisions/sequencing-target.md:110:| 2. Substrate exercise | **High** | **First agent to exercise Bullhorn auth refresh-loop** per `docs/decisions/bullhorn-integration-path.md` §4.5. First user of `_secrets.env` per Day 2 §4.3 (per-tenant Bullhorn OAuth tokens). First cron-driven agent writing to Postgres `decision_log`. Exercises dedup-confidence threshold (Ultraplan §8.1 line 511 Gate A: ≥0.85) |
docs/decisions/sequencing-target.md:390:- Postgres provisioning Day 4 with `entities` + `entity_links` split + `_secrets.env` skeleton + (now) extended `phase` enum.
docs/decisions/sequencing-target.md:432:Lands at Day 4 alongside the `entity_graph` → `entities` + `entity_links` split (ADR-002 Edit 3) and the `_secrets.env` skeleton addition (ADR-003 design §3.3 Spec gap §2.1-C). Three Day-4-tightenings consolidate into one provisioning task.
docs/decisions/bullhorn-integration-path.md:21:**Sub-decision B — OAuth flow.** Master brief §6 Day 2 line 466 pre-states a recommendation: "browser dance for production, service-account for dev." This is the authorization-code grant (per-tenant browser dance, refresh-token cycle) for production tenants, plus client-credentials grant (service account) for IFOS-internal sandbox/dev work. Sub-decision B verifies that recommendation against Bullhorn's actual OAuth implementation and pins the per-tenant token storage path (per `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C resolution: `/vault/<tenant>/_secrets.env`, mode `0600`).
docs/decisions/bullhorn-integration-path.md:54:- Per-tenant credential storage location (resolved by `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C: `/vault/<tenant>/_secrets.env`).
docs/decisions/bullhorn-integration-path.md:72:| B | "Refresh-token TTL and rotation behaviour specifics" | Same | Same | Affects renderer §3.3.2 `.env` materialisation: how often does per-tenant `_secrets.env` need rotation? Documented Bullhorn behaviour varies by account; partner-rep gives the canonical numbers |
docs/decisions/bullhorn-integration-path.md:149:- **Per-tenant model.** Each tenant has its own `corpToken` and its own per-tenant `restUrl` returned by /login. Operations are scoped by the corpToken; IFOS must hold per-tenant token state. This maps cleanly to the per-tenant credential model already pinned in `agent-bundle-renderer-design.md` §3.3.2 spec gap §2.1-C resolution (`/vault/<tenant>/_secrets.env`, mode `0600`).
docs/decisions/bullhorn-integration-path.md:173:| **Switching cost later** (start direct, move to marketplace at v1.1+) | n/a (this is the destination) | **Low if the connector code treats auth as a swap-point per §1.4 fallback architecture.** The connector's REST endpoint calls (Sub-decision C surface) are identical between paths. The auth module — `packages/mcp-connectors/bullhorn/src/auth.ts` and the `_secrets.env` materialisation in the renderer — is the only differing surface. Bounded to ~200-400 lines of code per the design in `agent-bundle-renderer-design.md` §3.3.4. |
docs/decisions/bullhorn-integration-path.md:224:This rotation pattern matters operationally: IFOS must persist the **most recent** refresh_token after every token refresh, atomically overwriting the previous one in `/vault/<tenant>/_secrets.env`. A failure between obtaining the new refresh_token and persisting it permanently invalidates the previous one — the tenant admin must re-run the browser dance. **Spec gap §3.1-A:** the renderer + auth module need a refresh-token-persistence atomicity protocol. Recommended resolution: write to `_secrets.env.tmp` then rename, matching the atomic write pattern in `agent-bundle-renderer-design.md` §3.3.4.
docs/decisions/bullhorn-integration-path.md:250:- **Production tenants:** authorization-code grant per §3.1. Per-tenant admin runs the browser dance during onboarding wizard Day 2 (Product Spec §5.2 OAuth + vault provisioning step). Refresh tokens persisted at `/vault/<tenant>/_secrets.env` mode 0600 with atomic-rename rotation per Spec gap §3.1-A resolution.
docs/decisions/bullhorn-integration-path.md:252:- **Strict separation:** IFOS internal dev tooling never touches production tenant refresh tokens. The renderer (per `ADR-003`) materialises tenant-scoped tokens into per-tenant `_secrets.env`; dev tooling reads from a separate gitignored path that doesn't pass through the renderer at all.
docs/decisions/bullhorn-integration-path.md:262:3. **The renderer's `_secrets.env` materialisation per Spec gap §2.1-C handles the credential storage cleanly.** No new persistence layer needed; the path was already specified in `agent-bundle-renderer-design.md` §3.3.2.
docs/decisions/bullhorn-integration-path.md:319:- **On-disk per-tenant credentials:** `/vault/<tenant-slug>/_secrets.env`, mode `0600`, owner `ifos-tenant-<slug>`, group `ifos-tenants`. Filesystem isolation per Ultraplan §5.1 line 218.
docs/decisions/bullhorn-integration-path.md:320:- **Refresh-token persistence atomicity:** write to `_secrets.env.tmp`, rename atomically per `agent-bundle-renderer-design.md` §3.3.4 — resolves Spec gap §3.1-A of this document.
docs/decisions/bullhorn-integration-path.md:355:- **Refresh-token rotation atomicity:** every successful refresh atomically writes the new refresh_token to `_secrets.env.tmp` then renames (Spec gap §3.1-A resolution per `agent-bundle-renderer-design.md` §3.3.4). The old refresh_token is unusable after the new one is generated — atomicity is mandatory.
docs/decisions/bullhorn-integration-path.md:410:- **`_secrets.env` vault structure provisioned** per renderer §3.3.2 — already on Week-1 prereq list from ADR-003.
docs/decisions/bullhorn-integration-path.md:415:No Postgres schema changes from this decision document. `_secrets.env` is filesystem (vault), not Postgres, per the design's vault/Postgres split (ADR-002 §3 + `second-brain-design.md` §2.4). `decision_log` columns already support per-tenant `ESC_BULLHORN_AUTH` rows per ADR-002 Decision 3 schema — no new columns needed.
docs/decisions/bullhorn-integration-path.md:483:| §3.1-A | §4.3 + §4.5 | Refresh-token persistence atomicity: write `_secrets.env.tmp`, rename atomically per `agent-bundle-renderer-design.md` §3.3.4 |
docs/decisions/bullhorn-integration-path.md:485:| Per-tenant credential isolation | §4.3 | Restated from `agent-bundle-renderer-design.md` §3.3.2 — `/vault/<tenant>/_secrets.env` mode 0600 + per-tenant OS user kernel isolation + Postgres RLS |
docs/decisions/bullhorn-integration-path.md:503:| Vault `_secrets.env` skeleton in `provision-tenant.sh` (per ADR-003 Spec gap §2.1-C) | Claude Code | Day 4 Week 0 (already scheduled) |

exec
/bin/zsh -lc "nl -ba agents/recruitment/concierge/agent.md | sed -n '330,390p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   330	| `ESC_GATE_B_MISS` | Ghosted-rate >5% OR send-as-is <60% OR 30-min SLA hit-rate <90% for 30 consecutive days | warn | founder + operator |
   331	| `ESC_AUTOSEND_ORANGE_PENDING` | Draft awaiting approval (info — heartbeat reminder when ≥50% of timeout elapsed) | info | (logged) |
   332	| `ESC_AUTOSEND_SAMPLED_SPOT_CHECK` | Yellow/orange-tier sample row selected for audit | info | operator_chat_id |
   333	
   334	Concierge has the largest escalation surface of any v1.0 agent — appropriate for the highest-stakes customer-facing comms.
   335	
   336	Concierge does NOT use:
   337	
   338	- `ESC_AUTOSEND_BLOCKED` — reserved for red-tier action attempts per catalogue line 41; Concierge has no red-tier actions. Gate A failures fire `ESC_AGENT_OUTPUT_SHAPE` instead.
   339	- `ESC_SCHEMA_VIOLATION` — reserved for vertical-schema field-constraint violations at write time per catalogue line 163; Concierge's Gate A failures are output-shape or addressee-resolution failures.
   340	- `ESC_VOICE_DRIFT_TENANT` (direct firing) — that's fired by the nightly voice-drift cron per catalogue §2.5; Concierge fires only per-run `ESC_VOICE_DRIFT`.
   341	
   342	---
   343	
   344	## §7 — Voice + tone constraints
   345	
   346	Steps 7-8 (draft generation + voice/tone validation) are the load-bearing voice surface of v1.0. The agent integrates with `_shared/voice-loader.sh`:
   347	
   348	- **`hh_load_tone_rules` filtered by `applies_to_agents` containing `concierge`** — surfaces rules like:
   349	  - No "We regret to inform you" boilerplate (rejection emails are the hardest test case per ULTRAPLAN A6 §gotchas (line numbers vary; see live file); demand specificity)
   350	  - No "Per our previous conversation" without referencing the actual conversation context
   351	  - No urgency language ("URGENT", "ACT NOW") unless the lifecycle event genuinely requires it
   352	  - No mention of other candidates by name
   353	  - No salary/rate specifics outside what's already on the candidate's record
   354	  - No competing-agency references
   355	- **`hh_load_voice_samples` ANN query against tenant voice_corpus**: top-5 chunks matching the specific event_type (e.g., "rejection email" task context surfaces rejection-style samples).
   356	- **`hh_load_recent_edits` last 30 days for `concierge` agent**: drift signal. Per-run `ESC_VOICE_DRIFT` fires when a draft's voice classifier score is below the position-specific threshold after 3 retries. Aggregate `ESC_VOICE_DRIFT_TENANT` is fired by the nightly voice-drift cron per `escalation-codes.md` §2.5 (≥N `ESC_VOICE_DRIFT` rows from the same tenant in rolling 7d window); Concierge does NOT fire `_TENANT` directly. Edit-distance metrics are tracked for analytics; they inform the canary's threshold tuning but do not fire ESC codes from Concierge.
   357	
   358	**Position-specific thresholds:**
   359	- Position 1 (standard sends — acknowledgement, prep, debrief, nurture): voice ≥0.75
   360	- Position 2 (placement-positive, status-update): voice ≥0.78
   361	- Position 3 (rejections, sensitive on-hold): voice ≥0.82 (ULTRAPLAN A6 §gotchas (line numbers vary; see live file) explicitly names rejection voice as the hardest case)
   362	
   363	Per master brief §8.1 Change 1: voice is per-tenant; never cross-tenant.
   364	
   365	---
   366	
   367	## §8 — Build dependencies (W10-13 prerequisites)
   368	
   369	Concierge build cannot start until ALL of the following are confirmed:
   370	
   371	| Dependency | Source | Status |
   372	|---|---|---|
   373	| Renderer + `_shared/` substrate | Day-8 + Round-3 ratified | ✅ |
   374	| Diagnostic ratified | Week 3 Codex Round 4 | ⏸ |
   375	| Janitor + Scribe ratified (Bullhorn R+W substrate) | W5-W6 Codex Rounds | ⏸ |
   376	| Cash Conductor ratified (autosend-bridge precedent if D1 path A) | W7-8 Codex Round | ⏸ |
   377	| First pilot tenant onboarded | Post Q1-LOI | ⏸ |
   378	| **Bullhorn Sub-decisions A+B Accepted** | Bullhorn partnerships response | ⏸ |
   379	| Bullhorn MCP R+W capability | W3-W4-W5 build chain | ⏸ |
   380	| **Microsoft Graph commercial signup** (per tenant) | Tenant onboarding | ⏸ |
   381	| **Gmail / Google Workspace signup** (alternative per tenant) | Tenant onboarding | ⏸ |
   382	| Microsoft Graph MCP connector | W10 build start (~3 days) | ⏸ |
   383	| Gmail MCP connector | W10 build start (~3 days) | ⏸ |
   384	| **Founder Decision D1 (autosend orange-tier path)** RESOLVED | Founder decision; awaits review of D1-A/B/C spec | ⏸ |
   385	| Autosend bridge built (per D1 outcome) | W10 build start (~2 days for D1-A; less for D1-B/C) | ⏸ |
   386	| Voice classifier microservice live | W4-5 polish | ⏸ |
   387	| Per-tenant comms-template library at `/vault/<slug>/concierge-templates/` | Tenant onboarding | ⏸ |
   388	| Tenant tone_rule table seeded for concierge | Tenant-admin | ⏸ |
   389	| Voice corpus seeded for first pilot tenant | Tenant-admin onboarding | ⏸ |
   390	| `validate.sh` Gate A logic | Build at W10 start (~2 days; most complex of v1.0 validators) | ⏸ |

exec
/bin/zsh -lc "nl -ba docs/decisions/autosend-safety-policy.md | sed -n '252,268p'; nl -ba docs/decisions/autosend-safety-policy.md | sed -n '460,488p'" in /Users/madsadmin/code/CortexOS
 succeeded in 0ms:
   252	  "approval_gate_id": "<cortextOS approval gate primary key>"
   253	}
   254	```
   255	
   256	**Escalation path:**
   257	
   258	1. `autosend_emit_decision_log` writes the row with `phase='action'`, `payload.approval_status='pending'`
   259	2. `autosend_escalate ESC_AUTOSEND_NEEDS_REVIEW` opens the cortextOS approval gate
   260	3. Telegram bot (master brief primitive 5) notifies tenant operator via the chat ID in `tenant_adapters[autosend_policy].config.approval_routing.default_recipient`
   261	4. Operator responds via Telegram inline button: `approve` / `reject` / `escalate-up`
   262	5. On resolution, `decision_log` row is **appended** (not modified — append-only) with `phase='action'`, `payload.approval_status='approved'|'rejected'|'escalated'` and `payload.approval_resolution_at`
   263	
   264	**Expected resolution time:** human responds within 4h (default). Auto-rejects on timeout with `payload.approval_status='timeout_rejected'`. Tenant operators can adjust the timeout per-action_type via `tenant_adapters[autosend_policy].config.approval_timeouts.<action_type>` (range: 30min to 72h).
   265	
   266	**Telegram message template:**
   267	
   268	```
   460	
   461	1. **Elevation only.** Tenants can move an action_type from green → yellow → orange → red. They cannot move it the other direction (red → orange, orange → yellow, yellow → green).
   462	2. **Red is absolute.** A red action_type cannot be elevated by tenant override (already at maximum) and cannot be relaxed (red is the floor).
   463	3. **`blocked_recipients`** is additive only. Recipients can be added; system-default red-list recipients cannot be removed. Pattern matching supported via `*` wildcards.
   464	4. **`approval_routing.default_recipient`** is required for any tenant with orange-tier actions enabled. Pointer to a Telegram chat ID (or other channel via tenant_adapters expansion). Sourced from `/vault/<tenant>/_secrets.env` at render time per ADR-003 Decision 3 §2.1.
   465	5. **`approval_timeouts`** allow per-action_type customisation within range [PT30M, PT72H]. Defaults to PT4H if unspecified.
   466	6. **`sampling_rates`** allow per-action_type adjustment to the 1-in-N spot-check rate for yellow tier. Tenant cannot set rate to 0 (disable sampling); minimum is 1-in-100.
   467	
   468	### Override propagation
   469	
   470	Overrides take effect at next agent session boundary (cortextOS PTY restart). For immediate effect, tenant operator can request manual restart via Brain UI. Override changes are themselves logged to `decision_log` with `phase='trigger'`, `agent_name='_tenant_admin'`, `payload.action='autosend_policy_override_changed'`.
   471	
   472	---
   473	
   474	## §9 — v1.0 vs v1.1+ phasing
   475	
   476	### v1.0 ships with green + red only
   477	
   478	**Rationale:**
   479	
   480	- **Green and red** give the binary "allowed" vs "blocked" classification needed for a low-risk v1.0 launch. Every action is either fully auto-sent or fully blocked. No "needs approval" or "sampled" intermediate states.
   481	- **Yellow** (sampled review) requires building the spot-check queue infrastructure (spot_check_queue table, Brain UI review interface, sampling-disagreement-feedback loop). Defers without operational risk: high-volume agent work can run as green at v1.0 without sampled review, with tier elevation to orange-in-v1.1 as a fallback if quality issues surface.
   482	- **Orange** (per-action approval) requires the cortextOS approval gate to be wired with IFOS-specific approval categories. The gate primitive ships per Day 1 audit (`src/bus/approval.ts`), but the routing logic + Telegram bot configuration per tenant + tenant_adapters approval_routing wiring is non-trivial.
   483	- v1.0 handles "needs approval" cases via **ad-hoc Telegram approval** outside the policy pipeline: agent emits a manual approval request via existing primitive 5, founder/operator resolves manually, agent proceeds. These cases are tracked as "would-be-orange" candidates for v1.1 prioritisation.
   484	
   485	### v1.1 phases in
   486	
   487	- **Orange tier:** approval gate driven by policy lookup. Implementation tasks: `autosend_await_approval` function, `tenant_adapters[autosend_policy].config.approval_routing` resolution, Telegram bot inline-button handling, timeout enforcement.
   488	- **Yellow tier:** spot-check sampling. Implementation tasks: `spot_check_queue` table, `autosend_should_sample` function, Brain UI spot-check review interface, sampling-disagreement feedback loop into policy review.

codex
REJECTED

1. Invalid tenant config key is introduced while claiming no schema impact. Lines 53 and 66 cite `tenant_adapters.config.operator_telegram_chat_id` and say no new schema is needed, but `vertical-schema.v0.3-supplement.yaml` §4 says unknown keys hard-fail, and the migration allowlist lines 432-445 does not include `operator_telegram_chat_id`. Use the existing `tenant_adapters[autosend_policy].config.approval_routing.default_recipient` shape documented in `autosend-safety-policy.md` lines 260 and 464, or add the new key to a schema supplement + migration.

2. Missing required end-of-document status update line. The architecture-decision skill §1 requires a status update line at the end for all statuses, but the artefact ends at line 71 with only `*End of D1 decision doc.*`. Add a final status line such as `Status update: Accepted on 2026-05-31 by founder-delegated arbitration; pending Codex ratification outcome.`.

3. False citation about Telegram secrets provisioning. Line 67 says the Telegram bot token is "already in `_secrets.env` per Day-4 provisioning", but `docs/runbooks/day-4-provisioning.md` lines 871-873 only create an empty `_secrets.env` skeleton; they do not provision a Telegram bot token. Replace the claim with "Day-4 provisioning creates the `_secrets.env` skeleton; tenant onboarding must populate Telegram credentials" and cite the correct onboarding/runbook source if applicable.
tokens used
69,519
REJECTED

1. Invalid tenant config key is introduced while claiming no schema impact. Lines 53 and 66 cite `tenant_adapters.config.operator_telegram_chat_id` and say no new schema is needed, but `vertical-schema.v0.3-supplement.yaml` §4 says unknown keys hard-fail, and the migration allowlist lines 432-445 does not include `operator_telegram_chat_id`. Use the existing `tenant_adapters[autosend_policy].config.approval_routing.default_recipient` shape documented in `autosend-safety-policy.md` lines 260 and 464, or add the new key to a schema supplement + migration.

2. Missing required end-of-document status update line. The architecture-decision skill §1 requires a status update line at the end for all statuses, but the artefact ends at line 71 with only `*End of D1 decision doc.*`. Add a final status line such as `Status update: Accepted on 2026-05-31 by founder-delegated arbitration; pending Codex ratification outcome.`.

3. False citation about Telegram secrets provisioning. Line 67 says the Telegram bot token is "already in `_secrets.env` per Day-4 provisioning", but `docs/runbooks/day-4-provisioning.md` lines 871-873 only create an empty `_secrets.env` skeleton; they do not provision a Telegram bot token. Replace the claim with "Day-4 provisioning creates the `_secrets.env` skeleton; tenant onboarding must populate Telegram credentials" and cite the correct onboarding/runbook source if applicable.
