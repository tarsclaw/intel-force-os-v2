# IntelForce AI OS — Planning Phase Execution Brief
**The split between what you produce in chat with me (planning) and what Claude Code builds against the plans (building), plus the exact sequence for completing the planning phase.**

> *Companion to the Execution Plan. Read this one first to understand the split. Use the Execution Plan as your checklist.*

---

## 1. The core split

**Planning phase (you + me, in chat) produces 89 of the 95 artifacts:**
- Specifications a developer implements against
- Prompts (agent.md files) Claude reads at runtime
- Schemas, configs, and YAML declarations
- Scripts that are small and tightly coupled to a spec (validate.sh, context.sh)
- Copy, legal templates, runbooks, playbooks
- Test fixtures and golden outputs

**Building phase (Claude Code + dev hire) takes those specs and writes ~11 substantial codebases.** Claude Code doesn't write the agent prompts or the legal contracts; it writes the *software that runs the prompts and enforces the contracts*.

The dividing rule: if the artifact is a discrete document or file authored once and committed as-is, it's planning. If the artifact is a codebase spanning many files with interdependencies, tests, and iteration, it's Claude Code's build work.

---

## 2. What Claude Code actually builds

These are the 11 deliverables Claude Code owns (with the planning specs they consume):

| # | Codebase | Language | Implements specs from |
|---|---|---|---|
| **CC1** | **Control Plane (Next.js app)** — tenant management, billing, config wizard, dashboard, HITL approval queue, API layer | TypeScript / Next.js 14 / Postgres | Phase 3 (§3.1, 3.2, 3.10, 3.12), all of Phase 4 |
| **CC2** | **Webhook Receiver Service** — multi-tenant Fastify endpoint for every integration's webhooks | TypeScript / Fastify | §1.8, §3.5 |
| **CC3** | **Scheduler Service** — BullMQ + Redis, per-tenant cron execution | TypeScript | §3.6 |
| **CC4** | **Provisioning Orchestrator** — state machine that deploys new tenants from wizard config | TypeScript | §3.1 |
| **CC5** | **Voice Ingestion Pipeline** — document → voice profile extraction service | Python or TypeScript | §3.3 |
| **CC6** | **Vault Service** — file watcher, git sync, dashboard API, graph renderer | TypeScript | §3.4, §4.6 |
| **CC7** | **Observability Stack** — log shippers, metrics, alerting, Grafana dashboards | Vector + Postgres + Grafana | §3.9 |
| **CC8** | **Tenant Docker Image** — base image with Claude Code + integration configs + hooks | Dockerfile + shell | §1.7 |
| **CC9** | **Custom MCP Servers (6 of them)** — DocuSign, GA4, Meta Ads, Companies House, Prospeo, Dentally | Python (FastMCP) or TypeScript | §3.8 (six of the 15 integration specs) |
| **CC10** | **Integration Fallback Wrappers** — direct API clients for when MCP is degraded | TypeScript | §3.7, §3.8 |
| **CC11** | **Agent Library Repo CI/CD** — pipelines that test, version, release agent bundles across all tenants | GitHub Actions / your agent bundles as inputs | §2.1 + all of Phase 2 bundles |

**Total Claude Code scope:** roughly 3–4 months of concentrated build work with a dev in the loop, assuming all planning specs are tight.

**Critical insight:** Claude Code cannot start CC1–CC11 cleanly until the specs they consume are written. Phase 3 specs block CC1–CC7. Phase 4 specs block CC1. Phase 2 bundles block CC11. That's why planning has to come first.

---

## 3. The 95-artifact bucket (per phase)

Reusing the Execution Plan's numbering. **P** = planning (produce in chat), **B** = Claude Code build work, **H** = human work outside this chat (solicitor, designer review).

