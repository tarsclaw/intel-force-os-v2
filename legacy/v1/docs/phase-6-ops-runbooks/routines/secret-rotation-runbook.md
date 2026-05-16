# Secret Rotation Runbook

**How we rotate secrets — routine quarterly rotations for hygiene, emergency rotations after suspected compromise, and the specific procedures per secret type.**

> **Audience:** platform operator. Routine rotations are scheduled; emergency rotations are invoked from breach response or incident response flows.
>
> **Status:** v1.0. Works with the secrets vault architecture in `phase-3-platform/secrets/secrets-vault-spec.md`.
>
> **Principle:** rotation is boring by design. A rotation that requires heroics is one we'll avoid doing; a rotation we avoid doing is a secret that becomes a liability.

---

## 1. Why rotate at all

Secrets leak in more ways than people expect:
- Screenshots accidentally shared
- Git commits containing a test credential
- Browser extensions exfiltrating session cookies
- Third-party providers getting breached (and our creds with them)
- Disgruntled ex-contractor

Rotation caps the lifetime of any leaked secret. A 90-day rotation window means a secret leaked today is useless after 90 days. That's the entire benefit.

Routine rotation AND emergency rotation both matter:
- **Routine** — catches undetected leaks
- **Emergency** — responds to known compromise

---

## 2. What we rotate

Inventory, from `phase-3-platform/secrets/secrets-vault-spec.md`:

### 2.1 Per-tenant secrets (stored in vault, encrypted with tenant CMK)

| Secret type | Example | Rotation cadence | Rotation mechanism |
|---|---|---|---|
| Provider API keys | Fathom API key | Quarterly | Vault auto-rotation via provider API |
| OAuth refresh tokens | Gmail refresh token | On provider schedule (Google: ~6mo) | Auto-refresh via OAuth flow |
| Webhook secrets | HubSpot webhook signing secret | Quarterly | Regenerated + pushed to provider |
| Integration passwords | Breathe HR password (if not OAuth) | Quarterly | Manual: tenant updates, we store |
| Third-party data provider | Prospeo, Kaspr API keys | Quarterly | Tenant owns the account; they rotate |

### 2.2 Platform-level secrets (stored in 1Password shared vault + AWS Secrets Manager)

| Secret type | Example | Rotation cadence | Rotation mechanism |
|---|---|---|---|
| Postgres passwords | Dashboard's DB role password | Every 180 days | Manual, scripted |
| PgBouncer admin password | | Every 180 days | Manual, scripted |
| Anthropic organisation keys | Production key | Yearly or on change | Via Anthropic console |
| Cohere API key | | Yearly | Via Cohere console |
| Stripe API keys (restricted) | | Yearly | Via Stripe console |
| Clerk secret keys | | Yearly | Via Clerk console |
| Cloudflare API tokens | | Yearly | Via Cloudflare console |
| Hetzner API tokens | | Yearly | Via Hetzner console |
| GitHub tokens (deploy) | | 90 days (GitHub max) | Via GitHub Settings |
| PagerDuty API keys | | Yearly | Via PagerDuty console |

### 2.3 Infrastructure secrets (root-level)

| Secret type | Rotation cadence | Method |
|---|---|---|
| KMS CMK keys (per-tenant) | Automatic annually (AWS rotates key material; key ID stays stable) | AWS-managed |
| KMS CMK keys (platform-level) | Automatic annually | AWS-managed |
| SSH keys to bastion | Per-person; when person leaves team | Manual |
| Tailscale auth keys | 90 days per-person | Tailscale admin |
| AWS IAM access keys | 90 days | IAM rotation, scripted |
| Backup encryption keys | Never rotated (rotating means re-encrypting all backups) | N/A |

### 2.4 What we never rotate

- KMS key *identity* (the key ARN) — rotating would require re-encrypting every existing secret encrypted under that key. AWS automatic rotation rotates the underlying key material; the key ID stays stable, which is what we want.
- Historical audit log signing keys — rotating those would break verification of past entries. New signing keys cover new entries only.
- Backup encryption passphrase — once set, it's permanent. Backups encrypted with it remain restorable forever.

---

## 3. Routine rotation — the quarterly rhythm

Every quarter, on the first business day of the quarter, run the routine rotation.

### 3.1 Quarterly rotation checklist

```
□ 1. Review inventory (this document) for any new secret types
□ 2. Check dashboard /admin/platform/secrets-status page for last-rotated dates
□ 3. Identify: which secrets are due?
□ 4. Schedule the rotation window (aim for quiet ops period)
□ 5. Execute rotations, one at a time
□ 6. Verify each rotation:
   - Old secret revoked
   - New secret in use
   - Dependent services running
□ 7. Document in Linear ticket per rotation
□ 8. Update "last rotated" metadata for each
```

