# Secrets Management Specification

**How every API key, OAuth token, webhook secret, and deploy key lives at rest and in transit across the IntelForce AI OS platform.**

> **Audience:** the engineer implementing CC5 (Secrets Vault) and the ops engineer designing rotation cadences.
>
> **Status:** v1.0. Targets AWS KMS (UK region) as the key management service plus a thin in-house secrets-vault service.
>
> **Non-negotiable principles:**
> - Secrets are NEVER written to a filesystem in plain form
> - Secrets are NEVER logged in any form
> - Secrets ARE recoverable from backup — the platform doesn't re-authenticate every tenant from scratch on disaster recovery
> - Rotation is automatic for secrets we can rotate (webhook secrets) and scheduled-manual for those we can't (user-granted OAuth tokens)

---

## 1. Architecture

```
┌───────────────────────────────────────────────────────────────┐
│                    AWS KMS (eu-west-2)                        │
│                                                               │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐     │
│  │ platform-CMK  │  │ tenant-CMKs   │  │ audit-CMK     │     │
│  │ (1 key)       │  │ (1 per tenant)│  │ (1 key)       │     │
│  └───────┬───────┘  └───────┬───────┘  └───────┬───────┘     │
│          │                  │                  │             │
└──────────┼──────────────────┼──────────────────┼─────────────┘
           │                  │                  │
           │ Encrypt/Decrypt  │                  │
           │                  │                  │
           ▼                  ▼                  ▼
┌───────────────────────────────────────────────────────────────┐
│                    Secrets Vault Service                      │
│                                                               │
│  HTTP API (internal only):                                    │
│    GET  /v1/secrets/{ref}      → decrypted value              │
│    PUT  /v1/secrets/{ref}      → encrypt and store            │
│    POST /v1/secrets/rotate     → rotate a secret              │
│    POST /v1/secrets/revoke     → mark secret revoked          │
│                                                               │
│  Storage: DynamoDB table `secrets` (encrypted at rest too)    │
│    Partition key: tenant_id                                   │
│    Sort key: secret_ref                                       │
│    Attributes: ciphertext, encryption_context, kms_key_id,    │
│                created_at, last_rotated_at, version           │
└───────────────────────────────────────────────────────────────┘
           │
           │ mTLS, short-lived service tokens
           │
           ▼
┌───────────────────────────────────────────────────────────────┐
│  Consumers                                                    │
│  - Tenant containers (read their own tenant's secrets only)   │
│  - Provisioning System (full read+write)                      │
│  - Dashboard backend (tenant-scoped via operator identity)    │
│  - Webhook receiver (read webhook_secret only)                │
└───────────────────────────────────────────────────────────────┘
```

---

## 2. Why this shape (and not pure-AWS-Secrets-Manager)

AWS Secrets Manager handles most of this natively. We don't use it directly because:

- **Per-tenant CMK isolation is cleaner as a first-class concept.** Secrets Manager can do it via resource policies, but a thin in-house service lets us enforce the "only your tenant's CMK can decrypt your tenant's secrets" invariant at the application layer, not just IAM.
- **Secret refs (`secrets://tnt_xxx/...`) are platform-native.** They appear in tenant-config.json, in agent tools.yaml, in webhook_registrations. Having our own service lets those refs be the API.
- **Rotation is orchestrated, not managed.** Secrets Manager's rotation is per-secret Lambda functions. Our rotation needs to coordinate: rotate webhook secret → update `webhook_registrations` in Postgres → notify the provider's API → update tenant config. Owning the orchestration is cleaner than chaining Secrets Manager rotation.

Trade-off: we build and run a small service. Acceptable — it's ~400 lines of Node and the rotation logic is where most of the value lives.

The backing store is DynamoDB (not Postgres) because:
- Secrets workload is high-read, low-write, key-value
- We want a hard blast-radius boundary from the main Postgres cluster

---

## 3. Secret refs

Every secret is addressed by a stable reference string. Format:

```
secrets://{tenant_id}/{provider}/{secret_kind}[/{instance}]
```

Examples:
```
secrets://tnt_01JKDY.../anthropic/api_key
secrets://tnt_01JKDY.../fathom/api_key
secrets://tnt_01JKDY.../fathom/webhook_secret
secrets://tnt_01JKDY.../hubspot/oauth_token
secrets://tnt_01JKDY.../google/oauth_token
secrets://tnt_01JKDY.../github/deploy_key
secrets://tnt_01JKDY.../cohere/api_key
secrets://tnt_01JKDY.../stripe/api_key
secrets://tnt_01JKDY.../slack/oauth_token

secrets://platform/github/app_private_key       # platform-level secret
secrets://platform/stripe/webhook_secret
```

