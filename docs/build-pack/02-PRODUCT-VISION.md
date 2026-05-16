# 02 · Product Vision

**What v2 is in product terms, framed as the Cortex / Workforce / Brain / Queue model. What the wiki+graphify brain adds that the stock cortextOS knowledge-base doesn't. How v2 differs from v1 in the customer's experience.**

---

## The thesis in one paragraph

v1 was *a managed agent workforce* — eleven agents that draft, never send, escalate when uncertain, governed by approvals. It worked, but the agents were largely reactive — each waiting for its trigger, doing its job, queuing for review. v2 makes that workforce **persistent, proactive, and compounding**. cortextOS gives us a 24/7 daemon that keeps agents resident across days, not minutes — so agents can be assigned long-running goals ("watch the inbox for grievance signals; surface weekly trends"), not just one-shot tasks. The wiki+graphify brain replaces stock RAG with a memory layer the founder can *see* — a beautiful Obsidian-style vault that grows visibly, with a graph view that makes the compounding tangible. The dashboard becomes both *operations console* and *brain explorer*. The Telegram integration becomes the founder's mobile-control surface, so v2 is the first version of Intel Force that the operator can run from their phone in line at the coffee shop.

---

## The four-pillar model

v2 is composed of four layers. v1 had three of them, weakly. v2 has all four, deliberately.

```
┌─────────────────────────────────────────────────────────────┐
│  CORTEX          → planning + scheduling + lifecycle        │
│                    (cortextOS daemon, PTY sessions, crons,  │
│                     Orchestrator agent decomposes goals)    │
├─────────────────────────────────────────────────────────────┤
│  WORKFORCE       → 11 agents doing the work                 │
│                    (HR Assistant, Proposal Builder, …       │
│                     templated from cortextOS templates/     │
│                     + lifted catalogue from v1)             │
├─────────────────────────────────────────────────────────────┤
│  BRAIN           → wiki+graphify memory (NEW in v2)         │
│                    (Obsidian-style vault + graph store      │
│                     + visualisation that compounds visibly) │
├─────────────────────────────────────────────────────────────┤
│  QUEUE           → governance: draft / approve / escalate   │
│                    (lifted from v1 — approvals UI, audit    │
│                     trail, sensitivity scoring, escalations)│
└─────────────────────────────────────────────────────────────┘
```

### Cortex (the planning layer)

What it is: cortextOS, with its Orchestrator + Analyst + Specialist templates, runs the day. The Orchestrator agent decomposes high-level customer goals ("clean up the HR inbox every morning at 9am and tell me what needs my judgement") into concrete tasks routed to specialist agents.

What's new vs v1: v1 had no planning agent. Every agent was directly triggered. v2 has an explicit Orchestrator that holds the goals, schedules the cron jobs, watches for blockers, and routes work — exactly cortextOS's Orchestrator role, with prompts tuned for our domain.

What it gives the customer: a single agent ("Boss" — cortextOS's term, or rename it) they talk to in Telegram, that knows everything that's happening. "What's running right now?" "Approve all low-sensitivity HR drafts from this morning." "Add a cron that checks Stripe revenue every Monday at 8am and flags anomalies." Conversational.

### Workforce (the eleven agents)

What it is: the eleven agents from v1's catalogue, redefined as cortextOS agent templates with v2-specific prompts. Same role split:

| Director | Agents |
|---|---|
| HR | HR Assistant · Email Handler |
| Sales | Proposal Builder · Lead Hunter · Follow-Up Pilot |
| Marketing | Content Creator · Repurposer · Caption Writer |
| Operations | Client Onboarder · Reporting Engine · SOP Writer |

What's new vs v1: each agent now lives as a **persistent PTY session** under PM2, not a Worker invocation. State is preserved across runs. The HR Assistant remembers the conversation thread it had with Sarah yesterday morning without having to re-fetch context from Breathe HR — because it's the same session, still running.

What it gives the customer: dramatically lower latency on follow-ups, conversation continuity that feels human, and the ability for agents to do multi-step work over hours not seconds.

### Brain (the wiki+graphify memory)

What it is: a per-tenant **Obsidian-style markdown vault** stored on disk, indexed into a **graph store** (Postgres + pgvector for embeddings + property-graph schema for relationships), with a **stunning visualisation** in the dashboard that makes the customer's institutional memory visible as it compounds.

The customer's flow:
1. They upload the handbook, paste past replies, connect Fathom — material lands in the vault as markdown pages.
2. Graphify processes each page: extracts entities (people, policies, products, accounts), draws relationships, embeds for retrieval.
3. The dashboard's `/brain` view renders the vault as: a graph (force-directed, communities clustered, like Obsidian), a wiki index, a search bar that returns both pages and graph paths.
4. As agents work, every approval and every edit feeds back into the brain as new edges or weighted facts.
5. By month three, the customer can *see* their compounding intelligence — the graph is denser, the wiki has more cross-links, search recall is better.

What's new vs v1: v1's "Brain" was conceptually right but mostly text/index. v2's brain is a real graph store with a real Obsidian-quality view. It looks stunning. That's the part v1 didn't deliver.

What it gives the customer: 1) a moat they can *show* (graph density over time = the compounding loop made visible); 2) better retrieval than RAG-over-flat-docs because the graph carries entity relationships; 3) a knowledge management tool they'd pay for on its own merits.