One full quarterly cycle takes 2-4 hours if nothing goes wrong. Block a half-day on the calendar.

### 3.2 Ordering

Rotate platform-level secrets first (higher blast radius if we break them, better to do when focus is fresh). Then per-tenant secrets.

Within platform-level:
1. Databases (Postgres roles)
2. Infrastructure providers (Hetzner, Cloudflare)
3. AI providers (Anthropic, Cohere)
4. Auxiliary services (PagerDuty, GitHub)

### 3.3 Dual-window mechanics

Every rotation uses a dual-window pattern:
1. Create the new secret
2. Configure services to ACCEPT both old and new (dual-accept phase)
3. Switch services to USE the new secret
4. Wait for grace period (30 min to 24h depending on service)
5. Revoke the old secret
6. Close the dual-window

This prevents outages during rotation. A bad rotation reverts by cancelling step 5.

---

## 4. Per-secret rotation procedures

### 4.1 Postgres role password

```bash
# Step 1: Generate new password
NEW_PW=$(openssl rand -base64 48 | tr -d '/+' | cut -c1-40)

# Step 2: Update role in Postgres (dual-accept not really possible for passwords)
psql -h primary-db-01 -U postgres -c "
  ALTER ROLE dashboard_app WITH PASSWORD '$NEW_PW';"

# Step 3: Update 1Password + deploy env
# (manual step: paste $NEW_PW into 1Password entry, update dashboard env var)

# Step 4: Trigger dashboard restart (picks up new env)
ssh dashboard-01 'sudo systemctl restart dashboard'
ssh dashboard-02 'sudo systemctl restart dashboard'

# Step 5: Verify
curl https://app.clawd.ai/api/health  # should be 200
```

Timing: 5 minutes. Window of momentary connection failures during restart — do during low-traffic window.

### 4.2 Anthropic API key

Dual-window is supported by Anthropic: create second key, use it, delete first.

```
1. Log in to Anthropic console
2. Create new key "clawd-prod-2026Q2"
3. Copy key value (only shown once)
4. Update 1Password entry
5. Deploy new key to production env
6. Wait 30 min for rolling deploy
7. Verify Anthropic dashboard shows new key in use
8. Revoke "clawd-prod-2026Q1" key
```

Anthropic-specific concern: if a monthly commit is attached to the organisation, verify the new key is still within that org (not accidentally personal org).

### 4.3 Stripe API key (restricted key)

```
1. Stripe Dashboard → Developers → API keys
2. Create a new restricted key with same permissions as the old
3. Update 1Password
4. Deploy to production
5. Wait 1 hour
6. Revoke old key
```

Critical: restricted keys ensure the platform key can't do arbitrary account-level actions (creating new products, refunding outside our policy, etc.). Verify the permissions match exactly; copy-paste old permissions list into new.

### 4.4 Clerk secret key

```
1. Clerk Dashboard → API Keys → Rotate
2. Clerk keeps both old and new valid for 24 hours (grace period)
3. Update 1Password + dashboard env
4. Deploy
5. Verify sign-ins work for new sessions
6. After 24 hours: old key auto-expires
```

Clerk is one of the cleaner rotation flows — the 24h grace period is built in.

### 4.5 Cloudflare API token

```
1. Cloudflare Dashboard → My Profile → API Tokens
2. Create new token with identical permissions
3. Update 1Password
4. Any services using Cloudflare API (Terraform, deploy scripts) get new token
5. Test: run a dry-run Terraform plan
6. Revoke old token
```

### 4.6 GitHub deploy token

GitHub fine-grained tokens have max 90-day expiry. Forces us to rotate quarterly.

```
1. GitHub → Settings → Developer settings → Personal access tokens (fine-grained)
2. Create new token with same scope (Deployments: Read/Write on specific repos)
3. Update 1Password + GitHub Actions secrets
4. Expire old token within 24h
```

Set calendar reminders 14 days before expiry — GitHub sends email warnings but they're easy to miss.

### 4.7 Per-tenant provider API keys (automated)

For providers whose API keys we CAN rotate programmatically (subset):

```python
# Simplified; actual code in the vault-rotation-service
def rotate_provider_key(tenant_id, provider_key_ref):
    old_metadata = vault.get_metadata(provider_key_ref)

    # Generate new key via provider API
    new_key = provider_api.generate_new_key(tenant_id)

    # Store new key with dual-accept mode
    vault.put(provider_key_ref, new_key, mode='dual')

    # Switch services to new key
    vault.activate(provider_key_ref)

    # Verify
    ok = verify_agent_can_fetch(tenant_id, provider_key_ref)
    if not ok:
        vault.rollback(provider_key_ref)
        raise RotationFailed()

    # Wait grace period (30 min)
    time.sleep(1800)

    # Revoke old key
    provider_api.revoke_key(old_metadata.key_id)
    vault.close_dual_window(provider_key_ref)
```

