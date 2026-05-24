// CLI entry point. Parses args, loads tenant target_patch if available,
// generates the report, writes to stdout. cycle.sh redirects stdout
// to /tmp draft path before validate.sh + vault move.

import { Command } from "commander";
import { promises as fs } from "node:fs";
import { generateReport } from "./generate.js";
import type { TargetPatch } from "./sections/icp-fit.js";

const program = new Command();
program
  .name("ifos-diagnostic-generate")
  .description("Generate a 12-section Diagnostic report for a UK recruitment firm")
  .requiredOption("--firm <name>", "Firm name (free-text; used for Companies House search)")
  .requiredOption("--tenant <slug>", "Tenant slug (per common-base.json pattern)")
  .option("--sector <hint>", "Sector hint (free-text)", "")
  .option("--target-patch <path>", "Path to tenant target_patch.json", "")
  .option("--iso-date <date>", "Override report date (default: today UTC)", "");

program.parse(process.argv);
const opts = program.opts<{
  firm: string;
  tenant: string;
  sector: string;
  targetPatch: string;
  isoDate: string;
}>();

async function loadTargetPatch(path: string): Promise<TargetPatch | null> {
  if (!path) return null;
  try {
    const raw = await fs.readFile(path, "utf8");
    return JSON.parse(raw) as TargetPatch;
  } catch (err) {
    process.stderr.write(`warning: could not load target_patch from ${path}: ${(err as Error).message}\n`);
    return null;
  }
}

async function main(): Promise<void> {
  const targetPatch = await loadTargetPatch(opts.targetPatch);
  const md = await generateReport({
    firmName: opts.firm,
    tenantSlug: opts.tenant,
    sectorHint: opts.sector,
    targetPatch,
    isoDate: opts.isoDate || undefined,
  });
  process.stdout.write(md);
}

main().catch((err) => {
  process.stderr.write(`ifos-diagnostic-generate: ${(err as Error).message}\n`);
  process.exit(1);
});
