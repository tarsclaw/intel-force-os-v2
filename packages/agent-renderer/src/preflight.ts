import { existsSync, statSync } from "node:fs";
import { join } from "node:path";
import type { RenderContext } from "./types.js";
import { bundleRequiredFiles } from "./fileMap.js";

export const RENDERED_MARKER = ".rendered-by-ifos-renderer";

export class PreflightError extends Error {
  constructor(public reason: string, message: string) {
    super(message);
    this.name = "PreflightError";
  }
}

export function checkBundle(ctx: RenderContext): void {
  if (!existsSync(ctx.bundleDir)) {
    throw new PreflightError("bundle-malformed", `Bundle directory not found: ${ctx.bundleDir}`);
  }
  for (const required of bundleRequiredFiles()) {
    const path = join(ctx.bundleDir, required);
    if (!existsSync(path)) {
      throw new PreflightError("bundle-malformed", `Required bundle file missing: ${required}`);
    }
  }
}

export function checkSharedHelpers(ctx: RenderContext): void {
  if (!existsSync(ctx.sharedDirSrc)) {
    throw new PreflightError("shared-helpers-missing", `agents/_shared/ not found at ${ctx.sharedDirSrc}`);
  }
  const escalationCodes = join(ctx.sharedDirSrc, "escalation-codes.md");
  if (!existsSync(escalationCodes)) {
    throw new PreflightError("shared-helpers-missing", `escalation-codes.md missing from ${ctx.sharedDirSrc}`);
  }
}

export function checkTenant(ctx: RenderContext): void {
  const vaultDir = ctx.vaultRoot;
  if (!existsSync(vaultDir)) {
    throw new PreflightError("tenant-not-provisioned", `Tenant vault not found: ${vaultDir}`);
  }
  const stat = statSync(vaultDir);
  if (!stat.isDirectory()) {
    throw new PreflightError("tenant-not-provisioned", `Tenant vault path is not a directory: ${vaultDir}`);
  }
}

export function checkRenderedMarker(ctx: RenderContext): void {
  if (!existsSync(ctx.orgAgentDir)) return;
  const marker = join(ctx.orgAgentDir, RENDERED_MARKER);
  if (!existsSync(marker) && !ctx.force) {
    throw new PreflightError(
      "non-rendered-target",
      `Target directory exists without ${RENDERED_MARKER} marker. Likely created by 'cortextos-ifos add-agent'. Use --force-overwrite-non-rendered to override (ADR-003 Decision 1).`,
    );
  }
}

export function runPreflight(ctx: RenderContext): void {
  checkBundle(ctx);
  checkSharedHelpers(ctx);
  checkTenant(ctx);
  checkRenderedMarker(ctx);
}