Runs quarterly from the Temporal scheduler. Any failure stops rotation for that tenant and alerts `#ops`.

### 4.8 Per-tenant OAuth tokens

Different from API keys — refreshed automatically on use. The "rotation" here is passive: every time an agent uses the refresh token, we get a new access token automatically.

Manual rotation (revoke + force re-auth) invoked only:
- After suspected compromise
- When tenant's OAuth refresh token is near expiry and hasn't been used (common for Gmail)
- When the tenant explicitly requests it

To manually rotate:
1. Mark integration as `pending_reauth` in control.integrations
2. Next time tenant or operator opens the dashboard Settings page, they see "Reconnect [provider]" prompt
3. OAuth flow runs fresh; new tokens stored

---

## 5. Emergency rotation

When a secret is suspected or confirmed compromised, the rotation is fast-and-full rather than dual-window.

### 5.1 Triggering

Emergency rotation invoked when:
- Breach response runbook says to (see `compliance/breach-response-runbook.md`)
- Operator sees a secret in a git history search they ran
- A teammate leaves under unusual circumstances (offboarding runbook covers this)
- A provider reports one of our keys was used from an unexpected location
- Any "I left my laptop in a cafe and didn't wipe quickly" scenarios

### 5.2 Emergency rotation process

Skip the dual-accept phase. Accept brief outage.

```
□ 1. Decide: is this emergency rotation, or full breach response?
   → If breach: go to breach-response-runbook; rotation is one step there
   → If just compromise of one key: continue here
□ 2. Identify all services using the compromised secret
□ 3. Generate new secret
□ 4. Revoke old secret immediately (before rotating services to new)
□ 5. Update services in parallel where possible
□ 6. Verify services come back up
□ 7. Monitor for 1 hour for any unexpected failures
□ 8. Post-incident: postmortem covers HOW the leak happened
```

Yes, step 4 before step 5 means services briefly fail. For a confirmed compromise, that's the right tradeoff — don't give the attacker extra minutes of access just to maintain smooth UX.

### 5.3 Emergency rotation of Anthropic key (worst case)

If our Anthropic key is compromised:
1. Revoke key in Anthropic console immediately
2. **All agent invocations will fail platform-wide during rotation** (SEV-1 declared)
3. Generate new key in Anthropic console
4. Deploy to production (staging skipped for speed)
5. Verify
6. Total downtime: typically 10-15 minutes

