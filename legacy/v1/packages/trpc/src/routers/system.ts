import { z } from 'zod';
import { router, platformProcedure, publicProcedure } from '../init';

export const systemRouter = router({
  health: publicProcedure.query(async ({ ctx }) => {
    let dbOk = false;
    try {
      await ctx.db.$queryRaw`SELECT 1`;
      dbOk = true;
    } catch {
      dbOk = false;
    }

    return {
      status: dbOk ? 'ok' : 'degraded',
      db: dbOk ? 'ok' : 'error',
      ts: Date.now(),
    };
  }),

  deployments: platformProcedure
    .input(z.object({ component: z.string().optional(), limit: z.number().int().default(10) }))
    .query(async ({ ctx, input }) => {
      return ctx.db.deployment.findMany({
        where: input.component ? { component: input.component } : undefined,
        orderBy: { deployedAt: 'desc' },
        take: input.limit,
      });
    }),

  alerts: platformProcedure.query(async ({ ctx }) => {
    // Derive alerts from DB state
    const now = new Date();
    const dayAgo = new Date(now.getTime() - 86_400_000);

    const [openEscalations, failedInvocations, activeTenants] = await Promise.all([
      ctx.db.escalation.count({ where: { status: 'OPEN', createdAt: { gte: dayAgo } } }),
      ctx.db.invocation.count({ where: { status: 'FAILED', startedAt: { gte: dayAgo } } }),
      ctx.db.tenant.count({ where: { status: 'ACTIVE' } }),
    ]);

    const alerts = [];

    if (openEscalations > 10) {
      alerts.push({
        severity: 'HIGH',
        message: `${openEscalations} open escalations in the last 24h`,
        category: 'escalations',
      });
    }

    if (failedInvocations > 20) {
      alerts.push({
        severity: 'MEDIUM',
        message: `${failedInvocations} failed invocations in the last 24h`,
        category: 'invocations',
      });
    }

    return {
      alerts,
      summary: {
        activeTenants,
        openEscalations,
        failedInvocationsDay: failedInvocations,
      },
    };
  }),
});
