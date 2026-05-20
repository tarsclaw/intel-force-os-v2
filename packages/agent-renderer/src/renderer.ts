import {
  copyFileSync,
  cpSync,
  existsSync,
  mkdirSync,
  readFileSync,
  writeFileSync,
  chmodSync,
  symlinkSync,
  readdirSync,
} from "node:fs";
import { join, dirname } from "node:path";
import yaml from "js-yaml";
import type { RenderContext, RenderResult, TenantConfig } from "./types.js";
import { runPreflight, PreflightError, RENDERED_MARKER } from "./preflight.js";
import { createStaging, commitStaging, abortStaging, cleanOldPrev, AtomicWriteError } from "./atomicWrite.js";
import { synthesiseClaudeMd, checkPreambleResolved } from "./synthesis/claudeMd.js";
import { synthesiseConfigJson, ConfigSynthesisError } from "./synthesis/configJson.js";
import { synthesiseEnvFile, EnvSynthesisError } from "./synthesis/envFile.js";
import { GOALS_JSON_PLACEHOLDER } from "./fileMap.js";

export class RenderError extends Error {
  constructor(public reason: string, message: string) {
    super(message);
    this.name = "RenderError";
  }
}

function loadTenantConfig(ctx: RenderContext): TenantConfig {
  const candidates = [
    join(ctx.vaultRoot, "_config.yaml"),
    join(ctx.vaultRoot, "_config", "_config.yaml"),
  ];
  for (const path of candidates) {
    if (existsSync(path)) {
      const raw = yaml.load(readFileSync(path, "utf-8")) as Record<string, unknown> | null;
      return { tenant_slug: ctx.tenantSlug, ...(raw ?? {}) } as TenantConfig;
    }
  }
  return { tenant_slug: ctx.tenantSlug };
}

function syncSharedDir(ctx: RenderContext): void {
  const dst = ctx.sharedDirDst;
  if (existsSync(dst)) return;
  mkdirSync(dirname(dst), { recursive: true });
  cpSync(ctx.sharedDirSrc, dst, { recursive: true, dereference: false });
}

function writeFileTracked(path: string, content: string, mode?: number, counter?: { n: number }): void {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, content, "utf-8");
  if (mode !== undefined) chmodSync(path, mode);
  if (counter) counter.n += 1;
}

function copyTracked(src: string, dst: string, mode: number | undefined, counter: { n: number }): void {
  mkdirSync(dirname(dst), { recursive: true });
  copyFileSync(src, dst);
  if (mode !== undefined) chmodSync(dst, mode);
  counter.n += 1;
}

function listRecursive(dir: string): string[] {
  const out: string[] = [];
  for (const entry of readdirSync(dir, { withFileTypes: true })) {
    if (entry.name === "tests") continue;
    const full = join(dir, entry.name);
    if (entry.isDirectory()) {
      out.push(...listRecursive(full).map((sub) => join(entry.name, sub)));
    } else if (entry.isFile()) {
      out.push(entry.name);
    }
  }
  return out;
}

