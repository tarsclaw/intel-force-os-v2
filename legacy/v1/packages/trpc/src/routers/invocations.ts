import { TRPCError } from '@trpc/server';
import { z } from 'zod';
import { router, tenantProcedure } from '../init';
import { InvocationListSchema } from '@intelforce/schemas';

export const invocationsRouter = router({
  list: tenantProcedure
    .input(InvocationListSchema)
    .query(async ({ ctx, input }) => {
      const items = await ctx.db.invocation.findMany({
        where: {
          tenantId: ctx.tenantId,
          ...(input.agent ? { agent: input.agent } : {}),
          ...(input.status ? { status: input.status as never } : {}),
          ...(input.dateFrom || input.dateTo
            ? { startedAt: { gte: input.dateFrom, lte: input.dateTo } }
            : {}),
          ...(input.triggerType ? { trigger: input.triggerType } : {}),
        },
        orderBy: { startedAt: 'desc' },
        take: input.limit,
        skip: input.cursor ? 1 : 0,
        cursor: input.cursor ? { id: input.cursor } : undefined,
      });
      return { items, nextCursor: items.length === input.limit ? items[items.length - 1]?.id : null };
    }),

  get: tenantProcedure
    .input(z.object({ id: z.string().uuid() }))
    .query(async ({ ctx, input }) => {
      const inv = await ctx.db.invocation.findFirst({
        where: { id: input.id, tenantId: ctx.tenantId },
        include: { costs: true },
      });
      if (!inv) throw new TRPCError({ code: 'NOT_FOUND' });
      return inv;
    }),

  listRunning: tenantProcedure.query(async ({ ctx }) => {
    return ctx.db.invocation.findMany({
      where: { tenantId: ctx.tenantId, status: 'RUNNING' },
      orderBy: { startedAt: 'asc' },
      take: 10,
    });
  }),
});
