import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { mkdtempSync, rmSync, mkdirSync, writeFileSync, cpSync, existsSync, readFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, resolve, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { synthesiseClaudeMd, checkPreambleResolved } from "../../src/synthesis/claudeMd.js";
import { synthesiseConfigJson, ConfigSynthesisError } from "../../src/synthesis/configJson.js";
import { synthesiseEnvFile, EnvSynthesisError } from "../../src/synthesis/envFile.js";
import type { RenderContext, TenantConfig } from "../../src/types.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const REPO_ROOT = resolve(__dirname, "..", "..", "..", "..");
const FIXTURES_DIR = resolve(__dirname, "..", "fixtures");
const PREAMBLE_PATH = resolve(__dirname, "..", "..", "templates", "claude-md-preamble.md");
const COMMON_SCHEMAS_DIR = resolve(REPO_ROOT, "packages", "agents-runtime", "_shared");

let tmpRoot: string;
let bundleDir: string;
let vaultDir: string;

function buildCtx(): RenderContext {
  return {
    agentName: "test-agent",
    tenantSlug: "migration-test",
    bundleDir,
    frameworkRoot: join(tmpRoot, "framework"),
    orgAgentDir: join(tmpRoot, "framework", "orgs", "migration-test", "agents", "test-agent"),
    sharedDirSrc: join(REPO_ROOT, "agents", "_shared"),
    sharedDirDst: join(tmpRoot, "framework", "orgs", "migration-test", "agents", "_shared"),
    vaultRoot: vaultDir,
    preambleTemplatePath: PREAMBLE_PATH,
    commonSchemasDir: COMMON_SCHEMAS_DIR,
    ctxInstanceId: "ifos-v2",
    dryRun: false,
    force: false,
  };
}

beforeEach(() => {
  tmpRoot = mkdtempSync(join(tmpdir(), "renderer-synth-"));
  bundleDir = join(tmpRoot, "bundle");
  vaultDir = join(tmpRoot, "vault", "migration-test");
  cpSync(join(FIXTURES_DIR, "test-agent"), bundleDir, { recursive: true });
  mkdirSync(vaultDir, { recursive: true });
  cpSync(join(FIXTURES_DIR, "test-tenant-vault", "migration-test"), vaultDir, { recursive: true });
});

afterEach(() => {
  if (tmpRoot) rmSync(tmpRoot, { recursive: true, force: true });
});

describe("synthesis/claudeMd", () => {
  it("resolves all tokens with no unresolved placeholders", () => {
    const ctx = buildCtx();
    const result = synthesiseClaudeMd(ctx, {
      agentMdBody: "[agent body here]",
      tenant: { tenant_slug: "migration-test", tenant_legal_name: "Migration Test Ltd", tier: "boutique", operating_window: "business-hours", voice_threshold: 0.75 } as TenantConfig,
      agentDisplayName: "Test-agent",
      agentDirAbs: ctx.orgAgentDir,
    });
    expect(result).toContain("Test-agent — Migration Test Ltd");
    expect(result).toContain("CTX_TENANT_SLUG=migration-test");
    expect(result).toContain("CTX_AGENT_NAME=test-agent");
    expect(result).toContain("[agent body here]");
    const check = checkPreambleResolved(result);
    expect(check.ok).toBe(true);
  });

  it("flags unresolved placeholders if template substitution fails", () => {
    const broken = "Hello {{unresolved_token}} world";
    const check = checkPreambleResolved(broken);
    expect(check.ok).toBe(false);
    if (!check.ok) {
      expect(check.unresolved).toContain("{{unresolved_token}}");
    }
  });
});

describe("synthesis/configJson", () => {
  it("materialises config.json with bundle + common defaults applied", () => {
    const ctx = buildCtx();
    const tenantConfig: TenantConfig = { tenant_slug: "migration-test", tier: "boutique" };
    const result = synthesiseConfigJson(ctx, tenantConfig, {});
    expect(result.tenant_slug).toBe("migration-test");
    expect(result.agent_name).toBe("test-agent");
    expect(result.runtime).toBe("claude-code");
    expect(result.echo_prefix).toBe("[test-agent]");
    expect(result.working_directory).toBe(ctx.orgAgentDir);
  });

  it("resolves {tenant_slug} tokens in default string values", () => {
    const ctx = buildCtx();
    const result = synthesiseConfigJson(ctx, { tenant_slug: "migration-test" }, {});
    if (typeof result.working_directory === "string") {
      expect(result.working_directory).not.toContain("{tenant_slug}");
    }
  });

  it("throws schema-validation-failure when required fields are missing", () => {
    const ctx = buildCtx();
    const brokenSchema = {
      type: "object",
      properties: { tenant_slug: { type: "string" } },
      required: ["tenant_slug", "made_up_field"],
      additionalProperties: true,
    };
    writeFileSync(join(ctx.bundleDir, "config.schema.json"), JSON.stringify(brokenSchema));
    expect(() => synthesiseConfigJson(ctx, { tenant_slug: "migration-test" }, {})).toThrow(ConfigSynthesisError);
  });
});

describe("synthesis/envFile", () => {
  it("emits CTX_* identity vars + tools.yaml required_env values", () => {
    const ctx = buildCtx();
    const env = synthesiseEnvFile(ctx, {
      secretsEnvPath: join(ctx.vaultRoot, "_secrets.env"),
      toolsYamlPath: join(ctx.bundleDir, "tools.yaml"),
    });
    expect(env).toContain("CTX_INSTANCE_ID=ifos-v2");
    expect(env).toContain("CTX_TENANT_SLUG=migration-test");
    expect(env).toContain("CTX_AGENT_NAME=test-agent");
    expect(env).toContain("TEST_AGENT_TOKEN=dummy-token-not-used-in-tests");
  });

  it("fails tenant-not-provisioned if _secrets.env is missing", () => {
    const ctx = buildCtx();
    rmSync(join(ctx.vaultRoot, "_secrets.env"));
    expect(() =>
      synthesiseEnvFile(ctx, {
        secretsEnvPath: join(ctx.vaultRoot, "_secrets.env"),
        toolsYamlPath: join(ctx.bundleDir, "tools.yaml"),
      }),
    ).toThrow(EnvSynthesisError);
  });

  it("fails bundle-malformed if tools.yaml declares missing env key", () => {
    const ctx = buildCtx();
    writeFileSync(join(ctx.bundleDir, "tools.yaml"), "mcp_servers: []\nrequired_env: [MISSING_KEY]\n");
    expect(() =>
      synthesiseEnvFile(ctx, {
        secretsEnvPath: join(ctx.vaultRoot, "_secrets.env"),
        toolsYamlPath: join(ctx.bundleDir, "tools.yaml"),
      }),
    ).toThrow(EnvSynthesisError);
  });

  it("placeholder uses cpSync — vault fixture loaded", () => {
    expect(existsSync(join(vaultDir, "_secrets.env"))).toBe(true);
  });
});
