import { Command } from "commander";
import { resolve, join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { render } from "./renderer.js";
import type { RenderContext } from "./types.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const PACKAGE_ROOT = resolve(__dirname, "..");
const REPO_ROOT = resolve(PACKAGE_ROOT, "..", "..");

function defaultFrameworkRoot(): string {
  const ctxRoot = process.env.CTX_ROOT;
  if (ctxRoot && ctxRoot.length > 0) return ctxRoot;
  return join(process.env.HOME ?? "/", ".cortextos", process.env.CTX_INSTANCE_ID ?? "ifos-v2");
}

function defaultVaultRoot(tenantSlug: string): string {
  return process.env.IFOS_VAULT_ROOT
    ? join(process.env.IFOS_VAULT_ROOT, tenantSlug)
    : `/vault/${tenantSlug}`;
}

interface CliOptions {
  tenant: string;
  bundleRoot?: string;
  vaultRoot?: string;
  frameworkRoot?: string;
  org?: string;
  dryRun?: boolean;
  forceOverwriteNonRendered?: boolean;
  verify?: boolean;
}

function buildContext(agentName: string, opts: CliOptions): RenderContext {
  const bundleRoot = opts.bundleRoot ?? join(REPO_ROOT, "agents", "recruitment");
  const bundleDir = join(bundleRoot, agentName);
  const tenantSlug = opts.tenant;
  const org = opts.org ?? tenantSlug;
  const frameworkRoot = opts.frameworkRoot ?? defaultFrameworkRoot();
  const orgAgentDir = join(frameworkRoot, "orgs", org, "agents", agentName);
  const sharedDirSrc = join(REPO_ROOT, "agents", "_shared");
  const sharedDirDst = join(frameworkRoot, "orgs", org, "agents", "_shared");
  const vaultRoot = opts.vaultRoot ?? defaultVaultRoot(tenantSlug);
  const preambleTemplatePath = join(PACKAGE_ROOT, "templates", "claude-md-preamble.md");
  const commonSchemasDir = join(REPO_ROOT, "packages", "agents-runtime", "_shared");
  return {
    agentName,
    tenantSlug,
    bundleDir,
    frameworkRoot,
    orgAgentDir,
    sharedDirSrc,
    sharedDirDst,
    vaultRoot,
    preambleTemplatePath,
    commonSchemasDir,
    ctxInstanceId: process.env.CTX_INSTANCE_ID ?? "ifos-v2",
    dryRun: opts.dryRun === true,
    force: opts.forceOverwriteNonRendered === true,
  };
}

const program = new Command();
program
  .name("ifos-render-agent")
  .description("Render an IFOS agent bundle into a cortextOS-shaped per-tenant agent directory (ADR-003).")
  .version("0.1.0");

program
  .command("render <agent-name>")
  .description("Render a single agent bundle for one tenant.")
  .requiredOption("--tenant <slug>", "Tenant slug (matches /vault/<slug>/)")
  .option("--bundle-root <path>", "Override agents/<vertical>/ root (default: <repo>/agents/recruitment)")
  .option("--vault-root <path>", "Override per-tenant vault dir")
  .option("--framework-root <path>", "Override $CTX_ROOT")
  .option("--org <name>", "cortextOS org name (default: tenant slug)")
  .option("--dry-run", "Compute the render but write nothing")
  .option("--force-overwrite-non-rendered", "Overwrite target even if .rendered-by-ifos-renderer marker is missing")
  .action(async (agentName: string, opts: CliOptions) => {
    const ctx = buildContext(agentName, opts);
    const result = await render(ctx);
    process.stdout.write(JSON.stringify(result, null, 2) + "\n");
    process.exit(result.outcome === "failed" ? 1 : 0);
  });

program.parseAsync(process.argv).catch((err: unknown) => {
  const message = err instanceof Error ? err.message : String(err);
  process.stderr.write(`fatal: ${message}\n`);
  process.exit(2);
});
