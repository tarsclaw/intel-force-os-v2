import { TRPCError } from '@trpc/server';
import { z } from 'zod';
import { router, tenantProcedure } from '../init';
import { EscalationListSchema, EscalationResolveSchema } from '@intelforce/schemas';

export const escalationsRouter = router({
  list: tenantProcedure
    .input(EscalationListSchema)
    .query(async ({ ctx, input }) => {
      const where = {
        tenantId: ctx.tenantId,
        ...(input.status ? { status: input.status as never } : {}),
        ...(input.severity ? { severity: input.severity as never } : {}),
        ...(input.category ? { category: { contains: input.category, mode: 'insensitive' as const } } : {}),
        ...(input.dateFrom || input.dateTo
          ? { createdAt: { gte: input.dateFrom, lte: input.dateTo } }
          : {}),
      };

      const items = await ctx.db.escalation.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        take: input.limit,
        skip: input.cursor ? 1 : 0,
        cursor: input.cursor ? { id: input.cursor } : undefined,
      });

      return {
        items,
        nextCursor: items.length === input.limit ? items[items.length - 1]?.id : null,
      };
    }),

  get: tenantProcedure
    .input(z.object({ id: z.string().uuid() }))
    .query(async ({ ctx, input }) => {
      const esc = await ctx.db.escalation.findFirst({
        where: { id: input.id, tenantId: ctx.tenantId },
      });
      if (!esc) throw new TRPCError({ code: 'NOT_FOUND' });
      return esc;
    }),

  resolve: tenantProcedure
    .input(EscalationResolveSchema)
    .mutation(async ({ ctx, input }) => {
      const esc = await ctx.db.escalation.findFirst({
        where: { id: input.id, tenantId: ctx.tenantId },
      });
      if (!esc) throw new TRPCError({ code: 'NOT_FOUND' });
      if (esc.status === 'RESOLVED') throw new TRPCError({ code: 'CONFLICT', message: 'Already resolved' });

      return ctx.db.escalation.update({
        where: { id: input.id },
        data: {
          status: 'RESOLVED',
          resolvedById: ctx.userId,
          resolvedAt: new Date(),
          resolution: input.resolution,
        },
      });
    }),

  wontFix: tenantProcedure
    .input(z.object({ id: z.string().uuid(), reason: z.string().min(1) }))
    .mutation(async ({ ctx, input }) => {
      const esc = await ctx.db.escalation.findFirst({
        where: { id: input.id, tenantId: ctx.tenantId },
      });
      if (!esc) throw new TRPCError({ code: 'NOT_FOUND' });

      return ctx.db.escalation.update({
        where: { id: input.id },
        data: {
          status: 'WONT_FIX',
          resolvedById: ctx.userId,
          resolvedAt: new Date(),
          resolution: input.reason,
        },
      });
    }),

  acknowledge: tenantProcedure
    .input(z.object({ id: z.string().uuid() }))
    .mutation(async ({ ctx, input }) => {
      return ctx.db.escalation.update({
        where: { id: input.id },
        data: { status: 'ACKNOWLEDGED' },
      });
    }),

  listGlobal: tenantProcedure
    .input(EscalationListSchema)
    .query(async ({ ctx, input }) => {
      // Platform admins can see across tenants — tenant filter removed
      const items = await ctx.db.escalation.findMany({
        where: {
          ...(input.status ? { status: input.status as never } : {}),
          ...(input.severity ? { severity: input.severity as never } : {}),
        },
        orderBy: { createdAt: 'desc' },
        take: input.limit,
        include: { tenant: { select: { name: true, slug: true } } },
      });
      return { items, nextCursor: items.length === input.limit ? items[items.length - 1]?.id : null };
    }),
});
