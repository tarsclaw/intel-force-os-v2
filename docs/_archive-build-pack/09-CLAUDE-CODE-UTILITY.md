# 09 · Maximising Claude Code Utility for This Build

**How to leverage Claude Code's features specifically for the Intel Force on cortextOS build. Skills, sub-agents, MCP servers, scheduled agents, project memory, slash commands. Each item below is concrete: when to use it, how to configure it, why it pays off for *this* build.**

---

## The shape of "one-shotting" through Claude Code

You said the goal is to one-shot this with Claude Code + Codex ratification. "One-shot" doesn't mean a single chat turn. It means **the build proceeds without architectural re-litigation**. Phase boundaries are gates; inside a phase, slices execute against the pack. Codex catches what Claude Code missed; Claude Code catches what Codex missed.

For that to work, Claude Code's features need to be deployed deliberately. This file is how.

---

## 1. Skills — the brain swap leverages two existing ones

### 1.1 `graphify` skill

Already installed at `~/.claude/skills/graphify/SKILL.md`. Description: "any input (code, docs, papers, images) → knowledge graph → clustered communities → HTML + JSON + audit report". Trigger: `/graphify`.

**For this build:** `packages/brain/src/graphify.ts` is the heart of the brain swap. Rather than designing the entity+relationship extraction pipeline from scratch, **read the graphify skill's implementation first**. It already encodes:
- Markdown → AST → entity extraction
- Entity → relationship inference
- Community clustering on the resulting graph
- HTML + JSON export

The skill is a working reference for what to implement in `packages/brain/src/`. Even better, the wiki-brain skill (next item) is *built on top of* graphify — it's the proof that this approach works for a personal knowledge base.

**During Phase 1 §P1.S3 (ingest pipeline):** open `~/.claude/skills/graphify/SKILL.md` first, then implement. Don't reinvent. Adapt.

### 1.2 `wiki-brain` skill

Installed at `~/.claude/skills/wiki-brain/SKILL.md`. Description: "Turn Claude Code into a knowledge base that compounds. Every conversation ingests into a personal wiki you browse in Obsidian. Based on Andrej Karpathy's LLM Wiki pattern, powered by Graphify."

**For this build:** this is the *prior art* for what we're building. The wiki-brain skill turns Claude Code into a personal Obsidian-shaped knowledge base; we're turning cortextOS into a *tenant-shaped* Obsidian-shaped knowledge base for customers.

**During Phase 1 §P1.S6 (wiki rendering):** read the wiki-brain skill's implementation. Adopt the markdown conventions, backlink computation, and folder structure. The customer-facing brain should look identical to wiki-brain visually because that's what the founder said "looks stunning" means.

### 1.3 Other relevant skills already installed

| Skill | When useful in this build |
|---|---|
| `cloudflare-intel-force` | Phase 3 if/when we deploy any Cloudflare components |
| `phase-3-platform` | Reference for multi-tenancy patterns — informs §3 of architecture |
| `phase-4-dashboard` | Reference for dashboard build — informs Phase 2 |
| `relevance-ai` | Retired in v1; not relevant in v2. Don't invoke. |
| `bot-framework-teams` | Reference if Phase 3 §P3.S4 (Teams adapter) ships |
| `frontend-design` | Phase 2 — the brain view "looks stunning" criterion |
| `adaptive-cards` | Only relevant if Teams adapter ships |

### 1.4 New skills to create for this build

Put these in `~/.claude/skills/` (global) or `/Users/madsadmin/code/CortexOS/.claude/skills/` (project-local):

- **`cortextos-bus`** — the file-bus interface, all 47 scripts, when to override vs augment vs keep. Lives at `.claude/skills/cortextos-bus/SKILL.md`. Phase 0 deliverable.
- **`brain-package`** — the wiki+graphify brain's architecture, ingest pipeline, query layer, vault layout. Lives at `.claude/skills/brain-package/SKILL.md`. Phase 1 deliverable.
- **`v2-build-pack`** — pointer to `/Users/madsadmin/code/CortexOS/docs/build-pack/` and how to use it. Lives at `.claude/skills/v2-build-pack/SKILL.md`. Phase 0 deliverable.

