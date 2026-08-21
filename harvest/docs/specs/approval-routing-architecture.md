# IntelForce OS — Approval, Routing & Foreground-Agent Architecture

**Document type:** Build specification & design rationale — for Claude Code handoff
**Status:** Proposed (component statuses inline). Supersedes nothing; extends the v2 PRD §4.1 (decision log), the 24/7 upgrade directive (approval classes), and race-demo-spec.md (Telegram demo surface).
**Owner:** Maddox (build)
**Scope:** How approvals are surfaced, who they route to, how the firm's structure is read rather than configured, and the foreground chat agent that makes the platform feel like a product rather than background admin.
**Quality bar:** A consultant should approve *less over time*, not *faster* — and should never receive an approval that isn't theirs. Routing must be derived from data the system already reads (Bullhorn ownership + M365 Graph), not hand-configured per firm.

---

## 0. The one idea everything else hangs off

**We do not assign approvals to people. We resolve them from data the firm already maintains.**

Bullhorn already contains the entire map of who owns what — every candidate's owning consultant, every client's account manager, every JobOrder's owner. The approval system is a *resolver* that reads this ownership at the moment an agent fires and routes accordingly. The consequence: a consultant covering "tech contract, North West" sees only their patch, and a consultant covering "finance perm, London" sees only theirs — **without us ever describing either patch.** The personalisation is emergent from one general rule (route to the record's owner) meeting Bullhorn's existing ownership data.

This collapses what looks like per-consultant configuration into a single mechanism that produces N tailored experiences. Build the mechanism once; the tailoring is free.

The only thing that genuinely varies per firm is a ~6-row lookup table (the function→role map, §6) covering the handful of firm-level actions that aren't tied to an owned record. And even that is inferred-and-confirmed, not configured.

---

## 1. The two surfaces of the product

IFOS has, until now, been a background system that surfaces via Telegram approvals. This spec adds a **foreground** surface so clients feel they hold a real, interactive product — not just invisible admin.

| Surface | Name | What it is | Direction |
|---|---|---|---|
| Foreground | **The Desk** | A named chat agent living in Teams/Slack/WhatsApp, answering questions against the tenant's second brain in real time, with citations to the source record | Pull (user asks) |
| Background | The agent suite | Janitor, Scribe, Concierge, Cash Conductor, Client Hunter, etc. — draft operational work, surface approvals | Push (agent acts) |

**The unifying move:** The Desk is *also* the approval surface. The same agent the recruiter asks ("who's gone quiet this week?") is the one that surfaces "Concierge drafted a reply to James Harker — approve?" One relationship, one thread, one trust model. The chat agent and the approval inbox stop being two things.

### 1.1 The Desk — build notes

- **Read-heavy, low-write.** Answers questions by reading the per-tenant vault + entity graph + decision log live. Any *write* it proposes (e.g. "draft a follow-up") routes through the same human-in-the-loop approval as every background agent. One trust model across the whole product.
- **Transparency hook (the differentiator):** every claim The Desk makes cites the vault record or decision-log entry it came from. "Where did that come from?" is always answerable. This is the second-brain-as-asset thesis made tangible and is the antidote to recruiter distrust of black-box AI.
- **Model approach for v1: base model + RAG over the vault, NOT a per-tenant LoRA.** "Personal model" is an honest *positioning* claim achievable with retrieval. This does **not** change the locked LoRA-vs-RAG gate — no fine-tuning, no hardware spend, until RAG is proven insufficient and the adapter beats base+RAG on the eval.
- **Scoping:** The Desk answers scoped to the asker's ownership (their candidates, clients, roles). Managers see their reports' records. Same owner-resolution as routing (§4), applied as a read-filter instead of a route. See §7.

### 1.2 Transport priority

| Transport | Role | Status |
|---|---|---|
| Microsoft Teams (Adaptive Cards + bot) | **Primary** — ~50%+ of UK boutique recruitment lives in the M365 estate | Proposed, build first |
| WhatsApp Business API (interactive buttons) | For the ~25–30% mobile-only / no-formal-chat segment | Proposed, fast-follow |
| Slack | Adapter behind same boundary, build only when a paying prospect lives there | Deferred |
| Telegram | Demo surface (race-demo-spec.md) + production fallback | Existing |

