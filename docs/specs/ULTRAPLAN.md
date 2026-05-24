# Intel Force OS — The Ultraplan

**Document type:** Master build plan. The technical, operational, and sequencing plan for delivering the recruitment product specified in `intelforce-os-recruitment-final-product-spec.md`.
**Audience:** Maddox first. Future co-founder / Hire #1 second. The senior engineer who reads this in week six and needs to know what to do without asking.
**Date:** 14 May 2026
**Status:** Authoritative build plan. Supersedes any informal build sequencing in prior documents. Where this contradicts an earlier doc on *how to build*, this wins. The product spec wins on *what to build*.
**Source documents this synthesises:** the final product spec; the CortexOS 24/7 directive; the temp deep dive; the internal business plan; the workflow analysis; the Phase 2 pattern reference; the hook-helpers reference implementation; the four Q&A answers provided by Maddox (Q2, Q4, Q5, Q8).
**Length:** Long. Read end-to-end before any code is written. Cross-references rather than repetition where another doc owns the detail.

---

## 0. How to use this document

There are four ways into it.

**For Maddox (build directive):** Read §1 → §2 → §6 → §9 → §10 → §11. That's the spine. Everything else is reference depth.

**For the senior engineer landing on the team:** Read §1 → §3 → §4 → §5 → §6 → §7 → §8. Skip the sprint plan; it'll be stale within two weeks of you joining. The technical model in §3–§8 won't be.

**For the CS hire (Q3 2027):** Read §1 → §6 → §8 → §10. The product is the agents; CS is the gate model and the configuration story.

**For an investor or advisor:** Read §0 → §1 → §11 only. Anything more is depth they don't need.

---

## 1. The five rules that govern every decision below

These are non-negotiable. If anything in §3–§9 violates one of these, the rule wins and §3–§9 gets fixed.

**Rule 1 — Output before architecture.** Every agent ships with its output contract written first. The architecture is downstream. If you can't write the output contract as a screenshot description in one paragraph, the agent isn't ready to start.

**Rule 2 — Schema before code.** Anything that varies between customers lives in `vertical-schema.yaml`, `config.schema.json`, or the tenant vault. Never in agent prompts. Never in agent logic. A code review that finds a customer-specific string in code is rejected on that basis alone.

**Rule 3 — Reuse before build.** Every agent uses the shared `_shared/` modules (voice loader, decision log writer, validate primitives, escalation router). No agent writes its own logging, its own voice handling, its own approval gate. If a shared module is missing, build the module first, then the agent.

**Rule 4 — Quality gates before features.** An agent that ships with a working Gate A and a measurement plan for Gate B/C is shippable. An agent that ships with extra features but a flaky Gate A is not. Every weekly review checks gates before features.

**Rule 5 — Honest signal before optimistic projection.** When something doesn't work, log it and re-plan. Do not paper over. The risk register in §10 is the truth-telling instrument; it gets updated weekly, by name, with no hedging.

---

## 2. The build philosophy in one paragraph

Intel Force OS is the recruitment product. CortexOS is the runtime. We build the product on top of the runtime without modifying it. Every agent is a bundle of six files in a canonical pattern. Every tenant is a process group, a vault directory, and a row in three Postgres tables. Voice is RAG-plus-scaffolding at v1, LoRA at Scale-tier v2. Quality is three gates that get measured weekly, not a slogan that gets put on the website. Onboarding is a five-day wizard, not a five-week project. The build is sequenced for "close the first three pilots fastest" — Maddox's stated default in Q3 — which means the Janitor and Cash Conductor close demos before the Triage agent absorbs the development heat.

---

## 3. The CortexOS contract — exactly what we depend on

This section is the explicit boundary between what we consume and what we build. It is also the answer to "could a competitor reproduce this with off-the-shelf orchestration" — no, because of the four primitives in §3.2 that aren't off-the-shelf anywhere.

### 3.1 The seven primitives, with build assumptions

I do not have a status report on CortexOS readiness (this is Q1, deferred). The build plan assumes each primitive has the following minimum viable state by start of v1.0 Sprint 1. If reality is worse than this, the sprint plan in §9 slips and we say so honestly.

| # | Primitive | Minimum required state for v1.0 | What we do if it's not ready |
|---|---|---|---|
| 1 | **Persistent PTY via PM2** | Working for ≥1 agent in dev; documented config; auto-restart on crash | Ship the v1.0 agents as scheduled cron with a documented migration path. Loses the Triage closing demo but keeps the build moving. |
| 2 | **71-hour context rotation** | Working in principle; tested manually | Manual restart cadence acceptable for v1.0 pilots; flag as known limitation in pilot agreement. |
| 3 | **Inter-agent file bus** | Directory contract documented; one example handoff working end-to-end | This is the load-bearing one for Brief Decoder. If not ready, Brief Decoder slips to v1.2 and we close pilots without it. |
| 4 | **Approval gates with standing authorisations** | Telegram approval surface working; standing-auth config schema defined | If not ready, every auto-send becomes draft-only for v1.0. Hurts the Triage pitch but doesn't kill it. |
| 5 | **Telegram + iOS approval surface** | Telegram working; iOS deferred to v1.2 acceptable | Telegram-only is fine for v1.0. iOS in v1.2 is the marketing line, not a tech blocker. |
| 6 | **Overnight autoresearch** | Long-session capability documented; rate-limit handling tested | This is for the Night Sourcer in v1.1, not v1.0. Defer the question. |
| 7 | **Multi-agent orchestrator** | One supervisor pattern working with one orchestrated agent | This is for v1.1+. Defer. |

**Action:** in week 0 of the build (the seven-day pre-build window in §11), Maddox audits each of the seven primitives and writes a one-line status against each. The sprint plan in §9 gets re-cut against the actual answers, not these assumptions.

### 3.2 What CortexOS gives us that nothing else does

The structural moat against a competitor reproducing the suite with AWS Lambda + SQS + Step Functions:

- **The file bus.** Inter-agent handoff via shared filesystem directories. No queue, no API, no serialisation tax. Brief Decoder writes a parsed-brief file; Sourcing Scout's `FastChecker` polls it up at the configured cadence (default 1000ms `pollInterval`, configurable per agent); result lands in a sub-directory the Concierge is polling. Four-agent pipelines complete in 3-5 seconds end-to-end. Off-the-shelf Lambda + Step Functions add a 3-8 second cold-start tax per hop, which compounds; our poll-based bus has a fixed floor that does not compound.
- **The persistent PTY.** Agent process is *already running* with firm voice profile, ATS state, current pipeline, recent context pre-loaded. Sub-second to first useful action. Lambda cold starts are 3–8 seconds before the first token; Triage at that latency stops being magical.
- **Standing approval gates.** Consultant pre-approves classes of action ("auto-send for acknowledge-new-candidate"); novel cases escalate. This is the safety story that makes auto-send sellable at all.
- **The orchestrator template.** A supervisor agent that watches the others, escalates jams, balances load. Lambda + Step Functions can't reason about whether two agents are deadlocked or one agent is producing low-quality outputs and needs throttling.

### 3.3 What we build on top, not inside

CortexOS layer (we consume, never modify):
- PM2 process supervision
- File bus directory contract
- Telegram approval surface
- Approval gate state machine
- Context rotation scheduler
- Orchestrator template

Intel Force OS layer (we build and own):
- Vertical schema (`docs/verticals/recruitment/vertical-schema.yaml`)
- Agent bundles (the 18 `agent.md` + 5 supporting files each)
- MCP connectors (Bullhorn, Vincere, Voyager Infinity, Companies House, Microsoft Graph, Xero, Fathom, LinkedIn, AgentMail)
- The vault syncer and vault contract
- Entity graph service (Postgres + pgvector)
- Decision log service
- Per-tenant LoRA training pipeline (v2.0)
- Brain UI (Next.js, extends CortexOS dashboard)
- The onboarding wizard
- The Diagnostic agent (sales tool)

