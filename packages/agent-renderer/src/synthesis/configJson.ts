import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import Ajv2020 from "ajv/dist/2020.js";
import addFormats from "ajv-formats";
import type { RenderContext, TenantConfig } from "../types.js";

export class ConfigSynthesisError extends Error {
  constructor(public reason: string, message: string) {
    super(message);
    this.name = "ConfigSynthesisError";
  }
}

type JsonValue = string | number | boolean | null | JsonObject | JsonValue[];
type JsonObject = { [key: string]: JsonValue };

function readJson(path: string): JsonObject {
  return JSON.parse(readFileSync(path, "utf-8")) as JsonObject;
}

function loadCommonSchemas(commonSchemasDir: string): Map<string, JsonObject> {
  const map = new Map<string, JsonObject>();
  const names = [
    "common-base.json",
    "common-client.json",
    "common-voice.json",
    "common-notifications.json",
    "common-vault.json",
    "common-ats.json",
    "common-accounting.json",
    "common-target-patch.json",
  ];
  for (const name of names) {
    const path = join(commonSchemasDir, name);
    if (existsSync(path)) {
      map.set(name, readJson(path));
    }
  }
  return map;
}

function applyDefaults(schema: JsonObject, target: JsonObject): void {
  const props = schema.properties as JsonObject | undefined;
  if (!props) return;
  for (const [key, propRaw] of Object.entries(props)) {
    const prop = propRaw as JsonObject;
    if (target[key] !== undefined) continue;
    if (prop.default !== undefined) {
      target[key] = prop.default as JsonValue;
    } else if (prop.const !== undefined) {
      target[key] = prop.const as JsonValue;
    }
  }
}

function resolveTokens(value: unknown, tenantSlug: string): unknown {
  if (typeof value === "string") {
    return value.replace(/\{tenant_slug\}/g, tenantSlug);
  }
  if (Array.isArray(value)) {
    return value.map((v) => resolveTokens(v, tenantSlug));
  }
  if (value && typeof value === "object") {
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value)) {
      out[k] = resolveTokens(v, tenantSlug);
    }
    return out;
  }
  return value;
}

export function synthesiseConfigJson(ctx: RenderContext, tenantConfig: TenantConfig, agentMaterialised: JsonObject): JsonObject {
  const bundleSchemaPath = join(ctx.bundleDir, "config.schema.json");
  const bundleSchema = readJson(bundleSchemaPath);
  const commonSchemas = loadCommonSchemas(ctx.commonSchemasDir);

  const ajv = new Ajv2020({ allErrors: true, strict: false, useDefaults: false });
  addFormats(ajv);
  for (const [name, schema] of commonSchemas.entries()) {
    ajv.addSchema(schema, name);
  }

  const config: JsonObject = {
    ...tenantConfig,
    ...agentMaterialised,
    tenant_slug: ctx.tenantSlug,
    agent_name: ctx.agentName,
    working_directory: ctx.orgAgentDir,
  };

  for (const schema of commonSchemas.values()) {
    applyDefaults(schema, config);
  }
  applyDefaults(bundleSchema, config);

  const resolved = resolveTokens(config, ctx.tenantSlug) as JsonObject;

  const validate = ajv.compile(bundleSchema);
  if (!validate(resolved)) {
    const errors = (validate.errors ?? []).map((e) => `${e.instancePath || "(root)"} ${e.message}`).join("; ");
    throw new ConfigSynthesisError("schema-validation-failure", `config.json failed schema validation: ${errors}`);
  }

  return resolved;
}