These give future sessions one-line invocations: `/skill cortextos-bus` and the right context loads.

---

## 2. Sub-agents — when to delegate

| Sub-agent | When to use in this build |
|---|---|
| **Plan** | At every phase boundary. Before P1, run a Plan agent to scope the brain swap. Before P2, run Plan for the dashboard. Plan returns a structured slice list — compare against the build pack's slices to catch what's missing. |
| **Explore** | Phase 1 §P1.S3 (where does cortextOS call kb-* scripts from internally? Explore: "find every call site of `bus/kb-query.sh` across cortex-os-upstream"). Phase 2 §P2.S2 (where in v1 is every primitive component?). |
| **phase-architect** | Use at phase boundaries to pressure-test your implementation against the spec. "Phase-architect: review Phase 1's brain package against `03-ARCHITECTURE.md` and `04-DATA-MODEL.md`. Surface deviations." Equivalent of Codex internal to Claude Code. |
| **general-purpose** | Catch-all for multi-step research. Less used in this build; the others are more specific. |
| **vercel:nextjs**, **vercel:vercel-functions** | Phase 2 dashboard scaffold. |
| **vercel:ai-sdk** | Phase 1 brain ingest — if we use AI SDK for entity extraction. |
| **vercel:vercel-storage** | Phase 3 R2/vault wiring. |

**Rule of thumb:** delegate when the task is read-heavy or research-heavy. Don't delegate writes — Claude Code in the main thread should do the writing so it can see its own context.

---

## 3. MCP servers — already configured, more to add

### 3.1 Already configured (in `/Users/madsadmin/code/intel-force-os/.claude/settings.json`)

- `cloudflare-docs` — useful for Phase 3 if we deploy to Cloudflare
- `cloudflare-observability` — Worker logs/metrics; less relevant in v2 (Fly.io daemon model)
- `cloudflare-api` — same

These transfer to v2 by copying the relevant block of `.claude/settings.json`.

### 3.2 Add for v2

| MCP | Purpose | Where to find |
|---|---|---|
| **postgres-mcp** | Direct SQL queries against the v2 Postgres for debugging during Phases 1–3 | github.com/modelcontextprotocol/servers |
| **filesystem-mcp** | Scoped to the vault directory; lets a session inspect / edit markdown files conversationally | github.com/modelcontextprotocol/servers |
| **github-mcp** | If we put cortextOS upstream tracking + v2 in GitHub, lets Claude Code query upstream PRs to spot relevant fixes before vendoring | github.com/modelcontextprotocol/servers |
| **anthropic-cookbook** | Patterns for prompt engineering the agent templates | depends on availability |

Configure in `/Users/madsadmin/code/CortexOS/.claude/settings.json` during Phase 0 §P0.S1.

---

## 4. Slash commands — port from v1, add v2-specific

### 4.1 Lift from v1

v1 has these in `/Users/madsadmin/code/intel-force-os/.claude/commands/`:

- `/session-start` — scope the session
- `/load-phase <n>` — load phase-specific context
- `/search-specs <q>` — grep across docs
- `/review-against-spec` — check implementation against spec
- `/deploy` — deploy Worker (rewrite for v2 daemon)
- `/tail` — Worker logs (rewrite for PM2 logs)
- `/new-customer` — onboard a customer (rewrite for v2)

Lift conceptually. Each has a markdown spec in v1's `.claude/commands/`. Adapt to v2 paths.

### 4.2 Add v2-specific

