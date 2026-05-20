import { readFileSync } from "node:fs";
import type { RenderContext, TenantConfig } from "../types.js";

const AGENT_BODY_MARKER = "[agent.md body verbatim from `agents/recruitment/{{agent_name}}/agent.md`]";

export interface ClaudeMdInputs {
  agentMdBody: string;
  tenant: TenantConfig;
  agentDisplayName: string;
  agentDirAbs: string;
}

export function synthesiseClaudeMd(ctx: RenderContext, inputs: ClaudeMdInputs): string {
  const template = readFileSync(ctx.preambleTemplatePath, "utf-8");
  const tenant = inputs.tenant;
  const replacements: Record<string, string> = {
    "{{agent_display_name}}": inputs.agentDisplayName,
    "{{tenant_legal_name}}": String(tenant.tenant_legal_name ?? tenant.tenant_slug),
    "{{agent_name}}": ctx.agentName,
    "{{tenant_slug}}": ctx.tenantSlug,
    "{{ctx_instance_id}}": ctx.ctxInstanceId,
    "{{agent_dir_abs}}": inputs.agentDirAbs,
    "{{orchestrator_agent_or_none}}": "(none in v1.0)",
    "{{operating_window}}": String(tenant.operating_window ?? "business-hours"),
    "{{tier}}": String(tenant.tier ?? "boutique"),
    "{{voice_threshold}}": String(tenant.voice_threshold ?? 0.75),
  };
  let rendered = template.replace(AGENT_BODY_MARKER, inputs.agentMdBody);
  for (const [token, value] of Object.entries(replacements)) {
    rendered = rendered.split(token).join(value);
  }
  return rendered;
}

export function checkPreambleResolved(rendered: string): { ok: true } | { ok: false; unresolved: string[] } {
  const matches = rendered.match(/\{\{[a-z_]+\}\}/g);
  if (!matches) return { ok: true };
  const unique = [...new Set(matches)];
  return { ok: false, unresolved: unique };
}