export async function render(ctx: RenderContext): Promise<RenderResult> {
  const started = Date.now();
  try {
    runPreflight(ctx);
  } catch (err) {
    if (err instanceof PreflightError) {
      return failure(ctx, err.reason, err.message, started);
    }
    throw err;
  }

  syncSharedDir(ctx);

  const tenantConfig = loadTenantConfig(ctx);

  const bundleSchemaPath = join(ctx.bundleDir, "config.schema.json");
  const agentMaterialisedPath = join(ctx.bundleDir, "_materialised.example.json");
  const agentMaterialised = existsSync(agentMaterialisedPath)
    ? (JSON.parse(readFileSync(agentMaterialisedPath, "utf-8")) as Record<string, unknown>)
    : {};

  let configJson: Record<string, unknown>;
  try {
    configJson = synthesiseConfigJson(ctx, tenantConfig, agentMaterialised as never) as Record<string, unknown>;
  } catch (err) {
    if (err instanceof ConfigSynthesisError) return failure(ctx, err.reason, err.message, started);
    throw err;
  }
  void bundleSchemaPath;

  const agentMdBody = readFileSync(join(ctx.bundleDir, "agent.md"), "utf-8");
  const agentDisplayName = `${ctx.agentName.charAt(0).toUpperCase()}${ctx.agentName.slice(1)}`;
  const claudeMd = synthesiseClaudeMd(ctx, {
    agentMdBody,
    tenant: tenantConfig,
    agentDisplayName,
    agentDirAbs: ctx.orgAgentDir,
  });
  const preambleCheck = checkPreambleResolved(claudeMd);
  if (!preambleCheck.ok) {
    return failure(ctx, "bundle-malformed", `Unresolved preamble tokens: ${preambleCheck.unresolved.join(", ")}`, started);
  }

  let envContent: string;
  try {
    envContent = synthesiseEnvFile(ctx, {
      secretsEnvPath: join(ctx.vaultRoot, "_secrets.env"),
      toolsYamlPath: join(ctx.bundleDir, "tools.yaml"),
    });
  } catch (err) {
    if (err instanceof EnvSynthesisError) return failure(ctx, err.reason, err.message, started);
    throw err;
  }

  if (ctx.dryRun) {
    return {
      outcome: "no-op",
      agentName: ctx.agentName,
      tenantSlug: ctx.tenantSlug,
      targetDir: ctx.orgAgentDir,
      filesWritten: 0,
      durationMs: Date.now() - started,
      reason: "dry-run",
    };
  }

  const staging = createStaging(ctx.orgAgentDir);
  const counter = { n: 0 };
  try {
    writeFileTracked(join(staging.tmpDir, "CLAUDE.md"), claudeMd, undefined, counter);
    writeFileTracked(join(staging.tmpDir, "config.json"), JSON.stringify(configJson, null, 2) + "\n", undefined, counter);
    writeFileTracked(join(staging.tmpDir, ".env"), envContent, 0o600, counter);
    writeFileTracked(
      join(staging.tmpDir, "goals.json"),
      JSON.stringify(GOALS_JSON_PLACEHOLDER, null, 2) + "\n",
      undefined,
      counter,
    );
    copyTracked(join(ctx.bundleDir, "tools.yaml"), join(staging.tmpDir, "tools.yaml"), undefined, counter);
    copyTracked(join(ctx.bundleDir, "README.md"), join(staging.tmpDir, "README.md"), undefined, counter);
    copyTracked(
      join(ctx.bundleDir, "validate.sh"),
      join(staging.tmpDir, ".claude", "hooks", "validate.sh"),
      0o755,
      counter,
    );
    copyTracked(
      join(ctx.bundleDir, "context.sh"),
      join(staging.tmpDir, ".claude", "hooks", "context.sh"),
      0o755,
      counter,
    );
    mkdirSync(join(staging.tmpDir, ".claude", "hooks"), { recursive: true });
    symlinkSync("../../_shared", join(staging.tmpDir, ".claude", "hooks", "_shared"));
    counter.n += 1;
    writeFileTracked(join(staging.tmpDir, RENDERED_MARKER), `${new Date().toISOString()}\n`, undefined, counter);

    commitStaging(staging);
    cleanOldPrev(ctx.orgAgentDir, 2);
  } catch (err) {
    abortStaging(staging);
    if (err instanceof AtomicWriteError) return failure(ctx, err.reason, err.message, started);
    if (err instanceof Error) return failure(ctx, "atomic-rename-failed", err.message, started);
    throw err;
  }

  void listRecursive;

  return {
    outcome: "rendered",
    agentName: ctx.agentName,
    tenantSlug: ctx.tenantSlug,
    targetDir: ctx.orgAgentDir,
    filesWritten: counter.n,
    durationMs: Date.now() - started,
  };
}

function failure(ctx: RenderContext, reason: string, message: string, started: number): RenderResult {
  return {
    outcome: "failed",
    agentName: ctx.agentName,
    tenantSlug: ctx.tenantSlug,
    targetDir: ctx.orgAgentDir,
    filesWritten: 0,
    durationMs: Date.now() - started,
    reason: `${reason}: ${message}`,
  };
}
