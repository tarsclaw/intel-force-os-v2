import { router } from './init';
import { tenantsRouter } from './routers/tenants';
import { invocationsRouter } from './routers/invocations';
import { escalationsRouter } from './routers/escalations';
import { costsRouter } from './routers/costs';
import { auditRouter } from './routers/audit';
import { wizardRouter } from './routers/wizard';
import { agenciesRouter } from './routers/agencies';
import { integrationsRouter } from './routers/integrations';
import { secretsRouter } from './routers/secrets';
import { systemRouter } from './routers/system';
import { invitationsRouter } from './routers/invitations';
import { apiKeysRouter } from './routers/api-keys';
import { notificationsRouter } from './routers/notifications';

export const appRouter = router({
  tenants: tenantsRouter,
  invocations: invocationsRouter,
  escalations: escalationsRouter,
  costs: costsRouter,
  audit: auditRouter,
  wizard: wizardRouter,
  agencies: agenciesRouter,
  integrations: integrationsRouter,
  secrets: secretsRouter,
  system: systemRouter,
  invitations: invitationsRouter,
  apiKeys: apiKeysRouter,
  notifications: notificationsRouter,
});

export type AppRouter = typeof appRouter;
// Re-export from init.ts where the caller factory is bound to our `t` instance.
// In tRPC v11 it's no longer a direct export from `@trpc/server`.
export { createCallerFactory } from './init';
