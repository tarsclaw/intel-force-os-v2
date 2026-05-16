# Settings View Specification

**Where tenants manage the "boring-but-critical" surface of their account: integrations, secrets, billing, team, API keys, and tenant configuration.**

> **Audience:** engineer implementing CC18 (Settings). Operators and tenant owners who live in this view less often than Operations but whose changes matter more.
>
> **Status:** v1.0. Lives at `/t/[tenantSlug]/settings` with sub-routes per panel. Operator-mirror at `/admin/tenants/[tenantId]/settings`.
>
> **Design stance:** every setting change is a material business event (money, data access, security). Every mutation is confirmed, audited, reversible where possible, and gated by role.

---

## 1. Purpose

The Settings view answers:

1. Which integrations are connected? Are any broken?
2. What secrets exist, when were they last rotated, when do they expire?
3. What am I being billed? When's the next invoice?
4. What's in my tenant configuration — name, budget, timezone?
5. Who has access to my tenant? What role?
6. What API keys exist for programmatic access?
7. How am I notified about escalations?

Seven panels, one view.

---

## 2. Layout

Desktop (`≥ 1024px`):

```
┌─────────────────────────────────────────────────────────────────────┐
│  Tenant chrome                                                       │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  Settings                                                           │
│                                                                      │
│  ┌──────────────┬───────────────────────────────────────────────┐  │
│  │  SIDEBAR     │  PANEL                                         │  │
│  │              │                                                │  │
│  │  Integrations│  Integrations                                  │  │
│  │  Secrets     │                                                │  │
│  │  Billing     │  Connected (4)                                 │  │
│  │  Config      │  ┌──────────────────────────────────────────┐  │  │
│  │  Team        │  │ Fathom    ✅ active  last verified 2m ago│  │  │
│  │  API keys    │  │ HubSpot   ✅ active  OAuth expires in 54d│  │  │
│  │  Notifications│  │ Gmail     ✅ active  OAuth expires in 12d│  │  │
│  │              │  │ Stripe    ✅ active  last verified 1h ago│  │  │
│  │              │  └──────────────────────────────────────────┘  │  │
│  │              │                                                │  │
│  │              │  Available (7 more)                            │  │
│  │              │  [+ Connect integration]                       │  │
│  └──────────────┴───────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

Mobile: sidebar becomes a top tab-bar.

URL structure:
- `/t/[slug]/settings` → redirects to `/t/[slug]/settings/integrations` (default panel)
- `/t/[slug]/settings/secrets`, `.../billing`, etc.

---

## 3. Panel 1 — Integrations

### 3.1 Connected list

One card per integration with:
- Provider logo + name
- Status badge: `active` (green), `error` (red), `pending_oauth` (amber), `disabled` (neutral)
- Last verified timestamp (relative)
- Next expiry (for OAuth; e.g., "OAuth refreshes automatically, renews every 60 days")
- Actions: `Test connection`, `Reauthorise`, `Disable`, `View details`

Card hover reveals:
- Scopes granted (OAuth)
- Which agents depend on this integration
- Link to the last error (if `status=error`)

### 3.2 Available integrations

Below connected list. Grid of provider cards for integrations that support this tenant's plan but aren't connected. Each:
- Provider logo
- Short description ("Call transcription and summaries")
- `Connect` button
- Required-for-agents badge (e.g., "Required by Proposal Builder")

Clicking `Connect` runs the same OAuth or API-key-input flow as the Wizard's step 6.

### 3.3 Error states

When an integration has `status='error'`:
- Red banner at top of panel: "2 integrations need attention"
- Affected cards are expanded by default showing the last error
- Specific remediation suggested: "Gmail token expired. [Reauthorise]"

### 3.4 Test connection

Calls `integrations.testConnection`. Ping the provider's API:
- Success: toast "Fathom responded in 142ms"
- Failure: surfaces error message + timestamps it

Useful after making provider-side changes (e.g., adding a new Gmail user).

### 3.5 Disable vs disconnect

- **Disable** — stops the integration from firing but preserves secrets (can re-enable instantly). Use when pausing.
- **Disconnect** — removes secrets, revokes OAuth at provider, re-connect requires full OAuth dance again. Step-up required.

Most users want "disable." The product nudges toward disable; disconnect is behind a "more actions" menu.

---

## 4. Panel 2 — Secrets

### 4.1 Purpose

Inventory of every secret this tenant has. Never shows values — only refs and metadata.

### 4.2 Table

| Column | Content |
|---|---|
| Ref | e.g., `secrets://tnt_xxx/fathom/api_key` (truncated; hover for full) |
| Kind | `api_key`, `oauth_token`, `webhook_secret`, `deploy_key` |
| Status | `active`, `rotating`, `revoked`, `expired` |
| Last rotated | Relative time |
| Next rotation | Relative time or "manual" |
| Last accessed | Relative time (helpful for detecting unused secrets) |
| Actions | `Rotate now`, `Revoke`, `View history` |

