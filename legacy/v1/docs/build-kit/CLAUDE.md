# Intel Force OS — Project Context

**This file is automatically loaded by Claude Code in every session for this project. Read it first before any task.**

---

## What this project is

**Intel Force OS** is a productised Microsoft Teams app for UK small and medium enterprises (20–200 employees), delivering AI-assisted HR response drafting. The thesis: "everything drafts, nothing sends without you." An employee asks an HR question in Teams; the HR Lead gets an Adaptive Card with a draft reply and approve/edit/reject buttons.

Operating entity: **Intel Force Ltd** (UK). Primary domain: **intelforce.ai**.

The HR agent is the product wedge. The same Teams app will host future agents (Sales, Recruiting) as additional routes without requiring customers to install new apps.

---

## Architecture in 60 seconds

- **Teams app with a bot** — registered via Teams Developer Portal (not Azure Portal)
- **Bot backend** — Cloudflare Workers at `bot.intelforce.ai`
- **Storage** — Cloudflare KV (tenant config) + D1 (audit log)
- **Agent brain** — Relevance AI (existing), called over HTTP from the Worker. Swap for direct Claude API later.
- **Azure footprint** — ONE Entra ID app registration + ONE bot registration + ONE resource group (`intelforce-rg`). No App Service, no Bot Service resource, no Key Vault.
- **Customer side** — zero Azure. They upload the Teams app zip and click admin consent.

**Per-message flow:** employee message → Worker `/api/messages` → Relevance AI call → compose Adaptive Card → send to HR Lead DM → HR Lead taps Approve → Worker posts reply in original thread.

Full architecture: `docs/architecture/01-architecture-overview.md`

---

## Tech stack

| Layer | Tech | Why |
|---|---|---|
| Runtime | Cloudflare Workers | Free tier covers first 20 customers; global edge; no cold starts |
| Language | TypeScript strict | Type safety for Bot Framework protocol quirks |
| Bot SDK | `botbuilder` (npm) | Microsoft's official Node SDK |
| Card rendering | `adaptivecards-templating` | Schema 1.5 — desktop/web/mobile |
| Storage | Cloudflare KV + D1 | KV for config, D1 for audit (SQLite at edge) |
| Secrets | Wrangler secrets | No Key Vault needed |
| Auth | JWT (jose library) | Verify Bot Framework tokens |
| Tests | Vitest | Fast, Workers-compatible |
| Deployment | `wrangler deploy` | One command |
| Agent | Relevance AI (existing) | Existing agent + knowledge base |

---

## Directory layout

```
intel-force-os/
├── CLAUDE.md                    # ← You're reading this
├── .claude/
│   ├── skills/                  # Project-specific skills (loaded on demand)
│   └── commands/                # Slash commands (/deploy, /session-start, etc.)
├── docs/
│   └── architecture/            # The 8-file architecture pack
├── src/
│   ├── index.ts                 # Worker entry
│   ├── bot/                     # Bot Framework handlers + JWT auth
│   ├── cards/                   # Adaptive Card builders (one per card type)
│   ├── agents/                  # External agent clients (relevance.ts)
│   ├── storage/                 # KV + D1 access
│   └── utils/                   # Redaction, error types
├── teams-app/
│   ├── manifest.json
│   ├── color.png
│   └── outline.png
├── migrations/                  # D1 schema migrations
├── onboarding/                  # Per-customer onboarding CLI
├── tests/
└── dist/                        # Build output (git-ignored)
```

---

## Code conventions

**TypeScript:**
- Strict mode, `noImplicitAny: true`, `strictNullChecks: true`
- No `any` types. If you need to widen, propose it to me first with justification.
- Named exports preferred over default exports
- Async/await over promise chains

**File organisation:**
- One concept per file. `src/cards/approval.ts` only builds the approval card, not all cards.
- Pure functions where possible. Side effects (network, storage) concentrated in `src/bot/` and `src/storage/`.
- No circular imports.

**Testing:**
- After any change to `src/`, run `npm run typecheck` and `npm test`
- Do not mark a task complete until both pass
- New business logic needs a test. New Adaptive Cards need a render test.

**Git:**
- Small commits, one slice per commit
- Conventional commit format: `feat:`, `fix:`, `chore:`, `docs:`
- Never commit `.env*` files or wrangler secrets

**Secrets:**
- NEVER log environment variables or secret values
- NEVER commit `.env.local` (already in `.gitignore`)
- Use `wrangler secret put` for production secrets; `.env.local` for dev only

---

## Common commands

