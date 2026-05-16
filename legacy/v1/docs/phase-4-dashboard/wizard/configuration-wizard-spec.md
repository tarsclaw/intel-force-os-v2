# Configuration Wizard Specification

**The multi-step onboarding flow that takes a new tenant from "we just signed them" to "agents running, webhooks receiving, first proposal drafted within 48 hours."**

> **Audience:** the engineer implementing CC14 (Wizard frontend + backend orchestration) and the operator who'll run the wizard on new tenants.
>
> **Status:** v1.0. Lives at `apps/dashboard/src/app/admin/wizard/`. Submits to the Provisioning System.
>
> **Operator-first, not self-serve.** The Wizard is built to be run by an IntelForce operator (or an agency partner's operator) for their client — not by the end-tenant themselves. v1 onboarding is high-touch. Self-serve might come later; it's not a priority.

---

## 1. Purpose and scope

The Wizard is the critical interface between "sales close" and "agents running." Everything wrong with v1 onboarding either lives in the Wizard (too many steps, bad defaults, unclear copy) or shows up as a bad first week. Get this right and the rest of the product reads well; get this wrong and every later view inherits the fallout.

### 1.1 What the Wizard does

1. Collects tenant metadata (name, plan, industry, etc.)
2. Selects which agents to enable (gated by plan tier)
3. Configures each agent with tenant-specific fields
4. Collects secret material (API keys, OAuth connections)
5. Validates the full config
6. Submits to the Provisioning System's `TenantOnboard` workflow

### 1.2 What the Wizard does NOT do

- Does NOT run agents directly — it sets them up; the Provisioning System executes
- Does NOT collect payment — Stripe portal handles that via a separate link (Phase 5)
- Does NOT onboard sub-tenants for agencies — that's a different flow (`agencies.addSubTenant` in the tRPC router, which re-uses the Wizard component but scoped to the parent agency)

### 1.3 Duration

Target: **30 minutes end-to-end** for a typical Growth-tier tenant, not including the async OAuth steps.

OAuth steps (HubSpot, Gmail, Slack, etc.) happen at the end. They can take hours to days depending on who the admin is on the tenant side. The Wizard handles async gracefully: operator submits, Wizard says "pending OAuth from the client — we'll email you when they're done."

---

## 2. Wizard structure

The Wizard is a **stepped form** with live validation and resumable drafts.

### 2.1 Steps

| # | Step | Collects |
|---|---|---|
| 1 | **Tenant basics** | Client name, slug, industry, website, primary owner email, timezone, currency |
| 2 | **Plan & agents** | Plan tier (Starter/Growth/Scale/Enterprise); which agents to enable (tier-gated); cost budget |
| 3 | **Voice profile** | Upload 5–20 writing samples OR point to existing URLs; agent will extract the profile async |
| 4 | **Brand & positioning** | Services offered, pricing range, ICP (who we're selling to), positioning statement, suppression list (optional) |
| 5 | **Per-agent config** | Only for enabled agents; dynamically rendered from each agent's `config.schema.json` |
| 6 | **Integrations** | Select providers (Fathom, HubSpot, Gmail, Stripe, GA4, etc.); API keys and OAuth placeholders |
| 7 | **Review & submit** | Full config summary, validation result, "submit" button |
| 8 | **OAuth handoff (async)** | Shows pending integrations with connect buttons; waits for tenant admin to complete |
| 9 | **Provisioning status** | Real-time status of the Provisioning System workflow; confirms tenant live |

Steps 1–6 are editable in any order (you can go back). Step 7 locks editing until you come back from submit. Step 8 is async and may take hours/days. Step 9 is a status page.

### 2.2 Navigation

Left-rail step indicator showing progress. Each step has:
- Title
- Subtitle (one-liner description)
- Icon
- Status dot (not started / in progress / valid / has errors / submitted)

Main content area for the current step's form. Sticky footer with:
- "Back" (disabled on step 1)
- "Save draft" (always visible; auto-saves also happen every 30s)
- "Next" (primary) — enabled only when current step is valid

Keyboard: `⌘/Ctrl + Enter` submits current step and advances.

---

## 3. Persistence & drafts

### 3.1 Draft model

Each Wizard run is a `WizardDraft` stored in `control.wizard_drafts`:

```sql
CREATE TABLE control.wizard_drafts (
  id            text PRIMARY KEY,                     -- wd_01JKDY...
  created_by    text NOT NULL,                        -- Clerk user ID
  agency_id     text REFERENCES control.tenants(id),  -- if an agency is onboarding a sub-tenant
  current_step  integer NOT NULL DEFAULT 1,
  draft_data    jsonb NOT NULL DEFAULT '{}'::jsonb,   -- partial tenant-config-to-be
  submitted_at  timestamptz,                          -- null if in progress
  tenant_id     text,                                 -- set after submission
  workflow_id   text,                                 -- Temporal workflow ID
  created_at    timestamptz NOT NULL DEFAULT now(),
  updated_at    timestamptz NOT NULL DEFAULT now()
);
```

Drafts are visible at `/admin/wizard` (list of in-progress drafts). Operators can resume any draft they own or any draft in their org.

### 3.2 Auto-save

Every 30s + on blur of any form field. Uses `wizard.saveStep` tRPC procedure. Saves partial data even if the current step is invalid (we don't block the save on validation).

### 3.3 Draft TTL

Drafts expire after 30 days of no activity. Reminder email sent at 14 and 28 days.

---

## 4. Each step in detail

### 4.1 Step 1 — Tenant basics

```
Client name: [__________________________]  required
Client slug: [__________________________]  required — used in URLs; auto-generated from name with "edit" affordance
Legal name (optional): [________________]
Industry: [dropdown: dentistry, law, accounting, ...]
SIC code (optional): [___]
Website: [__________________________]
Owner email: [__________________________]  required — becomes the tenant's first admin user
Currency: [GBP] [EUR] [USD]  default GBP
Timezone: [Europe/London ▼]  default based on IP
VAT treatment: [ex-VAT] [inc-VAT] [no VAT]  default ex-VAT (UK B2B norm)
```

Validation: all required fields non-empty; slug uniqueness checked via tRPC async validator; email format; website valid URL.

### 4.2 Step 2 — Plan & agents

Plan cards: Starter / Growth / Scale / Enterprise — clickable cards with what's included.

Below, the agent list. Each agent is a toggleable row:
- Checkbox to enable
- Agent name + icon
- Short description
- "Tier required" badge if not in selected plan (disabled state)

Cost budget field: default per plan (Starter £150, Growth £550, Scale £1,200, Enterprise custom); editable within reasonable bounds.

Budget mode: `soft_alert` (default) or `hard_stop` (for paranoid clients). Hard-stop requires step-up on submit.

### 4.3 Step 3 — Voice profile

Two input modes:

**Mode A — Upload samples**
- Drag-drop area accepting .txt, .md, .docx, .pdf
- Minimum 5 samples, up to 20
- Each sample > 500 characters
- Previews show after upload
- On submit, samples go to a voice-profile-extraction job (async; runs overnight; produces `/vault/brand/voice-profile.md`)

**Mode B — Link to existing**
- Free-text field for URLs (blog posts, published articles, etc.)
- Platform fetches them; if one fails, operator sees an error next to the specific URL
- Same minimum (5)

The step shows the user an explicit commitment: "We'll build a voice profile from these. It will take up to 24 hours. You can review and adjust it in the Brand view after it's ready."

### 4.4 Step 4 — Brand & positioning

This step writes `/vault/brand/*.md` files to the new tenant's vault at provisioning time.

Sections:
- **Services** — free-text list of services offered + pricing range per service
- **ICP** — ideal customer profile (who they sell to)
- **Positioning** — one-paragraph statement
- **Suppression list** (optional) — email domains/patterns to exclude from Lead Hunter
- **Banned phrases** (optional) — phrases the client specifically dislikes; enforced by every content agent

Every field has good defaults for the selected industry (e.g., "dentistry" pre-fills ICP language about patient demographics, services about common dental offerings). Operator edits inline.

### 4.5 Step 5 — Per-agent config

Only shows for agents enabled in Step 2. Each agent's config is rendered dynamically from its `config.schema.json` file (see Phase 2 agent bundles).

Example — Proposal Builder:
- Minimum contract value (numeric, default £1,500/month)
- Minimum setup fee (numeric, default £3,000)
- Preferred proposal length (short / medium / long)
- Retrieval tag for past proposals (default: `proposal-template`)

Layout: one accordion panel per agent, collapsible. Operator can work through them sequentially or skip ones with safe defaults.

### 4.6 Step 6 — Integrations

Grid of integration cards. Each shows:
- Provider logo
- Required-vs-optional badge (some agents require specific integrations)
- Status: `not set up` / `ready to connect`
- Action: "Connect" (for OAuth) or "Enter API key" (for static keys)

For static API keys:
- Modal with:
  - API key input (password-type, with "show" toggle)
  - "Where to find this" help link
  - Optional: base URL field (for self-hosted providers)
- On save: key sent to Secrets Vault, `integration` row created with `status='active'` and `last_verified_at=null`

For OAuth:
- Operator clicks "Connect"
- Dashboard navigates to OAuth consent URL (after `integrations.beginOauth` returns it)
- Tenant admin completes OAuth (could be operator themselves if they have tenant access, or the real tenant admin if they don't)
- On callback, integration marked active

**Critical UX:** the integration step doesn't block the Wizard from submitting. Integrations can be in `pending_oauth` state when the Wizard submits. The OAuth handoff (Step 8) happens after submission.

### 4.7 Step 7 — Review & submit

Summary of everything collected across previous steps. Read-only rendering:
- Tenant identity block
- Plan + cost budget
- Enabled agents (count and list)
- Voice profile status (uploading or linked)
- Integrations (with connected/pending status)

Validation panel at top shows:
- ✅ Green: "Ready to submit"
- 🟠 Orange: "X items need attention before submit" (with jump-links back to the specific step)
- 🔴 Red: "Blocking errors — cannot submit"

Submit button:
- Enabled when no blocking errors
- Confirms with a modal: "This will provision the tenant. Irreversible action requires you to type the client slug to confirm."
- On confirm: calls `wizard.submit` → Provisioning System → kicks off `TenantOnboard` workflow

### 4.8 Step 8 — OAuth handoff (async)

Post-submit page. Grid of integrations that need OAuth from the tenant admin:
- Each row: provider name, "Send invitation" button (emails the tenant admin a magic link)
- Status for each: `not sent` / `invitation sent` / `in progress` / `connected`

Once all OAuth is complete, the Provisioning System workflow proceeds automatically. The dashboard shows "All integrations connected. Finalising setup..."

### 4.9 Step 9 — Provisioning status

Real-time view of the `TenantOnboard` workflow. Shows each step:

- `generate_tenant_id` ✅
- `create_postgres_tenant_role` ✅
- `create_pgvector_schema` ✅
- `seed_secrets_vault` ✅
- `create_github_vault_repo` ✅
- `register_webhook_endpoints` ✅
- `oauth_handoff` ✅
- `wait_for_oauth_completion` ✅
- `run_preflight_checks` 🔄 in progress
- ...

Data via `provisioning.streamWorkflow` SSE subscription. Completed steps show a green check + duration. Failed steps show an "X" with error message and a "Retry activity" button.

On success, banner says "Tenant live! View it at [/t/meadowlane-dental]."

---

## 5. Validation

Three layers, matching the tRPC pattern:

1. **Client-side** (React Hook Form + Zod) — instant feedback as the user types
2. **Server-side step validation** (`wizard.saveStep`) — prevents invalid data from being saved
3. **Server-side full-config validation** (`wizard.validate`) — cross-step checks (e.g., "Proposal Builder is enabled but no minimum contract value provided")

Same Zod schemas on both sides. One source of truth.

### 5.1 Cross-step validation rules

- Enabled agents must match plan tier
- Agents with `required: true` integrations in their `tools.yaml` must have those integrations configured
- Voice profile must have samples (either upload or URLs)
- Cost budget must be > sum of enabled agents' minimum operational costs (usually £40–£100 floor)
- Suppression list domains must be valid domain format

### 5.2 Warnings vs errors

- **Errors** block submission (red; must fix)
- **Warnings** don't block but encourage attention (yellow; acknowledge to submit)

Example warning: "ICP description is very short (12 words). This may affect Lead Hunter quality."

---

## 6. Error recovery

### 6.1 Network / save failures

Every auto-save shows a subtle status indicator: "Saving..." / "Saved" / "Save failed — retry". On failure, the form holds local state; user can retry or continue editing.

### 6.2 Slug collision

Slug uniqueness is an async validation. If another tenant grabs the slug between draft creation and submit, submit fails with a clear message: "Slug `meadowlane-dental` is now taken. Please choose another."

### 6.3 Provisioning failure

If `TenantOnboard` workflow fails, Step 9 shows the failing step and the error. Operator can:
- Retry the failing activity
- Abort the workflow (triggers compensations; returns to Step 7 with a draft)
- Escalate to engineering (opens a support ticket with workflow ID pre-filled)

---

## 7. Permissions

- `platform_admin`, `platform_operator` can start/submit Wizards for any tenant
- `agency_admin` can start/submit Wizards for sub-tenants under their agency only
- `platform_readonly` can view drafts but not edit or submit
- `tenant_*` cannot access the Wizard at all (it's operator-only)

---

## 8. Accessibility

- Every form field has an explicit label
- Error messages are announced via `aria-live="polite"`
- Required fields announced via `aria-required="true"`
- Step progress announced when changing steps (`aria-live="polite"` on step indicator)
- Keyboard navigation end-to-end (no mouse required)
- Focus managed correctly when errors appear (focus moves to first errored field)

---

## 9. Analytics

Wizard emits events to our analytics pipeline (Phase 6):

| Event | Properties |
|---|---|
| `wizard_started` | `agency_id?`, `operator_id` |
| `wizard_step_completed` | `draft_id`, `step`, `durationSec`, `fieldsFilled` |
| `wizard_step_abandoned` | `draft_id`, `step` (tracked on draft expiry without submit) |
| `wizard_validation_error` | `draft_id`, `step`, `field`, `errorCode` |
| `wizard_submitted` | `draft_id`, `tenant_id`, `durationSec` (full Wizard duration) |
| `wizard_oauth_completed` | `tenant_id`, `integration`, `durationFromSubmitSec` |
| `wizard_provisioning_failed` | `tenant_id`, `activity`, `error` |
| `tenant_first_agent_run` | `tenant_id`, `agent`, `durationFromOnboardSec` |

These let us optimise the Wizard based on real data: which steps take longest, where operators abandon, which integrations cause delays.

---

## 10. Metrics and SLAs

| Metric | Target |
|---|---|
| Median Wizard completion time (steps 1–7) | < 20 minutes |
| P95 Wizard completion time | < 45 minutes |
| OAuth-handoff to completion (median) | < 2 hours |
| Tenant onboard to first agent run (median) | < 24 hours |
| Wizard abandonment rate (started but not submitted within 30 days) | < 10% |

Missing a target → the Wizard gets a revision. These metrics are the primary input for v1.x iterations.

---

## 11. Implementation checklist (for CC14)

- [ ] Wizard page scaffolded at `/admin/wizard` with step navigation
- [ ] `wizard.*` tRPC procedures per §5.9 of router spec
- [ ] `control.wizard_drafts` table (add to Phase 3 schema — small addendum migration)
- [ ] Each step's form built with React Hook Form + Zod
- [ ] Dynamic rendering of per-agent config from `config.schema.json`
- [ ] Secrets Vault integration for API key storage
- [ ] OAuth handoff flow with invitation emails
- [ ] SSE subscription to provisioning workflow status
- [ ] Auto-save every 30s
- [ ] Draft list view at `/admin/wizard/drafts`
- [ ] Analytics instrumentation
- [ ] E2E Playwright test: full happy path, submit, mock OAuth, workflow success
- [ ] E2E test: workflow failure, retry activity

---

## 12. What's deferred to Wizard v1.1

- **Self-serve mode** — tenants complete their own Wizard with guardrails
- **Template tenants** — "clone from existing" to seed a new tenant with another tenant's config (useful for agency partners with similar sub-tenants)
- **Onboarding checklist email** — pre-Wizard email with everything needed to complete (samples, integration credentials, etc.) so the Wizard session is fast
- **Wizard analytics dashboard** — operator-facing view of completion metrics, drop-off rates, etc.

---

## 13. Related

- `api/trpc-router-spec.md` §5.9 (wizard procedures) and §5.8 (provisioning)
- `phase-3-platform/provisioning/provisioning-system-spec.md` — what happens after submit
- Phase 2 agent bundles' `config.schema.json` files — what each agent collects
- `phase-3-platform/secrets/secrets-vault-spec.md` — where secrets go
