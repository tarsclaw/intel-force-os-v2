---
name: intel-force-os
description: Intel Force OS product context — the Teams-first AI HR assistant for UK SMEs. Use this skill whenever you're working on anything related to Intel Force OS including the Worker backend, Adaptive Cards, Teams app manifest, Relevance AI integration, tenant onboarding, customer-facing copy, or architectural decisions. Also triggers on mentions of intelforce.ai, the HR agent, "the product", approval cards, HR Lead flow, escalation handling, or any slice of the build plan.
---

# Intel Force OS Product Context

This skill loads when working on Intel Force OS — the Teams-first AI HR assistant product being built by Intel Force Ltd.

## Product in one paragraph

Intel Force OS is a Microsoft Teams app for UK small and medium enterprises (20-200 employees). It reads HR messages in Teams channels, drafts replies using AI, flags sensitive issues for human handling, and never sends anything without the HR Lead's approval. The core promise: *"everything drafts, nothing sends without you."* First customer tier: £400/month flat (founding), scaling to £450 Starter / £1,800 Growth / £4,500 Scale as the product matures.

## The invariants (never violate these)

1. **Everything drafts, nothing sends without approval.** Every user-facing reply must pass through HR Lead approval, except the carefully-scoped holding messages for escalations. If you find yourself writing code that auto-sends a reply, stop and ask.

2. **Sensitive queries never get AI-drafted answers.** Anything that the agent classifies as sensitivity ≥ 0.7 (grievance, mental health, resignation, harassment) results in a gentle human-written holding message to the employee and an escalation card to the HR Lead. No AI attempt to resolve.

3. **The HR Lead is the trust anchor.** The product serves the HR Lead, not the employee. The HR Lead's confidence in the product is the leading indicator of renewal. Every feature decision should be checked against: "does this make the HR Lead more confident?"

4. **One Teams app, many agents (future).** Whatever you build must fit within a single Teams app called "Intel Force OS." The HR agent is the first capability. Sales agent, Recruiting agent will be added later as additional routes — not separate Teams installs.

5. **Customer side: zero Azure.** Customers upload a Teams app zip and click admin consent. That's it. Any change that would require customers to touch Azure Portal is a non-starter.

6. **Data stays where it should.** Customer data passes through Cloudflare Workers and Relevance AI, but the central audit log (D1) is the source of truth. Customers must be able to export their data (GDPR Art. 15) and delete it (Art. 17) via documented procedures.

## The six vertical build slices

Build in this order. Don't skip, don't parallelise.

| # | Slice | Acceptance test |
|---|---|---|
| 1 | Echo bot | DM the bot in Teams dev tenant; get an echo reply within 3s |
| 2 | Relevance AI integration | DM a real HR question; get a real draft back (not card yet, just text reply) |
| 3 | Approval card + flow | HR Lead sees approval card; tap Approve → reply posts in original thread |
| 4 | Audit log + tenant config | Every message logged in D1; per-tenant config in KV |
| 5 | Escalation + weekly reports | Sensitive queries route to escalation card; Monday morning report card delivers |
| 6 | Manifest + onboarding | Teams app zip builds; `npm run onboard` provisions a new tenant in <5 min |

## The core data flow (commit this to memory)

```
Employee in Teams #hr channel
  ↓ [Bot Framework protocol, JWT signed]
POST /api/messages (Worker)
  ↓ verify JWT, extract tenantId
Load tenant config from KV
  ↓
POST to Relevance AI agent endpoint
  ↓ returns { draft_reply, sensitivity_score, escalation_recommended, ... }
Branch:
  - If escalation_recommended:
      → send holding_reply to employee
      → send escalation_card to HR Lead DM
  - Else:
      → send approval_card to HR Lead DM
Log to D1 audit_log (status = pending_approval)
  ↓
[HR Lead taps Approve]
POST /api/card-action (Worker)
  ↓ verify JWT, get audit record
Post the draft as thread reply in original conversation
Update audit: status = approved, actor = HR Lead AAD ID
```

Variations:
- Edit action: HR Lead provides edited text in `activity.value.editedReply` → post that instead
- Reject action: Post a generic holding message to employee, mark rejected
- Acknowledge action (escalation cards): mark acknowledged, no reply sent (HR Lead handles out-of-band)

## Key architectural decisions and their rationale

Before proposing architectural changes, know why current decisions were made:

| Decision | Why |
|---|---|
| Cloudflare Workers, not Azure App Service | Free tier covers first 20 customers; no cold starts; UK/EU data residency; Claude Code-friendly |
| Bot registration via Teams Dev Portal, not Azure Portal | Dramatically simpler UX; no separate Azure Bot Service resource needed |
| Adaptive Cards, not messaging extensions | Cards work in both channels and DMs; button actions have clean state flow |
| Relevance AI brain, not direct Claude calls (yet) | Relevance AI has the knowledge base + prompt work already done; migrate later if cost justifies |
| Single Entra ID app, multi-tenant | Customer installs scale without per-tenant app registration |
| D1 for audit, not customer SharePoint | Central audit enables cross-tenant analytics; SharePoint is slow + awkward |
| One Intel Force OS Teams app for all agents | Customer installs once, gets all current + future agents |

## Common failure modes to avoid

### Scope creep in Claude Code sessions
If you find yourself building two slices at once, stop. Finish the current slice, commit, open a new session for the next.

### Reimplementing what Relevance AI already does
The agent handles retrieval, prompt versioning, sensitivity classification, handbook citations. The Worker is a thin routing layer. If you're writing classification logic in the Worker, something is wrong.

### Adding Azure resources
The only Azure resources that should exist: one Entra ID app, one bot registration, one resource group (`intelforce-rg`) containing one bot service entry. If a task requires adding another Azure resource, flag it as a scope change.

### Hardcoding customer-specific things
Everything customer-specific goes in `TenantConfig` (loaded from KV per request). Hardcoded email addresses, channel names, or company names in the Worker are bugs.

### Loosening TypeScript types
Use `any` or `as unknown as X` is a smell. Real types exist for Bot Framework activities (`botbuilder` package), for Adaptive Cards, and for Relevance AI responses (define them). If you need to loosen, explain why first.

## Where to look for answers

| Question type | Location |
|---|---|
| Overall architecture | `docs/architecture/01-architecture-overview.md` |
| Specific component implementation | `docs/architecture/02-component-design.md` (organised by component) |
| Azure setup | `docs/architecture/03-azure-bootstrap-via-claude-code.md` |
| Customer install process | `docs/architecture/04-deployment-guide.md` |
| Scaling / Teams App Store / productisation | `docs/architecture/05-productisation-playbook.md` |
| Adaptive Card JSON | `docs/architecture/06-adaptive-card-examples.json` |
| Step-by-step build prompts | `docs/architecture/07-claude-code-prompts.md` |
| Copy, pricing, outreach | `docs/gtm-pack/` |
| Cloudflare API / Workers specifics | Cloudflare docs MCP server (configured) |
| Bot Framework SDK | Microsoft Learn docs (search) |
| Relevance AI contract | `.claude/skills/relevance-ai/SKILL.md` |

## Tone and style for customer-facing copy

When writing any copy that customers will see (welcome cards, error messages, emails, landing page text):

- **Direct, not corporate.** Say "we flagged this" not "the system has identified a matter requiring attention."
- **Trust-building, not hype.** "Drafts every reply. Sends nothing without you." beats "Revolutionise HR with AI."
- **British English.** Colour, organise, favour, licence (noun) / license (verb). Summarise not summarize.
- **No "just".** Avoid "just click here" / "just takes a minute" — sounds diminutive.
- **Human in every message.** Even error cards should feel like a person wrote them. "I couldn't process that — I've flagged it to Maddox" is better than "An error occurred. Please try again later."

## Customer archetype (who we're serving)

**Sarah Chen, 32, HR Lead at Acme Consulting Ltd** — a 60-person professional services firm in Bristol.

Sarah:
- Handles 15-30 HR messages per day across Teams, email, and walk-ups
- Uses Breathe HR for formal records
- Spent 7 years in HR, wants the bot to assist not replace
- Is sceptical of AI; the "nothing sends without you" promise is what gets her to trust it
- Will churn if the draft quality is <70% acceptable or if anything sensitive is auto-sent

Every feature decision should be defensible from Sarah's point of view. If Sarah would ask "why is the bot doing that?" and I can't answer, the feature is wrong.

## When to push back on Maddox

If Maddox (user) asks for something that would:
- Violate an invariant above
- Require adding Azure resources beyond the core three
- Slip the vertical slice discipline (mixing slices, starting slice N+1 before N passes)
- Weaken the "nothing sends without you" promise
- Build more planning/documentation instead of code or customer conversations

...push back. Cite the relevant invariant or architectural decision. Maddox tolerates and rewards honest pushback. The biggest risk to this project is building too much before a customer validates it.