Tenant-scoped refs start with `tnt_<id>`. Platform-scoped refs start with `platform`.

A ref string is NEVER a secret itself — it's a pointer. Refs can appear in logs, config files, audit trails.

---

## 4. Per-tenant CMK model

Each tenant gets their own AWS KMS Customer Managed Key. On tenant creation:

```typescript
// In Provisioning System's `seed_secrets_vault` activity
const cmk = await kms.createKey({
  Description: `CMK for tenant ${tenantId} (${clientSlug})`,
  KeyUsage: 'ENCRYPT_DECRYPT',
  KeySpec: 'SYMMETRIC_DEFAULT',
  Tags: [
    { TagKey: 'tenant_id', TagValue: tenantId },
    { TagKey: 'platform', TagValue: 'intelforce' },
    { TagKey: 'environment', TagValue: 'production' }
  ]
});

// Alias for easier reference
await kms.createAlias({
  AliasName: `alias/intelforce/tenant/${tenantId}`,
  TargetKeyId: cmk.KeyMetadata.KeyId
});
```

IAM policy on the CMK: only the Secrets Vault service role can Encrypt/Decrypt with it. Nothing else can touch it — not the dashboard, not the tenant container, not other tenants.

### 4.1 Encryption context

Every encrypt/decrypt call passes an encryption context — AWS KMS uses this as additional authenticated data:

```json
{
  "tenant_id": "tnt_01JKDY8X5RQ4P2N6",
  "secret_ref": "secrets://tnt_01JKDY.../fathom/api_key"
}
```

If someone steals the ciphertext AND the CMK ID, they still can't decrypt without the correct encryption context. This is the belt-and-braces against misconfigured IAM.

### 4.2 What CMK isolation actually buys us

- **Tenant compromise is contained.** If an attacker somehow gets the Secrets Vault service role credentials for one tenant, they can decrypt that tenant's secrets but not others' (because IAM allows decrypt only with the correct CMK).
- **GDPR deletion is real.** Schedule-delete the tenant's CMK and all their ciphertexts become mathematically unrecoverable — even we can't recover them. This is the right way to handle "right to erasure."
- **Regulated clients get an auditable isolation story.** Enterprise prospects in regulated industries want to see per-tenant crypto isolation diagrammed before they sign. This delivers it.

---

## 5. Secrets Vault service — API

Internal HTTP+mTLS API. Only reachable from inside the private network. Service identity tokens (short-lived, 5min TTL) issued by the platform's IAM.

### 5.1 `PUT /v1/secrets/{ref}`

Encrypt and store a secret.

**Request:**
```json
{
  "value": "sk-ant-api03-xxxxx",
  "secret_kind": "api_key",
  "rotation_policy_days": 0,
  "expires_at": null,
  "metadata": {
    "created_via": "provisioning-system",
    "note": "Anthropic API key for tenant"
  }
}
```

**Response:**
```json
{
  "ref": "secrets://tnt_01JKDY.../anthropic/api_key",
  "version": 1,
  "stored_at": "2026-04-22T15:45:00Z"
}
```

Writes:
- Encrypted ciphertext to DynamoDB `secrets` table
- Metadata row to `control.secrets_metadata` in Postgres
- Audit event: `secret.stored`

### 5.2 `GET /v1/secrets/{ref}`

Return decrypted secret value.

**Response:**
```json
{
  "ref": "secrets://tnt_01JKDY.../anthropic/api_key",
  "value": "sk-ant-api03-xxxxx",
  "version": 1,
  "expires_at": null
}
```

Writes:
- `last_accessed_at` updated in `control.secrets_metadata`
- Audit event: `secret.read` (with caller identity, not with the value)

Rate-limited per tenant: max 1000 reads/hour. Reasonable for legitimate runtime. Anything above triggers an alert.

### 5.3 `POST /v1/secrets/rotate`

Rotate a secret. Only works for secrets we can rotate ourselves.

**Request:**
```json
{
  "ref": "secrets://tnt_01JKDY.../fathom/webhook_secret",
  "strategy": "dual-window",
  "grace_period_minutes": 60
}
```

**Strategy: `dual-window`:**
1. Generate new secret
2. Store new secret alongside old (two-row write with `version: 2`)
3. Both are valid for `grace_period_minutes`
4. For webhook secrets: call provider's API to tell them about the new signing key
5. After grace period, old secret is marked revoked (not deleted — kept for audit)