- **`/vendor-cortextos`** — vendor cortextOS upstream into `packages/harness/cortextos/`. Updates `.upstream-version`. Run tests. Single command.
- **`/brain-stats <tenant>`** — query the graph store; print node/edge counts, density, last ingest timestamp.
- **`/codex-bundle <phase>`** — bundle the phase's git diff + relevant build-pack files into a single text file ready to paste into Codex.
- **`/phase-gate <n>`** — runs all acceptance criteria checks for Phase n. Output: which check passed, which failed, what to fix.

Build during Phase 0 §P0.S1.

---

## 5. Project memory

`~/.claude/projects/-Users-madsadmin-code-CortexOS/memory/` will be auto-created on first session in `/Users/madsadmin/code/CortexOS/`. Use it for:

### 5.1 Memories to seed at Phase 0 start

- `project_cortexos_v2.md` (type: project) — one-paragraph: what v2 is, what the canonical paths are, where the build pack lives
- `feedback_voice.md` (type: feedback) — lift from v1's voice rules
- `feedback_invariants.md` (type: feedback) — the seven non-negotiable invariants from `07-V1-INHERITED-CONTEXT.md` §3
- `reference_v1_codebase.md` (type: reference) — pointer to `/Users/madsadmin/code/intel-force-os/` and what it's for (the v1 source, kept alive)
- `reference_cortextos_upstream.md` (type: reference) — pointer to `/Users/madsadmin/code/cortex-os-upstream/`, read-only
- `reference_build_pack.md` (type: reference) — pointer to `/Users/madsadmin/code/CortexOS/docs/build-pack/`
- `user_maddox.md` (type: user) — founder profile: solo, builds and sells, no sales team, ratifies through Codex, prefers fast direct iteration over over-planning

Seed all of these in Phase 0 §P0.S1.

### 5.2 Memories to grow during the build

- At each phase boundary, add a `project_phase_<n>_outcome.md` recording what shipped + what slipped + the Codex delta applied
- Each ADR in `docs/adr/` should have a matching memory: `decision_<topic>.md` (type: project) with the headline outcome

This keeps cross-session continuity — a new Claude Code session in the v2 codebase lands knowing what's been built without re-reading 10 spec files.

---

## 6. Scheduled agents — for the parts that run between sessions

Claude Code can schedule background work. Useful for this build:

| Schedule | What | Why |
|---|---|---|
| Weekly | "Pull cortextOS upstream, diff against `packages/harness/cortextos/`, surface what's safe to apply" | Keeps the vendored copy fresh without weekly manual checks |
| Daily (during Phase 1) | "Run `pnpm test --filter brain` and surface failures" | Catches regressions in the brain package |
| One-time, 2 weeks after Phase 0 ships | "Open a Codex-review PR for Phase 0 artifacts" | Forces the Codex ratification step to actually happen |
| Quarterly | "Survey v1 vs v2 customer split. If v2 has > 5 customers and v1 has < 3, draft the v1 sunset announcement" | Triggers v1 sunset timeline (see `08-OPEN-DECISIONS.md` §10) |

Set these up via `/schedule` once Phase 0 ships.

---

## 7. Plan mode

Use Plan mode at every phase boundary. Concretely:

```
Phase 0 start:  Plan mode → "Scope Phase 0 from build pack §06"
Phase 1 start:  Plan mode → "Scope Phase 1 brain swap from build pack §06 + §03 §6"
Phase 2 start:  Plan mode → "Scope Phase 2 dashboard from build pack §06 + §03 §7"
Phase 3 start:  Plan mode → "Scope Phase 3 parity + migration from build pack §06 + §04 §8"
```

The plan output gets reviewed against the build pack's slices. Discrepancies = either the plan missed something, or the build pack is wrong and needs updating. Either way, resolve before writing code.

---

## 8. Reduce-permission-prompt setup

Set up a project-local allowlist for common commands so the build doesn't get interrupted by permission prompts:

`/Users/madsadmin/code/CortexOS/.claude/settings.json` (add to `permissions.allow`):

