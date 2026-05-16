# 01 · Architectural Recommendation

**Build v2 as a fresh third codebase at `/Users/madsadmin/code/CortexOS/` that depends on cortextOS upstream (vendored) and lifts selectively from Intel Force OS v1. Don't fork cortextOS. Don't graft cortextOS into v1. Both shortcuts ship slower and produce a worse product.**

---

## TL;DR

| Option | Verdict | Why |
|---|---|---|
| **A · Extend v1 in place** (graft cortextOS into `intel-force-os/`) | ❌ Reject | v1 has its own Cloudflare Worker runtime, Prisma schema shaped around v1 invocations, tRPC server, dashboard. cortextOS is a PM2 daemon with PTY-managed Claude Code sessions and a file bus — completely different runtime model. Forcing them together is a rewrite disguised as a refactor. |
| **B · Fork cortextOS** (clone, rename, add product into the fork) | ❌ Reject | Couples product cadence to upstream cadence. Forks rot. cortextOS's repo layout optimises for harness use; jamming a `apps/dashboard/`-style product layer into it creates a structural mismatch you'll fight forever. |
| **C · Fresh codebase with cortextOS as vendored dependency** | ✅ **Recommended** | Clean separation. v1 keeps running. cortextOS stays upstream. v2 owns the product layer and pulls cortextOS as a versioned vendor. |

---

## What "Option C" means concretely

Three directories in three states:

```
/Users/madsadmin/code/
├── intel-force-os/                 ← v1, frozen-but-running once v2 lands
├── cortex-os-upstream/             ← read-only clone of cortextOS, source-of-truth for vendoring
└── CortexOS/                       ← v2, the new product codebase (this is what we build)
```

Inside v2:

```
CortexOS/
├── packages/
│   ├── harness/
│   │   └── cortextos/              ← vendored from upstream at a pinned SHA
│   ├── brain/                      ← NEW wiki+graphify memory subsystem
│   │                                 (ships drop-in replacements for bus/kb-*.sh)
│   ├── agents/                     ← 11-agent catalogue lifted from v1 concepts
│   ├── governance/                 ← draft/approve/escalate + audit trail
│   ├── db/                         ← Prisma schemas (tenants, audit, escalations)
│   └── ui/                         ← shared design tokens + primitives from v1
├── apps/
│   ├── dashboard/                  ← Next.js dashboard — IA lifted from v1
│   ├── daemon/                     ← thin wrapper that boots cortextOS with v2 config
│   └── docs/                       ← public docs (later)
├── docs/
│   ├── build-pack/                 ← this pack
│   └── adr/                        ← architecture decision records
├── tests/
├── CLAUDE.md
└── .claude/
    ├── settings.json
    ├── skills/
    └── agents/
```

cortextOS in `packages/harness/cortextos/` is **vendored** — a copy of the upstream at a pinned SHA recorded in `packages/harness/.upstream-version`. Pulling upstream changes is a deliberate, batched operation; in between, you alter freely without merge pain. Codex gets a single, frozen surface to reason about.

---

## Why not extend v1

Concretely, v1 has:

| v1 module | What it does | Why grafting cortextOS breaks it |
|---|---|---|
| `src/index.ts`, `src/bot/` | Cloudflare Worker bot runtime targeted at Teams | cortextOS is a PM2 daemon, not a Worker. Two orchestrators, one customer = pain. |
| `packages/db/prisma/schema.prisma` | Invocation, Escalation, AuditEvent, BrainGraph models shaped for v1 | v2 needs a graph store for brain + cortextOS's file-bus state. Either retrofit everything or run two databases. |
| `packages/trpc/` | tRPC server keyed to v1 data model | tRPC stays, but every query touches the schema you'd have to retrofit. |
| `apps/dashboard/` | Reads tRPC. 12 routes, 50+ components. | Either retrofit to read v2 state, or maintain dual reads. |
| `docs/` (163 spec files, ~40k lines) | All anchored on v1's runtime assumptions | Re-relitigating spec while customers are live = the failure mode v1 already taught us. |

Total: a quarter of work for negative product velocity. The honest read is v1 was built for v1's runtime. Forcing cortextOS in is a rewrite disguised as a refactor.

---

## Why not fork cortextOS

cortextOS upstream layout (verified):

```
cortextos/
├── src/{bus,cli,daemon,hooks,pty,telegram,types,utils}/
├── bus/                  (47 shell scripts — kb-*, task-*, send-*, etc.)
├── dashboard/            (its own Next.js 14 app)
├── knowledge-base/       (Python+Gemini RAG — the swap target)
├── templates/            (agent, orchestrator, analyst, hermes, m2c1-worker, org)
├── skills/, community/, tests/, scripts/, hooks/
├── install.mjs
└── package.json          (name: cortextos, bin: cortextos)
```