### 3.4 The contribution-upstream rule

If we need something CortexOS doesn't have, we contribute upstream rather than fork. The exception: anything that's recruitment-vertical-specific stays in our layer. The test: would another industry's product also benefit from this? If yes, upstream. If no, ours.

### 3.5 The dependency vector

The thing we are most at risk on with CortexOS is *operational maturity*, not capability. Pre-1.0 distributed runtimes on consumer-grade infrastructure have failure modes we won't discover until production. The mitigation:

- Every Tier 1 agent has a "degraded mode" fallback (drafts-only, no auto-send, scheduled retry) that runs if CortexOS state is unhealthy.
- The orchestrator runs a health check every 60 seconds; degraded state triggers Telegram alert to the on-call founder.
- We do not market 99.9% uptime. The honest number is 99.5%, and the customer agreement says so.

---

## 4. The Agent Bundle v2 pattern — the canonical file structure

This is the answer to Q2 ("fork, harden, rebrand"). The Phase 2 pattern is the structural foundation. Three changes from Phase 2 → IntelForce OS Agent Bundle v2.

### 4.1 The file structure

Every agent — front-office and temp — ships as exactly these files:

```
{agent-name}/
├── README.md                      # Human-facing 2-minute overview
├── agent.md                       # The agent definition: prompt, rules, output contract
├── config.schema.json             # Per-tenant configuration schema
├── tools.yaml                     # The MCP tools this agent can call
├── validate.sh                    # Output validation hook (Gate A)
├── context.sh                     # Context hydration (vault, brand, decision log)
└── tests/
    └── fixtures/
        ├── 01-primary/
        │   ├── input.json
        │   └── expected.md
        ├── 02-edge-case-{name}/
        │   ├── input.json
        │   └── expected.md
        └── 99-voice-drift-canary/
            ├── input.json
            └── expected.md
```

The 99-voice-drift-canary fixture is new in v2. Every agent has one — a fixture designed to expose voice drift over time. Run weekly in CI; output diffed against historical baselines.

### 4.2 The three changes from Phase 2 → v2

**Change 1 — Voice handling moves into a shared module.**

Phase 2 has each `context.sh` `cat` the voice profile inline. That works for nine agents; it's brittle at eighteen. v2 introduces `_shared/voice-loader.sh`:

```bash
# Sourced from every agent's context.sh
source /tenant/.claude/bin/_shared/voice-loader.sh

# Load tone rules YAML
hh_load_tone_rules

# Retrieve top-N similar samples from voice corpus
hh_load_voice_samples --n=3 --task-type="candidate-acknowledgement"

# Load last-5 consultant-edited drafts of this type
hh_load_recent_edits --n=5 --task-type="candidate-acknowledgement"
```

Every agent's `context.sh` becomes 30 lines instead of 200. The voice loader is the canonical surface; agents never read the voice corpus directly.

**Change 2 — Decision logging is enforced, not optional.**

Phase 2's `hook-helpers.sh` has `hh_log` available but agents use it inconsistently. v2 enforces three writes via wrapper functions:

```bash
hh_decision_trigger     # Called at start of agent run; logs the trigger
hh_decision_output      # Called when agent produces output; logs the artefact
hh_decision_action      # Called when human acts on output; logs the action
```

These are required. `validate.sh` checks that all three were called; missing calls = hard fail. This is what enables the per-tenant LoRA training pipeline later — without complete decision logs there is no SFT corpus.

**Change 3 — Escalation codes expand to recruitment-vertical vocabulary.**

Phase 2's `escalation-codes.md` is consulting-product vocabulary. v2 expands to recruitment:

- `ESC_VOICE_DRIFT` — voice classifier score below threshold after retries
- `ESC_BULLHORN_AUTH` — Bullhorn OAuth token expired or revoked
- `ESC_DUPLICATE_DETECTED` — Janitor found a high-confidence dedup candidate requiring human review
- `ESC_JSL_RED_FLAG` — Supply Chain Auditor detected a red-flag pattern requiring immediate consultant attention
- `ESC_BRIEF_AMBIGUITY` — Brief Decoder found ambiguities that prevent confident shortlisting
- `ESC_PII_LEAKAGE_RISK` — output references PII outside firm boundary
- `ESC_RATE_LIMIT_HIT` — upstream API (LinkedIn especially) rate limited
- `ESC_SCHEMA_VIOLATION` — agent produced output that violates the vertical schema (e.g., a "placement" with no candidate)

About 20–30 codes total. The full catalogue is built in week 0; new codes added only when a real production case demands one.

### 4.3 The test fixture discipline

Every agent must have at least three fixtures before it ships:

- `01-primary` — the happy path. The single example every demo runs against.
- `02-edge-case-*` — at least one. For Triage, this is "candidate withdrawal email". For Cash Conductor, "partial payment with wrong reference". For Watchtower, "AWR week 12 with intervening sickness break". The edge cases come from the workflow analysis document and the temp deep dive.
- `99-voice-drift-canary` — the structural canary.

Fixtures run in CI on every commit. Pass rate < 100% blocks merge.

### 4.4 The migration discipline

We do not back-port v2 to Phase 2 consulting agents. They stay on v1 of the pattern because we are not maintaining them for recruitment. Every new agent ships against v2. The migration doc is a 1-page artefact for the engineer that says "here is what changed; here is the helper function you call instead of inlining".

---

## 5. The tenancy architecture — physical layout, isolation, and scaling boundary

This is the answer to Q5 ("shared Postgres + per-tenant vault + per-tenant PM2 process group at v1.0; per-tenant Docker at v1.1; dedicated cluster slice at Sovereign v2.0"). Restated as a build specification.

### 5.1 The three logical components per tenant

**Component 1 — The vault.**

- Filesystem path: `/vault/{tenant-slug}/` on a shared encrypted volume (LUKS at-rest encryption).
- Owned by OS user `ifos-tenant-{tenant-slug}` (group `ifos-tenants`).
- POSIX permissions `0700` on the tenant root; `0644` for files within.
- Inside: `_voice/`, `_playbooks/`, `_decisions/`, `candidates/`, `clients/`, `opportunities/`, `temp/` (if Temp tier active), `_config.yaml`.
- The agent process for tenant X runs as `ifos-tenant-{X}` and *cannot* read tenant Y's vault because the kernel stops it. POSIX permissions are the isolation boundary at v1.0.
- Encryption at rest via LUKS on the volume; keys held in the host's TPM, rotated quarterly.

**Component 2 — The structured data.**

- Shared Postgres 16 instance on Hetzner UK VPS.
- Three relevant tables: `tenants`, `entity_graph`, `decision_log`.
- Both `entity_graph` and `decision_log` partitioned by `tenant_id` (hash partitioning, 32 partitions to start).
- **Row-Level Security (RLS) policies enforce isolation.** Each tenant has a Postgres role `ifos_tenant_{slug}`; the role can SELECT/UPDATE only rows where `tenant_id` matches its mapped tenant. Application code does not filter by tenant; the database enforces it.
- pgvector extension installed for the voice corpus embeddings (per-tenant, partitioned the same way).
- TLS in transit, mTLS between CortexOS and Postgres.
- Per-tenant connection pooling via PgBouncer with prepared statements pinned to the tenant's role at session start.

**Component 3 — The agent processes (CortexOS / PM2).**