```json
{
  "permissions": {
    "allow": [
      "Bash(pnpm:*)",
      "Bash(npm:*)",
      "Bash(pm2:*)",
      "Bash(prisma:*)",
      "Bash(node:*)",
      "Bash(git:add:*)",
      "Bash(git:commit:*)",
      "Bash(git:status)",
      "Bash(git:diff:*)",
      "Bash(git:log:*)",
      "Bash(psql:*)",
      "Bash(docker compose:*)",
      "Bash(rclone:ls:*)",
      "Read",
      "Edit",
      "Write"
    ],
    "deny": [
      "Bash(rm:-rf:*)",
      "Bash(git push --force:*)",
      "Bash(curl:*pipe to bash:*)"
    ]
  }
}
```

Run `/fewer-permission-prompts` periodically to audit what got asked but auto-approve next time.

---

## 9. The CLAUDE.md anchor

`/Users/madsadmin/code/CortexOS/CLAUDE.md` is what every session reads first. Keep it tight (under 200 lines).

### What it should contain (after Phase 0)

```markdown
# Intel Force OS v2 (CortexOS-based)

System-level project context. Loaded by Claude Code at the start of every session.

## What this is
Intel Force OS v2 — the agentic workforce + wiki+graphify brain product, built on top of cortextOS. v1 lives at /Users/madsadmin/code/intel-force-os/, alive serving founding customers. cortextOS upstream at /Users/madsadmin/code/cortex-os-upstream/, read-only.

## The build pack
Full context: docs/build-pack/. Read in order. README.md is orientation.

## Current phase
[Phase 0 / 1 / 2 / 3] — see docs/build-pack/06-BUILD-PLAN.md.

## Active slice
[Slice ID] — [one-line summary]

## Conventions
- TypeScript strict everywhere
- One slice at a time
- Commit per slice with conventional-commit prefix
- Codex review at every phase boundary

## Never
- Modify packages/harness/cortextos/* except the four kb-* bus overrides
- Modify v1 (/Users/madsadmin/code/intel-force-os/)
- Modify cortextOS upstream (/Users/madsadmin/code/cortex-os-upstream/)
- Add features without a slice in 06-BUILD-PLAN.md
- Skip the Codex ratification step at phase boundaries

## On stuck
docs/build-pack/08-OPEN-DECISIONS.md. If not there, ask the founder; don't guess.
```

Update CLAUDE.md at every phase boundary to reflect the new state.

---

## 10. The Codex ↔ Claude Code loop

Concretely, the ratification ritual at each phase boundary:

```
1. Claude Code finishes the phase's slices, commits.
2. Run /codex-bundle <phase> (slash command from §4.2) → produces docs/codex-bundles/phase-<n>.md
   Contents: git diff for the phase + relevant build-pack sections
3. Paste docs/codex-bundles/phase-<n>.md into Codex (web or CLI)
4. Codex returns a delta document — what's missing, what's weak, what's wrong
5. Open the delta in this Claude Code session
6. Apply the changes — typically a single commit `chore(phase-<n>): codex review delta`
7. Update CLAUDE.md to mark the phase complete
8. Move to next phase
```

The goal is that Codex and Claude Code are in adversarial collaboration. Each catches the other's blind spots. The pack + the slice + the diff form a complete enough artefact for Codex to be useful.

---

## 11. What this section does NOT do

- Doesn't pick which model variant runs Claude Code (Opus vs Sonnet vs Haiku) — that's the founder's call per session
- Doesn't configure remote orchestration (Anthropic Console agent fleets) — out of scope for this build
- Doesn't replace the build pack — this is one of nine files, focused on Claude Code as the tool

---

## 12. The single most important leverage

If you remember one thing from this file: **the wiki-brain skill at `~/.claude/skills/wiki-brain/SKILL.md` is the prior art for the entire Phase 1 brain swap.** Read it before Phase 1 §P1.S3 starts. It will save days of design.
