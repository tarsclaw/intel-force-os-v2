export interface TenantConfig {
  tenantId: string;
  customerName: string;
  customerDomain: string;

  // Agent config
  anthropicModel?: string;
  handbookKvKey: string; // e.g. "handbook_text:abc-123"
  breatheHrApiKeyRef?: string; // Secrets Vault ref, e.g. "secrets://{tenantId}/breathe_hr/api_key"

  // Approval flow
  hrLeadAadId: string;
  hrLeadEmail: string;
  backupHrLeadAadId?: string;

  // Behaviour
  approvalMode: 'all' | 'sensitive_only' | 'none';
  sensitivityThreshold: number;
  channels: string[];
  escalationChannels: Record<string, 'hr_lead' | 'backup' | 'both'>;

  // Tone
  companyTone: string;

  // Reporting
  weeklyReportEnabled: boolean;
  weeklyReportTime: string;

  // Compliance
  auditRetentionDays: number;
  piiRedactionEnabled: boolean;

  // Subscription
  subscriptionTier: 'founding' | 'starter' | 'growth';
  subscriptionStatus: 'active' | 'suspended' | 'cancelled';

  // Metadata
  createdAt: string;
  updatedAt: string;
  version: number;
}

export interface ConversationRef {
  serviceUrl: string;
  conversationId: string;
  tenantId: string;
  botId: string;
  userId: string;
}

const TENANT_PREFIX = 'tenant_config:';
const CONVO_PREFIX = 'hr_lead_conversation:';
const HANDBOOK_PREFIX = 'handbook_text:';

export async function getTenantConfig(
  kv: KVNamespace,
  tenantId: string,
): Promise<TenantConfig | null> {
  const json = await kv.get(`${TENANT_PREFIX}${tenantId}`);
  if (!json) return null;
  try {
    return JSON.parse(json) as TenantConfig;
  } catch {
    return null;
  }
}

export async function setTenantConfig(
  kv: KVNamespace,
  tenantId: string,
  config: TenantConfig,
): Promise<void> {
  const updated: TenantConfig = { ...config, updatedAt: new Date().toISOString() };
  await kv.put(`${TENANT_PREFIX}${tenantId}`, JSON.stringify(updated));
}

export async function getAllTenantIds(kv: KVNamespace): Promise<string[]> {
  const list = await kv.list({ prefix: TENANT_PREFIX });
  return list.keys.map((k) => k.name.replace(TENANT_PREFIX, ''));
}

export async function getConversationRef(
  kv: KVNamespace,
  tenantId: string,
  aadObjectId: string,
): Promise<ConversationRef | null> {
  const json = await kv.get(`${CONVO_PREFIX}${tenantId}:${aadObjectId}`);
  if (!json) return null;
  try {
    return JSON.parse(json) as ConversationRef;
  } catch {
    return null;
  }
}

export async function setConversationRef(
  kv: KVNamespace,
  tenantId: string,
  aadObjectId: string,
  ref: ConversationRef,
): Promise<void> {
  await kv.put(`${CONVO_PREFIX}${tenantId}:${aadObjectId}`, JSON.stringify(ref));
}

export async function getHandbookText(
  kv: KVNamespace,
  tenantId: string,
): Promise<string> {
  return (await kv.get(`${HANDBOOK_PREFIX}${tenantId}`)) ?? '';
}

export async function setHandbookText(
  kv: KVNamespace,
  tenantId: string,
  text: string,
): Promise<void> {
  await kv.put(`${HANDBOOK_PREFIX}${tenantId}`, text);
}
