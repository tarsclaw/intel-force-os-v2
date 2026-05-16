/**
 * AWS KMS operations for per-tenant CMK management
 * Per docs/phase-3-platform/secrets/secrets-vault-spec.md
 */

import {
  KMSClient,
  CreateKeyCommand,
  EncryptCommand,
  DecryptCommand,
  ScheduleKeyDeletionCommand,
  DescribeKeyCommand,
  type CreateKeyCommandOutput,
} from '@aws-sdk/client-kms';

const kms = new KMSClient({
  region: process.env['AWS_KMS_REGION'] ?? 'eu-west-2',
  credentials: {
    accessKeyId: process.env['AWS_ACCESS_KEY_ID'] ?? '',
    secretAccessKey: process.env['AWS_SECRET_ACCESS_KEY'] ?? '',
  },
});

// Encrypt plaintext with a tenant's CMK
export async function encryptWithCmk(cmkArn: string, plaintext: string): Promise<string> {
  const cmd = new EncryptCommand({
    KeyId: cmkArn,
    Plaintext: Buffer.from(plaintext, 'utf-8'),
    EncryptionContext: { purpose: 'intel-force-os-secret' },
  });
  const result = await kms.send(cmd);
  if (!result.CiphertextBlob) throw new Error('KMS encryption returned no ciphertext');
  return Buffer.from(result.CiphertextBlob).toString('base64');
}

// Decrypt ciphertext with a tenant's CMK
export async function decryptWithCmk(cmkArn: string, ciphertextBase64: string): Promise<string> {
  const cmd = new DecryptCommand({
    KeyId: cmkArn,
    CiphertextBlob: Buffer.from(ciphertextBase64, 'base64'),
    EncryptionContext: { purpose: 'intel-force-os-secret' },
  });
  const result = await kms.send(cmd);
  if (!result.Plaintext) throw new Error('KMS decryption returned no plaintext');
  return Buffer.from(result.Plaintext).toString('utf-8');
}

// Create a per-tenant CMK
export async function createTenantCmk(tenantId: string, plan: string): Promise<CreateKeyCommandOutput> {
  return kms.send(
    new CreateKeyCommand({
      Description: `Intel Force OS tenant CMK — ${tenantId}`,
      KeyUsage: 'ENCRYPT_DECRYPT',
      Origin: 'AWS_KMS',
      Tags: [
        { TagKey: 'tenant_id', TagValue: tenantId },
        { TagKey: 'plan', TagValue: plan },
        { TagKey: 'product', TagValue: 'intel-force-os' },
      ],
      // Enable automatic key rotation annually
      EnableKeyRotation: true,
    } as Parameters<typeof kms.send>[0]['input'] & { EnableKeyRotation?: boolean }),
  );
}

// Schedule CMK deletion (30-day pending window — GDPR erasure)
export async function scheduleCmkDeletion(cmkArn: string, pendingWindowDays = 30): Promise<void> {
  await kms.send(
    new ScheduleKeyDeletionCommand({
      KeyId: cmkArn,
      PendingWindowInDays: pendingWindowDays,
    }),
  );
}

// Verify CMK is accessible
export async function verifyCmk(cmkArn: string): Promise<boolean> {
  try {
    const result = await kms.send(new DescribeKeyCommand({ KeyId: cmkArn }));
    return result.KeyMetadata?.Enabled === true;
  } catch {
    return false;
  }
}