- One PM2 process group per tenant, named `ifos-{tenant-slug}`.
- Process group runs as the tenant's OS user.
- Process group includes one process per always-on agent the tenant has subscribed to.
- Scheduled agents (Janitor, Reporting, Spec Pitcher) run as cron jobs *also* under the tenant's OS user.
- Each process holds a Postgres connection authenticated as the tenant's RLS role.
- The CortexOS orchestrator runs as a separate process group (`ifos-orchestrator`) that has read-only visibility into all tenant process groups for health-monitoring; it does NOT have data-access to tenant vaults or Postgres rows.

### 5.2 Why this for v1.0 and not Docker-per-tenant

- Shared Postgres instance: at 6–15 tenants in Q4 2026, running 15 separate Postgres instances is operationally suicidal at our headcount. RLS gives us audit-grade isolation without the operational cost.
- Per-tenant OS users: kernel-enforced. We don't have time to audit every line of application code for tenant-filter correctness at this stage. POSIX permissions are the belt; RLS is the braces.
- PM2 process-group-per-tenant: gives us the CortexOS persistent PTY primitive per tenant, which is what the always-on agents need.

### 5.3 The Docker upgrade at v1.1

At approximately tenant #10, the noisy-neighbour risk on the shared kernel becomes real. One tenant's runaway loop can starve another's agents of CPU. Docker per tenant gives us cgroup-enforced CPU/memory limits.

The migration is non-disruptive: each tenant's PM2 process group gets wrapped in a Docker container with the same vault mount, same Postgres connection, same OS user. The agent code does not change. Customer-facing change: zero.

### 5.4 The Sovereign tier (v2.0)

Per the sovereign compute plan. Sovereign-tier tenants run on a dedicated slice of the Mac Studio cluster, with inference routed exclusively to local hardware. Their vault may be mirrored to local NVMe on the cluster nodes rather than the shared Hetzner volume. This is a deployment configuration, not a code path — same agent bundles, different physical placement.

### 5.5 Tenant lifecycle operations

**Provisioning** (Day 1 of the wizard):
1. Generate tenant slug, write `tenants` row, create RLS role, create OS user.
2. Run `provision-tenant.sh {slug}` — creates `/vault/{slug}/` with skeleton, mounts in `/tenant/.claude/bin/` shared helpers, creates `.claude/tenant-config.json` placeholder.
3. Run `pm2-ecosystem-generate.sh {slug}` — writes `ecosystem.{slug}.config.js` for PM2.
4. Run a single dry-run agent invocation (the Diagnostic) to validate the path end-to-end.

**Tier change** (e.g., Boutique → Growth):
1. Update `tenants.tier` column.
2. Run `pm2-ecosystem-generate.sh {slug}` again — adds the new tier's agents to the process group.
3. `pm2 reload ecosystem.{slug}.config.js` — zero-downtime restart.

**Offboarding**:
1. Day 0 of cancellation: `pm2 stop ifos-{slug}` — agents stop running. Vault remains.
2. Day 30: soft-delete — vault tarball'd to cold storage, tagged with retention policy; Postgres rows soft-deleted (RLS continues to hide them).
3. Day 60: hard-delete — vault tarball cryptographically erased, Postgres rows physically deleted, OS user removed, attestation document written and emailed to the (ex-)customer.

This is all in the customer contract.

### 5.6 The backup model

- Vault: nightly snapshot via Restic to S3-compatible storage (UK region) with 30 days of dailies, 12 months of monthlies.
- Postgres: continuous WAL streaming to the same S3 region. PITR (point-in-time recovery) available to any second in the last 30 days.
- RPO: 5 minutes. RTO: 4 hours. These are documented in the customer contract and tested quarterly.

### 5.7 The cost of doing all this

Tenancy plumbing for v1.0:
- Postgres setup with RLS: 1.5 days
- Vault provisioning scripts: 1 day
- PM2 ecosystem generation: 0.5 days
- Tenant lifecycle scripts: 1 day
- Backup setup with Restic: 1 day
- Documentation and runbooks: 1 day
- Initial pen test / boundary verification: 1 day

**Total: 7 engineering days.** This is week 2 of the v1.0 build, after the Agent Bundle v2 refactor in week 1.

---

## 6. The voice delivery system — how we technically deliver "in your voice" at 10/10

This is the answer to Q8, restated as a build specification. Voice is the single most important thing to get right. If voice fails, the product is a £49/month ChatGPT wrapper, not a £6,950/month operator.

### 6.1 The four layers

**Layer 1 — The voice corpus (data).**

Captured at onboarding (wizard Day 3) and extended continuously thereafter.

Initial capture:
- 20+ sample emails pasted into the wizard from the firm's top performer (founder or named senior consultant).
- AI-guided extraction produces:
  - `tone-rules.yaml` — structured rules (banned phrases, opening patterns, closing patterns, length norms, capitalisation rules, British vs US English, formality markers)
  - `samples/{n}.md` — raw samples indexed for RAG retrieval (embedded with pgvector at capture time)

Continuous extension:
- Every consultant-edited draft is captured: agent's original draft + consultant's edit + the diff metadata.
- Appended to the voice corpus weekly, with the edit's "lesson" extracted ("consultant shortened the opening", "consultant replaced 'I hope this finds you well' with nothing").
- The growing corpus is the SFT seed for the Scale-tier LoRA adapter at v2.0.

**Layer 2 — Runtime voice application (prompt assembly).**

Every agent's `context.sh` calls `_shared/voice-loader.sh`, which:

1. Loads `tone-rules.yaml` and injects it as structured constraints in the system prompt:
   ```
   You are writing in the voice of {firm name}. Hard rules:
   - Never use these phrases: {banned list}
   - Opening: {pattern}
   - Closing: {pattern}
   - Length: {min}–{max} words
   - Spelling: {British|US}
   - Formality marker: {casual|formal|mixed}
   ```

2. Retrieves the 3 most semantically similar past samples to the current task via pgvector cosine similarity. Injects them as in-context examples.

3. Loads the 5 most recent consultant-edited drafts of this task type, showing both the original draft AND the edit, so the model learns the editing pattern in-context.

The total prompt overhead is ~2,500 tokens. Acceptable given context windows now exceed 200k.

**Layer 3 — Validation (validate.sh).**

Before any draft leaves the agent:

- **Banned-phrase check** — exact-match grep against `tone-rules.yaml`'s banned list. Hard fail if any present. Cost: <50ms.
- **Length bounds check** — word count against `tone-rules.yaml`'s min/max. Hard fail if outside. Cost: <10ms.
- **Voice classifier score** — a small Sentence-BERT classifier trained on the tenant's voice corpus. Outputs a similarity score 0.0–1.0. Soft fail if < 0.75 (retry), hard fail if < 0.6 (escalate). Cost: ~200ms.
- **Schema check** — does the draft have the required structural elements (greeting, body, closing, signature)? Defined per task type in the tone-rules. Hard fail if missing. Cost: <50ms.
- **PII boundary check** — does the draft reference any PII outside the firm boundary (e.g., another tenant's candidate's name)? Hard fail. Cost: <100ms.

Total Gate A latency: <500ms. Acceptable.

If any hard fail, the agent regenerates with the failure reason injected as additional context ("your previous draft used the banned phrase 'I hope this finds you well'; rewrite avoiding it"). After 3 retries with hard fails, escalate with `ESC_VOICE_DRIFT` or `ESC_SCHEMA_VIOLATION`.

**Layer 4 — The Scale-tier LoRA upgrade (v2.0).**

Once a tenant has 6+ months of decision logs, they qualify for the per-firm LoRA adapter. The pipeline:

1. Extract SFT pairs from the decision log: (agent prompt + context, consultant-edited final output) for every approved or edited draft.
2. Train a LoRA adapter (rank 8–16) on a base model — Qwen3 70B for the cluster, or Claude/Anthropic API with similar fine-tuning if cloud-tier.
3. Eval the adapter against held-out drafts using the voice classifier — promote only if the adapter beats the RAG baseline by ≥5 percentage points on the voice score *and* doesn't regress on compliance or factual checks.
4. Serve the adapter from the cluster at inference time; agents transparently use it.

The LoRA improves voice score from ~80% (RAG + scaffolding) to ~90%+. This is what justifies the Scale tier at £6,950/mo.

The training pipeline itself is the v2.0 work; the data capture starts at v1.0 with the decision log writes from §4.2.

### 6.2 The voice drift alerting

Weekly cron job per tenant:
1. Sample 20 drafts the agent produced that week.
2. Run the voice classifier on each.
3. Compute the average score and the 4-week rolling trend.

If the rolling 4-week average drops by ≥5 percentage points: `ESC_VOICE_DRIFT_TENANT` fires. Email goes to the customer's primary contact AND to the internal CS Slack:

> "Your voice quality score has dropped from 0.83 to 0.76 over the last 4 weeks. This usually means new edit patterns we haven't absorbed. Can we book 30 minutes to review samples?"

We never silently accept voice drift. The structural commitment is that voice quality is measurable, measured, and surfaced.

### 6.3 The sales-floor demo of voice quality

This is the commercial corollary. On the sales call, the salesperson can:

1. Take a sample email from the prospect (paste 5 of their own emails into a demo wizard).
2. Run the demo Triage agent on a synthetic inbound.
3. Show the voice classifier score live on the screen: "0.84. Here's the draft."

Generic ChatGPT scores 0.4–0.5 on the same test. That delta is the close.

This demo capability is part of the v1.0 sales toolkit. ~3 days of engineering, built once.

---

## 7. The quality gate model — what 10/10 means in code, not slogans

This is the answer to Q4. Three gates, three time horizons, three measurement instruments.

### 7.1 Gate A — Output gate (per single run, automated, binary)

Already specified in §4 and §6. Every agent's `validate.sh` enforces Gate A. Pass = output ships. Fail = output quarantined, retry up to 3 times, then escalate.

Gate A measurements stored in `gate_a_results` Postgres table:
- `tenant_id`, `agent`, `run_id`, `timestamp`
- `validator_name`, `passed`, `reason_if_failed`
- `regeneration_attempt_count`

Dashboard query: per-agent Gate A pass rate, weekly trend.

### 7.2 Gate B — Outcome gate (per 100 runs in a real tenant, statistical, monthly)

Each agent has its outcome targets pinned. Restated from §3 of the product spec, with monthly measurement protocols.

| Agent | Gate B target | Measurement protocol |
|---|---|---|
| Inbound Triage | 95% of inbounds get response within 60s; consultant-edit rate <30% on auto-sent categories | Decision-log query over 30 days, per tenant |
| Cash Conductor | Tenant's DSO at month-3 ≥ 12 days lower than month-0 baseline | DSO computed from accounting MCP every month; baseline captured at onboarding |
| Client Hunter | ≥ 20 BD opportunities/month produced with ≥ 30% receiving consultant action | Decision-log query; action defined as "approved-and-sent" |
| Night Sourcer | ≥ 6 of 10 candidates per brief advance past first consultant review | Decision-log + ATS state query |
| Concierge | <5% candidate-ghosted rate (drafts produced for every lifecycle event) | Lifecycle-event audit against decision log monthly |
| Pulse | ≥1 churning-client signal caught >4 weeks before customer-confirmed loss event | Manually verified; tenant-confirmed monthly |
| Janitor | 30-day before/after report shows ≥15% dedup, ≥10% field-completeness improvement | The day-30 report IS the Gate B measurement |
| Brief Decoder | Brief-to-first-shortlist time <90 minutes for ≥ 80% of inbound briefs | Decision-log timestamps |
| T5 Supply Chain Auditor | Zero JSL incidents with red-flag patterns missed; quarterly audit pack delivered on time | Internal review + customer attestation |
| T3 Compliance Watchtower | Zero compliance deadlines missed in the tenant; <2 false-positive alerts per tenant per month | Decision-log + tenant feedback |

Gate B failures in month 3: the agent goes into tuning mode. The engineer pairs with the tenant for 2 weeks. Re-measure at month 4. If still failing, escalate to product review — is this config, schema, or genuine product weakness?

### 7.3 Gate C — Human acceptance gate (per draft, qualitative, customer-self-reported)

The Brain UI captures three buttons on every draft:
- **Send as-is** — the highest signal
- **Edit then send** — captures the diff for the voice corpus
- **Reject** — captures the "why" in a free-text field

Targets at month 3 in a tenant:
- Send as-is rate ≥ 60% on auto-send-eligible drafts
- Edit-then-send rate ≤ 35%
- Reject rate ≤ 5%

If reject rate > 10% for two consecutive weeks → agent paused for that tenant, engineer engagement triggered.

### 7.4 The public-internal scorecard

Every agent has a scorecard refreshed weekly, visible on the team dashboard, with three numbers:
- Gate A pass rate (target: 100%; alert at <99%)
- Gate B trend (target: monotone-improving; alert at any monthly regression)
- Gate C send-as-is rate (target: ≥60%; alert at <50%)

Any agent below 8/10 across all three has its feature development frozen. No new functionality on an underperforming agent. Only bug fixes and Gate restoration work.

### 7.5 Who sets the bars

- v1.0 (the first three pilots): Maddox sets bars calibrated to "good enough to keep paying", slightly more generous than feels comfortable.
- v1.1 onwards: quarterly bar review with two pilot customers in the room. They set the next quarter's bars based on what they actually experienced.

This is how 10/10 becomes culturally real, not a marketing claim.

---

## 8. The 18-agent technical specs

This is the heart of the document. For each agent, this section specifies the build: which CortexOS primitives are required, which MCP tools, which shared modules, which gotchas, and how much it costs to build.

The agents are ordered by build wave (v1.0 → v1.1 → v1.2 → v2.0), not by revenue priority.

The spec for each agent is consistent:

```
Agent name + tier
Build wave (v1.0 / v1.1 / v1.2 / v2.0)
Always-on? (Tier 1 / Tier 2)
Trigger type
CortexOS primitives required
MCP tools required
Shared modules required
External APIs / dependencies
Gate A specifics
Gate B target (restated from §7.2)
Build complexity (S / M / L / XL where S=2 days, M=1 week, L=2 weeks, XL=4 weeks)
Gotchas (the things that will bite us)
```

### 8.1 v1.0 agents (six)

#### A1. The Diagnostic — the sales tool