All four sit behind the existing **notification-adapter** boundary. The orchestrator emits an approval-required event with a payload and an opaque token; the adapter renders it for whichever transport the tenant uses. **Production never imports the transport.** Same one-way boundary as the current Telegram integration.

**Why Teams resolves the data-sovereignty tension:** the Telegram minimal-PII constraint (summary + opaque token only, full content stays in IFOS) gets *easier* in Teams — approval cards show summary + token, full draft lives in the vault behind a deep link, and everything stays inside the Microsoft 365 boundary the firm already trusts. This reinforces the UK-data-residency pitch rather than fighting it.

---

## 2. What actually needs approving — the three buckets

Sort every agent action into one of three trust states. This is the foundation: **the frictionless endpoint is approving *less*, because trusted classes graduate out of the queue — not tapping faster.**

| Bucket | Trust state | Behaviour | Examples |
|---|---|---|---|
| 1 | **Never asks** | Read-only actions touch nothing external; no approval | Sourcing Scout reads; Janitor *detection* pass; The Desk reads |
| 2 | **Asks once → standing approval** | Starts as draft-and-approve. After a class shows <2% override rate over ~30 days, firm-admin can flip it to standing approval; agent then auto-executes and logs, stops asking | Concierge "acknowledge new candidate"; Scribe note-writing; Janitor cleanup tags |
| 3 | **Always asks** | Irreversible or relationship-sensitive; never graduates | Outbound to a *client*; any finance action (credit note); candidate withdrawal/complaint flagged sensitive; first-contact competitor-interception outreach |

**Design principle:** the goal is to shrink Bucket 3 and graduate Bucket 2. A product where the recruiter taps four times a day instead of forty is what retains. Expect approval volume to drop ~80% within two months of onboarding as Bucket 2 classes graduate.

**Graduation gate:** a Bucket 2 class is eligible to flip to standing approval when its consultant-reviewed override rate stays under 2% for 30 days in that category (consistent with the 24/7 directive §10.1). The override rate is computed from the decision log (rejections + edits / total drafts for that class).

---

## 3. Firm structure — what the system must read

Routing only makes sense against how recruitment firms are actually built.

### 3.1 The desk is the unit

A **desk** = a consultant (or pair) owning a market: a sector × geography ("tech contract, North West"). The desk owner is accountable for everything in that patch. **Most approvals follow the desk, not a function** — which is why record-ownership resolution (§4) handles the majority of routing.

### 3.2 Two desk models — this changes routing

| Model | Who does what | Typical firm | Routing consequence |
|---|---|---|---|
| **360** | One consultant runs the full cycle: BD, source, screen, place, account-manage | Boutiques (your v1 ICP) | One owner per record; candidate + client approvals both go to the same consultant |
| **180 / split** | Account managers own clients & win briefs; resourcers own candidates & fill roles | Larger firms (~30 staff) | Candidate-side and client-side of the *same placement* route to *two different people* |

### 3.3 The two archetypes (from pricing-and-value doc)

**6-person boutique (v1 ICP):** founder + ~4 consultants (360) + 1 ops admin.
- Desk-bound approvals → each consultant approves their own candidates/clients. ~5 independent streams, no overlap.
- Function-bound approvals → Janitor + Cash Conductor → the **founder** (who is also FD and ops decision-maker). Client Hunter → the consultant owning that patch.
- **Config needed: near-zero.** Bullhorn ownership + "founder is catch-all" covers ~95%. This is why the boutique is the right wedge.

**30-person split-desk firm:** ~3 desk leads, ~12 account managers, ~10 resourcers, an FD, an ops/data manager, a director.
- Desk-bound approvals → split by side of the deal. Candidate-side Concierge/Scribe → the owning resourcer. Client-side Concierge/Competitor Interception → the owning account manager.
- Function-bound approvals → Janitor → ops/data manager; Cash Conductor → FD; Client Hunter → relevant desk lead.
- Escalation has real depth: resourcer → desk lead → director.

