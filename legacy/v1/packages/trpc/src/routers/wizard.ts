import { TRPCError } from '@trpc/server';
import { z } from 'zod';
import { router, authenticatedProcedure, platformProcedure } from '../init';
import {
  WizardStep1Schema,
  WizardStep2Schema,
  WizardStep4Schema,
} from '@intelforce/schemas';

const DRAFT_TTL_DAYS = 30;

/**
 * Trigger a brain build for a newly-created tenant.
 *
 * Routes (in order of preference):
 *   1. CF_BRAIN_QUEUE_URL  — Cloudflare Queue producer URL (durable, retryable)
 *   2. BRAIN_BUILDER_URL   — direct HTTP call (simple, less durable)
 *   3. Neither — log and return; operator does it manually.
 *
 * In all paths this is best-effort: the wizard never fails on a brain build
 * trigger error. The BrainGraph row stays at PENDING and can be retried.
 */
async function enqueueBrainBuild(payload: { tenantSlug: string; sourceDir: string }): Promise<void> {
  const queueUrl = process.env.CF_BRAIN_QUEUE_URL;
  const builderUrl = process.env.BRAIN_BUILDER_URL;
  const sharedToken = process.env.BRAIN_BUILDER_TOKEN;

  if (queueUrl) {
    const r = await fetch(queueUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(sharedToken ? { Authorization: `Bearer ${sharedToken}` } : {}),
      },
      body: JSON.stringify({ type: 'brain.build', payload }),
    });
    if (!r.ok) throw new Error(`CF queue returned ${r.status}: ${await r.text().catch(() => '')}`);
    return;
  }

  if (builderUrl) {
    const r = await fetch(`${builderUrl.replace(/\/$/, '')}/build`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(sharedToken ? { Authorization: `Bearer ${sharedToken}` } : {}),
      },
      body: JSON.stringify(payload),
    });
    if (!r.ok && r.status !== 202) {
      throw new Error(`brain-builder returned ${r.status}: ${await r.text().catch(() => '')}`);
    }
    return;
  }

  console.warn(
    `[wizard] Neither CF_BRAIN_QUEUE_URL nor BRAIN_BUILDER_URL set. Tenant ${payload.tenantSlug} brain stays PENDING. ` +
    `Build manually with: pnpm --filter @intelforce/brain-builder build:tenant -- --tenant-slug ${payload.tenantSlug} --source-dir <path>`,
  );
}

function expiresAt() {
  const d = new Date();
  d.setDate(d.getDate() + DRAFT_TTL_DAYS);
  return d;
}

