import type { FileMapRow } from "./types.js";

export function buildFileMap(): FileMapRow[] {
  return [
    { source: "agent.md", target: "CLAUDE.md", action: "synthesis", note: "agent.md body + preamble + tenant footer per ADR-003 §2.1 row 1" },
    { source: "config.schema.json", target: "config.json", action: "synthesis", note: "Schema + _config.yaml + common-*.json $refs per ADR-003 §2.1 row 2" },
    { source: null, target: ".env", action: "synthesis", note: "Synthesised from _secrets.env + tools.yaml MCP list per ADR-003 §2.1 row 3" },
    { source: "tools.yaml", target: "tools.yaml", action: "passthrough" },
    { source: "validate.sh", target: ".claude/hooks/validate.sh", action: "verbatim-copy" },
    { source: "context.sh", target: ".claude/hooks/context.sh", action: "verbatim-copy" },
    { source: "README.md", target: "README.md", action: "verbatim-copy" },
    { source: "tests/fixtures/", target: null, action: "stays-in-source", note: "CI fixture runner reads from IFOS repo per master brief §8.3" },
    { source: null, target: null, action: "drop", note: "cortextOS templates (IDENTITY/SOUL/GUARDRAILS/GOALS/HEARTBEAT/MEMORY/USER/SYSTEM/TOOLS/AGENTS/memory/experiments)" },
    { source: null, target: null, action: "drop", note: ".claude/skills/ 24-skill tree (R2 commitment per ADR-003 Decision 1)" },
    { source: null, target: "goals.json", action: "empty-placeholder", note: "{focus,goals,bottleneck,updated_at,updated_by} per add-agent.ts:131-140 daemon-compat" },
    { source: null, target: ".claude/hooks/_shared", action: "passthrough", note: "Symlink → ../../_shared/ resolved at runtime per ADR-003 §3.3.3 Option γ" },
  ];
}

export function bundleRequiredFiles(): string[] {
  return ["agent.md", "config.schema.json", "tools.yaml", "validate.sh", "context.sh", "README.md"];
}

export const GOALS_JSON_PLACEHOLDER = {
  focus: "",
  goals: [],
  bottleneck: "",
  updated_at: "",
  updated_by: "",
};