- **Build wave:** v1.0 (week 4–5)
- **Always-on?** No — invoked on demand
- **Trigger type:** Manual (run from CLI or sales-tool web page)
- **CortexOS primitives required:** None — runs as a one-shot batch job
- **MCP tools required:** Companies House, LinkedIn (read-only), web scraper for careers pages
- **Shared modules required:** Voice loader (uses Maddox's voice for the audit narrative), decision log writer
- **External APIs:** Companies House API (free), LinkedIn (via Proxycurl or similar), basic HTTP fetch
- **Gate A:** report contains all 12 required sections; each section has at least 1 evidence link; no claims unsupported by source data *(see `docs/decisions/ADR-006-diagnostic-gate-a-hybrid.md` — per-section citation subcheck is hard-fail at v0; per-claim quality signal is a separate post-launch metric outside Gate A; voice classifier + PII subchecks remain per current `validate.sh`)*
- **Gate B target:** ≥30% of diagnostics produced lead to a discovery call booked
- **Build complexity:** **M** (1 week)
- **Gotchas:** LinkedIn ToS — we cannot store profile data beyond the audit. Companies House rate limits — cache aggressively.

#### A2. The Janitor — the wedge agent

- **Build wave:** v1.0 (week 5–6)
- **Always-on?** Tier 2 — scheduled nightly cron
- **Trigger type:** Cron 02:00 UTC daily; manual full-cleanup on demand
- **CortexOS primitives required:** None (scheduled batch)
- **MCP tools required:** Bullhorn (read-write), Companies House (for entity enrichment)
- **Shared modules required:** Decision log writer, escalation router
- **External APIs:** Bullhorn REST API, Companies House
- **Gate A:** dedup confidence score ≥ 0.85 on every merge proposal; no merge proposed where candidate has had activity in last 90 days without explicit review flag
- **Gate B target:** day-30 before/after report shows ≥15% dedup, ≥10% field completeness improvement
- **Build complexity:** **L** (2 weeks) — the Bullhorn MCP work is the rate-limiting piece
- **Gotchas:** Bullhorn MCP server doesn't exist yet — this is the critical-path build for v1.0. Estimate 1 week for the MCP server, 1 week for the agent itself. Dedup is hard; start conservative (high-confidence merges only) and tune up.

#### A3. The Scribe — the data spine

- **Build wave:** v1.0 (week 6–7)
- **Always-on?** Tier 2 — webhook-driven
- **Trigger type:** Webhook from Fathom / Fireflies / Ringover when a call ends
- **CortexOS primitives required:** None per call (stateless between calls)
- **MCP tools required:** Bullhorn (write), Fathom (read), Fireflies (read)
- **Shared modules required:** Voice loader (for tone-detection of tacit notes), decision log writer
- **External APIs:** Fathom webhook, Fireflies webhook, Bullhorn for write-back
- **Gate A:** every transcript produces at least 3 structured-field extractions AND 1 tacit-note; tacit-notes have a confidence score ≥ 0.6
- **Gate B target:** 90% of calls processed within 5 minutes of webhook; consultant edit-rate on structured fields ≤ 20%
- **Build complexity:** **M** (1 week) — the structured field mapping is per-firm config, not code
- **Gotchas:** Tacit-note extraction is the hard part. Start with a small taxonomy (5–10 tacit-note types) and expand. Customers will provide examples of "things I'd write down but there's no field for" — that's the training data.

#### A4. Cash Conductor (real-time mode) — the FD's evenings back

- **Build wave:** v1.0 (week 7–8)
- **Always-on?** Tier 1 — persistent watcher on accounting + bank webhooks
- **Trigger type:** Webhook (payment received, invoice issued, invoice viewed) + cron sweep at 07:00 daily
- **CortexOS primitives required:** Persistent PTY (#1), Telegram approval surface (#5), standing authorisations (#4)
- **MCP tools required:** Xero / QuickBooks / Sage (one of, per tenant), bank-feed connector
- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate
- **External APIs:** Xero API or QuickBooks API or Sage API; bank feed via Open Banking (TrueLayer / Plaid UK)
- **Gate A:** chase email references correct invoice number AND correct amount AND correct contact; never proposes chase for an invoice that's been paid in last 24h
- **Gate B target:** tenant DSO at month-3 ≥ 12 days lower than month-0 baseline
- **Build complexity:** **L** (2 weeks) — three accounting integrations × Open Banking is the work
- **Gotchas:** Open Banking auth is a 90-day token; rotation logic is non-trivial. Bank feed reconciliation against invoice register is the hard logic; start with exact-amount matches and expand to fuzzy.

#### A5. Sourcing Scout (daytime form) — request-response sourcing

- **Build wave:** v1.0 (week 8–9)
- **Always-on?** Tier 2 — request-response
- **Trigger type:** Brain UI button, Telegram command, or webhook from a "new brief" event
- **CortexOS primitives required:** None for the daytime form (Night Sourcer in v1.1 will use #6)
- **MCP tools required:** Bullhorn (read for ATS passive matches), LinkedIn (via Proxycurl or similar), Reed.co.uk API, CV-Library API
- **Shared modules required:** Voice loader (for the rationale narrative), decision log writer
- **External APIs:** Proxycurl, Reed, CV-Library
- **Gate A:** 5–15 candidates returned per brief; each has a working contact method; each has rationale ≥ 50 words; no candidate flagged "do not contact" in tenant vault
- **Gate B target:** ≥6 of 10 candidates advance past first consultant review (shared target with Night Sourcer)
- **Build complexity:** **L** (2 weeks) — the multi-source aggregation logic is the work
- **Gotchas:** LinkedIn rate limits via Proxycurl. Reed/CV-Library have separate auth and separate result schemas. Build the source-abstraction layer carefully — Night Sourcer in v1.1 will reuse it.

#### A6. The Concierge — no candidate ghosted

- **Build wave:** v1.0 (week 9–10)
- **Always-on?** Tier 1 — persistent state across the candidate lifecycle
- **Trigger type:** ATS state changes (candidate moved to interview, rejected, placed, etc.) + cron sweep for time-elapsed nurture events
- **CortexOS primitives required:** Persistent PTY (#1), context rotation (#2), approval gates (#4), Telegram surface (#5)
- **MCP tools required:** Bullhorn (read for state, write for activity log), Microsoft Graph / Gmail (send), AgentMail (optional for agent-identity sends)
- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate
- **External APIs:** Microsoft Graph or Google Workspace per tenant; AgentMail for v1.1+
- **Gate A:** every lifecycle event has a draft generated within 30 minutes; voice classifier score ≥ 0.75; correct addressee resolution (no candidates emailed under another's name)
- **Gate B target:** <5% candidate-ghosted rate; ≥60% send-as-is rate on drafts
- **Build complexity:** **XL** (4 weeks) — this is the biggest v1.0 agent because of the lifecycle state machine and the breadth of comms types (acknowledgement, prep, debrief, rejection, placement, check-ins ×6)
- **Gotchas:** Lifecycle event detection from Bullhorn is the unreliable bit — Bullhorn's webhook coverage is patchy and we'll need polling fallbacks. Voice quality on rejections is the hardest test case — get this wrong and it costs the tenant a candidate relationship.

### 8.2 v1.1 agents (seven, in build order)

#### A7. Inbound Triage (priority 1, 4 weeks)

- **Build wave:** v1.1 (Q4 2026 weeks 1–4)
- **Always-on?** Tier 1 — the highest 24/7 agent
- **Trigger type:** Inbound email webhook (Microsoft Graph subscription or AgentMail webhook), LinkedIn InMail webhook, website contact form webhook
- **CortexOS primitives required:** All except #6 — Persistent PTY (#1), context rotation (#2), file bus (#3, hands off to Concierge), approval gates (#4), Telegram (#5), orchestrator (#7)
- **MCP tools required:** Microsoft Graph or Gmail (read + send), AgentMail (send, where agent-identity is needed), Bullhorn (read for candidate matching), LinkedIn (read)
- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate, escalation router
- **External APIs:** Microsoft Graph subscriptions, AgentMail
- **Gate A:** draft generated within 60s of webhook receipt; classification has confidence ≥ 0.8; no auto-send on uncategorised messages
- **Gate B target:** 95% within 60s; consultant edit-rate <30% on auto-sent categories; <2% wrong-classification rate
- **Build complexity:** **XL** (4 weeks)
- **Gotchas:** This is the most dangerous auto-send agent. Auto-send categories must be gated tightly (acknowledge-new-candidate only at v1.1 launch, expand after 30 days of clean data). Misclassification of a complaint as a routine inbound is a relationship killer. The deliverability test for AgentMail vs Microsoft Graph is the rate-limiting research.

#### A8. The Brief Decoder (priority 2, 2 weeks)

- **Build wave:** v1.1 (weeks 5–6)
- **Always-on?** Tier 1
- **Trigger type:** Inbound brief detected by Triage; file-bus handoff
- **CortexOS primitives required:** File bus (#3), persistent PTY (#1), orchestrator (#7), Telegram (#5)
- **MCP tools required:** Bullhorn (read for prior placements + candidates), shared with Sourcing Scout
- **Shared modules required:** Voice loader, decision log writer, the Brief Decoder→Sourcing Scout→Concierge orchestration template
- **External APIs:** Same as Sourcing Scout (reuses)
- **Gate A:** every brief produces 3 ambiguity flags OR an "unambiguous" signal; pre-shortlist contains 3–10 candidates; intake-call agenda has 5–8 items
- **Gate B target:** brief-to-first-shortlist <90 minutes for ≥80% of inbound briefs
- **Build complexity:** **M** (2 weeks)
- **Gotchas:** Brief format varies hugely between clients. Build the parser as schema-driven, not pattern-matching. The orchestration handoff to Sourcing Scout is the load-bearing CortexOS test.

#### A9. Real-time Cash Conductor reframe (2 weeks)

Already specified in §8.1 A4 as v1.0. The v1.1 work is the reframe of pitch and any latency optimisations needed once we have 3+ tenants in production. Not a new build, ~3 days of polish.

#### A10. Competitor Interception (2 weeks)

- **Build wave:** v1.1 (weeks 7–8)
- **Always-on?** Tier 1
- **Trigger type:** Broadbean / job-board scraper detects a target-patch company posted via a competitor agency
- **CortexOS primitives required:** Persistent PTY (#1), Telegram (#5), file bus (#3)
- **MCP tools required:** Bullhorn (read for prior relationships + matching candidates), LinkedIn (read for contact identification)
- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate
- **External APIs:** Broadbean (no public API — scraping required), LinkedIn, Companies House
- **Gate A:** detection latency <5 min from competitor posting; outreach references the specific role title AND the competitor agency by name (the firm needs to know we're not making this up)
- **Gate B target:** ≥1 competitor interception per tenant per month converts to a meeting
- **Build complexity:** **M** (2 weeks)
- **Gotchas:** Broadbean scraping is the rate-limiting work. We may need to invest in a small headless-browser scraper layer with rotation; this is fragile by nature. Plan for a 2-week refactor in v1.2 once we see how often it breaks.

#### A11. The Night Sourcer (2 weeks)

- **Build wave:** v1.1 (weeks 9–10)
- **Always-on?** Tier 1 — overnight autoresearch is the canonical use case
- **Trigger type:** Cron 22:00 weeknights per tenant
- **CortexOS primitives required:** Overnight autoresearch (#6), file bus (#3), context rotation (#2), orchestrator (#7)
- **MCP tools required:** Bullhorn, LinkedIn, Reed, CV-Library, GitHub (for tech briefs), Sector-specific (configurable per tenant)
- **Shared modules required:** Voice loader, decision log writer, the source-abstraction layer from Sourcing Scout
- **External APIs:** Same as Sourcing Scout + GitHub
- **Gate A:** 8–12 candidates per brief; each has rationale ≥ 50 words; drafts for each are valid (Gate A on the draft itself); no rate-limit exceptions raised
- **Gate B target:** ≥6 of 10 candidates advance past first consultant review (shared with Sourcing Scout)
- **Build complexity:** **M** (2 weeks) — reuses Sourcing Scout's source layer; the new work is the overnight scheduling + rate-limit budget allocation
- **Gotchas:** LinkedIn rate limits are the single most fragile dependency in the platform. Build the rate-limit budget allocator carefully; this is where £40–60/mo of the £200 per-tenant compute cost lives.

#### A12. T5 Supply Chain Auditor (parallel to v1.1 front-office work)

- **Build wave:** v1.1 (parallel; weeks 1–8)
- **Always-on?** Tier 1
- **Trigger type:** Continuous (daily sweep) + event-driven on umbrella changes
- **CortexOS primitives required:** Persistent PTY (#1), context rotation (#2), Telegram (#5), orchestrator (#7)
- **MCP tools required:** Companies House (umbrella entity monitoring), HMRC (RTI spot-check via PAYE Employer queries), umbrella-provider APIs (Parasol, Brookson, Giant — top UK umbrellas)
- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate, escalation router
- **External APIs:** Companies House, HMRC (RTI submissions visibility — this is the hard one; access may require Government Gateway credentials at the tenant level), umbrella-provider APIs (which often don't exist publicly — fallback to manual data ingestion)
- **Gate A:** every red-flag pattern (e.g., FCSA accreditation lapsed, complaint volume spike, director change) produces an alert within 24 hours; quarterly audit pack contains all required sections
- **Gate B target:** zero JSL-incident-eligible patterns missed (verified retrospectively)
- **Build complexity:** **XL** (8 weeks across the v1.1 window — this is the most regulatory-heavy agent)
- **Gotchas:** HMRC RTI visibility is the biggest unknown. We may need to build this around tenant-provided HMRC credentials rather than direct API access. Umbrella-provider APIs are inconsistent or absent; budget for a manual-data-ingestion fallback. This is the highest-priced SKU in the portfolio — quality has to be unimpeachable.

#### A13. T3 Compliance Watchtower (parallel to v1.1 front-office work)

- **Build wave:** v1.1 (parallel; weeks 4–10)
- **Always-on?** Tier 1
- **Trigger type:** Continuous state-machine; daily sweep + event-driven on contractor events
- **CortexOS primitives required:** All of #1, #2, #3, #5, #7 — this is the agent with the most stateful watchers
- **MCP tools required:** Bullhorn (contractor data), Voyager Infinity / 3R (where used), Companies House
- **Shared modules required:** Voice loader, decision log writer, Telegram approval gate
- **External APIs:** Same as Bullhorn + Voyager
- **Gate A:** every active contractor has a live state with AWR week counter, RTW expiry, contract end, holiday pay year-to-date; deadline-imminent alerts fire ≥7 days ahead
- **Gate B target:** zero compliance deadlines missed in the tenant; <2 false-positive alerts per tenant per month
- **Build complexity:** **L** (6 weeks parallel)
- **Gotchas:** AWR edge cases (sickness breaks, maternity, jury service, anti-avoidance patterns) are the long tail. We will not get this right in v1.1; expect 6 months of edge-case tuning post-launch.

### 8.3 v1.2 agents (five)

Short specs only — these are downstream of v1.0+v1.1 and will benefit from the production lessons.

| Agent | Build complexity | Key dependencies | Notes |
|---|---|---|---|
| Real-Time Pulse | L (2 weeks) | Microsoft Graph subscriptions + LinkedIn + Companies House watchers | The signal-weighting per tenant is the per-customer config work |
| Spec Pitcher | M (1 week) | Reuses Client Hunter + Concierge primitives | Bundles, never sold standalone |
| Recruitment Reporting | M (1 week) | Bullhorn + accounting + decision log | Mostly a SQL + templating job |
| T1 Onboarding Concierge | M (1 week) | Bullhorn (write), DocuSign, Microsoft Graph | Tracks onboarding tasks; less reasoning-heavy |
| T2 Sunday-Evening Timesheet Ranger | M (1 week) | Bullhorn/Voyager + Microsoft Graph | The voice quality on per-contractor history is the work |

### 8.4 v2.0 agents (three) + the LoRA pipeline

| Agent | Build complexity | Notes |
|---|---|---|
| T4 IR35 Coordinator | L (2 weeks) | SDS parsing + CEST adequacy scoring |
| T6 Pay & Bill Reconciler | L (2 weeks) | The three-way recon is the work |
| Per-firm LoRA pipeline | XL (8+ weeks) | The training, eval, and serving infrastructure |

### 8.5 The complete tools-and-skills matrix

| Agent | Voice | Bullhorn | MSGraph | Xero/Sage | LinkedIn | CoHouse | Reed/CVLib | Fathom | AgentMail | Telegram | Special |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Diagnostic | ✓ | | | | ✓ | ✓ | | | | | Web scraper |
| Janitor | | ✓ | | | | ✓ | | | | | |
| Scribe | ✓ | ✓ | | | | | | ✓ | | | |
| Cash Conductor | ✓ | | | ✓ | | | | | | ✓ | Open Banking |
| Sourcing Scout | ✓ | ✓ | | | ✓ | | ✓ | | | ✓ | |
| Concierge | ✓ | ✓ | ✓ | | | | | | ✓ | ✓ | |
| Inbound Triage | ✓ | ✓ | ✓ | | ✓ | | | | ✓ | ✓ | |
| Brief Decoder | ✓ | ✓ | | | | | | | | ✓ | |
| Competitor Interception | ✓ | ✓ | | | ✓ | ✓ | | | | ✓ | Broadbean scraper |
| Night Sourcer | ✓ | ✓ | | | ✓ | | ✓ | | | ✓ | GitHub |
| T5 Supply Chain Auditor | ✓ | | | | | ✓ | | | | ✓ | HMRC, Umbrella |
| T3 Compliance Watchtower | ✓ | ✓ | | | | ✓ | | | | ✓ | Voyager/3R |
| Real-Time Pulse | ✓ | ✓ | ✓ | | ✓ | ✓ | | | | ✓ | |
| Spec Pitcher | ✓ | ✓ | ✓ | | ✓ | | | | | ✓ | |
| Reporting | | ✓ | | ✓ | | | | | | | |
| T1 Onb. Concierge | ✓ | ✓ | ✓ | | | ✓ | | | | ✓ | DocuSign |
| T2 Timesheet Ranger | ✓ | ✓ | ✓ | | | | | | | ✓ | Voyager/3R |
| T4 IR35 | ✓ | ✓ | ✓ | | | | | | | ✓ | CEST/HMRC |
| T6 Pay & Bill | | ✓ | | ✓ | | | | | | ✓ | Voyager/3R |

This matrix tells us the MCP-server build priority:

1. **Bullhorn** — 18 of 18 agents need it (or compatible ATS). Top priority.
2. **Voice loader / vault helpers** — 16 of 18. Build in week 1.
3. **Telegram** — 16 of 18. Comes free with CortexOS if primitive #5 works.
4. **Microsoft Graph** — 8 of 18. Second-priority MCP work.
5. **Companies House** — 6 of 18. Free API, easy build.
6. **LinkedIn (via Proxycurl)** — 6 of 18. Third-priority.
7. **Xero / QuickBooks / Sage** — 4 of 18 (one per tenant typically). Cash Conductor's blocker.

---

## 9. The 14-week v1.0 sprint plan

Targets: 3 paid pilots by end of Q3 2026 (per the internal business plan). v1.0 = the six v1.0 agents shippable in the Starter and Boutique tiers; Growth/Scale defer to v1.1.

**Assumptions baked in:**
- Maddox solo for weeks 0–6; Hire #1 starts week 7 (per the most plausible reading of the user's memory, with caveat in §10).
- CortexOS primitives 1, 4, 5 are working by week 0; 2, 3, 6, 7 land during the build window.
- Bullhorn MCP server is the critical path; week 1 starts on it.
- The first pilot lands at week 10 (mid-July 2026) for a 2-week pilot, converting to paid week 12.

### Week 0 — Pre-build clearance (the seven-day window from §11)

| Day | Activity |
|---|---|
| Mon | CortexOS primitive audit; one-line status per primitive |
| Tue | Decision on Bullhorn integration path (marketplace vs direct); design partner conversation 1 |
| Wed | Phase 2 pattern refactor scoping (the three v2 changes) |
| Thu | Postgres + Hetzner UK + LUKS volume setup |
| Fri | First MCP server scoped (Bullhorn); contract review with first design partner |

End-of-week-0 deliverables:
- One-line status per CortexOS primitive
- Signed letter-of-intent (LOI) from at least one pilot, even if non-binding
- Bullhorn integration path decided and documented
- Hetzner UK VPS provisioned with Postgres + LUKS volume

### Weeks 1–2 — Foundation

- Week 1: Agent Bundle v2 pattern refactor; `_shared/` module build; voice loader; escalation codes catalogue; vertical schema v0.1
- Week 2: Tenancy plumbing (Postgres RLS, tenant provisioning scripts, PM2 ecosystem generator); backup setup; first dry-run tenant provisioned end-to-end

Milestone: a tenant can be provisioned in <30 minutes by a script.

### Weeks 3–4 — Bullhorn + Diagnostic

- Week 3: Bullhorn MCP server build (auth, read endpoints, write endpoints, webhook subscription)
- Week 4: Diagnostic agent built end-to-end; first diagnostic run against a real prospect's footprint

Milestone: Diagnostic produces a 12-page audit on a real firm; sales motion has its first artefact.

### Weeks 5–6 — Janitor + Scribe

- Week 5: Janitor agent; day-30 before/after report template; CI fixtures
- Week 6: Scribe agent; Fathom + Fireflies MCP; tacit-note taxonomy v0.1

Milestone: Janitor produces an audit report against a real Bullhorn (the first pilot's, ideally). Scribe processes 10 real calls.

### Weeks 7–8 — Cash Conductor + Hire #1 onboards

- Week 7: Hire #1 onboards (assumed); Xero MCP + Open Banking integration
- Week 8: Cash Conductor agent; chase-cadence config; tenant-level baseline DSO captured

Milestone: Cash Conductor running in shadow mode against first pilot's accounting data.

### Weeks 9–10 — Sourcing Scout + Concierge start

- Week 9: Sourcing Scout (daytime); LinkedIn + Reed + CV-Library integration
- Week 10: Concierge build starts (4-week build); first pilot landed for shadow-mode trial

Milestone: First pilot signed; agents running in shadow mode (drafts to a separate inbox, no auto-send).

### Weeks 11–14 — Concierge completion + first pilot conversion

- Weeks 11–13: Concierge build continues; Brain UI minimal v1 (the "what did the agents do today" view); auto-send graduation for Triage-eligible categories (initially Concierge-only candidate-acknowledgement)
- Week 14: First pilot converts to paid; pilots 2 and 3 sales conversations active

Milestone: One paying tenant at end of Q3 2026; two more in advanced sales.

### Sprint review cadence

- Daily standup: 15 min, async via Slack (if solo, written; if 2-person, video Mon/Wed/Fri)
- Weekly review: Friday afternoon. Three questions: what shipped, what's stuck, what changed in the plan
- Bi-weekly tenant check-in: with whichever pilot is most active
- Monthly strategic review: re-cut sprint plan based on tenant signals

### What slips first if it slips

In priority order of what we cut to hit the date:

1. Edge-case test fixtures beyond the minimum 3 per agent
2. Brain UI polish (we use Telegram + email as the surface)
3. Sovereign-tier setup (deferred to v2.0 regardless)
4. Janitor's Workflow F (the day-30 before/after report) — can be manually compiled for the first tenant
5. Cash Conductor's escalation-tier-3 (bad debt write-off draft) — manual until 6 months in
6. Concierge's deep nurture sequence (months 12 and 24 check-ins) — can be added in v1.1

What we never cut:
- Agent Bundle v2 pattern compliance (Rule 3)
- Decision log writes (Rule 4 — required for the LoRA pipeline later)
- Voice classifier and Gate A enforcement (Rule 4)
- Tenant isolation (Rule 1, §5)

---

## 10. The risk register

Ordered by probability × impact. Updated weekly during the build. The "Tripwire" column is the leading indicator we watch.

| # | Risk | Probability | Impact | Tripwire | Mitigation |
|---|---|---|---|---|---|
| 1 | CortexOS primitives 3 or 4 are flaky in production | High | High | Daily orchestrator health check flags >1 incident/week | Degraded-mode fallbacks per agent (§3.5); the file bus contract is documented and we can manually trigger handoffs if needed |
| 2 | Bullhorn MCP build takes longer than 1 week | High | High | End of week 3 status not "core read endpoints working" | Pre-emptive: spend week 0 on Bullhorn auth research. Contingency: defer Janitor and Scribe to weeks 7–8, push Concierge to v1.1 |
| 3 | First design partner not signed by end of week 0 | Medium | High | Week 0 ends without LOI | Sales conversations start before week 0; do NOT begin code until first LOI lands |
| 4 | Hire #1 doesn't start until Q4 2026 | Medium | High | No offer accepted by end of week 4 | v1.0 scope cut from 6 agents to 4 (drop Concierge + Sourcing Scout to v1.1); Maddox solo through end of v1.0 |
| 5 | Open Banking integration takes more than 1 week | Medium | Medium | End of week 7 status not "Xero + first bank connected" | Cash Conductor ships with manual reconciliation in v1.0; webhook-driven mode at v1.1 |
| 6 | LinkedIn rate limits via Proxycurl are tighter than expected | Medium | Medium | Sourcing Scout cost >£100/run | Negotiate Proxycurl enterprise plan; defer Night Sourcer to v1.2 if needed |
| 7 | Voice classifier underperforms (false positives blocking valid drafts) | Medium | Medium | First pilot reports >5% block rate on legitimate drafts | Soften the threshold from 0.75 → 0.65 for v1.0; tune up as corpus grows |
| 8 | First pilot's Bullhorn data is too messy for Janitor's dedup confidence threshold | Medium | Medium | <5% dedup proposed in week 6 trial run | Lower threshold to 0.7 for the initial cleanup; ship the day-30 report regardless |
| 9 | A consultant complains about auto-send tone within first 2 weeks | High | Low | Single rejection of an auto-sent draft | Auto-send paused immediately for that tenant; engineer pairs to add edit pattern to corpus |
| 10 | A CortexOS update breaks an agent mid-week | Low | High | Orchestrator health check fails | All updates staged on dev tenant first; production update Sundays 02:00–04:00 UK only |
| 11 | A GDPR breach via cross-tenant data leak | Very low | Catastrophic | RLS policy violation in logs | Quarterly tenant-isolation test (synthetic queries from one role attempting to read another tenant's data); the kernel + RLS belt-and-braces makes this unlikely |
| 12 | A pilot churns within 90 days | Medium | High | Gate B failure at month 2 OR Gate C reject rate >10% sustained 2 weeks | Engineer pairs with tenant; if not recoverable by month 3, churn-with-grace and capture learnings |
| 13 | The Bullhorn API rate limits prevent Janitor from completing its initial sweep on day 1 | Medium | Medium | First sweep takes >24 hours | Initial sweep runs in batches over 3 days; communicate to tenant explicitly |
| 14 | A regulatory change (a sixth JSL rule, an Acturis API change) invalidates a Temp agent's logic | Low | High | Compliance team change notification (UK Gov) | Compliance Watchtower has its own meta-agent that watches UK Gov regulatory pages weekly |

Risks #1, #2, #3, #4 are the four that could kill v1.0. Everything below them is recoverable.

---

## 11. The 7-day pre-build checklist

These are the questions and decisions that must be cleared before any code is written. Each has an owner and a deadline. If any are still open at end of day 7, the v1.0 build start slips by the same number of days.

### Day 1 — Monday

- [ ] CortexOS primitive status audit. One line per primitive: "shipped and tested" / "shipped but flaky" / "documented not built" / "aspirational". **Owner:** Maddox. **Output:** `cortexos-primitive-status.md` committed to repo.
- [ ] Design-partner sales conversation 1 (pilot candidate A). **Owner:** Maddox.

### Day 2 — Tuesday

- [ ] Bullhorn integration path decision: marketplace vs direct API. **Owner:** Maddox. **Output:** decision documented in `decisions/bullhorn-integration-path.md`.
- [ ] OAuth model decision (browser dance for production, service-account for dev). **Owner:** Maddox.
- [ ] Design-partner conversation 2 (pilot candidate B). **Owner:** Maddox.

### Day 3 — Wednesday

- [ ] v1.0 sequence optimisation target: Maddox confirms (b) "close first 3 pilots fastest" or revises. **Owner:** Maddox.
- [ ] Brain UI v1.0 scope: confirm "minimal what-did-the-agents-do-today view" or revise. **Owner:** Maddox (after at least one pilot conversation).
- [ ] Hire #1 status one-liner. **Owner:** Maddox.

### Day 4 — Thursday

- [ ] Hetzner UK VPS provisioned; LUKS volume mounted; Postgres 16 installed; basic RLS policy template tested. **Owner:** Maddox (engineering work).
- [ ] First MCP server scoped: tools.yaml schema for Bullhorn integration documented.

### Day 5 — Friday

- [ ] Auto-Send Safety Policy artefact drafted (Q11). **Owner:** Maddox. **Output:** `auto-send-safety-policy.md`.
- [ ] v1.0 kill criterion documented (Q12). **Owner:** Maddox. **Output:** `v1-kill-criterion.md`.

### Day 6 — Saturday (light day)

- [ ] Vertical schema v0.1 draft started. **Owner:** Maddox. **Output:** `docs/verticals/recruitment/vertical-schema.yaml` with the 8 core entities.

### Day 7 — Sunday (review)

- [ ] First design-partner LOI signed (non-binding pilot commitment). **Owner:** Maddox.
- [ ] Sprint week 1 ticket-by-ticket plan written. **Owner:** Maddox.
- [ ] Risk register reviewed; tripwires set for week 1. **Owner:** Maddox.

End-of-week-0 review:
- If ≥1 of: design-partner LOI signed + CortexOS primitives 1, 4, 5 working + Bullhorn auth working → proceed to week 1
- If <1: extend pre-build by 1 week and clear the blocker

This is the structural protection against building something nobody will pay for.

---

## 12. The single-sentence test

If Maddox can't answer each of the following with a confident yes by end of week 0, the build does not start.

1. Do we have at least one design partner who has said "yes I will pilot this in Q3 2026"?
2. Does the CortexOS submodule give us primitives 1, 4, and 5 working today?
3. Have we decided which ATS we're building against first (Bullhorn) and have we cleared the auth path?
4. Have we scoped the Agent Bundle v2 refactor and is the work <5 days?
5. Have we drafted the vertical schema v0.1 with the 8 core entities?

If yes-yes-yes-yes-yes, week 1 starts.

Otherwise, week 0 extends, and we say so honestly.

---

## 13. Document control

| Version | Date | Author | Notes |
|---|---|---|---|
| 1.0 | 14 May 2026 | Maddox + Claude | Initial ultraplan synthesising spec + Q&A answers |

This document is authoritative on the v1.0 → v2.0 build sequence and the technical architecture for delivering the recruitment product. Where it conflicts with prior plans on *how to build*, this wins. The product spec wins on *what to build*. The Internal Business Plan wins on commercial trajectory and ICP.

End of ultraplan.
