/**
 * Temporal worker process
 * Run: pnpm --filter @intelforce/provisioning worker
 *
 * Requires:
 *   TEMPORAL_ADDRESS=<namespace>.tmprl.cloud:7233
 *   TEMPORAL_NAMESPACE=intelforce.production
 *   TEMPORAL_API_KEY=<key>    (Temporal Cloud mTLS/API key)
 *   DATABASE_URL=<postgres>
 */

import { Worker, NativeConnection } from '@temporalio/worker';
import * as activities from './activities/tenant-onboard-activities';

async function main() {
  const address = process.env['TEMPORAL_ADDRESS'] ?? 'localhost:7233';
  const namespace = process.env['TEMPORAL_NAMESPACE'] ?? 'default';
  const apiKey = process.env['TEMPORAL_API_KEY'];

  const connection = await NativeConnection.connect({
    address,
    tls: apiKey ? {} : undefined,
    apiKey: apiKey ?? undefined,
  });

  const worker = await Worker.create({
    connection,
    namespace,
    taskQueue: 'intelforce-provisioning',
    workflowsPath: require.resolve('./workflows/tenant-onboard'),
    activities,
    maxConcurrentActivityTaskExecutions: 10,
    maxConcurrentWorkflowTaskExecutions: 50,
  });

  console.log(`Temporal worker started — queue: intelforce-provisioning, namespace: ${namespace}`);
  await worker.run();
}

main().catch((err) => {
  console.error('Worker failed:', err);
  process.exit(1);
});
