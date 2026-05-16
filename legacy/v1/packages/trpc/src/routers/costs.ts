import { z } from 'zod';
import { router, tenantProcedure } from '../init';
import { BudgetSetSchema } from '@intelforce/schemas';

export const costsRouter = router({
  currentMonth: tenantProcedure.query(async ({ ctx }) => {
    const now = new Date();
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    const [total, byDay, byAgent, tenant] = await Promise.all([
      ctx.db.cost.aggregate({
        where: { tenantId: ctx.tenantId, recordedAt: { gte: monthStart } },
        _sum: { costGbp: true, inputTokens: true, outputTokens: true, cacheHits: true },
      }),
      ctx.db.cost.groupBy({
        by: ['recordedAt'],
        where: { tenantId: ctx.tenantId, recordedAt: { gte: monthStart } },
        _sum: { costGbp: true },
        orderBy: { recordedAt: 'asc' },
      }),
      ctx.db.invocation.groupBy({
        by: ['agent'],
        where: { tenantId: ctx.tenantId, startedAt: { gte: monthStart } },
        _count: true,
        _sum: { costGbp: true },
      }),
      ctx.db.tenant.findUnique({
        where: { id: ctx.tenantId },
        select: { costBudgetGbp: true, hardStopBudget: true },
      }),
    ]);

    const spend = Number(total._sum.costGbp ?? 0);
    const budget = tenant?.costBudgetGbp ? Number(tenant.costBudgetGbp) : null;

    return {
      spendGbp: spend,
      budgetGbp: budget,
      budgetUsedPercent: budget ? Math.round((spend / budget) * 100) : null,
      hardStop: tenant?.hardStopBudget ?? false,
      inputTokens: total._sum.inputTokens ?? 0,
      outputTokens: total._sum.outputTokens ?? 0,
      cacheHits: total._sum.cacheHits ?? 0,
      byDay: byDay.map((d) => ({
        date: d.recordedAt.toISOString().slice(0, 10),
        costGbp: Number(d._sum.costGbp ?? 0),
      })),
      byAgent: byAgent.map((a) => ({
        agent: a.agent,
        invocations: a._count,
        costGbp: Number(a._sum.costGbp ?? 0),
      })),
    };
  }),

  setBudget: tenantProcedure
    .input(BudgetSetSchema)
    .mutation(async ({ ctx, input }) => {
      return ctx.db.tenant.update({
        where: { id: ctx.tenantId },
        data: {
          costBudgetGbp: input.costBudgetGbp,
          hardStopBudget: input.hardStop,
        },
      });
    }),

  byDay: tenantProcedure
    .input(z.object({ days: z.number().int().min(7).max(90).default(30) }))
    .query(async ({ ctx, input }) => {
      const from = new Date();
      from.setDate(from.getDate() - input.days);

      return ctx.db.cost.groupBy({
        by: ['recordedAt', 'provider'],
        where: { tenantId: ctx.tenantId, recordedAt: { gte: from } },
        _sum: { costGbp: true },
        orderBy: { recordedAt: 'asc' },
      });
    }),
});
