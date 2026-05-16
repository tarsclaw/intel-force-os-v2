# 08 · Open Decisions

**Questions only the founder can answer. Each has a recommendation, a recommended decision deadline (relative to Phase 0 start), and a "what blocks if undecided" note. Resolve these before the corresponding phase starts.**

---

## §1 · CortexOS source access ✅ RESOLVED

**Status:** Resolved 16 May 2026.

cortextOS is at `/Users/madsadmin/code/cortex-os-upstream/` cloned from `github.com/grandamenium/cortextos`. Read-access confirmed. Treated as upstream; not modified.

Recorded here for future-session reference.

---

## §2 · Product branding for v2

**Decision needed:** What does v2 call itself, customer-facing?

**Options:**

| Option | Pros | Cons |
|---|---|---|
| **A. Intel Force OS (continue)** | Customers know it. Marketing site already built. SEO, brand equity. | Risks "v2 is just v1 + upgrades" perception. May undersell the brain leap. |
| **B. Intel Force OS 2 / Intel Force Cortex** | Anchors the upgrade narrative. Same parent brand. | Customers may wonder what happened to "1". Naming-version is awkward. |
| **C. New product name entirely** (e.g. *Cortex Operations*, *Atlas*, *Brain Office*, …) | Fresh start. Can lead with the brain story. | Throws away brand equity. Adds marketing-site rewrite to scope. |
| **D. Intel Force, drop "OS"** | Cleaner. "Intel Force is now a brain + workforce." | Subtle, may not register. |

**Recommendation:** **A. Continue as Intel Force OS** for v1's first 10 customers. Treat v2 as the major version. Marketing the leap is a copy job, not a rename job. The brain is the leap; let the product story shift, keep the name stable.

**Deadline:** Before Phase 2 starts (the dashboard surfaces the brand prominently).

**Blocks if undecided:** Phase 2 design tokens import; favicon and logo work; any tweet/LinkedIn copy mentioning v2.

---

## §3 · Telegram as a v2 channel — Phase 1 or Phase 3?

**Decision needed:** When does Telegram control become a real shipped feature?

cortextOS ships Telegram natively. v2 inherits it for free at the harness level. But:

- Phase 1 ship: founders can already use Telegram against the dev daemon. Cool for demos, doesn't affect customers.
- Phase 2 (dashboard) doesn't depend on Telegram.
- Phase 3 customer-facing Telegram = needs onboarding flow ("create your bot, paste the token"), permissions model, etc.

**Options:**

| Option | Pros | Cons |
|---|---|---|
| **A. Phase 1 internal only; Phase 3 customer-facing** | Lets v2 land the brain swap without UX work on Telegram. | Telegram is a v2 differentiator; delaying it hurts the demo. |
| **B. Phase 2 customer-facing** | Telegram is in scope as part of the dashboard build. Demo-ready. | Adds 1 slice to Phase 2. |
| **C. Phase 3 customer-facing, optional Phase 1 demo** | Same as A but explicit that early demos can use the founder's bot. | Same as A. |

**Recommendation:** **C.** Internal-only Telegram in Phase 1 (the daemon needs it for "Phase 0 alive" anyway). Customer-facing Telegram in Phase 3 alongside per-tenant daemon spawning. Demos in the Phase 1–2 window use the founder's bot pointing at the demo tenant.

**Deadline:** Before Phase 1 ends.

**Blocks if undecided:** Phase 2 onboarding wizard scope.

---

## §4 · iOS app in scope?

**Decision needed:** Does v2 include the iOS app cortextOS roadmaps?

cortextOS's README mentions "Native iOS app coming soon." That's upstream's roadmap. v2 inherits if we want.

**Recommendation:** **Out of scope.** No iOS in v2 launch. Revisit once v2 has ≥ 10 paying customers and at least 3 explicitly ask for iOS.

**Deadline:** Now. (To stop creep.)

**Blocks if undecided:** Phase 3 scope sprawl.

---

## §5 · v1 → v2 migration pilot

**Decision needed:** Which v1 tenant migrates first?

The migration script in Phase 3 needs a real (or realistic) test. Options:

| Option | Pros | Cons |
|---|---|---|
| **A. A real founding customer (opted in)** | Realistic; produces a case study | Risky — customer sees rough edges |
| **B. The demo tenant** (`demo-co`) | Safe; you control it | Doesn't prove customer-shaped scenarios |
| **C. A new fake "v1-fixture" tenant created for this purpose** | Most realistic without customer risk | Effort to fabricate convincing v1 data |
| **D. Don't do v1 migration in v2 Phase 3 at all; new customers go straight to v2** | Phase 3 simpler; v1 customers stay on v1 until they churn or v1 sunsets | Risks indefinitely-supported v1 |

**Recommendation:** **B then A.** Phase 3 ships migration script against the demo tenant (B). Then once stable, a founding customer who's opted in (A) gets migrated. New customer signups from v2 launch date onward go straight to v2. No new sign-ups on v1.

**Deadline:** Before Phase 3 starts.

**Blocks if undecided:** Phase 3 §P3.S5 scope.

---

## §6 · Embedding model

**Decision needed:** Which embedding model powers the brain's pgvector store?

| Option | Cost (per 1M tokens) | Dimensions | Quality |
|---|---|---|---|
| OpenAI `text-embedding-3-small` | $0.02 | 1536 | Good, cheap, default |
| OpenAI `text-embedding-3-large` | $0.13 | 3072 | Better, ~6× cost |
| Voyage AI `voyage-3` | $0.06 | 1024 | Excellent quality, different vendor |
| Cohere `embed-multilingual-v3` | $0.10 | 1024 | Multilingual; we're UK-only so less relevant |