**Both firms run the identical routing logic.** What differs is only the number of owners and whether desks are 360 or split — both read straight from Bullhorn. One resolver, degrading gracefully: in a boutique most function roles collapse onto the founder; in a large firm they fan out.

---

## 4. The routing resolver — record-owner-first ladder

When an agent produces an action requiring approval, resolve the approver by walking this ladder, most-specific first:

```
1. RECORD OWNER (from Bullhorn)
   Does the acted-on record (Candidate / ClientCorporation / JobOrder / Placement)
   have an owner field populated?  → route to that person.
   Handles the vast majority of candidate- and client-bound actions.

2. FUNCTION ROLE (from the function→role map, §6)
   No record owner, or action is not record-bound (finance reconciliation,
   ATS-wide cleanup)?  → route to whoever holds that function.

3. FIRM DEFAULT APPROVER (designated catch-all, usually a director/founder)
   Function unmapped or role unfilled?  → route here so nothing falls through.
```

The escalation chain + TTL logic (§5) sits *on top* of whichever level resolves: if the resolved approver doesn't respond within the TTL, escalate to their backup, then the firm default.

### 4.1 Agent → routing-class table (fixed in product, same for every firm)

Every agent is **desk-bound** (resolves to record owner) or **function-bound** (resolves to a role). This column is shipped, not configured.

| Agent | Class | Acts on | Resolves to | Default bucket |
|---|---|---|---|---|
| Concierge | desk-bound | a candidate / a client | record owner (consultant; or resourcer/AM in split desk) | 2 (candidate) / 3 (client) |
| Scribe | desk-bound | a candidate/client record | consultant who had the call | 2 |
| Sourcing Scout | desk-bound | a JobOrder | role owner (read-only; rarely approves) | 1 |
| Spec Pitcher / Network Compounder | desk-bound | candidate + target client | candidate's owner | 3 (client-facing) |
| Janitor | function-bound | whole ATS | ops/data role (founder in boutique) | 2 |
| Cash Conductor | function-bound | firm invoices/cash | finance role (FD; founder in boutique) | 3 |
| Client Hunter / Competitor Interception | function-bound | target market | relevant desk lead / BD role | 3 |

### 4.2 Conflict & gap rules

