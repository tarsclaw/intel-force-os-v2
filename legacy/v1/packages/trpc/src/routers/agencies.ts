import { TRPCError } from '@trpc/server';
import { z } from 'zod';
import { router, authenticatedProcedure, agencyProcedure, platformProcedure } from '../init';
import { PaginationSchema, TenantCreateSchema } from '@intelforce/schemas';

export const agenciesRouter = router({
  list: platformProcedure
    .input(PaginationSchema)
    .query(async ({ ctx, input }) => {
      const items = await ctx.db.tenant.findMany({
        where: { plan: 'AGENCY_PARTNER' },
        orderBy: { createdAt: 'desc' },
        take: input.limit,
        skip: input.cursor ? 1 : 0,
        cursor: input.cursor ? { id: input.cursor } : undefined,
        include: {
          _count: { select: { subTenants: true } },
        },
      });
      return { items, nextCursor: items.length === input.limit ? items[items.length - 1]?.id : null };
    }),

  get: agencyProcedure
    .input(z.object({ agencyId: z.string().uuid() }))
    .query(async ({ ctx, input }) => {
      const agency = await ctx.db.tenant.findUnique({
        where: { id: input.agencyId },
        include: { _count: { select: { subTenants: true } } },
      });
      if (!agency) throw new TRPCError({ code: 'NOT_FOUND' });
      return agency;
    }),

  getBySlug: authenticatedProcedure
    .input(z.object({ slug: z.string() }))
    .query(async ({ ctx, input }) => {
      const agency = await ctx.db.tenant.findFirst({
        where: { slug: input.slug, plan: 'AGENCY_PARTNER' },
      });
      if (!agency) throw new TRPCError({ code: 'NOT_FOUND' });
      return agency;
    }),

  listSubTenants: agencyProcedure
    .input(z.object({
      agencyId: z.string().uuid(),
      ...PaginationSchema.shape,
      status: z.string().optional(),
      search: z.string().optional(),
    }))
    .query(async ({ ctx, input }) => {
      const items = await ctx.db.tenant.findMany({
        where: {
          parentTenantId: input.agencyId,
          ...(input.status ? { status: input.status as never } : {}),
          ...(input.search
            ? { name: { contains: input.search, mode: 'insensitive' as const } }
            : {}),
        },
        orderBy: { createdAt: 'desc' },
        take: input.limit,
        skip: input.cursor ? 1 : 0,
        cursor: input.cursor ? { id: input.cursor } : undefined,
      });
      return { items, nextCursor: items.length === input.limit ? items[items.length - 1]?.id : null };
    }),

  aggregateMetrics: agencyProcedure
    .input(z.object({ agencyId: z.string().uuid() }))
    .query(async ({ ctx, input }) => {
      const subTenants = await ctx.db.tenant.findMany({
        where: { parentTenantId: input.agencyId },
        select: { id: true },
      });
      const subTenantIds = subTenants.map((t) => t.id);

      if (subTenantIds.length === 0) {
        return { tenantCount: 0, openEscalations: 0, monthSpendGbp: 0, invocationsTotal: 0, successRate: 0 };
      }

      const now = new Date();
      const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

      const [escalations, invocations, costs] = await Promise.all([
        ctx.db.escalation.count({
          where: { tenantId: { in: subTenantIds }, status: { in: ['OPEN', 'ACKNOWLEDGED'] } },
        }),
        ctx.db.invocation.groupBy({
          by: ['status'],
          where: { tenantId: { in: subTenantIds }, startedAt: { gte: monthStart } },
          _count: true,
        }),
        ctx.db.cost.aggregate({
          where: { tenantId: { in: subTenantIds }, recordedAt: { gte: monthStart } },
          _sum: { costGbp: true },
        }),
      ]);

      const total = invocations.reduce((acc, g) => acc + g._count, 0);
      const success = invocations.find((g) => g.status === 'SUCCESS')?._count ?? 0;

      return {
        tenantCount: subTenantIds.length,
        openEscalations: escalations,
        monthSpendGbp: Number(costs._sum.costGbp ?? 0),
        invocationsTotal: total,
        successRate: total > 0 ? Math.round((success / total) * 100) : 0,
      };
    }),

  create: platformProcedure
    .input(TenantCreateSchema)
    .mutation(async ({ ctx, input }) => {
      return ctx.db.tenant.create({ data: { ...input, plan: 'AGENCY_PARTNER' as never } });
    }),

  addSubTenant: agencyProcedure
    .input(z.object({ agencyId: z.string().uuid(), subTenantId: z.string().uuid() }))
    .mutation(async ({ ctx, input }) => {
      const sub = await ctx.db.tenant.findUnique({ where: { id: input.subTenantId } });
      if (!sub) throw new TRPCError({ code: 'NOT_FOUND' });
      if (sub.parentTenantId) throw new TRPCError({ code: 'CONFLICT', message: 'Tenant already has a parent' });

      return ctx.db.tenant.update({
        where: { id: input.subTenantId },
        data: { parentTenantId: input.agencyId },
      });
    }),
});
