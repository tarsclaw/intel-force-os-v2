import { TRPCError } from '@trpc/server';
import { z } from 'zod';
import { router, platformProcedure, tenantProcedure, authenticatedProcedure } from '../init';
import { TenantCreateSchema, TenantUpdateSchema, PaginationSchema } from '@intelforce/schemas';

export const tenantsRouter = router({
  list: platformProcedure
    .input(z.object({ ...PaginationSchema.shape, status: z.string().optional() }))
    .query(async ({ ctx, input }) => {
      const tenants = await ctx.db.tenant.findMany({
        where: input.status ? { status: input.status as never } : undefined,
        orderBy: { createdAt: 'desc' },
        take: input.limit,
        skip: input.cursor ? 1 : 0,
        cursor: input.cursor ? { id: input.cursor } : undefined,
      });
      const nextCursor = tenants.length === input.limit ? tenants[tenants.length - 1]?.id : null;
      return { items: tenants, nextCursor };
    }),

  get: tenantProcedure
    .input(z.object({ tenantId: z.string().uuid() }))
    .query(async ({ ctx, input }) => {
      const tenant = await ctx.db.tenant.findUnique({ where: { id: input.tenantId } });
      if (!tenant) throw new TRPCError({ code: 'NOT_FOUND' });
      return tenant;
    }),

  getBySlug: authenticatedProcedure
    .input(z.object({ slug: z.string() }))
    .query(async ({ ctx, input }) => {
      const tenant = await ctx.db.tenant.findUnique({ where: { slug: input.slug } });
      if (!tenant) throw new TRPCError({ code: 'NOT_FOUND' });
      return tenant;
    }),

  create: platformProcedure
    .input(TenantCreateSchema)
    .mutation(async ({ ctx, input }) => {
      const existing = await ctx.db.tenant.findUnique({ where: { slug: input.slug } });
      if (existing) throw new TRPCError({ code: 'CONFLICT', message: 'Slug already taken' });
      return ctx.db.tenant.create({ data: input });
    }),

  update: tenantProcedure
    .input(z.object({ tenantId: z.string().uuid(), data: TenantUpdateSchema }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db.tenant.update({ where: { id: input.tenantId }, data: input.data });
    }),

  suspend: platformProcedure
    .input(z.object({ tenantId: z.string().uuid(), reason: z.string() }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db.tenant.update({
        where: { id: input.tenantId },
        data: { status: 'SUSPENDED', suspendedAt: new Date() },
      });
    }),

  resume: platformProcedure
    .input(z.object({ tenantId: z.string().uuid() }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db.tenant.update({
        where: { id: input.tenantId },
        data: { status: 'ACTIVE', suspendedAt: null },
      });
    }),

  metrics: tenantProcedure
    .input(z.object({ tenantId: z.string().uuid(), period: z.enum(['week', 'month', '30d', '90d']) }))
    .query(async ({ ctx, input }) => {
      const now = new Date();
      const from = new Date(now);
      if (input.period === 'week') from.setDate(now.getDate() - 7);
      else if (input.period === 'month') from.setDate(1);
      else if (input.period === '30d') from.setDate(now.getDate() - 30);
      else from.setDate(now.getDate() - 90);

      const [invocations, escalations, costs] = await Promise.all([
        ctx.db.invocation.groupBy({
          by: ['status'],
          where: { tenantId: input.tenantId, startedAt: { gte: from } },
          _count: true,
        }),
        ctx.db.escalation.count({
          where: { tenantId: input.tenantId, createdAt: { gte: from }, status: 'OPEN' },
        }),
        ctx.db.cost.aggregate({
          where: { tenantId: input.tenantId, recordedAt: { gte: from } },
          _sum: { costGbp: true },
        }),
      ]);

      const total = invocations.reduce((acc, g) => acc + g._count, 0);
      const success = invocations.find((g) => g.status === 'SUCCESS')?._count ?? 0;

      return {
        invocationsTotal: total,
        invocationsSuccess: success,
        successRate: total > 0 ? Math.round((success / total) * 100) : 0,
        openEscalations: escalations,
        monthSpendGbp: Number(costs._sum.costGbp ?? 0),
      };
    }),
});