- **Record ownership vs org-chart role disagree (record-bound action):** record ownership wins. The person actually working the candidate is the right approver, even if a director "owns" the function on paper. Org chart is only the fallback for non-record-bound actions. *(Open decision — confirm against first split-desk prospect, §10.)*
- **Record with no owner in Bullhorn:** route to firm default approver, AND surface "these N records have no assigned consultant" as a **Janitor finding**. The data gap becomes a selling point.
- **Split-desk action touching both sides of a placement** (e.g. a candidate-offer message that's also a client commitment): route to the candidate-owner with a visible CC to the account manager. The content-owning side approves. *(Open decision, §10. Boutiques don't have this problem — one more reason they're the right v1.)*

---

## 5. Reachability & escalation — handling "not at their desk"

Teams is an account, not a desktop app: the same Adaptive Card renders in the Teams **mobile** app and fires a push notification. The majority case ("I'm between meetings") is solved by mobile Teams — you inherit Microsoft's notification infrastructure for free. The genuine edge (phone dead, on a flight, asleep at 23:30) is a *routing* problem, handled by four mechanisms.

### 5.1 Every action class carries five routing properties

This is the **action-class registry** — the whole approval-management system in one table. It extends the trust-state from §2.

| Property | What it controls | Example: candidate ack | Example: client credit note |
|---|---|---|---|
| Trust state | graduates / always-asks | graduating (Bucket 2) | always-approve (Bucket 3) |
| Routing rule | record owner / function role | record owner | function role: finance |
| Escalation chain | who's next if no response | → desk lead (after 30 min) | → none |
| TTL | how long before on-expiry fires | 2 hours | none (holds indefinitely) |
| On-expiry behaviour | hold / auto-execute / safe-default | safe-default holding reply | hold |
| Breaks quiet hours? | can it ping out-of-hours | yes if live conversation | no — morning digest |

### 5.2 The three on-expiry behaviours

When the TTL expires and nobody in the chain responded, the action does one **pre-declared** thing per class:

1. **Hold** *(default for all Bucket 3 — irreversible/client-facing/financial)*: waits in the queue. Nothing lost. A credit note that waits overnight costs nothing.
2. **Auto-execute** *(only for classes already proven near-standing-approval)*: sends itself and logs "auto-sent on TTL expiry, no approver responded." Allowed only for classes past the graduation gate. Silence triggers it instead of an explicit flip.
3. **Safe-default** *(the key one for live candidate flows)*: sends a minimal, pre-approved **holding reply** ("Thanks for your CV, one of the team will be in touch") instead of the full drafted response. Relationship protected (candidate engaged immediately, doesn't go to a competitor by morning), but no judgment-requiring content goes out unreviewed. The full personalised reply still waits for human approval in the morning.

**Safe-default squares the "Hudson by morning" pitch with the blast-radius risk.** It's the only option that keeps the always-on candidate-response promise honest without auto-sending unreviewed content. Holding-reply templates are produced per firm in the voice-profile step you already run.

### 5.3 Quiet hours & digest batching

- Low-urgency Bucket 2 items batch into a **morning digest** — one card at (firm-configurable) 08:30 listing everything drafted overnight, with approve-all or tap-through.
- Only genuinely time-sensitive classes (live candidate mid-conversation, competitor-interception window) break quiet hours.
- Firm sets its own quiet hours.

**Principle:** the always-on engine working overnight is the feature; always-on *pinging* is the bug. Reachability is a fallback for the genuinely urgent, not the default mode. Resist making everything reachable 24/7 — the better product mostly *doesn't* ask out of hours; it holds, batches, or safe-defaults, and respects that the recruiter is asleep.

---

## 6. The function→role map — the only per-firm artifact

### 6.1 What it is and why it exists

The routing ladder (§4) resolves most approvals via Bullhorn record ownership before this map is ever consulted. The map exists **only for function-bound agents** — the handful of firm-level actions with no single record owner:

- Cash Conductor drafts a credit note → no "owner" of a credit note → *finance* action → finance role.
- Janitor runs an ATS-wide sweep → no single record owner → *data/ops* action → ops role.
- Client Hunter surfaces an unowned BD lead → no owner exists yet → *BD* action → BD role.

So the map answers one narrow question: *for firm-level actions not tied to an owned record, which human is accountable?* That's why it's ~6 rows.

### 6.2 How it coincides with the existing product

Three places, **no new infrastructure**:

1. **It's a vault file.** Lives in the per-tenant vault (e.g. `routing/function-roles.yaml`) alongside the voice profile and entity graph. The notification-adapter reads it to resolve function-bound approvers. Vault data, not a new DB.
2. **Populated by the Diagnostic + Graph you already run.** M365 Graph returns job titles → auto-generated first-pass draft. The Recruitment Diagnostic surfaces it for confirmation ("finance → Priya, ops → Tom, correct?") — two minutes. Confirmed map writes to the vault at onboarding. Same infer→surface→confirm pattern as the rest of the product, applied to routing itself.
3. **Degrades along the tier archetypes automatically.** Boutique: five of six functions collapse onto the founder. 30-person: same six rows pointing at six people. Identical structure; only values differ.

### 6.3 Drop-in schema — `routing/function-roles.yaml`

```yaml
# Per-tenant function→role map. One file per tenant, in the vault.
# Populated: M365 Graph inference → Diagnostic confirmation → written here.
# Read by: notification-adapter, for function-bound agents only.
# Record-bound actions never consult this file (they resolve via Bullhorn owner).

tenant_id: "{tenant-uuid}"
schema_version: 1
confirmed_at: "2026-06-10T00:00:00Z"   # set when Diagnostic confirmation completes
confirmed_by: "{m365-user-id}"

# The firm-wide catch-all. Ladder step 3. Must always be set.
firm_default_approver:
  person_ref: "{m365-user-id}"          # canonical identity = M365/Entra object id
  display_name: "Jane Founder"

functions:
  - function: finance                    # Cash Conductor, invoice/credit actions
    holder:
      person_ref: "{m365-user-id}"
      display_name: "Priya Finance"
      source: graph_inferred             # graph_inferred | diagnostic_confirmed | manual
    escalation:
      - person_ref: "{m365-user-id}"     # backup #1
        display_name: "Jane Founder"
    ttl_minutes: null                    # null = holds indefinitely (Bucket 3)
    breaks_quiet_hours: false

  - function: ops_data                   # Janitor cleanup batches, ATS hygiene
    holder:
      person_ref: "{m365-user-id}"
      display_name: "Tom Ops"
      source: diagnostic_confirmed
    escalation:
      - person_ref: "{m365-user-id}"
        display_name: "Jane Founder"
    ttl_minutes: 1440                    # 24h, low urgency
    breaks_quiet_hours: false

  - function: business_development       # Client Hunter / Competitor Interception
    holder:
      person_ref: "{m365-user-id}"
      display_name: "Desk Lead — Tech"
      source: diagnostic_confirmed
    escalation:
      - person_ref: "{m365-user-id}"
        display_name: "Jane Founder"
    ttl_minutes: 120
    breaks_quiet_hours: true             # competitor-interception window is time-sensitive

  - function: candidate_comms_default    # fallback when a candidate has no Bullhorn owner
    holder:
      person_ref: "{m365-user-id}"
      display_name: "Jane Founder"
      source: manual
    escalation: []
    ttl_minutes: 120
    breaks_quiet_hours: false

  - function: client_comms_default       # fallback when a client has no Bullhorn owner
    holder:
      person_ref: "{m365-user-id}"
      display_name: "Jane Founder"
      source: manual
    escalation: []
    ttl_minutes: null
    breaks_quiet_hours: false

  - function: admin                      # timesheet chases, generic ops
    holder:
      person_ref: "{m365-user-id}"
      display_name: "Tom Ops"
      source: graph_inferred
    escalation:
      - person_ref: "{m365-user-id}"
        display_name: "Jane Founder"
    ttl_minutes: 1440
    breaks_quiet_hours: false

# Boutique collapse note: in a boutique, multiple `holder.person_ref` values
# will be identical (the founder). That is correct and expected. If the founder
# wants to delegate a function from day one, edit one `holder` row — no other change.
```

### 6.4 Identity resolution

The canonical person identity is the **M365/Entra object id** (`person_ref`), because Teams is the primary surface and Graph is the directory of record. The resolver needs a mapping from **Bullhorn user id → M365 object id** so that a Bullhorn record owner can be routed to their Teams identity. Build this mapping once at onboarding (match on email; confirm exceptions in the Diagnostic). Store it in the vault alongside `function-roles.yaml`.

---

## 7. Scoping — The Desk and digests

The same record→owner join used for routing is reused as a **read-filter**:

- **The Desk chat:** answers a person only against records they own. "Who's gone quiet?" → scoped to the asker's candidates/clients/roles. A manager sees records owned by their direct reports (reporting line from Graph).
- **Digests & proactive nudges:** a person's morning digest contains only their desk.

One join (record → owner → person), three uses: a **route** (approvals), a **read-filter** (The Desk), a **digest-filter** (proactive surfacing). Not configured — it's the owner data applied three ways.

---

## 8. Territories — explicitly NOT built for v1

Do **not** build a "territory" concept. A consultant's patch is implicit in the records they own. The only case needing explicit territory data is assigning *new/unowned* work (e.g. Client Hunter finds a North West tech lead nobody owns yet).

**v1 decision:** route all unassigned work to a **desk lead who manually assigns** it (assigning leads is a real recruiter habit; zero config). Add per-consultant territory tags ("Sarah = North West + tech") only if a paying firm asks for auto-assignment. Do not build territories until someone's paying and asking.

---

## 9. Implementation checklist — for Claude Code

Build order respects dependency and the "output before architecture, reuse before build" discipline.

**Phase A — resolver core (no new transport)**
- [ ] `routing/function-roles.yaml` schema + loader (validate against schema_version).
- [ ] Bullhorn-user-id → M365-object-id mapping table in vault; email-match populator + exception list.
- [ ] Owner-resolution function implementing the §4 ladder: `resolve_approver(action) → person_ref`. Pure function over (Bullhorn owner lookup, function-roles map, firm default).
- [ ] Action-class registry (§5.1): the five routing properties per class. Seed from the §4.1 table defaults.
- [ ] Decision-log integration: every resolution writes (action, resolved person_ref, ladder-step-hit, reason) so routing itself is auditable.

**Phase B — trust state & escalation**
- [ ] Trust-state machine per action class (Bucket 1/2/3); graduation gate computing override rate from decision log (<2% / 30 days).
- [ ] Standing-approval flip: firm-admin-only, per-firm, audit-logged.
- [ ] TTL + escalation-chain walker: on no-response, escalate per chain, then firm default.
- [ ] On-expiry behaviours: hold / auto-execute / safe-default. Safe-default needs per-firm holding-reply templates (extend voice-profile step).
- [ ] Quiet-hours + morning-digest batcher (firm-configurable window).

**Phase C — Teams surface (behind notification-adapter)**
- [ ] Teams bot + Adaptive Card renderer: summary + opaque token only; full draft via deep link into vault. Approve / Edit / Reject buttons; callback round-trip via Bot Framework.
- [ ] Edit flow decision (§10): inline card vs deep-link into The Desk thread.
- [ ] Reject captures reason → feeds override-rate stat.
- [ ] Push-notification path verified on Teams mobile.

**Phase D — The Desk (foreground)**
- [ ] Read-only chat agent: base model + RAG over vault/entity graph/decision log. NO LoRA.
- [ ] Citation layer: every claim cites source record/decision-log entry.
- [ ] Owner-scoped read-filter (§7); manager-sees-reports via Graph reporting line.
- [ ] Approval surfacing in the same thread (unify chat + approval inbox).

**Deferred:** WhatsApp adapter (fast-follow), Slack adapter (on paying-prospect demand), territory tags (on demand).

---

## 10. Open decisions (need Maddox's call before/within build)

1. **Empty-chain behaviour on candidate acknowledgements (highest-volume class):** hold / auto-execute / safe-default? *Recommendation: safe-default — only option keeping the "Hudson by morning" pitch honest without auto-sending unreviewed content. Cost: per-firm holding-reply templates.*
2. **Who can flip a class to standing approval — per-recruiter or per-firm?** *Recommendation: firm-admin-only, per-firm, audited. A junior auto-sending client comms is exactly the §10.1 blast-radius risk.*
3. **Edit happens in the Teams card or deep-links into The Desk chat?** *Recommendation: deep-link — Adaptive Cards are clumsy for free-text editing.*
4. **Record-ownership vs org-chart precedence for record-bound actions:** *Recommendation: record ownership always wins; confirm against first split-desk prospect.*
5. **Split-desk both-sides-of-placement action — who approves?** *Recommendation: candidate-owner approves, account-manager CC'd. Test against first split-desk prospect's accountability model. Not a boutique problem.*
6. **Does the boutique founder WANT all function-bound approvals, or delegate some from day one?** *Confirm in Diagnostic; delegation = editing one `holder` row, not config.*
7. **Configurability of escalation chains/TTLs:** *Recommendation: ship opinionated defaults, hide config; expose only when a firm asks. Config is a v1.2 concern.*

---

## 11. What this does NOT change (guardrails)

- **LoRA-vs-RAG gate intact.** The Desk is base+RAG. No fine-tuning, no hardware spend until RAG is proven insufficient and the adapter beats base+RAG on the eval.
- **Per-tenant isolation intact.** Owner resolution, function-roles map, scoping — all per-tenant. No cross-tenant data.
- **Minimal-PII on the HITL surface intact.** Summary + opaque token only on any transport; full regulated content stays in IFOS.
- **Notification-adapter boundary intact.** Production never imports the transport.
- **Sales gates intact.** This is a spec, not a build authorisation. Build gated behind the same paying-client milestones as everything else.

---

*End of specification.*