export const wizardRouter = router({
  // Start a new draft or return existing incomplete one
  begin: authenticatedProcedure
    .input(z.object({ agencyId: z.string().uuid().optional() }))
    .mutation(async ({ ctx, input }) => {
      const existing = await ctx.db.wizardDraft.findFirst({
        where: {
          createdById: ctx.userId,
          submittedAt: null,
          expiresAt: { gt: new Date() },
          ...(input.agencyId ? { agencyId: input.agencyId } : {}),
        },
        orderBy: { createdAt: 'desc' },
      });
      if (existing) return existing;

      return ctx.db.wizardDraft.create({
        data: {
          createdById: ctx.userId,
          agencyId: input.agencyId ?? null,
          currentStep: 1,
          draftData: {},
          expiresAt: expiresAt(),
        },
      });
    }),

  // Save a step's data (auto-saves even if invalid — just persists)
  saveStep: authenticatedProcedure
    .input(z.object({
      draftId: z.string().uuid(),
      step: z.number().int().min(1).max(9),
      data: z.record(z.unknown()),
    }))
    .mutation(async ({ ctx, input }) => {
      const draft = await ctx.db.wizardDraft.findFirst({
        where: { id: input.draftId, createdById: ctx.userId, submittedAt: null },
      });
      if (!draft) throw new TRPCError({ code: 'NOT_FOUND' });

      const existingData = draft.draftData as Record<string, unknown>;
      const merged = { ...existingData, [`step${input.step}`]: input.data };

      return ctx.db.wizardDraft.update({
        where: { id: input.draftId },
        data: {
          // Prisma's InputJsonValue is a structural subset of any plain
          // JSON-serialisable object. Casting through unknown is the
          // documented escape hatch for nested generic Records.
          draftData: merged as unknown as object,
          currentStep: Math.max(draft.currentStep, input.step),
          updatedAt: new Date(),
        },
      });
    }),

  // Validate a specific step (returns errors array)
  validate: authenticatedProcedure
    .input(z.object({
      draftId: z.string().uuid(),
      step: z.number().int().min(1).max(7),
    }))
    .query(async ({ ctx, input }) => {
      const draft = await ctx.db.wizardDraft.findFirst({
        where: { id: input.draftId, createdById: ctx.userId },
      });
      if (!draft) throw new TRPCError({ code: 'NOT_FOUND' });

      const data = draft.draftData as Record<string, Record<string, unknown>>;
      const stepData = data[`step${input.step}`] ?? {};
      const errors: string[] = [];

      if (input.step === 1) {
        const result = WizardStep1Schema.safeParse(stepData);
        if (!result.success) {
          errors.push(...result.error.issues.map((i) => `${i.path.join('.')}: ${i.message}`));
        }
        // Check slug uniqueness
        if (result.success) {
          const existing = await ctx.db.tenant.findUnique({ where: { slug: result.data.slug } });
          if (existing) errors.push('slug: This slug is already taken');
        }
      }

      if (input.step === 2) {
        const result = WizardStep2Schema.safeParse(stepData);
        if (!result.success) {
          errors.push(...result.error.issues.map((i) => `${i.path.join('.')}: ${i.message}`));
        }
      }

      if (input.step === 4) {
        const result = WizardStep4Schema.safeParse(stepData);
        if (!result.success) {
          errors.push(...result.error.issues.map((i) => `${i.path.join('.')}: ${i.message}`));
        }
      }

      return { valid: errors.length === 0, errors };
    }),

  // Final submit — validates everything, creates tenant
  submit: authenticatedProcedure
    .input(z.object({
      draftId: z.string().uuid(),
      confirmSlug: z.string(), // User must type the slug to confirm
    }))
    .mutation(async ({ ctx, input }) => {
      const draft = await ctx.db.wizardDraft.findFirst({
        where: { id: input.draftId, createdById: ctx.userId, submittedAt: null },
      });
      if (!draft) throw new TRPCError({ code: 'NOT_FOUND' });

      const data = draft.draftData as Record<string, Record<string, unknown>>;

      // Validate step 1
      const step1 = WizardStep1Schema.safeParse(data['step1'] ?? {});
      if (!step1.success) throw new TRPCError({ code: 'BAD_REQUEST', message: 'Step 1 incomplete' });

      if (input.confirmSlug !== step1.data.slug) {
        throw new TRPCError({ code: 'BAD_REQUEST', message: 'Slug confirmation does not match' });
      }

      // Validate step 2
      const step2 = WizardStep2Schema.safeParse(data['step2'] ?? {});
      if (!step2.success) throw new TRPCError({ code: 'BAD_REQUEST', message: 'Step 2 incomplete' });

      // Check slug uniqueness
      const existing = await ctx.db.tenant.findUnique({ where: { slug: step1.data.slug } });
      if (existing) throw new TRPCError({ code: 'CONFLICT', message: 'Slug already taken' });

      // Create the tenant
      const tenant = await ctx.db.tenant.create({
        data: {
          slug: step1.data.slug,
          name: step1.data.name,
          plan: step2.data.plan as never,
          status: 'PENDING',
          billingEmail: step1.data.billingEmail ?? step1.data.ownerEmail,
          timezone: step1.data.timezone,
          currency: step1.data.currency as never,
          agentsEnabled: step2.data.agentsEnabled,
          costBudgetGbp: step2.data.costBudgetGbp,
          hardStopBudget: step2.data.hardStopBudget,
          ...(draft.agencyId ? { parentTenantId: draft.agencyId } : {}),
        },
      });

      // Mark draft submitted
      await ctx.db.wizardDraft.update({
        where: { id: draft.id },
        data: { submittedAt: new Date(), tenantId: tenant.id },
      });

      // Create the brain graph row immediately. The brain-builder will flip
      // it to BUILDING and then READY/FAILED as work proceeds — the dashboard
      // reads from this row directly.
      await ctx.db.brainGraph.create({
        data: {
          tenantId: tenant.id,
          status: 'PENDING',
        },
      });

      // Trigger the brain build, fire-and-forget. Two transports supported:
      //
      //   1. Cloudflare Queue (preferred for production durability) —
      //      send a message to CF_BRAIN_QUEUE_URL; a consumer Worker
      //      drains it and POSTs to brain-builder-server.
      //
      //   2. Direct HTTP — POST to BRAIN_BUILDER_URL, fire-and-forget.
      //      Simpler, no queue infra needed for early customers.
      //
      // If neither env is set, the wizard still completes — the brain row
      // stays PENDING and the dashboard shows demo data with a banner. An
      // operator can then build manually:
      //   pnpm --filter @intelforce/brain-builder build:tenant -- \
      //     --tenant-slug <slug> --source-dir <path-to-handbook>
      const brainSourceDir = (data['step3'] as { sourceDir?: string } | undefined)?.sourceDir;
      void enqueueBrainBuild({
        tenantSlug: step1.data.slug,
        sourceDir: brainSourceDir ?? `/data/uploads/${step1.data.slug}`,
      }).catch((err) => {
        // Non-fatal — the wizard still succeeds. The build can be retried.
        console.error('[wizard] brain build enqueue failed:', err);
      });

      return { tenant, workflowId: null }; // workflowId populated by Temporal when provisioning is wired
    }),

  getDraft: authenticatedProcedure
    .input(z.object({ draftId: z.string().uuid() }))
    .query(async ({ ctx, input }) => {
      const draft = await ctx.db.wizardDraft.findFirst({
        where: { id: input.draftId, createdById: ctx.userId },
      });
      if (!draft) throw new TRPCError({ code: 'NOT_FOUND' });
      return draft;
    }),

  listDrafts: authenticatedProcedure
    .query(async ({ ctx }) => {
      return ctx.db.wizardDraft.findMany({
        where: {
          createdById: ctx.userId,
          submittedAt: null,
          expiresAt: { gt: new Date() },
        },
        orderBy: { updatedAt: 'desc' },
        take: 10,
      });
    }),

  deleteDraft: authenticatedProcedure
    .input(z.object({ draftId: z.string().uuid() }))
    .mutation(async ({ ctx, input }) => {
      await ctx.db.wizardDraft.deleteMany({
        where: { id: input.draftId, createdById: ctx.userId },
      });
    }),
});
