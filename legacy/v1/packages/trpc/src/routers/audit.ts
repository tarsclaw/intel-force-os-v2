import { z } from 'zod';
import { router, tenantProcedure, platformProcedure } from '../init';
import { AuditListSchema } from '@intelforce/schemas';

export const auditRouter = router({
  list: tenantProcedure
    .input(AuditListSchema)
    .query(async ({ ctx, input }) => {
      const items = await ctx.db.auditEvent.findMany({
        where: {
          tenantId: ctx.tenantId,
          ...(input.category ? { action: { startsWith: input.category } } : {}),
          ...(input.actorId ? { actorId: input.actorId } : {}),
          ...(input.severity ? { severity: input.severity as never } : {}),
          ...(input.action ? { action: { contains: input.action, mode: 'insensitive' as const } } : {}),
          ...(input.dateFrom || input.dateTo
            ? { createdAt: { gte: input.dateFrom, lte: input.dateTo } }
            : {}),
          ...(input.search
            ? {
                OR: [
                  { action: { contains: input.search, mode: 'insensitive' as const } },
                  { detail: { contains: input.search, mode: 'insensitive' as const } },
                  { actorLabel: { contains: input.search, mode: 'insensitive' as const } },
                ],
              }
            : {}),
        },
        orderBy: { createdAt: 'desc' },
        take: input.limit,
        skip: input.cursor ? 1 : 0,
        cursor: input.cursor ? { id: input.cursor } : undefined,
        include: { actor: { select: { name: true, email: true, imageUrl: true } } },
      });

      return { items, nextCursor: items.length === input.limit ? items[items.length - 1]?.id : null };
    }),

  listGlobal: platformProcedure
    .input(AuditListSchema)
    .query(async ({ ctx, input }) => {
      const items = await ctx.db.auditEvent.findMany({
        where: {
          ...(input.severity ? { severity: input.severity as never } : {}),
          ...(input.dateFrom || input.dateTo
            ? { createdAt: { gte: input.dateFrom, lte: input.dateTo } }
            : {}),
        },
        orderBy: { createdAt: 'desc' },
        take: input.limit,
        include: {
          actor: { select: { name: true, email: true } },
          tenant: { select: { name: true, slug: true } },
        },
      });
      return { items, nextCursor: items.length === input.limit ? items[items.length - 1]?.id : null };
    }),

  export: tenantProcedure
    .input(z.object({ format: z.enum(['json', 'csv']), ...AuditListSchema.shape }))
    .mutation(async ({ ctx, input }) => {
      const items = await ctx.db.auditEvent.findMany({
        where: { tenantId: ctx.tenantId },
        orderBy: { createdAt: 'desc' },
        take: 10_000,
      });
      // In production: stream to S3 and return a download URL
      return { count: items.length, format: input.format };
    }),
});
