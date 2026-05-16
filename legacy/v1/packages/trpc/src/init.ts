import { initTRPC, TRPCError } from '@trpc/server';
import { ZodError } from 'zod';
import type { Context } from './context';

// NOTE: providers.tsx (in apps/dashboard) attaches a `superjson` transformer
// on the client side. To match, install `superjson` in this package and add
// `transformer: superjson` to the .create() call below. We don't add the
// dependency here without an explicit go-ahead — see PRODUCTION-CHECKLIST.md.

const t = initTRPC.context<Context>().create({
  errorFormatter({ shape, error }) {
    return {
      ...shape,
      data: {
        ...shape.data,
        zodError:
          error.cause instanceof ZodError ? error.cause.flatten() : null,
      },
    };
  },
});

export const router = t.router;
export const middleware = t.middleware;
// In tRPC v11, createCallerFactory lives on the `t` instance instead of
// being importable from `@trpc/server`. Export from here so consumers don't
// need direct access to `t`.
export const createCallerFactory = t.createCallerFactory;

// ─── Middleware ───────────────────────────────────────────────────────────────

const enforceAuth = middleware(({ ctx, next }) => {
  if (!ctx.userId) {
    throw new TRPCError({ code: 'UNAUTHORIZED' });
  }
  return next({ ctx: { ...ctx, userId: ctx.userId } });
});

const enforceTenant = middleware(({ ctx, next }) => {
  if (!ctx.userId) throw new TRPCError({ code: 'UNAUTHORIZED' });
  if (!ctx.tenantId) throw new TRPCError({ code: 'FORBIDDEN', message: 'No tenant context' });
  return next({ ctx: { ...ctx, userId: ctx.userId, tenantId: ctx.tenantId } });
});

const enforcePlatform = middleware(({ ctx, next }) => {
  if (!ctx.userId) throw new TRPCError({ code: 'UNAUTHORIZED' });
  if (!ctx.isPlatformAdmin) throw new TRPCError({ code: 'FORBIDDEN' });
  return next({ ctx: { ...ctx, userId: ctx.userId } });
});

const enforceAgency = middleware(({ ctx, next }) => {
  if (!ctx.userId) throw new TRPCError({ code: 'UNAUTHORIZED' });
  if (!ctx.agencyId) throw new TRPCError({ code: 'FORBIDDEN', message: 'No agency context' });
  return next({ ctx: { ...ctx, userId: ctx.userId, agencyId: ctx.agencyId } });
});

// ─── Procedure builders ───────────────────────────────────────────────────────

export const publicProcedure = t.procedure;
export const authenticatedProcedure = t.procedure.use(enforceAuth);
export const tenantProcedure = t.procedure.use(enforceTenant);
export const platformProcedure = t.procedure.use(enforcePlatform);
export const agencyProcedure = t.procedure.use(enforceAgency);
