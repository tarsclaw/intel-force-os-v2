# Authentication & Authorization Specification

**Who gets in, who sees what, how sessions work, how destructive actions are gated.**

> **Audience:** the engineer wiring auth; the person deciding on Clerk vs WorkOS; security reviewer.
>
> **Status:** v1.0. Recommendation: Clerk for v1. Migrate to WorkOS for agency partners that require SAML.
>
> **Non-negotiables:**
> - MFA required for every operator and every tenant admin
> - RLS in Postgres enforces tenant isolation even if app code has a bug (belt-and-braces)
> - Every destructive action requires step-up auth (re-auth or MFA challenge)
> - Audit every session creation, every permission check, every destructive action
> - UK/EU data residency for identity data (Clerk supports EU; confirmed before onboarding)

---

## 1. Identity provider — Clerk

### 1.1 Why Clerk

- Fast to integrate — full Next.js + tRPC integration in hours, not days
- Built-in UI components (sign-in, sign-up, user button) that look credible and are a11y-compliant
- Organisations primitive matches our multi-tenant model out of the box
- MFA (TOTP + backup codes) built-in; SMS optional but not recommended
- EU data residency available (verify at signup)
- Pricing is reasonable for MVP

### 1.2 Why not WorkOS (yet)

- WorkOS is stronger for enterprise SSO (SAML, SCIM provisioning) but our first 50 customers won't need SAML
- WorkOS' consumer auth flows are thinner
- Per-connection pricing adds up fast for many small tenants

Our migration plan: any enterprise customer (or agency partner) who requires SAML goes to WorkOS, with Clerk fronting everyone else. Clerk + WorkOS can coexist (route by organisation type).

### 1.3 Why not rolling our own

Running auth is a distraction. Password reset flows, MFA enrolment, OAuth-callback edge cases, account recovery, abuse detection — all of this is nearly invisible work if you get it right, and a security incident if you get it wrong. Pay Clerk (or WorkOS) until scale justifies building your own. We don't hit that scale in v1.

---

## 2. Identity model

### 2.1 Entities

| Entity | In Clerk | In our DB |
|---|---|---|
| **User** | `User` | Mirrored in `control.users` (email, name, clerk_user_id, mfa_enabled) |
| **Organisation** | `Organization` | Maps to either a tenant OR an agency partner OR IntelForce staff |
| **Membership** | `OrganizationMembership` | User belongs to one or more orgs with a role |
| **Role** | `OrganizationRole` | See §3 |

We keep a mirror in Postgres so:
- Audit log can reference `user_id` without needing to hit Clerk
- `ops.audit_log` stays resilient if Clerk has an outage
- Analytics over users are feasible without exporting from Clerk

### 2.2 Clerk org naming

- IntelForce staff organisation: `intelforce-staff`
- Tenant organisation: matches `client_slug` (e.g., `meadowlane-dental`)
- Agency partner organisation: matches `agency_slug` (e.g., `rigby-group`)

Clerk organisation slugs are unique per Clerk instance. Our slugs are unique per tenant/agency. We guarantee match by creating the Clerk org at the same moment the tenant/agency is created (in the Provisioning System).

---

## 3. Roles

### 3.1 Role matrix

| Role | Scope | Can… |
|---|---|---|
| `platform_admin` | IntelForce staff org | Everything — manage any tenant, run any mutation, access audit log |
| `platform_operator` | IntelForce staff org | Read every tenant; run onboarding; cannot decommission or rotate secrets without 2-person approval |
| `platform_readonly` | IntelForce staff org | Read-only across every tenant |
| `tenant_owner` | Tenant org | Full access to their tenant: view, approve drafts, manage integrations, billing |
| `tenant_member` | Tenant org | View + approve drafts; cannot manage integrations or billing |
| `tenant_viewer` | Tenant org | Read-only |
| `agency_admin` | Agency org | Manage sub-tenants under this agency; view activity across all sub-tenants |
| `agency_member` | Agency org | View sub-tenants; cannot create new sub-tenants |

### 3.2 Role storage

Roles live in Clerk (as custom organisation roles) AND are mirrored in `control.users_roles` (user_id, org_id, role, granted_at, granted_by).

Why mirror: Clerk is the write path for role changes, but Postgres is the read path during permission checks. Hitting Clerk on every permission check would add 50ms+ per request — unacceptable.

Mirror is updated via Clerk webhooks (`organization_membership.created`, `.updated`, `.deleted`). Webhook handler writes to `control.users_roles` and logs to `ops.audit_log`.

### 3.3 Role assignment UI