**This is the swap target.** cortextOS stock memory is `knowledge-base/scripts/mmrag.py` (Gemini RAG, shell-script interface in `bus/kb-*.sh`). v2 replaces the Python backend with the wiki+graphify implementation. Same shell-script interface — agents don't notice. Customer experience is transformed.

### Queue (the governance layer)

What it is: the same draft-approve-escalate model from v1. Every agent output is a draft. Sensitivity ≥ 0.7 routes humans-only. Seven-year audit trail. One-click approve/edit/reject. Lifted unchanged in product terms from v1.

What's new vs v1: integrated with cortextOS's approval flow (it has `bus/create-approval.sh`, `bus/list-approvals.sh`, `bus/update-approval.sh`). v2 writes through cortextOS's bus to a Prisma-backed governance store, then surfaces the same UI as v1's `/approvals` view.

What it gives the customer: zero change. This is the trust pillar. v2 preserves it identically.

---

## What v2 means for the customer

### The two-paragraph product story

> Intel Force OS gives you an **always-on AI operations team that works while you sleep, drafts when you wake up, and grows smarter every week**. Eleven specialist agents — HR, Sales, Marketing, Operations — run continuously on your behalf, doing the repetitive work and surfacing what needs your judgement. Everything drafts; nothing sends without your approval. You stay in control of every output before it leaves your account.
>
> What makes it different is the **Brain**: a private second-brain your company builds in real time. The handbook you uploaded, the proposals that closed, the way Sarah handles holiday requests differently from Tom — it all goes in. As the agents work and you approve their drafts, the Brain compounds. By month three, the system reads like you. By month twelve, no one can replicate what you've built. You can see it growing in the dashboard's graph view — a stunning Obsidian-style map of your operations that gets denser every day. Control everything from your phone via Telegram, or the web dashboard, or the iOS app when it ships.

### The two-paragraph differentiation

> Most AI tools forget your company every time you close the tab. You ask, they answer, they reset. Intel Force OS is the inverse: it remembers everything you've written, every decision you've approved, every edit you've made — and it operates from that memory continuously, not on prompts. The agents are running right now, drafting your next reply, while you sleep.
>
> Most AI tools also can't be trusted. Intel Force OS escalates when it's uncertain — when policy is unclear, data is weak, or output might embarrass you. Sensitive HR matters never get AI-drafted. The four-objection rule applies to every output: nothing sends without you. UK-hosted, GDPR-ready, built on Claude. Your operations, in your voice, at your standard.

### The hero-stat the dashboard surfaces in week 1

> **Your Brain has indexed 1,247 facts and drawn 8,432 relationships across 47 knowledge pages. Three agents have run 184 times this week, drafting 47 outputs. You've approved 41. Your operating memory is 12% denser than it was last week.**

That single stat — *denser than last week* — is the compounding loop made tactile. The Brain literally getting bigger and more connected, every week, visibly.

---

## What v2 keeps from v1 (product-side)

Unchanged. Inherited as canon, no relitigation:

- **Positioning** — managed agent workforce for UK SMEs (20–200 employees)
- **ICP** — UK service businesses on Breathe HR / BambooHR / HiBob, 20–200 emp, £1M–£20M revenue
- **Brand voice** — direct, specific, honest about limits, quiet confidence, British English
- **Banned phrases** — "AI-powered", "leverage", "revolutionary", "cutting-edge", exclamation marks in body
- **Invariant** — *everything drafts, nothing sends without human approval*
- **Pricing** — founding £400/mo until customer #10, then Starter £450 / Growth £1,800 / Scale £4,500 / Enterprise £10k+
- **Compliance posture** — UK-hosted, GDPR-ready, 7-year audit retention, per-tenant keys
- **Visual identity** — emerald primary, amber secondary, dark mode default, Inter + JetBrains Mono

Full inheritance map in `07-V1-INHERITED-CONTEXT.md`.

---

## What v2 changes from v1 (product-side)

- **Brain is visual.** v1's Brain was a knowledge view. v2's is a graph-rendered second-brain people would pay for standalone.
- **Agents are persistent.** v1 invocations were short-lived. v2 sessions persist for the 71-hour context cycle.
- **Telegram is first-class.** v1 had Teams + Slack. v2 adds Telegram as the founder's mobile-control surface (cortextOS's native channel).
- **Orchestrator exists.** v1 had no planning agent. v2 has an explicit "Boss" the customer talks to in Telegram.
- **Multi-runtime.** v1 was Anthropic API only. v2 supports cortextOS's runtime choice — `claude-code` or `codex-app-server` per agent.
- **24/7 autoresearch.** cortextOS's "theta wave" feature: agents run autonomous experiments overnight (e.g., "test 3 cold-outreach hooks against the next 30 leads"), evaluate results, surface findings for review. v1 had nothing like this.

---

## What v2 explicitly drops or defers

- **Cloudflare Worker bot runtime** (v1's bot, currently in `intel-force-os/src/`) → not ported. cortextOS's daemon replaces it.
- **Microsoft Teams as primary channel** → secondary in v2. Telegram is primary. Teams gets ported in Phase 3 if/when a customer demands it.
- **v1's tRPC + Prisma stack** → not lifted directly. v2 uses its own Prisma (different schema shape, see `04-DATA-MODEL.md`). tRPC may or may not be re-adopted; default is yes (it worked).

---

## What "looks stunning" means for the Brain UI

Concrete acceptance criteria for the wiki+graphify brain view in the v2 dashboard:

- Graph renders as **force-directed**, with **community clustering** (different colours per cluster, like Obsidian's Graph view)
- **Zoomable**: from "all 1,247 facts" overview down to a single-node inspector
- Hover a node → tooltip with the node's wiki page snippet
- Click a node → opens the wiki page in a side drawer (don't navigate away)
- Search bar above the graph — type "holiday policy" and watch matching nodes pulse and centre
- **Growth indicator**: a small inset showing "+47 facts this week, +12% density" — the compounding loop quantified
- Time-scrubber: drag a slider to see the graph "rewind" to last month, last quarter — visible growth over time
- **Light + dark mode** matter; users will screenshot this for LinkedIn — it must look beautiful in both
- Wiki view (sibling tab to graph view) is **Obsidian-quality markdown**: backlinks, tag pills, footnote previews, code blocks, callouts
- Editing the wiki page in the dashboard writes to the underlying markdown file in the per-tenant vault — round-trip-safe so a power user can also edit in Obsidian directly

The brain view is the **product's centrepiece in marketing**. It's what the screenshot in the landing-page hero will be. Design accordingly.

---

## What this section does NOT decide

- Product brand name (Intel Force OS continues? new name? see `08-OPEN-DECISIONS.md` §2)
- Whether the Telegram interface ships in Phase 1 or Phase 3 (`08-OPEN-DECISIONS.md` §3)
- Whether the iOS app is in scope at all this cycle (`08-OPEN-DECISIONS.md` §4)
- The exact graph database technology (Postgres+pgvector with property tables vs. dedicated graph DB like Neo4j vs. Cosmograph in-memory) — see `04-DATA-MODEL.md`

These are all decided downstream of this vision being accepted. The vision itself only commits to: four-pillar model, brain as graph+wiki, dashboard as the centrepiece, governance preserved.