If you fork it and build product into the fork:
- The dashboard at `cortextos/dashboard/` is **the harness's dashboard** (agent fleet, tasks, approvals, experiments). Bolting Intel Force product views in muddies the boundary between "harness control surface" and "product UI".
- Every upstream cortextOS release becomes a 3-way merge with your product changes
- The `package.json` says `name: cortextos` — branding/identity is the harness's, not your product's
- Your product becomes implicit ("Intel Force is the long-running thing in this fork"). That's exactly the muddle you said you wanted to avoid.

Library / consumer is the right relationship. Fork / extension is not.

---

## Why fresh-third-codebase wins

| Dimension | Win |
|---|---|
| Dependency direction | v2 → cortextOS (always upgradeable). cortextOS → nothing of yours. |
| v1 continuity | Untouched. Customers see no disruption. |
| Codex reasoning | One coherent codebase. No "is this v1 or v2's flavour?" disambiguation. |
| Brain swap | Becomes a real package (`packages/brain/`) — self-contained, testable, replaceable. Not a graft on top of stock cortextOS memory. |
| Product ownership | Top-to-bottom in `packages/` you own without upstream constraints. |
| Migration | Single mechanical cutover event, not ongoing two-codebases burden. |
| Codex ratification | One coherent target. Codex returns one delta. |

---

## What you give up

Honest costs:

| Cost | Mitigation |
|---|---|
| Phase 0 produces no customer-visible value (~1 focused session) | Unblockable. Pay it once. |
| Phase 1 also customer-invisible (brain swap) | Phase 1 produces internal validation — wiki+graphify backend running through the bus interface. |
| Duplicate maintenance window between v2 Phase 0 and customer migration | Plan for 6–10 weeks overlap. Security patches in both. Feature work only in v2. |
| Temptation to "just do it in v1" when a customer asks | Hard rule: v1 is frozen-for-features. Bugs only. |

These costs are bounded. The alternative costs (grafting / forking) are unbounded.

---

## The cortextOS integration shape (preview — full detail in `03-ARCHITECTURE.md`)

```
v2 daemon process
├─ packages/harness/cortextos/dist/daemon.js     (cortextOS daemon)
│  └─ spawns PTY sessions for agents
│     └─ agents call bus/* shell scripts
│        ├─ bus/send-message.sh      → Telegram or v2 dashboard
│        ├─ bus/create-task.sh       → file-bus state dir
│        ├─ bus/create-approval.sh   → Prisma escalations table (v2 governance)
│        └─ bus/kb-query.sh          → packages/brain/cli/query.ts (NEW backend)
│                                       └─ graph traversal + wiki generation
│                                          backed by Postgres + pgvector + Obsidian-style markdown vault
└─ v2 dashboard process (Next.js)
   └─ reads:
      ├─ Prisma DB (governance, audit, tenants)
      ├─ file-bus state dirs (real-time agent telemetry)
      └─ packages/brain/api/ (graph + wiki views)
```

The key insight: **cortextOS agents don't know they've been re-homed.** They keep calling `bus/kb-query.sh`. The script's contents change (call `packages/brain/cli/query.ts` instead of `mmrag.py`) but the interface is identical. This is the whole reason a swap is feasible without forking the harness.

---

## Decision tree

```
Adding a small feature?
└─ Yes → v1. No question.

Replacing the runtime (cortextOS integration)?
└─ Yes → v2 fresh codebase. Always.

Experimenting with the wiki-graphify brain?
└─ Build in v2 packages/brain/ from day one. Don't prototype in v1.

Has v2 reached feature parity?
├─ No → v1 is canonical. Customers stay on v1.
└─ Yes → freeze v1, migrate customers, rename v2 to canonical.

Did upstream cortextOS ship a breaking change?
└─ Bump packages/harness/.upstream-version. Run v2 tests. Ship to v2 only.
```

---

## Acceptance for this recommendation

Before any code is written, founder confirms:

- [ ] v2 happens in `/Users/madsadmin/code/CortexOS/` (the empty scaffold)
- [ ] cortextOS is vendored into `packages/harness/cortextos/`, pinned by SHA, not forked
- [ ] v1 stays running, unmodified, until v2 reaches feature parity
- [ ] Product naming decision is made (see `08-OPEN-DECISIONS.md` §2)
- [ ] Telegram-control as a v2 feature is decided (see `08-OPEN-DECISIONS.md` §3)

Then Phase 0 (`06-BUILD-PLAN.md`) starts.