- Platform admins assign `platform_*` roles via a dedicated admin view (`/admin/users`)
- `tenant_owner` is set during tenant creation (the email submitted in the wizard); additional members invited via tenant settings
- `agency_admin` is set during agency creation

---

## 4. Session management

### 4.1 Session cookie

Clerk issues a session JWT stored in a secure, HTTP-only, same-site cookie. Cookie scope: `.intelforce.ai` (shared between dashboard and any subdomains).

### 4.2 Session lifetime

- Idle timeout: 30 minutes (re-prompt after inactivity)
- Absolute timeout: 12 hours (re-prompt after this period regardless of activity)
- Remember-me option: extends to 30 days but requires MFA challenge every 24 hours

These match industry defaults. Configurable per organisation for enterprise customers (agency partners and enterprise-tier tenants).

### 4.3 Device/session visibility

Every user can see their active sessions in settings, with:
- Location (IP geolocation)
- Device (user agent parsed)
- Last active timestamp
- Sign-out button per session

Session revocation is immediate (cookie invalidated server-side, next request re-prompts).

### 4.4 MFA enforcement

- **platform_* roles:** MFA required at signup; cannot disable
- **tenant_owner:** MFA required (enforced via Clerk org setting)
- **tenant_member, tenant_viewer:** MFA recommended; optional for v1
- **agency_admin, agency_member:** MFA required

TOTP via any authenticator app (Authy, 1Password, Google Authenticator). Backup codes provided at enrolment (printable, 10 codes). SMS MFA not offered — SIM swap risks too high for ops tool.

---

## 5. Authorisation — the permission model

### 5.1 Three layers

```
Request arrives
     │
     ▼
┌─────────────────────────────────────┐
│ Layer 1: Clerk session check        │
│ (middleware in Next.js; rejects     │
│ requests without valid session)     │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ Layer 2: tRPC procedure guard       │
│ (explicit role check per procedure) │
└────────────┬────────────────────────┘
             │
             ▼
┌─────────────────────────────────────┐
│ Layer 3: Postgres RLS               │
│ (final fence — bug in app can't     │
│ leak across tenants)                │
└─────────────────────────────────────┘
```

### 5.2 Layer 1 — Session middleware

Every Next.js request passes through middleware that:
1. Reads session cookie
2. Validates session via Clerk
3. Attaches `user_id`, `org_id`, `roles[]` to request context
4. If no session, redirects to `/sign-in?redirect=<original-path>`

Public routes: `/sign-in`, `/sign-up`, `/invitation/:id` — whitelist.

### 5.3 Layer 2 — tRPC procedure guards

Every tRPC procedure declares its required role(s):

```typescript
export const escalationsRouter = router({
  // Anyone with tenant_* role can view
  list: tenantProcedure.query(async ({ ctx, input }) => { /* ... */ }),

  // Only owner/admin can resolve
  resolve: tenantProcedure
    .input(z.object({ escalationId: z.number() }))
    .use(requireRole(['tenant_owner', 'platform_admin']))
    .mutation(async ({ ctx, input }) => { /* ... */ }),

  // Platform only
  listAll: platformProcedure
    .use(requireRole(['platform_admin', 'platform_operator', 'platform_readonly']))
    .query(async ({ ctx }) => { /* ... */ })
});
```

Procedure types:
- `publicProcedure` — no auth required (rare; sign-in callbacks only)
- `authenticatedProcedure` — any signed-in user
- `tenantProcedure` — user must be a member of the tenant in the URL params
- `agencyProcedure` — user must be a member of the agency in the URL params
- `platformProcedure` — user must be in `intelforce-staff` org

`tenantProcedure` automatically:
1. Reads `tenantId` from input
2. Verifies user's Clerk org matches the tenant (or user is in `intelforce-staff`)
3. Sets `app.current_tenant_id` Postgres session variable (for RLS)

### 5.4 Layer 3 — Postgres RLS

Covered in `phase-3-platform/postgres/schema-spec.md §6`. Every tenant-scoped row filter depends on `app.current_tenant_id`. The tRPC `tenantProcedure` always sets this.

Platform admins connect with the `platform_admin` role which `BYPASSRLS` — they see everything. Platform operators connect with a role that DOES respect RLS — they set `app.current_tenant_id` explicitly when acting on a specific tenant.

### 5.5 Permission helper functions

Common checks are helper functions, not inlined:

```typescript
// packages/trpc/src/permissions.ts
export const requireRole = (allowedRoles: Role[]) => {
  return t.middleware(({ ctx, next }) => {
    if (!ctx.user) throw new TRPCError({ code: 'UNAUTHORIZED' });
    const hasRole = ctx.user.roles.some(r => allowedRoles.includes(r));
    if (!hasRole) throw new TRPCError({ code: 'FORBIDDEN', message: `Requires one of: ${allowedRoles.join(', ')}` });
    return next();
  });
};

export const requireTenantAccess = (tenantIdField: string) => {
  return t.middleware(async ({ ctx, input, next }) => {
    const tenantId = (input as any)[tenantIdField];
    if (!tenantId) throw new TRPCError({ code: 'BAD_REQUEST' });
    const canAccess = await userCanAccessTenant(ctx.user.id, tenantId);
    if (!canAccess) throw new TRPCError({ code: 'FORBIDDEN' });
    // Set Postgres RLS session variable
    ctx.setTenantContext(tenantId);
    return next();
  });
};
```

`userCanAccessTenant` is cached per-request (no need to re-check mid-request).

---

## 6. Step-up authentication

Some actions are dangerous. We require recent re-authentication before allowing them.

### 6.1 What requires step-up

| Action | Step-up required |
|---|---|
| Decommission tenant | 2FA challenge |
| Rotate all secrets for a tenant (emergency) | 2FA challenge |
| Delete vault archive | 2FA challenge + reason required |
| Export tenant data (GDPR response) | 2FA challenge |
| Add a new `platform_admin` | 2FA challenge + approval from another platform_admin |
| Change cost budget mode to `hard_stop` | 2FA challenge |
| Revoke a user's access | No step-up (common action), but logged |

### 6.2 Mechanism

Clerk's "step-up auth" flow:
1. Frontend calls `clerk.user.verifyMFA()` before initiating the dangerous mutation
2. MFA challenge appears as a modal
3. On success, Clerk issues a short-lived (5-minute) "recently authenticated" token
4. Frontend includes the token in the mutation request
5. Backend verifies the token before proceeding

### 6.3 Two-person approval

For `platform_admin` role grants, decommissioning paying tenants, and similar gravity:

1. Operator 1 initiates; the action enters a `pending_approval` state
2. Operator 2 sees a request in `/admin/approvals`
3. Operator 2 approves or rejects (with reason)
4. On approval, the action executes
5. Both operators' user_ids recorded in audit log

Implementation is a simple `control.pending_approvals` table with a 24-hour expiry.

---

## 7. Invitation flow

### 7.1 Tenant owner invites team members

1. Tenant owner goes to Settings → Team
2. Enters email + role (member or viewer)
3. Dashboard calls Clerk's `organization.inviteMember()`
4. Clerk sends invitation email
5. Invitee clicks link → creates account (if new) or signs in (if existing) → joins org

### 7.2 IntelForce invites an agency partner

1. Platform admin goes to Admin → Agencies → New
2. Enters agency slug, primary contact email, initial roster of sub-tenants
3. Provisioning System creates the Clerk org (agency)
4. Clerk invites primary contact as `agency_admin`
5. Primary contact signs in, sees onboarding tour

### 7.3 Invitation expiry

- Tenant invitations expire after 7 days
- Agency admin invitations expire after 14 days
- Expired invitations can be resent (not auto-renewed)

---

## 8. Impersonation (support access)

Sometimes a platform operator needs to see the dashboard "as" a specific tenant user to debug an issue. This is impersonation.

### 8.1 Flow

1. Operator navigates to `/admin/tenants/[tenantId]` → "Impersonate" button
2. Clerk issues a short-lived impersonation session (max 30 minutes)
3. Dashboard chrome adds a persistent orange banner: "🟠 IMPERSONATING [tenant owner email] — end impersonation"
4. Every action during the session is logged with BOTH the impersonating operator's user_id AND the impersonated user_id
5. Operator can end impersonation at any time; auto-ends after 30 min

### 8.2 Impersonation restrictions

- Cannot trigger step-up-requiring actions while impersonating (prevents "I accidentally decommissioned while logged in as the tenant")
- Cannot view secrets values (only masked refs)
- Tenant owner sees an entry in their audit log: "Support accessed your account on 2026-04-22 15:30 for 12 minutes (operator: [name])"

### 8.3 Customer consent

Tenant owners can disable impersonation entirely via settings ("Require my explicit approval for support access"). If enabled, operator's impersonation request sends an email to the owner; owner clicks "Grant access" to consent.

We default impersonation to allowed. Not a dark pattern — it's actually how support works; making it opt-out would cripple operators' ability to debug issues.

---

## 9. API key access (for automation)

