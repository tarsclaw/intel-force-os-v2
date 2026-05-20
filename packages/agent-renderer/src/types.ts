export type RenderOutcome = "rendered" | "no-op" | "failed";

export type FileMapAction =
  | "synthesis"
  | "passthrough"
  | "verbatim-copy"
  | "stays-in-source"
  | "drop"
  | "empty-placeholder";

export interface FileMapRow {
  source: string | null;
  target: string | null;
  action: FileMapAction;
  note?: string;
}

export interface RenderContext {
  agentName: string;
  tenantSlug: string;
  bundleDir: string;
  frameworkRoot: string;
  orgAgentDir: string;
  sharedDirSrc: string;
  sharedDirDst: string;
  vaultRoot: string;
  preambleTemplatePath: string;
  commonSchemasDir: string;
  ctxInstanceId: string;
  dryRun: boolean;
  force: boolean;
}

export interface RenderResult {
  outcome: RenderOutcome;
  agentName: string;
  tenantSlug: string;
  targetDir: string;
  filesWritten: number;
  durationMs: number;
  reason?: string;
}

export interface TenantConfig {
  tenant_slug: string;
  tenant_legal_name?: string;
  operating_window?: string;
  tier?: string;
  voice_threshold?: number;
  [key: string]: unknown;
}