Status page update: "We're experiencing a brief disruption while we address a security matter. Agents will resume shortly." (Don't say "we rotated a compromised key" publicly — attracts attention.)

### 5.4 Emergency rotation of KMS CMK

KMS CMKs can't be rotated in the traditional sense (see §2.4). If a CMK is compromised:
1. Immediately revoke IAM access to the CMK for the compromised principal
2. Create a new CMK
3. Re-encrypt all secrets that were encrypted under the old CMK with the new one
4. Update vault metadata to point secrets to the new CMK
5. Schedule deletion of old CMK (7-day window)

This is a day-scale operation, not an hour-scale one. Fortunately, "CMK compromise" is rare — it requires the attacker to have AWS credentials with KMS access, not just a leaked API key.

---

## 6. Monitoring rotation health

### 6.1 Alerts

- `secret_rotation_failure` — any rotation job failed (SEV-3)
- `secret_rotation_overdue` — secret last rotated >120 days ago (SEV-4)
- `secret_soon_expiring` — GitHub/other token expiring in <14 days (SEV-4)
- `dual_window_stuck` — a dual-accept window has been open >7 days (SEV-3; indicates rotation didn't complete)

### 6.2 Dashboard view

`/admin/platform/secrets-status` shows:
- Every platform-level secret with last-rotated date
- Every tenant's secret count + aggregate last-rotated dates
- Secrets nearing rotation window
- Any in dual-window phase

Platform operator reviews weekly as part of cost governance review.

### 6.3 Weekly ops review includes rotation status

Part of the weekly Monday review (cost-governance runbook): confirm no secrets have drifted past 120 days without rotation.

---

## 7. Offboarding — human leaving the team

When a teammate leaves:

### 7.1 Same day

- Revoke all their access (Clerk org, GitHub org, PagerDuty, 1Password, Tailscale)
- Generate a fresh SSH key for the bastion (old keys including theirs invalidated)
- Rotate any shared passwords they would have seen (1Password entries for shared accounts)

### 7.2 Within 7 days

- Rotate any API key they handled directly (AWS IAM user, Anthropic key if they had console access)
- Force re-auth of OAuth apps in shared accounts (Clerk, GitHub, etc.)
- Audit log review — any unusual actions by their account in the last 90 days

### 7.3 Within 30 days

- Platform-level secrets rotated (even if they didn't know them, defence in depth)
- All SSH keys in authorized_keys reviewed platform-wide
- Offboarding postmortem (not blame; just "what did we learn")

Documented offboarding checklist in `/vault/ops/hr/offboarding.md`.

---

## 8. Special considerations

### 8.1 OAuth refresh-token expiry

Some providers (notably Google) let refresh tokens expire if unused for 6 months. A tenant with a dormant Gmail integration comes back, tries to use it, we get a 401.

Mitigation: we refresh OAuth tokens preemptively every 60 days for all integrations, even dormant ones. Done by a scheduled job. Keeps tokens fresh.

### 8.2 Webhook secrets

Rotating a webhook secret (the HMAC signing secret) requires coordination with the provider:
1. Generate new secret in our secrets vault
2. Update provider's webhook config with new secret
3. **We must accept both old and new signatures during a grace period**
4. Delete old secret after grace period

Some providers let us configure two webhook endpoints/secrets simultaneously for smooth rotation; others don't. Document per-provider.

### 8.3 Tenant-owned vs platform-owned secrets

Some integrations: the tenant owns the account (Prospeo, Kaspr API keys bought directly). They rotate on their own schedule; we just store.

Other integrations: platform-owned (Anthropic, Cohere). We rotate.

Clear in each integration's documentation which one applies.

### 8.4 What if a tenant refuses to rotate?

If tenant-owned secrets aren't rotated by tenant for 180+ days:
- Reminder emails
- Dashboard banner encouraging rotation
- Not a blocker to service continuation
- We only intervene if we observe the secret being used abusively

Tenant's account; tenant's choice. We provide visibility and reminders.

---

## 9. Key vault backup and restore

The vault itself has secrets. How do we handle them?

### 9.1 Backups

Vault data:
- DynamoDB continuous backups (AWS-managed)
- Daily snapshot to S3 (cross-region)
- Restore tested quarterly (see backup verification runbook)

Backup contents are encrypted with the per-tenant CMKs. A backup is useless without the CMKs, and the CMKs are AWS-managed with cross-region redundancy.

### 9.2 Disaster scenarios

**DynamoDB table accidentally deleted:**
- Restore from AWS point-in-time backup (35-day retention)
- All secrets remain accessible (CMKs unchanged)
- No tenant-side action needed

**All KMS CMKs deleted (catastrophic; requires deliberate action):**
- KMS pending-delete window (7 days) applies; recoverable within that window
- Past 7 days: all tenant secrets are permanently unrecoverable
- This is why IAM policies forbid mass CMK deletion, even for platform admins; two-person approval required in IAM

**AWS region outage (eu-west-2 down):**
- Vault is single-region v1; secondary region is roadmap
- In outage, platform degrades (agents can't fetch secrets)
- Acceptable short-term (AWS regions rarely down >hours)

---

## 10. Never do during rotation

- Rotate Anthropic key at the start of a busy week without checking staging first
- Rotate more than one platform-level secret in the same hour (amplifies blast radius of mistakes)
- Skip the verification step (you'll find the failure tomorrow at 3am)
- Rotate without someone else available to help if something goes wrong
- Leave an old secret un-revoked "for safety" — defeats the point of rotation
- Document the new secret in plaintext anywhere outside 1Password + the vault

---

## 11. Rotation checklist per quarter

Printable/template version for operator use each quarter:

```
[Q_] Rotation — initiated YYYY-MM-DD by ____

Platform-level:
[ ] Dashboard DB role
[ ] PgBouncer admin
[ ] Anthropic API key
[ ] Cohere API key
[ ] Stripe restricted key
[ ] Clerk secret key
[ ] Cloudflare API token
[ ] Hetzner API token
[ ] GitHub deploy token (if within 14 days of expiry)
[ ] PagerDuty API key

Per-tenant (automated; check dashboard):
[ ] All tenants: provider API keys rotated where auto-rotatable
[ ] Any manual rotation needed? _____

Verification:
[ ] All services healthy post-rotation
[ ] Dashboard /admin/platform/secrets-status shows fresh last-rotated dates
[ ] No open dual-windows
[ ] No alerts firing

Sign-off: _____ Date: _____
```

Copy into `/vault/ops/rotations/YYYY-QX-rotation.md`.

---

## 12. Related

- `compliance/breach-response-runbook.md` — emergency rotations invoked from here
- `compliance/gdpr-dsar-and-deletion-runbook.md` — rotation is not deletion (different process)
- `routines/backup-verification-and-dr-drills.md` — rotation's sibling routine
- `routines/cost-governance-runbook.md` — weekly review includes secret status
- `phase-3-platform/secrets/secrets-vault-spec.md` — vault architecture
- `phase-4-dashboard/views/settings-spec.md` — tenant-facing secret management UI