**Strategy: `hard-cutover`:**
1. Generate new secret
2. Replace old with new
3. Old secret immediately invalid

Used for secrets where the external system must accept the new value atomically (rare).

### 5.4 `POST /v1/secrets/revoke`

Mark a secret as revoked. Actual deletion happens after retention period (default 90 days for audit).

**Request:**
```json
{
  "ref": "secrets://tnt_01JKDY.../hubspot/oauth_token",
  "reason": "user_disconnected_integration"
}
```

Writes:
- `control.secrets_metadata.status = 'revoked'`
- Does NOT delete ciphertext (yet)
- Audit event: `secret.revoked`

### 5.5 Bulk operations (for tenant decommission)

`POST /v1/secrets/bulk-revoke?tenant_id=tnt_xxx` — marks every secret for a tenant as revoked in one call. Used by `TenantDecommission` workflow.

`POST /v1/secrets/bulk-delete?tenant_id=tnt_xxx` — actually deletes ciphertexts after the 90-day retention. Requires platform-admin role.

---

## 6. Rotation policies

### 6.1 Summary table

| Secret kind | Rotation | Strategy | Cadence | Who triggers |
|---|---|---|---|---|
| Anthropic API key | Automatic | Hard-cutover | 90 days | Rotation scheduler |
| Cohere API key | Automatic | Hard-cutover | 90 days | Rotation scheduler |
| Fathom webhook secret | Automatic | Dual-window | 90 days | Rotation scheduler |
| HubSpot webhook secret | Automatic | Dual-window | 90 days | Rotation scheduler |
| Fathom API key | Semi-automatic | Hard-cutover | On demand | Operator (provider doesn't offer rotation API) |
| Prospeo API key | Semi-automatic | Hard-cutover | On demand | Operator |
| Kaspr API key | Semi-automatic | Hard-cutover | On demand | Operator |
| HubSpot OAuth token (refresh) | Continuous | — | Every 60min before expiry | Tenant supervisor |
| Gmail OAuth token (refresh) | Continuous | — | Every 60min before expiry | Tenant supervisor |
| GitHub deploy key | On rotation | Hard-cutover | 180 days | Rotation scheduler |
| Stripe API key | Manual | Hard-cutover | Yearly | Operator |
| Platform-level GitHub App key | Manual | Hard-cutover | Yearly | Operator |

### 6.2 Rotation scheduler

A small cron-like service (single instance, runs every hour):

1. Query `control.secrets_metadata` for rows where:
   - `rotation_policy_days > 0`
   - `last_rotated_at + rotation_policy_days * interval '1 day' < now() + interval '24 hours'`
   - `status = 'active'`
2. For each, call `POST /v1/secrets/rotate` with appropriate strategy
3. If rotation succeeds, update `last_rotated_at`
4. If rotation fails (provider API down, etc.), log and alert; retry in 1 hour

### 6.3 OAuth token refresh

OAuth tokens (HubSpot, Gmail, Slack, Notion) are refreshed per-request by the tenant supervisor, not via the rotation scheduler. Pattern:

```typescript
async function getHubspotToken(tenantId: string): Promise<string> {
  const meta = await getSecretMetadata(`secrets://${tenantId}/hubspot/oauth_token`);

  // Refresh if expiring within 60 minutes
  if (meta.expires_at.getTime() - Date.now() < 60 * 60 * 1000) {
    const current = await secrets.get(`secrets://${tenantId}/hubspot/oauth_token`);
    const refreshed = await hubspot.refreshToken(current.refresh_token);
    await secrets.put(`secrets://${tenantId}/hubspot/oauth_token`, refreshed);
    return refreshed.access_token;
  }

  const current = await secrets.get(`secrets://${tenantId}/hubspot/oauth_token`);
  return current.access_token;
}
```

Refresh happens inside the supervisor, so tenant containers never need to manage OAuth state directly.

### 6.4 Emergency rotation

For a suspected compromise:
- Dashboard has a big red "Rotate all secrets for this tenant" button
- Requires 2FA step-up
- Triggers a bulk rotation workflow — rotates what's automatic, alerts operator for what's manual
- Notifies tenant via email within 15 minutes

---

## 7. Audit trail

Every secret access is logged to `ops.audit_log` with:

```json
{
  "actor": "tenant-supervisor:tnt_01JKDY.../proposal-builder",
  "action": "secret.read",
  "target": "secrets://tnt_01JKDY.../fathom/api_key",
  "metadata": {
    "session_id": "sess_xxx",
    "invocation_id": "42"
  },
  "ip_address": "10.0.1.42",
  "created_at": "2026-04-22T15:47:12Z"
}
```

**Values are NEVER logged.** Only refs.

Retention: 7 years (regulatory hedge for dental/finance verticals). Stored in append-only S3 bucket with Object Lock (Governance mode).

---

## 8. Disaster recovery

### 8.1 Backup model

- **DynamoDB `secrets` table:** point-in-time recovery enabled, 35-day window
- **KMS CMKs:** AWS manages durability. Never delete a CMK immediately — always schedule deletion (30-day window) so we can recover from mistakes
- **`control.secrets_metadata` in Postgres:** follows Postgres backup strategy (pgBackRest, 30-day PITR)

### 8.2 Recovery scenarios

| Scenario | Impact | Recovery |
|---|---|---|
| Lost one tenant's secrets | That tenant's agents fail | Restore DynamoDB to point-in-time; re-authorize OAuth if expired |
| Lost KMS CMK (we deleted it) | Tenant's ciphertexts unrecoverable | **CATASTROPHIC** — have to re-authenticate every integration. See §8.3 |
| Lost Secrets Vault service | No agent can run until restored | Redeploy; no data loss |
| Lost both Dynamo table + KMS | Full platform recovery | Restore Dynamo from PITR; CMKs recoverable if deletion pending; else see §8.3 |

### 8.3 Catastrophic secrets loss procedure

If tenant CMKs are truly lost:
1. Suspend all affected tenants (webhook routing off, supervisors shut down)
2. Notify affected tenant operators within 1 hour
3. Provisioning System re-runs a "re-authorise all integrations" flow — operator re-consents to OAuth, re-enters API keys
4. Typical recovery time: 24–48 hours per tenant (depends on operator availability)

This is the scenario the 30-day CMK deletion schedule exists to prevent. Never set `PendingWindowInDays: 7` on CMK deletion unless you're very sure.

---

## 9. Threat model

What we're defending against:

| Threat | Defence |
|---|---|
| Stolen DB snapshot | Ciphertexts useless without CMKs |
| Stolen CMK ID | Useless without correct encryption context |
| Compromised Secrets Vault service | Per-tenant CMKs limit blast radius; mTLS + short-lived tokens limit exposure |
| Rogue internal operator | Audit log + 2FA on destructive actions; operator ops can't bulk-export tenant secrets |
| Upstream provider breach (e.g. Cohere leaks API keys) | Rotate automatically within 90 days; emergency rotation button for immediate response |
| GitHub Actions supply chain attack | Deployment pipeline signs artefacts; Provisioning System verifies signatures before deploying new versions |

What we're NOT defending against (v1):
- Nation-state adversary with persistent AWS infrastructure access — this is a different product conversation
- Insider with CMK admin access — we accept this risk for now; v2 adds separation of duties

---

## 10. Implementation checklist (for CC5)

- [ ] Deploy Secrets Vault service (Node.js + TypeScript + Fastify)
- [ ] DynamoDB table with encryption at rest
- [ ] KMS CMK creation automation (in Provisioning System)
- [ ] CMK key policies (IAM templates)
- [ ] mTLS between Secrets Vault and all consumers
- [ ] Service identity tokens (short-lived, signed by platform IAM)
- [ ] Audit log write to `ops.audit_log`
- [ ] Rotation scheduler service
- [ ] OAuth refresh helpers in tenant supervisor
- [ ] Dashboard UI for:
  - [ ] Secret inventory per tenant (shows refs, kinds, last rotated, expires)
  - [ ] "Rotate all" emergency button
  - [ ] OAuth re-consent flow
- [ ] Runbook: secrets recovery, rotation troubleshooting, catastrophic loss
- [ ] Chaos test: rotate all secrets for a test tenant while it's actively running agents — no agent should fail
- [ ] Security review: external firm audits the model once we hit 10 paying tenants

---

## 11. What this spec does NOT cover

- **Per-user dashboard auth secrets.** Those live in Clerk (or whatever identity provider). This spec is about tenant/integration secrets, not operator login secrets.
- **Platform-level secrets not tied to tenants.** A separate, simpler flow uses a single platform CMK. Covered in Phase 6 ops runbooks.
- **Encryption at rest for vault file contents.** The vault is stored in GitHub (private repo + deploy key). GitHub handles encryption at rest. Separate concern.
- **Encryption at rest for log streams.** Loki + S3 storage handles that. Separate concern.