### Phase 1 — POC Stack (10 artifacts)
| # | Artifact | Bucket |
|---|---|---|
| 1.1 | Proposal Builder agent.md | **P** |
| 1.2 | Proposal Builder config.schema.json | **P** |
| 1.3 | Proposal Builder tools.yaml | **P** |
| 1.4 | Proposal Builder validate.sh | **P** |
| 1.5 | Proposal Builder context.sh | **P** |
| 1.6 | Proposal Builder test fixtures | **P** |
| 1.7 | Tenant Container Structure Spec | **P** → CC8 builds |
| 1.8 | Fathom Webhook Receiver Spec | **P** → CC2 builds |
| 1.9 | Minimal Vault Structure | **P** → CC6 seeds |
| 1.10 | Week-1 Experiment Runbook | **P** |

### Phase 2 — Full Agent Suite (12 artifacts)
| # | Artifact | Bucket |
|---|---|---|
| 2.1 | Agent Library Repo Structure | **P** → CC11 builds |
| 2.2–2.10 | Nine more agent bundles (6 files each) | **P** |
| 2.11 | Standard sub-agent template (blank) | **P** |
| 2.12 | LLM-as-Judge Rubric Library | **P** |

### Phase 3 — Platform Engineering Specs (12 artifacts)
| # | Artifact | Bucket |
|---|---|---|
| 3.1 | Provisioning System Spec | **P** → CC4 builds |
| 3.2 | Configuration Centre Wizard Full UX | **P** → CC1 builds |
| 3.3 | Voice Ingestion Pipeline Spec | **P** → CC5 builds |
| 3.4 | Vault Service Spec | **P** → CC6 builds |
| 3.5 | Webhook Receiver Full Spec | **P** → CC2 builds |
| 3.6 | Scheduler Spec | **P** → CC3 builds |
| 3.7 | MCP Integration Layer Spec | **P** → CC10 builds |
| 3.8 | Individual Integration Specs × 15 | **P** → CC9 builds (6 of them) |
| 3.9 | Observability Stack Spec | **P** → CC7 builds |
| 3.10 | Cost & Billing System Spec | **P** → CC1 builds |
| 3.11 | Audit & Compliance Spec | **P** → CC1 builds |
| 3.12 | HITL Approval System Spec | **P** → CC1 builds |

### Phase 4 — Dashboard Specs (13 artifacts) — **all P → CC1 builds**
| # | Artifact | Bucket |
|---|---|---|
| 4.1–4.13 | Design system + 10 views + IA + mobile responsive | **P** (13 specs) → **CC1** implements |

### Phase 5 — Business/Commercial (15 artifacts)
| # | Artifact | Bucket |
|---|---|---|
| 5.1 | MSA template | **P** + **H** (solicitor review) |
| 5.2 | DPA template | **P** + **H** |
| 5.3 | Sub-processor list | **P** |
| 5.4 | Terms of Service | **P** + **H** |
| 5.5 | Privacy + Cookie policy | **P** + **H** |
| 5.6 | Founding Customer Agreement | **P** |
| 5.7 | Pricing page copy | **P** |
| 5.8 | Homepage copy | **P** |
| 5.9 | About + Case Studies shell | **P** |
| 5.10 | Dental outbound sequence | **P** |
| 5.11 | Agency outbound sequence | **P** |
| 5.12 | Visual Blueprint demo script | **P** |
| 5.13 | Sales objection handbook | **P** |
| 5.14 | Founding customer pitch deck | **P** + **H** (designer) |
| 5.15 | Case study template | **P** |

### Phase 6 — Ops Runbooks (7 artifacts) — **all P**
5.1–6.7 are pure planning artifacts (runbooks and playbooks). No code.

### Phase 7 — Post-Launch Expansion (8 artifacts) — **all P, most feed later CC work**

---

## 4. Total scoreboard

| Bucket | Count |
|---|---|
| **P (planning artifacts, produced in chat with me)** | 89 |
| **H (human work — solicitor / designer)** | 5 (overlapping with P) |
| **B (Claude Code builds) — codebases** | 11 |
| **Decisions (Part C)** | 18 |