**Recommendation:** **OpenAI text-embedding-3-small** for v2 launch. Cheap, well-supported, 1536 dims fits comfortably in pgvector HNSW. Re-evaluate at 100k+ nodes per tenant.

**Deadline:** Before Phase 1 §P1.S3.

**Blocks if undecided:** Phase 1 brain ingest implementation.

---

## §7 · Keep tRPC or move to Server Actions

**Decision needed:** v1 uses tRPC. v2 dashboard can either keep tRPC or use Next 16 Server Actions only.

| Option | Pros | Cons |
|---|---|---|
| Keep tRPC | Type safety, lift v1 routers, well-known patterns | One more layer; some Next 16 idioms get awkward |
| Server Actions only | Simpler, native to Next 16, no router boilerplate | Less type safety across client/server; lose code-sharing patterns |

**Recommendation:** **Keep tRPC** for v2. v1 router structure lifts cleanly. The team's muscle memory is already there.

**Deadline:** Before Phase 2 §P2.S1.

**Blocks if undecided:** dashboard scaffold imports.

---

## §8 · Hosting

**Decision needed:** Where does v2 run in prod?

| Component | Recommended | Alternative |
|---|---|---|
| Daemon (cortextOS + agent PTYs) | **Fly.io LHR region** (one VM per tenant, scales horizontally) | Hetzner UK bare metal at scale |
| Dashboard (Next 16) | **Vercel** (or Cloudflare Pages — both work) | Self-hosted on Fly.io |
| Postgres + pgvector | **Neon UK-East** | Supabase, RDS, Hetzner-hosted PG |
| Vault file storage | **Cloudflare R2 EU/UK** | S3 with UK encryption keys |

**Recommendation:** **Fly.io + Vercel + Neon + R2.** Each is best-in-class for its slot, all have UK/EU presence, all bill in £.

**Deadline:** Before Phase 3 (Phase 0–2 can run locally).

**Blocks if undecided:** Phase 3 deployment infra.

---

## §9 · Sub-processor list update

**Decision needed:** v2 adds Neon and Fly.io as sub-processors. v1's DPA must be amended.

**Recommendation:** Update the sub-processor list in `intel-force-os/docs/phase-5-business-legal/legal/dpa-template.md` before v2 launches. Notify all v1 customers in writing (email is fine — DPA standard practice).

**Deadline:** 30 days before first v2 customer goes live.

**Blocks if undecided:** v2 going live with real customer data.

---

## §10 · v1 sunset timeline

**Decision needed:** When does v1 freeze? When does v1 fully sunset?

| Phase | Suggested |
|---|---|
| **v2 launches** (first paying v2 customer) | Day 0 |
| **v1 freezes for new features** | Day 0 (already implied by this build pack) |
| **v1 freezes for new sign-ups** | Day 0 |
| **v1 sunset announcement to remaining v1 customers** | Day 60 |
| **All v1 customers migrated to v2** | Day 180 |
| **v1 infrastructure shut down** | Day 210 |
| **v1 archive (read-only audit access for 7 years per compliance)** | Day 211 onward |

**Recommendation:** Adopt this timeline as the default. Adjust if customer migration runs hot or cold.

**Deadline:** When v2 launches.

**Blocks if undecided:** v1 maintenance budget; customer comms; team time allocation.

---

## §11 · Sensitivity scoring model in v2

**Decision needed:** v1 has a sensitivity classifier. v2 can keep, replace, or extend it.

**Recommendation:** **Keep v1's approach** (Claude-side classification + a small prompt-based scoring step), running inside `packages/governance/src/sensitivity.ts`. Don't introduce a new ML pipeline. The ≥ 0.7 threshold is the contract; how the score is computed is implementation detail.

**Deadline:** Phase 1 §P1.S5 area.

**Blocks if undecided:** governance package.

---

## §12 · Marketing-site rewrite

**Decision needed:** When does the v1 marketing site (`Intelforce Website/`) get updated to reflect v2?

**Recommendation:** **After v2 has its first paying customer**, not before. Marketing the brain leap pre-customer is premature; do it with a real case study or a real screenshot of the brain view from a live tenant. Until then, the marketing site sells v1 (HR wedge) unchanged.

**Deadline:** Open-ended; ties to first v2 customer.

**Blocks if undecided:** nothing immediately.

---

## §13 · Codex ratification ritual

**Decision needed:** What exactly does "ratify through Codex" mean operationally?

**Recommendation:** Document the ritual:

1. At each phase boundary, bundle the phase's git diff + the relevant build-pack files
2. Hand to Codex with the prompt: *"Pressure-test this phase's implementation against the build pack. Surface deviations, weak abstractions, missing tests, latent bugs. Return a delta document."*
3. Apply Codex's delta as a final commit on the phase (with a co-author tag)
4. Move to the next phase

**Deadline:** Before Phase 0 ends.

**Blocks if undecided:** the founder's mental model of "one-shotting through Claude Code + Codex".

---

## §14 · Memory of decisions

**Where these decisions get recorded after being made:**

- `08-OPEN-DECISIONS.md` (this file) — append "✅ RESOLVED" status with date + outcome
- `docs/adr/` — every non-trivial decision becomes a 1-page ADR (Architecture Decision Record) in the v2 codebase
- `~/.claude/projects/-Users-madsadmin-code-CortexOS/memory/MEMORY.md` — the Claude Code project memory index for v2 picks up the headline outcomes as `project_*.md` memories

This ensures: this pack ages well, future Claude Code sessions land oriented, and Codex sees the same context the next session does.