Some tenants or agencies want to script against their data (e.g., pulling costs into their own reporting). We offer scoped API keys.

### 9.1 Scoped API keys

- Issued per tenant or per agency
- Scope: read-only by default; `write:escalations` or `write:settings` can be added
- Format: `intel_live_<prefix>_<random-hash>` (rotatable, prefix identifies the scope)
- Rate limit: 100 req/min per key

### 9.2 Management

- Settings → API Keys per tenant/agency
- List with last-used timestamp and scope
- Revoke button (immediate)
- Max 5 keys per tenant; contact support if you need more

### 9.3 Authentication in requests

```
Authorization: Bearer intel_live_<prefix>_<random-hash>
```

Backend validates against `control.api_keys` table. Every key use is logged.

---

## 10. OAuth for integrations (not user auth)

This spec is about dashboard login. OAuth for integrations (Fathom, HubSpot, Gmail) lives in the Provisioning System spec. Just noting: they're different systems and keep them separate in your head.

---

## 11. Audit log

Every security-relevant action is logged:

- Sign in / sign out
- MFA enrolment / disable
- Role grant / revoke
- Impersonation start / end
- Step-up challenge success / failure
- API key created / revoked / used
- Destructive action (decommission, emergency rotation, etc.)
- Failed authorisation attempts (someone tried to access a tenant they don't belong to)

Stored in `ops.audit_log` (see Phase 3 schema). Retention: 7 years in S3 Object Lock.

---

## 12. Rate limiting

Dashboard backend uses rate limits to slow down abuse:
- Anonymous: 60 req/min per IP
- Authenticated: 600 req/min per user
- API keys: 100 req/min per key

Implemented via Redis-backed sliding window. Per-route overrides for known-expensive routes (Brain view file preview: 30 req/min).

Rate limit exceeded → 429 with `Retry-After` header. Frontend shows a toast: "Slow down — taking a breather."

---

## 13. Session security

- CSP header that disallows inline scripts except ours (via nonce)
- Cookies: HTTP-only, Secure, SameSite=Lax
- No session fixation — cookie rotated on sign-in
- Brute-force protection: Clerk handles failed login attempts; we add our own rate limit for completeness
- Anomaly detection: flag sign-ins from a new country; require MFA re-challenge

---

## 14. Failure modes

| Scenario | Impact | Mitigation |
|---|---|---|
| Clerk has an outage | Users can't sign in; existing sessions keep working | Existing session validity extended to 24h during Clerk outage (via fallback in middleware); queue new sign-ins; page on-call |
| Clerk webhook delays | Role changes take time to propagate | Backend refreshes Clerk org state if cache is >10min old; accept 10min worst-case lag for role updates |
| Compromised operator account | Attacker has platform_admin access | MFA buys time; audit log identifies actions; revoke session immediately upon detection; rotate any secrets the attacker could have seen |
| Compromised tenant owner account | Attacker sees tenant's vault + integrations | MFA; alert on new-device sign-in; owner can revoke all sessions from settings |
| Session hijack | Attacker replays cookie | Cookie rotation on sensitive actions; step-up for destructive; anomaly detection |

---

## 15. Implementation checklist (for CC13, auth portion)

- [ ] Clerk project created, EU data region confirmed
- [ ] Clerk organisations seeded with correct roles
- [ ] Next.js middleware for session validation
- [ ] tRPC procedure guards (`tenantProcedure`, `platformProcedure`, etc.)
- [ ] Clerk webhooks → `control.users`, `control.users_roles` mirror
- [ ] Step-up auth flow wired for destructive actions
- [ ] Two-person approval pattern (platform-admin grants)
- [ ] Impersonation flow with audit logging
- [ ] API key management UI + backend validation
- [ ] Rate limiting middleware (Redis-backed)
- [ ] MFA enrolment enforced for ops roles + tenant_owner
- [ ] Session management view (active devices, sign out)
- [ ] Security review: test RLS bypass attempts; test role escalation paths

---

## 16. Open decisions

**OD-P4-E:** SSO for enterprise tenants — WorkOS alongside Clerk, or wait?
- **Recommendation:** wait until the first deal requires it; have WorkOS as the known answer when it does

**OD-P4-F:** Password-based sign-in or passwordless (magic link only)?
- **Recommendation:** passwordless primary, password optional. Most ops tools now default passwordless; it's both easier and more secure.

**OD-P4-G:** Social sign-in (Google, GitHub, etc.) — enabled or disabled?
- **Recommendation:** disabled for operators (too risky). Enabled optionally for tenant users to reduce friction, with Google being the only allowed provider.
