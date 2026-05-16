/**
 * CLI entrypoint for the brain builder.
 *
 * Usage:
 *   pnpm --filter @intelforce/brain-builder build:tenant -- \
 *     --tenant-slug acme-dental \
 *     --source-dir /tmp/acme-handbook
 *
 * In production this is invoked by a Cloudflare Queue consumer instead of
 * directly from the CLI.
 */
import { buildTenantBrain } from './build';

function parseArgs(argv: string[]): Record<string, string> {
  const out: Record<string, string> = {};
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith('--')) {
      const key = a.slice(2);
      const value = argv[i + 1];
      if (value && !value.startsWith('--')) {
        out[key] = value;
        i++;
      } else {
        out[key] = 'true';
      }
    }
  }
  return out;
}

async function main() {
  const args = parseArgs(process.argv.slice(2));
  const tenantSlug = args['tenant-slug'];
  const sourceDir = args['source-dir'];

  if (!tenantSlug || !sourceDir) {
    console.error(
      'Usage: --tenant-slug <slug> --source-dir <path>',
    );
    process.exit(1);
  }

  console.log(`[brain-builder] tenant=${tenantSlug} source=${sourceDir}`);

  try {
    const result = await buildTenantBrain({ tenantSlug, sourceDir });
    console.log(`[brain-builder] ✓ ${result.nodeCount} nodes, ${result.edgeCount} edges`);
    console.log(`[brain-builder] ✓ ${result.durationMs}ms · cost £${result.costGbp.toFixed(4)}`);
    process.exit(0);
  } catch (err) {
    console.error('[brain-builder] ✗ build failed:', err);
    process.exit(1);
  }
}

main();
