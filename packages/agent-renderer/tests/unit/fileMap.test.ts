import { describe, it, expect } from "vitest";
import { buildFileMap, bundleRequiredFiles, GOALS_JSON_PLACEHOLDER } from "../../src/fileMap.js";

describe("fileMap", () => {
  it("returns 12 rows per ADR-003 Decision 3", () => {
    const rows = buildFileMap();
    expect(rows).toHaveLength(12);
  });

  it("has the synthesis triple (CLAUDE.md + config.json + .env)", () => {
    const rows = buildFileMap();
    const synthesis = rows.filter((r) => r.action === "synthesis");
    expect(synthesis).toHaveLength(3);
    const targets = synthesis.map((r) => r.target).sort();
    expect(targets).toEqual([".env", "CLAUDE.md", "config.json"]);
  });

  it("drops cortextOS templates + 24-skill tree (R2 commitment)", () => {
    const rows = buildFileMap();
    const drops = rows.filter((r) => r.action === "drop");
    expect(drops).toHaveLength(2);
  });

  it("verbatim-copies hooks + README", () => {
    const rows = buildFileMap();
    const copies = rows.filter((r) => r.action === "verbatim-copy");
    expect(copies).toHaveLength(3);
    const targets = copies.map((r) => r.target).sort();
    expect(targets).toEqual([".claude/hooks/context.sh", ".claude/hooks/validate.sh", "README.md"]);
  });

  it("tools.yaml is passthrough (no synthesis)", () => {
    const rows = buildFileMap();
    const tools = rows.find((r) => r.source === "tools.yaml");
    expect(tools?.action).toBe("passthrough");
  });

  it("goals.json placeholder matches add-agent.ts:131-140 shape (drift-check at SHA c21fbfe)", () => {
    expect(GOALS_JSON_PLACEHOLDER).toEqual({
      focus: "",
      goals: [],
      bottleneck: "",
      updated_at: "",
      updated_by: "",
    });
  });

  it("required bundle files match master brief §8 layout (6 files)", () => {
    const required = bundleRequiredFiles();
    expect(required).toEqual(["agent.md", "config.schema.json", "tools.yaml", "validate.sh", "context.sh", "README.md"]);
  });
});