```bash
npm run dev              # Run Worker locally with hot reload
npm run typecheck        # TypeScript check
npm test                 # Vitest
npm run deploy           # wrangler deploy to production
npm run deploy:preview   # deploy to preview Worker
npm run package          # build teams-app zip in dist/
npm run tail             # live log stream from production Worker
npm run onboard          # interactive CLI for new customer tenant
npm run offboard         # delete tenant config + audit log
```

Slash commands in Claude Code: `/deploy`, `/tail`, `/session-start`, `/new-customer` — see `.claude/commands/`.

---

## The build is done in vertical slices

| Slice | What | Status |
|---|---|---|
| 1 | Echo bot (Teams → Worker → reply) | [ ] |
| 2 | Relevance AI integration (real drafts) | [ ] |
| 3 | Approval card + approve/edit/reject | [ ] |
| 4 | Audit log + tenant config | [ ] |
| 5 | Escalation flow + weekly reports | [ ] |
| 6 | Manifest, packaging, onboarding script | [ ] |

Each slice ends in something demonstrable. Do not start slice N+1 until slice N's acceptance tests pass.

Current slice: **[UPDATE THIS WHEN MOVING SLICES]**

---

## What to do when you're stuck

1. **Check the architecture pack** — `docs/architecture/` has detailed component designs. §2.1 has the project structure. §2.4 has the full handler pseudocode. Don't invent; reference.

2. **Check Cloudflare docs** — the Cloudflare docs MCP server (configured in this project) is authoritative for Workers/KV/D1 questions. Prefer it over pre-training.

3. **Check Bot Framework docs** — `https://learn.microsoft.com/en-us/azure/bot-service/` for SDK methods. The protocol has quirks; the docs are the ground truth.

4. **Check `docs/architecture/07-claude-code-prompts.md`** — this file contains literal prompts to execute each build stage. If you're mid-stage and confused, go back to the stage prompt.

5. **Fall back to small, verifiable steps** — if a change isn't working, shrink the change. Get a one-line version working, then grow it.

---

## Things Claude Code should NOT do in this project

- Do not install new npm packages without asking first. The dependency list is deliberate; additions need justification.
- Do not create files outside the directory layout above. If you think a new folder is needed, propose it.
- Do not write tests that require external services (real Relevance AI calls, real Microsoft Graph calls). Mock the boundary.
- Do not modify the architecture pack in `docs/`. It's reference. If the design needs changing, surface that as a question.
- Do not remove the "everything drafts, nothing sends" invariant in any code path. Every user-facing reply must go through approval (except for the holding replies for escalations, which are policy-defined).
- Do not log PII (names, emails, message content) at INFO level. Use DEBUG, and redact where possible.

---

## Context for specific areas

### Relevance AI integration
See `.claude/skills/relevance-ai/` for the HTTP contract, expected response shape, retry rules, and fallback behaviour.

### Adaptive Cards
See `docs/architecture/06-adaptive-card-examples.json` for all card templates. Use `adaptivecards-templating` library to expand with data. Test rendering at `https://adaptivecards.io/designer/` when designing new cards.

### Customer onboarding
See `docs/architecture/04-deployment-guide.md` for the 45-minute customer install script. The onboarding CLI in `onboarding/new-tenant.ts` automates the tenant config parts.

### Relevance AI agent configuration
The existing agent lives in the Relevance AI dashboard. The system prompt enforces the structured output format described in `docs/architecture/02-component-design.md` §4.3. Changes to the agent prompt should be tracked in `docs/agent-prompts/` (ASCII copy).

---

## Who to ask for what

- **Architecture questions** → re-read relevant section in `docs/architecture/`
- **Cloudflare questions** → Cloudflare docs MCP (configured in this project)
- **Bot Framework questions** → Microsoft Learn docs (search from within Claude Code)
- **Relevance AI questions** → `.claude/skills/relevance-ai/` skill
- **Brand / copy / pricing** → `docs/gtm-pack/` (the HR Agent GTM Pack files)

---

## Current state (update this as things change)

- Phase 0 (Azure bootstrap): **[Done/In progress/Not started]**
- Phase 1 (Worker scaffold): **[Done/In progress/Not started]**
- Phase 2 (Agent integration): **[Done/In progress/Not started]**
- Phase 3 (Approval flow): **[Done/In progress/Not started]**

Current customer count: **0**  
Current MRR: **£0**  
Target by end of month: **1 paying customer at £400/mo**

---

**When in doubt: the goal is one paying customer, not a perfect codebase. Ship the smallest slice that works. Let customer feedback drive what you build next.**
