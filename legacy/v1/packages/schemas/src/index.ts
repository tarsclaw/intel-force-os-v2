import { z } from 'zod';

// ─── Pagination ───────────────────────────────────────────────────────────────

export const CursorSchema = z.string().optional();
export const PaginationSchema = z.object({
  cursor: CursorSchema,
  limit: z.number().int().min(1).max(100).default(25),
});

// ─── Tenant ───────────────────────────────────────────────────────────────────

export const TenantSlugSchema = z
  .string()
  .min(2)
  .max(40)
  .regex(/^[a-z0-9-]+$/, 'Slug must be lowercase letters, numbers, and hyphens');

export const TenantCreateSchema = z.object({
  name: z.string().min(1).max(100),
  slug: TenantSlugSchema,
  plan: z.enum(['FOUNDING', 'STARTER', 'GROWTH', 'SCALE', 'ENTERPRISE', 'AGENCY_PARTNER']),
  billingEmail: z.string().email().optional(),
  timezone: z.string().default('Europe/London'),
  currency: z.enum(['GBP', 'EUR', 'USD']).default('GBP'),
  agentsEnabled: z.array(z.string()).default([]),
  costBudgetGbp: z.number().positive().optional(),
  hardStopBudget: z.boolean().default(false),
  parentTenantId: z.string().uuid().optional(),
  clerkOrgId: z.string().optional(),
});

export const TenantUpdateSchema = TenantCreateSchema.partial().omit({ slug: true });

// ─── Invocations ──────────────────────────────────────────────────────────────

export const InvocationListSchema = z.object({
  ...PaginationSchema.shape,
  agent: z.string().optional(),
  status: z.enum(['RUNNING', 'SUCCESS', 'FAILED', 'ESCALATED', 'CANCELLED']).optional(),
  dateFrom: z.coerce.date().optional(),
  dateTo: z.coerce.date().optional(),
  triggerType: z.string().optional(),
});

// ─── Escalations ─────────────────────────────────────────────────────────────

export const EscalationListSchema = z.object({
  ...PaginationSchema.shape,
  status: z.enum(['OPEN', 'ACKNOWLEDGED', 'RESOLVED', 'WONT_FIX']).optional(),
  severity: z.enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL']).optional(),
  category: z.string().optional(),
  dateFrom: z.coerce.date().optional(),
  dateTo: z.coerce.date().optional(),
});

export const EscalationResolveSchema = z.object({
  id: z.string().uuid(),
  resolution: z.string().min(1).max(2000),
});

// ─── Costs ───────────────────────────────────────────────────────────────────

export const CostPeriodSchema = z.object({
  dateFrom: z.coerce.date(),
  dateTo: z.coerce.date(),
});

export const BudgetSetSchema = z.object({
  costBudgetGbp: z.number().positive().max(100_000),
  hardStop: z.boolean().default(false),
});

// ─── Audit ───────────────────────────────────────────────────────────────────

export const AuditListSchema = z.object({
  ...PaginationSchema.shape,
  category: z.string().optional(),
  actorId: z.string().uuid().optional(),
  severity: z.enum(['INFO', 'WARN', 'ERROR', 'CRITICAL']).optional(),
  action: z.string().optional(),
  dateFrom: z.coerce.date().optional(),
  dateTo: z.coerce.date().optional(),
  search: z.string().max(200).optional(),
});

// ─── Wizard ──────────────────────────────────────────────────────────────────

export const WizardStep1Schema = z.object({
  name: z.string().min(1).max(100),
  slug: TenantSlugSchema,
  industry: z.string().min(1),
  ownerEmail: z.string().email(),
  billingEmail: z.string().email().optional(),
  website: z.string().url().optional(),
  timezone: z.string().default('Europe/London'),
  currency: z.enum(['GBP', 'EUR', 'USD']).default('GBP'),
  vatNumber: z.string().optional(),
});

export const WizardStep2Schema = z.object({
  plan: z.enum(['STARTER', 'GROWTH', 'SCALE', 'ENTERPRISE']),
  agentsEnabled: z.array(z.string()),
  costBudgetGbp: z.number().positive(),
  hardStopBudget: z.boolean().default(false),
});

export const WizardStep4Schema = z.object({
  services: z.array(z.string()).min(1),
  icp: z.string().min(10).max(500),
  positioningStatement: z.string().min(10).max(500),
  suppressionList: z.array(z.string()),
  bannedPhrases: z.array(z.string()),
});

// ─── Settings ─────────────────────────────────────────────────────────────────

export const TeamInviteSchema = z.object({
  email: z.string().email(),
  role: z.enum(['TENANT_OWNER', 'TENANT_MEMBER', 'TENANT_VIEWER']),
});

export const ApiKeyCreateSchema = z.object({
  name: z.string().min(1).max(50),
  scopes: z.array(
    z.enum([
      'read:all',
      'read:costs',
      'read:invocations',
      'read:escalations',
      'write:escalations',
      'write:settings',
    ]),
  ).min(1),
});

export const NotificationSettingsSchema = z.object({
  slackWebhookUrl: z.string().url().optional().or(z.literal('')),
  slackSeverities: z.array(z.enum(['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'])),
  emailRecipients: z.array(z.string().email()),
  emailDigest: z.enum(['instant', 'hourly', 'daily']),
  mutedCodes: z.array(z.string()),
});

export const TenantConfigUpdateSchema = z.object({
  name: z.string().min(1).max(100).optional(),
  billingEmail: z.string().email().optional(),
  timezone: z.string().optional(),
  vatNumber: z.string().optional(),
  website: z.string().url().optional().or(z.literal('')),
  costBudgetGbp: z.number().positive().optional(),
});

// ─── Shared types ─────────────────────────────────────────────────────────────

export type PaginationInput = z.infer<typeof PaginationSchema>;
export type TenantCreateInput = z.infer<typeof TenantCreateSchema>;
export type TenantUpdateInput = z.infer<typeof TenantUpdateSchema>;
export type InvocationListInput = z.infer<typeof InvocationListSchema>;
export type EscalationListInput = z.infer<typeof EscalationListSchema>;
export type AuditListInput = z.infer<typeof AuditListSchema>;
export type TeamInviteInput = z.infer<typeof TeamInviteSchema>;