### 4.3 Rotation

`Rotate now` button:
- For auto-rotatable secrets (webhook secrets, platform-level API keys): triggers the rotation scheduler immediately; toast on success
- For manual-rotation secrets (provider API keys): opens a guide — "1. Go to provider's dashboard, 2. Generate new key, 3. Paste it here" with a secure input field

Step-up MFA required for any rotation.

### 4.4 Emergency rotation

Above the table, a subtle link: "Rotate all secrets for this tenant — emergency only". Triggers the `secrets.rotateAllEmergency` procedure (Phase 3 Secrets Vault §6.4). Requires step-up + two-person approval (platform admins only for tenant-scope; tenant owners can trigger for their own tenant).

### 4.5 History

`View history` opens a drawer showing every rotation/revocation event for this secret. Useful for:
- "When did we last rotate this?"
- "Did rotation succeed on $date?"

---

## 5. Panel 3 — Billing

### 5.1 Overview

- Current plan (Starter / Growth / Scale / Enterprise) with feature list link
- Current month spend: £243 of £550 budget (with progress bar)
- Next invoice date and expected amount
- Payment method on file (masked last 4 digits of card OR bank details)

### 5.2 Change plan

`Change plan` button:
- Opens a modal with plan tiers and their features
- On select, triggers `TenantReprovision` with new plan
- Reprovisioning enables/disables agents according to tier (per Phase 3 provisioning spec)
- Clear copy: "Upgrading to Scale will enable 2 additional agents. Downgrading to Starter will disable Lead Hunter, Content Creator, Repurposer, Follow-Up Pilot — their historical output stays; they just stop running."

Downgrade is allowed but warned. Destructive changes to agents (disabling) go through the normal reprovision flow.

### 5.3 Invoices

List of past invoices (from Stripe):
- Invoice number, date, amount, status (paid / due / overdue)
- PDF download
- Link to Stripe-hosted payment page for unpaid

### 5.4 Payment method

`Manage payment method` button opens Stripe's hosted portal in a new tab. We don't build a payment-method-editing UI — Stripe's is battle-tested, PCI-compliant, and their problem.

### 5.5 Budget

Budget controls:
- Slider + numeric input for GBP amount
- Mode toggle: `Soft alert` (Slack warning at 80%, continue running) or `Hard stop` (agents stop at 100%)
- Change to hard stop requires step-up MFA

Clear explainer: "Budget is per calendar month. Resets 1st of each month."

---

## 6. Panel 4 — Config

### 6.1 Editable fields

These fields can be updated without reprovisioning:

- Client name (display only; not the slug)
- Support email
- Billing email
- Timezone
- VAT treatment
- Website URL
- Cost budget + mode (mirrors what's in Billing panel; edit in either place)

### 6.2 Read-only fields (with "Contact support to change")

- Client slug (changing it means URL changes, vault repo rename, webhook URL changes — possible but operator-only)
- Plan tier (use Billing panel)
- Enabled agents (triggers reprovisioning — use a dedicated "Agents" sub-panel; covered in §6.3)
- Tenant ID (stable; not user-visible anyway)

### 6.3 Agents sub-panel

List of all agents available at this tier with toggles. Changes queue into a pending reprovision:

```
Proposal Builder      [ON]  ✓ enabled
Lead Hunter           [ON]  ✓ enabled
Content Creator       [OFF] → will be enabled
Repurposer            [ON]  ✓ enabled
...

[3 changes pending]  [Review and apply]
```

`Review and apply` opens a confirmation modal summarising changes, cost implications ("Content Creator typically costs £15–£30/month"), and kicks off reprovisioning.

### 6.4 Voice profile

Read-only view of `/vault/brand/voice-profile.md`. With a button to request regeneration:

`[Regenerate voice profile]` — triggers the voice-profile-extraction job against the current samples. 24-hour SLA. Used when tenant has added new writing samples.

Adding samples: drag-drop area same as Wizard step 3. Samples stored in `/vault/brand/voice-samples/`.

### 6.5 Brand & positioning

Read-only view of `/vault/brand/positioning.md`, `/vault/brand/services.md`, `/vault/brand/icp.md` etc. — the files the Wizard step 4 writes. An `Edit in Obsidian` link that opens Obsidian via custom URL scheme (`obsidian://open?vault=...`). Non-Obsidian users can edit via a simple in-browser text editor with a big warning: "Changes here are committed to your vault. Use Obsidian for better editing."

---

## 7. Panel 5 — Team

### 7.1 Member list

Table of users with access to this tenant:

| Name | Email | Role | Added | Last active | Actions |
|---|---|---|---|---|---|
| Priya Sharma | priya@... | Owner | 2026-02-10 | 2m ago | — (can't remove self via UI) |
| Jack Rigby | jack@... | Member | 2026-02-15 | 3d ago | Edit role / Remove |

Roles: `Owner`, `Member`, `Viewer`.

### 7.2 Invite

`Invite member` button opens a modal:
- Email input
- Role radio
- Custom welcome message (optional)
- Sends Clerk invitation (per auth spec §7)

### 7.3 Role changes

- Owner → Member/Viewer: allowed; another owner must exist first
- Member → Owner: requires step-up
- Member → Viewer: allowed
- Remove member: confirmation + step-up for Owner removal

At least one Owner must exist at all times. UI prevents removing the last owner.

### 7.4 Impersonation settings (tenant-owner only)

Toggle: "Require my explicit approval for support access" (per auth spec §8.3).

List of recent support sessions:
- Operator name, timestamp, duration, actions taken summary
- "Revoke session" (if still active)

---

## 8. Panel 6 — API Keys

### 8.1 List

Table:

| Key prefix | Scope | Created | Last used | Actions |
|---|---|---|---|---|
| `intel_live_4tgx...` | read:all | 2026-03-01 | 4h ago | Revoke |
| `intel_live_9kzw...` | read:costs, read:invocations | 2026-03-15 | never | Revoke |

Values never shown. Only prefixes (first 12 chars).

### 8.2 Generate

`Generate key` button:
- Modal with scope checkboxes
- On submit: key appears ONCE, with copy button and warning: "This is the only time you'll see this key. Store it securely."
- After closing the modal: only the prefix is stored/shown

Step-up required.

### 8.3 Scopes

- `read:all` — broad read
- `read:costs`
- `read:invocations`
- `read:escalations`
- `write:escalations` (resolve, won't-fix)
- `write:settings` (limited to integration disable/reauthorise)

Max 5 keys per tenant. Contact support to raise limit.

---

## 9. Panel 7 — Notifications

### 9.1 Slack

Per-tenant webhook URL for escalation notifications.
- Set/update Slack webhook
- Select which severity levels notify ("critical + high" / "medium+" / "all")
- Test button (sends a fake escalation to verify)

### 9.2 Email

- Email recipients for escalation notifications (list of emails)
- Digest frequency: `instant` / `hourly digest` / `daily digest`
- Separate recipients for billing alerts (budget at 80%, invoice due, etc.)

### 9.3 Mute

Per-code mute list:
- "Don't notify me about `PROSPECT_OPTED_OUT` escalations — they're just informational for us"
- Muted codes still appear in the dashboard, just don't trigger Slack/email

---

## 10. Mutation patterns

Every destructive mutation in Settings:
1. Confirmation modal with specifics
2. Step-up MFA for destructive actions (rotation, disconnect, plan downgrade, removing members)
3. Two-person approval for platform-admin-level changes
4. Audit log entry via `auditLogMiddleware`
5. Toast on success + the changed state visible immediately in the UI
6. Undo affordance where possible (disable → re-enable is one click)

---

## 11. Permissions matrix

| Panel | Owner | Member | Viewer |
|---|---|---|---|
| Integrations — view | ✅ | ✅ | ✅ |
| Integrations — connect/disable | ✅ | ❌ | ❌ |
| Integrations — reauthorise | ✅ | ✅ | ❌ |
| Secrets — view | ✅ | ✅ | ❌ |
| Secrets — rotate/revoke | ✅ | ❌ | ❌ |
| Billing — view | ✅ | ✅ | ❌ |
| Billing — change plan/budget | ✅ | ❌ | ❌ |
| Config — view | ✅ | ✅ | ✅ |
| Config — edit | ✅ | ❌ | ❌ |
| Team — view | ✅ | ✅ | ✅ |
| Team — invite/remove/role change | ✅ | ❌ | ❌ |
| API keys — view | ✅ | ✅ | ❌ |
| API keys — create/revoke | ✅ | ❌ | ❌ |
| Notifications — view | ✅ | ✅ | ✅ |
| Notifications — edit | ✅ | ✅ | ❌ |

Platform admins bypass all of these (RLS bypass + role overrides).

---

## 12. Accessibility

- Sidebar navigation: `<nav aria-label="Settings sections">` with clear focus states
- Every table has caption / `aria-labelledby`
- Destructive actions have `aria-describedby` pointing to the confirmation text
- Success toasts use `aria-live="polite"`; errors use `aria-live="assertive"`
- Form validation errors attached via `aria-describedby` to the relevant input

---

## 13. Performance

Settings isn't performance-critical (read far less often than Operations), but we budget:
- Panel switch: < 200ms (client-side route, data cached)
- Integration list load: < 400ms
- Secrets list load: < 300ms

Integration status is live (`integrations.list` subscribes to SSE when the panel is open; updates reflect within 2s of backend changes).

---

## 14. Implementation checklist (for CC18)

- [ ] Routes `/t/[slug]/settings/*` with sidebar navigation
- [ ] Seven panels per §3–§9
- [ ] All tRPC procedures (integrations, secrets, tenants, wizard reprovision path)
- [ ] Step-up MFA integration per auth spec
- [ ] Stripe portal deep link for payment management
- [ ] Invitation flow (Clerk)
- [ ] API key generate/revoke with one-time reveal
- [ ] Notification settings UI + backend persistence
- [ ] Permissions enforcement at both UI + tRPC layers
- [ ] Audit entries for every mutation
- [ ] E2E tests: connect integration, rotate secret, change plan, invite member, generate API key
- [ ] Accessibility audit per §12

---

## 15. Operator Settings (/admin/tenants/[tenantId]/settings)

Mirror of tenant Settings with operator overlays:

- Additional panel: `Provisioning` — workflow history, reprovision button, "retry last failed step" affordance
- Additional panel: `Support` — impersonation button, force restart supervisor, trigger manual vault sync
- Secrets panel shows additional "Access history" per secret (which operator/agent accessed when)
- Team panel shows `Remove owner` without the "at least one owner must exist" client-side block (emergency cleanup; still blocked server-side unless flagged as platform decommission)

---

## 16. What's deferred to v1.1

- **Bulk actions** on integrations / secrets / keys (rotate all of type X, revoke all keys)
- **Webhook signing secret viewer** — currently hidden from UI; tenants contact support when setting up custom consumers
- **White-label branding** — agency partners may want to rebrand their tenants' settings view; deferred
- **Terraform/API exports of current settings** (for customers who want to IaC their tenant configuration)
- **Granular audit-log view per panel** (currently in Activity view; consolidating here would be convenient)

---

## 17. Related

- `api/trpc-router-spec.md` §5.1, 5.6, 5.7 (tenants, integrations, secrets)
- `auth-and-authorization-spec.md` §§5–8 (permissions, step-up, impersonation)
- `phase-3-platform/secrets/secrets-vault-spec.md` — rotation mechanics
- `phase-3-platform/provisioning/provisioning-system-spec.md` — reprovisioning triggered from Config panel
- Configuration Wizard — where most of these settings are first collected