Planning sessions estimated at **~125 focused C-sessions** = 6–9 weeks of concentrated work.
Claude Code build estimated at **~3–4 months** after planning complete.

**Total from now to first paying client:** ~5–6 months of serious work. That aligns with your 14-week build target *if* you parallelise: planning runs ahead 4–5 weeks, then build starts while planning continues for later-phase artifacts.

---

## 5. The planning phase, session by session

Here's the exact sequence of sessions I recommend. Each session label tells you what we produce together in a single sitting. Target 3–5 sessions per week of concentrated work.

### Session 1 — Open Decisions Workshop (today)
- Walk through all 18 decisions in Part C
- Output: locked decision log (I'll produce as a doc at the end)
- **45–90 min**

### Sessions 2–6 — Phase 1 POC Stack (week 1)
- Session 2: Proposal Builder agent.md v1 (1.1)
- Session 3: Proposal Builder supporting files (1.2–1.5)
- Session 4: Proposal Builder test fixtures + run-through against golden outputs (1.6)
- Session 5: Tenant Container Structure Spec (1.7) + Minimal Vault Structure (1.9)
- Session 6: Webhook Receiver Spec (1.8) + Week-1 Experiment Runbook (1.10)

**End state of week 1:** every document needed to execute the POC. You can now hand 1.7, 1.8, 1.9 to your dev to start building while we continue planning.

### Sessions 7–16 — Phase 2 Agent Suite (weeks 2–3)
- Session 7: Agent Library Repo Structure (2.1) + Blank template (2.11)
- Session 8: Lead Hunter bundle (2.2)
- Session 9: Follow-Up Pilot bundle (2.3)
- Session 10: Content Creator bundle (2.4)
- Session 11: Repurposer bundle (2.5) + Caption Writer bundle (2.6)
- Session 12: Client Onboarder bundle (2.7)
- Session 13: Reporting Engine bundle (2.8)
- Session 14: SOP Writer bundle (2.9)
- Session 15: The Librarian bundle (2.10)
- Session 16: LLM-as-Judge Rubric Library (2.12)

**End state of week 3:** all 10 agent bundles written. Agent library repo populated. Dev can start implementing CC11 (agent library CI/CD).

### Sessions 17–28 — Phase 3 Platform Specs (weeks 4–5)
- Session 17: Provisioning System Spec (3.1)
- Session 18: Configuration Centre Wizard UX — Steps 1-2 (3.2 part 1)
- Session 19: Configuration Centre Wizard UX — Steps 3-5 (3.2 part 2)
- Session 20: Voice Ingestion Pipeline Spec (3.3)
- Session 21: Vault Service Spec (3.4)
- Session 22: Webhook Receiver Full Spec (3.5) + Scheduler Spec (3.6)
- Session 23: MCP Integration Layer Spec (3.7)
- Session 24: Integration Specs Batch 1 — Fathom, HubSpot, Gmail, Slack, Notion, DocuSign (3.8)
- Session 25: Integration Specs Batch 2 — Stripe, GA4, Meta Ads, Cal.com (3.8)
- Session 26: Integration Specs Batch 3 — Companies House, Prospeo, Kaspr, Loom, Google Drive (3.8)
- Session 27: Observability Spec (3.9) + Cost & Billing Spec (3.10)
- Session 28: Audit & Compliance Spec (3.11) + HITL Approval Spec (3.12)

**End state of week 5:** every platform spec ready. Claude Code has everything needed to start builds CC1–CC10 in parallel. **This is the single most important milestone.** At this point, build work starts even though planning continues.

### Sessions 29–37 — Phase 4 Dashboard Specs (weeks 6–7)
- Session 29: Design System Doc (4.1)
- Session 30: IA + Navigation Spec (4.2)
- Session 31: Home, Activity, Agents views (4.3, 4.4, 4.5)
- Session 32: Brain view deep spec (4.6) — this is the hero view, deserves its own session
- Session 33: Approvals, Integrations, Billing views (4.7, 4.8, 4.9)
- Session 34: Team, Audit Log, Settings views (4.10, 4.11, 4.12)
- Session 35: Mobile Responsive Spec (4.13)
- Session 36: Dashboard build kickoff — walk through all specs with Claude Code / dev for any clarifications
- Session 37: Buffer — revisions based on dev questions

**End state of week 7:** dashboard fully spec'd; CC1 build in full flight.

### Sessions 38–48 — Phase 5 Business/Commercial (weeks 8–9)
- Session 38: MSA template draft (5.1)
- Session 39: DPA template draft (5.2) + Sub-processor list (5.3)
- Session 40: Terms of Service (5.4) + Privacy & Cookie policies (5.5) + Founding Customer Agreement (5.6)
- Session 41: Pricing page copy (5.7)
- Session 42: Homepage copy (5.8) + About/Case Studies shell (5.9)
- Session 43: Dental outbound sequence (5.10)
- Session 44: Agency outbound sequence (5.11)
- Session 45: Visual Blueprint demo script (5.12)
- Session 46: Sales objection handbook (5.13)
- Session 47: Founding customer pitch deck (5.14)
- Session 48: Case study template (5.15)

**End state of week 9:** legal docs in solicitor's hands; marketing copy finalised; sales playbook complete.

### Sessions 49–55 — Phase 6 Ops Runbooks (week 10)
- Session 49: Client Onboarding Human-Hours Playbook (6.1)
- Session 50: Support Playbook L1 (6.2)
- Session 51: Incident Response Runbook (6.3)
- Session 52: Monitoring & Alert Playbook (6.4)
- Session 53: Agency Partner Onboarding Playbook (6.5)
- Session 54: Dev Setup / Runtime Ops Guide (6.6)
- Session 55: Status Page Setup (6.7)

**End state of week 10:** planning phase 100% complete for v1 launch. Phase 7 (post-launch) produced as needed.

---

## 6. Definition of ready-for-Claude-Code

Claude Code can start meaningful build work as soon as Phase 3 is complete (end of week 5 on this schedule). Phases 4–6 continue alongside the build.

Full ready-for-handoff checklist:
- [ ] Part C decisions locked
- [ ] Phases 1–3 artifacts in a private docs repo
- [ ] Agent library repo initialised with Phase 2 bundles
- [ ] Dev hire onboarded and has read every doc in Phases 1–3
- [ ] First founding customer named (verbal commit acceptable)
- [ ] Infrastructure accounts live (Anthropic API org, AWS/Hetzner, Stripe, Supabase, GitHub org)
- [ ] The Open Decisions Log is a file in the docs repo

When those seven boxes tick, Claude Code can begin CC1–CC11.

---

## 7. How to actually begin — my recommendation

Two options for right now:

**Option A (strongly recommended): Begin Session 1 — Open Decisions Workshop now.** I'll walk through all 18 decisions. For each one I'll ask the question, give you the trade-offs, offer my recommendation. You answer. We move to the next. At the end of the session I produce the Decision Log as a committed doc.

**Option B: Park decisions for now, begin Session 2 (Proposal Builder agent.md)** and come back to decisions later.

Option A is the right move because four decisions (C2a API tenancy, C2d embedding provider, C1b first vertical, C1e pricing lock) materially change how the Proposal Builder agent.md gets written. You don't want to write that agent.md three times.

### To begin Session 1, reply with "go" and I'll open with decision C1a.

The first question is going to be:

> **C1a — Entity structure.** You currently run Intel Force Ltd. When you put IntelForce AI OS on the market, is that a product inside Intel Force Ltd, or does it get its own separate limited company? This affects tax (potential R&D tax credit separation), liability (separating SaaS exposure from the consultancy's exposure), and brand (if you ever raise VC for the AI product, investors usually want a clean cap table — easier in a separate entity). Tell me your instinct; I'll push back if I disagree.

Reply "go" and we begin the workshop. Alternatively, if you want to adjust something about this schedule first, tell me what.

---

*End of brief.*
