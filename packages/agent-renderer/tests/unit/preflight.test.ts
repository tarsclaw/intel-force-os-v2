import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { mkdtempSync, rmSync, writeFileSync, mkdirSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { runPreflight, checkBundle, checkSharedHelpers, checkTenant, checkRenderedMarker, PreflightError, RENDERED_MARKER } from "../../src/preflight.js";
import type { RenderContext } from "../../src/types.js";

let tmpRoot: string;
function ctx(overrides: Partial<RenderContext> = {}): RenderContext {
  return {
    agentName: "test-agent",
    tenantSlug: "migration-test",
    bundleDir: join(tmpRoot, "bundle"),
    frameworkRoot: join(tmpRoot, "framework"),
    orgAgentDir: join(tmpRoot, "framework", "orgs", "migration-test", "agents", "test-agent"),
    sharedDirSrc: join(tmpRoot, "shared-src"),
    sharedDirDst: join(tmpRoot, "framework", "orgs", "migration-test", "agents", "_shared"),
    vaultRoot: join(tmpRoot, "vault", "migration-test"),
    preambleTemplatePath: join(tmpRoot, "preamble.md"),
    commonSchemasDir: join(tmpRoot, "common"),
    ctxInstanceId: "ifos-v2",
    dryRun: false,
    force: false,
    ...overrides,
  };
}

function seedBundle(c: RenderContext): void {
  mkdirSync(c.bundleDir, { recursive: true });
  for (const f of ["agent.md", "config.schema.json", "tools.yaml", "validate.sh", "context.sh", "README.md"]) {
    writeFileSync(join(c.bundleDir, f), `# ${f}\n`);
  }
}

function seedShared(c: RenderContext): void {
  mkdirSync(c.sharedDirSrc, { recursive: true });
  writeFileSync(join(c.sharedDirSrc, "escalation-codes.md"), "# ESC\n");
}

function seedTenant(c: RenderContext): void {
  mkdirSync(c.vaultRoot, { recursive: true });
}

beforeEach(() => {
  tmpRoot = mkdtempSync(join(tmpdir(), "renderer-preflight-"));
});

afterEach(() => {
  if (tmpRoot) rmSync(tmpRoot, { recursive: true, force: true });
});

describe("preflight", () => {
  it("checkBundle passes with all 6 files", () => {
    const c = ctx();
    seedBundle(c);
    expect(() => checkBundle(c)).not.toThrow();
  });

  it("checkBundle fails bundle-malformed if agent.md missing", () => {
    const c = ctx();
    seedBundle(c);
    rmSync(join(c.bundleDir, "agent.md"));
    expect(() => checkBundle(c)).toThrow(PreflightError);
    try { checkBundle(c); } catch (e) {
      expect((e as PreflightError).reason).toBe("bundle-malformed");
    }
  });

  it("checkSharedHelpers fails shared-helpers-missing if _shared/ absent", () => {
    const c = ctx();
    expect(() => checkSharedHelpers(c)).toThrow(PreflightError);
  });

  it("checkSharedHelpers fails if escalation-codes.md missing from _shared/", () => {
    const c = ctx();
    mkdirSync(c.sharedDirSrc, { recursive: true });
    try { checkSharedHelpers(c); } catch (e) {
      expect((e as PreflightError).reason).toBe("shared-helpers-missing");
    }
  });

  it("checkTenant fails tenant-not-provisioned if vault missing", () => {
    const c = ctx();
    expect(() => checkTenant(c)).toThrow(PreflightError);
  });

  it("checkRenderedMarker refuses non-rendered targets without --force", () => {
    const c = ctx();
    mkdirSync(c.orgAgentDir, { recursive: true });
    expect(() => checkRenderedMarker(c)).toThrow(PreflightError);
    try { checkRenderedMarker(c); } catch (e) {
      expect((e as PreflightError).reason).toBe("non-rendered-target");
    }
  });

  it("checkRenderedMarker passes if marker present", () => {
    const c = ctx();
    mkdirSync(c.orgAgentDir, { recursive: true });
    writeFileSync(join(c.orgAgentDir, RENDERED_MARKER), "2026-05-20\n");
    expect(() => checkRenderedMarker(c)).not.toThrow();
  });

  it("checkRenderedMarker honours --force flag", () => {
    const c = ctx({ force: true });
    mkdirSync(c.orgAgentDir, { recursive: true });
    expect(() => checkRenderedMarker(c)).not.toThrow();
  });

  it("runPreflight passes when bundle + shared + tenant are clean", () => {
    const c = ctx();
    seedBundle(c);
    seedShared(c);
    seedTenant(c);
    expect(() => runPreflight(c)).not.toThrow();
  });
});
