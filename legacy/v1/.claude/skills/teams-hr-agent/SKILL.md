---
name: teams-hr-agent
description: Intel Force OS Teams HR Agent — the current v1 build target. Use this skill whenever working on the Teams bot, Cloudflare Worker, Adaptive Cards, Teams app manifest, per-customer onboarding, Relevance AI integration inside the Worker, the six build slices, or anything in docs/teams-hr-agent/. Also triggers on: Teams, Bot Framework, messaging endpoint, approval card, escalation card, HR Lead DM, build stage A/B/C/D/E/F/G/H/I/J/K/L.
---

# Teams HR Agent — v1 Build Skill

This skill is active when you're building the Teams HR Agent, which is the current v1 target.

## Where the spec lives

All architecture is in `docs/teams-hr-agent/`:

| File | When to read it |
|---|---|
| `README.md` | Orientation; read once at start of any Teams work |
| `01-architecture-overview.md` | When making architectural decisions or explaining to prospects |
| `02-component-design.md` | When implementing any component (organised by component for lookup) |
| `03-azure-bootstrap-via-claude-code.md` | When running the 30-min Azure setup (Stage B) |
| `04-deployment-guide.md` | When installing for a customer |
| `05-productisation-playbook.md` | When planning beyond v1 (month 4+) |
| `06-adaptive-card-examples.json` | When implementing any card (has all templates) |
| `07-claude-code-prompts.md` | When running a specific build stage — literal prompts |

**Read the specific section you need, not the whole file.** Section numbering is consistent — e.g. `02 §2.4` is the handler pseudocode; `02 §6.1` is the D1 schema.

## The six vertical build slices

Do these in order. Finish one, commit, then start the next. Never mix.

| # | Slice | Acceptance test | Spec reference |
|---|---|---|---|
| 1 | Echo bot | DM the bot in dev tenant; get echo reply | `02 §2` + `03` |
| 2 | Relevance AI integration | DM gets real draft back as text reply | `02 §4` |
| 3 | Approval card + flow | Card appears in HR Lead DM; Approve posts reply | `02 §3` + `06` |
| 4 | Audit log + tenant config | KV has per-tenant config; D1 logs every message | `02 §5` + `02 §6` |
| 5 | Escalation + weekly reports | Sensitive queries route correctly; Monday cron works | `02 §3.2` + `02 §7.3` |
| 6 | Manifest + onboarding | Customer install script runs end-to-end | `04` + Stage K prompts |

## The architecture in 8 lines

```
Employee in Teams → bot messaging endpoint (POST /api/messages)
  → Cloudflare Worker
    → verify JWT (Bot Framework auth)
    → load tenant config (Cloudflare KV)
    → call Relevance AI agent (HTTP)
    → compose Adaptive Card
    → send to HR Lead DM (proactive message)
    → log to D1 audit
[HR Lead taps Approve] → /api/card-action → post reply in original thread
```

Full detail: `docs/teams-hr-agent/01-architecture-overview.md` §4.2

## Core components and their files

| Component | Worker file | Spec section |
|---|---|---|
| Worker entry | `src/index.ts` | `02 §2.3` |
| Bot message handler | `src/bot/handler.ts` | `02 §2.4` |
| JWT verification | `src/bot/auth.ts` | `02 §2` + `02 §11` |
| Proactive messaging | `src/bot/proactive.ts` | `02 §7` |
| Approval card | `src/cards/approval.ts` | `02 §3.1` + `06 approval_card` |
| Escalation card | `src/cards/escalation.ts` | `02 §3.2` + `06 escalation_card` |
| Weekly report card | `src/cards/report.ts` | `02 §3.3` + `06 weekly_report_card` |
| Config card | `src/cards/config.ts` | `06 config_card` |
| Welcome card | `src/cards/welcome.ts` | `06 welcome_card` |
| Error card | `src/cards/error.ts` | `06 error_card` |
| Relevance AI client | `src/agents/relevance.ts` | `02 §4` (see also `.claude/skills/relevance-ai/`) |
| Tenant config | `src/storage/config.ts` | `02 §5` |
| Audit log | `src/storage/audit.ts` | `02 §6` |
| PII redaction | `src/utils/redact.ts` | `02 §6.2` |
| D1 schema | `migrations/0001_initial.sql` | `02 §6.1` |
| Teams manifest | `teams-app/manifest.json` | `02 §1` |

## The key design decisions (don't litigate these without a reason)

From `docs/teams-hr-agent/01-architecture-overview.md` §5:

1. **Cloudflare Workers, not Azure App Service** — free tier + no cold starts
2. **Teams Dev Portal bot registration, not Azure Portal** — simpler UX
3. **Adaptive Cards as primary UI** — richer than plain text
4. **Relevance AI stays as brain** — don't reimplement agent logic
5. **Single Entra ID app, multi-tenant** — no per-customer registration
6. **D1 for audit, not customer SharePoint** — central, queryable
7. **One Intel Force OS Teams app** — all agents share the install

If someone proposes reversing any of these, the conversation needs spec-level justification (not just preference). Direct them to `01 §5`.

## Common patterns

### Adding a new Adaptive Card
1. Add template JSON to `06-adaptive-card-examples.json`
2. Create `src/cards/{name}.ts` following existing card modules
3. Define typed Data interface matching the `_template_data_shape`
4. Use `adaptivecards-templating` library's `Template.expand()`
5. Test render at https://adaptivecards.io/designer/ before wiring up
6. Add usage in handler (either `handleBotMessage` or card action)

### Adding a new slash command to the manifest
1. Update `teams-app/manifest.json` `commandLists`
2. Bump manifest version (e.g. 1.0.0 → 1.0.1)
3. Add handler branch in `src/bot/handler.ts` (before the Relevance AI call)
4. Test locally with `wrangler dev`
5. Repackage: `npm run package`
6. Customers need to re-upload manifest — flag as upgrade required

### Onboarding a new customer
See `docs/teams-hr-agent/04-deployment-guide.md` §3 for full 45-min runbook.
Key commands:
```bash
npm run onboard    # interactive tenant provisioning
# During install call: IT admin uploads manifest zip + clicks consent
# HR Lead sees welcome card; smoke tests run
```

### Debugging a tenant
```bash
# Check tenant config exists
wrangler kv:key get --binding=TENANT_CONFIG "tenant_config:{tenantId}"

# Check recent audit log
wrangler d1 execute intel-force-audit --command \
  "SELECT * FROM audit_log WHERE tenant_id = '{tenantId}' ORDER BY id DESC LIMIT 10"

# Watch live traffic
wrangler tail --format json | jq 'select(.tenantId == "{tenantId}")'
```

## Gotchas (things that bit past sessions)

### JWT audience mismatch
Bot Framework JWTs have specific audience claims. The `verifyJWT` function must check audience is `env.MICROSOFT_APP_ID`, not the bot framework generic claim. Wrong audience = bot receives messages but can't authenticate itself for replies.

### Proactive messaging requires conversation reference
You can't DM a user from the bot without first capturing a conversation reference (from a `conversationUpdate` activity when bot was added, OR from any prior message in that conversation). Store in KV at `hr_lead_conversation:{tenantId}:{aadObjectId}`.

### Cloudflare Workers 10ms CPU free tier
Relevance AI calls take 1-3s. That exceeds free tier CPU time. **Paid plan ($5/mo) required from customer 1.** Don't deploy to free tier and wonder why requests time out.

### Adaptive Card templating data
`adaptivecards-templating` uses `${variable}` syntax. Data shape must match `_template_data_shape` in `06-adaptive-card-examples.json` exactly. Missing fields render as `${fieldName}` literal in the card — looks like a bug to the user.

### D1 migrations are not automatic
After a schema change:
```bash
wrangler d1 execute intel-force-audit --file=migrations/000N_whatever.sql
```
If skipped, new code expects columns that don't exist → runtime errors.

### Secrets are per-environment
`wrangler secret put FOO` only affects production by default. For preview: `wrangler secret put FOO --env=preview`. Staging environments need their own secret values.

## The "never do" list

- Never auto-send a reply to an employee without approval (except holding messages for escalations)
- Never log PII at INFO level — use DEBUG and redact
- Never modify `docs/teams-hr-agent/` files during implementation (they're the spec)
- Never commit `.env.local` or Wrangler secret values
- Never deploy without `npm run typecheck && npm test` passing
- Never install new npm packages without asking Maddox first
- Never skip a build slice
- Never attempt Stage F before E works, etc.

## When to cross-reference other skills

- **Working with Relevance AI specifically?** → `relevance-ai` skill
- **Designing a card?** → `adaptive-cards` skill
- **Bot Framework protocol question?** → `bot-framework-teams` skill
- **Cloudflare-specific (Workers/KV/D1)?** → `cloudflare-intel-force` skill
- **GTM / customer / pricing context?** → `gtm-execution` skill
- **Scaling beyond v1 (Postgres, etc.)?** → `phase-3-platform` skill

## The parallel commercial track

Building the Teams HR Agent doesn't happen in isolation. In parallel:
- Prospects being contacted (see `gtm-execution` skill)
- Demos being given (can use dev tenant + screen-share)
- First customer being closed
- Legal docs ready per customer (`phase-5-business-legal` skill)

If a session spends 3+ hours on code without any commercial activity that day, flag it as drift.
