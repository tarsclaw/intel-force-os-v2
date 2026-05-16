/**
 * Secret storage and retrieval
 * Secrets are stored as encrypted blobs in Postgres.
 * The CMK ARN for each tenant is stored in the secrets table metadata.
 * Values are NEVER stored in plaintext.
 */

import { db } from '@intelforce/db';
import { encryptWithCmk, decryptWithCmk } from './kms';

interface SecretRecord {
  ref: string;
  tenantId: string;
  provider: string;
  kind: string;
  label: string;
  encryptedValue: string;
  cmkArn: string;
  createdAt: Date;
  updatedAt: Date;
  expiresAt: Date | null;
}

// In production: dedicated secrets table
// For v1: store in webhook_registrations with encrypted payload in secretHash field
// This is a simplification — Phase 3 replaces with proper secrets table

export async function storeSecret(params: {
  tenantId: string;
  provider: string;
  kind: 'api_key' | 'oauth_access_token' | 'oauth_refresh_token' | 'webhook_secret';
  label: string;
  value: string;
  cmkArn: string;
  expiresAt?: Date;
}): Promise<string> {
  const encrypted = await encryptWithCmk(params.cmkArn, params.value);
  const ref = `secrets://${params.tenantId.replace(/-/g, '')}/${params.provider}/${params.kind}`;

  await db.webhookRegistration.upsert({
    where: { id: `${params.tenantId}-${params.provider}-${params.kind}` },
    create: {
      id: `${params.tenantId}-${params.provider}-${params.kind}`,
      tenantId: params.tenantId,
      provider: params.provider,
      endpoint: ref,
      secretHash: JSON.stringify({
        encrypted,
        cmkArn: params.cmkArn,
        kind: params.kind,
        label: params.label,
        ref,
      }),
      status: 'active',
    },
    update: {
      secretHash: JSON.stringify({
        encrypted,
        cmkArn: params.cmkArn,
        kind: params.kind,
        label: params.label,
        ref,
      }),
      status: 'active',
    },
  });

  return ref;
}

export async function retrieveSecret(ref: string, tenantId: string): Promise<string> {
  // Parse ref: secrets://{tenantId_nohyphens}/{provider}/{kind}
  const parts = ref.replace('secrets://', '').split('/');
  if (parts.length < 3) throw new Error(`Invalid secret ref: ${ref}`);

  const [, provider, kind] = parts;

  const record = await db.webhookRegistration.findFirst({
    where: { tenantId, provider, id: `${tenantId}-${provider}-${kind}` },
  });

  if (!record) throw new Error(`Secret not found: ${ref}`);

  const meta = JSON.parse(record.secretHash) as {
    encrypted: string;
    cmkArn: string;
  };

  return decryptWithCmk(meta.cmkArn, meta.encrypted);
}

export async function listSecretRefs(tenantId: string) {
  const records = await db.webhookRegistration.findMany({
    where: { tenantId },
    select: { secretHash: true, provider: true, status: true, lastFiredAt: true, createdAt: true },
  });

  return records.map((r) => {
    const meta = r.secretHash.startsWith('{')
      ? (JSON.parse(r.secretHash) as { kind?: string; label?: string; ref?: string; cmkArn?: string })
      : null;

    return {
      ref: meta?.ref ?? `secrets://${tenantId}/${r.provider}/unknown`,
      provider: r.provider,
      kind: meta?.kind ?? 'unknown',
      label: meta?.label ?? r.provider,
      status: r.status as 'active' | 'disabled',
      lastAccessedAt: r.lastFiredAt,
      createdAt: r.createdAt,
      nextRotationAt: null as Date | null,
    };
  });
}

export async function rotateSecret(ref: string, tenantId: string, newValue: string): Promise<void> {
  const parts = ref.replace('secrets://', '').split('/');
  const [, provider, kind] = parts;

  const record = await db.webhookRegistration.findFirst({
    where: { tenantId, provider },
  });
  if (!record) throw new Error(`Secret not found: ${ref}`);

  const meta = JSON.parse(record.secretHash) as { cmkArn: string; label: string };

  // Re-encrypt with the same CMK
  const encrypted = await encryptWithCmk(meta.cmkArn, newValue);

  await db.webhookRegistration.update({
    where: { id: record.id },
    data: {
      secretHash: JSON.stringify({
        encrypted,
        cmkArn: meta.cmkArn,
        kind,
        label: meta.label,
        ref,
      }),
    },
  });
}
