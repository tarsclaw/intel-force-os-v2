import { describe, it, expect, beforeEach, afterEach } from "vitest";
import { mkdtempSync, rmSync, mkdirSync, writeFileSync, existsSync, readFileSync, readdirSync } from "node:fs";
import { tmpdir } from "node:os";
import { join, dirname, basename } from "node:path";
import { createStaging, commitStaging, abortStaging, cleanOldPrev } from "../../src/atomicWrite.js";

let tmpRoot: string;

beforeEach(() => {
  tmpRoot = mkdtempSync(join(tmpdir(), "renderer-atomic-"));
});

afterEach(() => {
  if (tmpRoot) rmSync(tmpRoot, { recursive: true, force: true });
});

describe("atomicWrite", () => {
  it("creates tmp dir with .tmp.<pid> suffix", () => {
    const finalDir = join(tmpRoot, "agent");
    const staging = createStaging(finalDir);
    expect(existsSync(staging.tmpDir)).toBe(true);
    expect(staging.tmpDir).toContain(`.tmp.${process.pid}`);
  });

  it("commits staging when no prior target exists (no .prev created)", () => {
    const finalDir = join(tmpRoot, "agent");
    const staging = createStaging(finalDir);
    writeFileSync(join(staging.tmpDir, "CLAUDE.md"), "hello");
    const result = commitStaging(staging);
    expect(existsSync(finalDir)).toBe(true);
    expect(readFileSync(join(finalDir, "CLAUDE.md"), "utf-8")).toBe("hello");
    expect(result.prevDirIfAny).toBeNull();
  });

  it("renames existing target to .prev.<timestamp> and atomic-renames new", () => {
    const finalDir = join(tmpRoot, "agent");
    mkdirSync(finalDir);
    writeFileSync(join(finalDir, "OLD.md"), "old");
    const staging = createStaging(finalDir);
    writeFileSync(join(staging.tmpDir, "NEW.md"), "new");
    const result = commitStaging(staging);
    expect(existsSync(join(finalDir, "NEW.md"))).toBe(true);
    expect(existsSync(join(finalDir, "OLD.md"))).toBe(false);
    expect(result.prevDirIfAny).toMatch(/\.prev\./);
    if (result.prevDirIfAny) {
      expect(existsSync(join(result.prevDirIfAny, "OLD.md"))).toBe(true);
    }
  });

  it("abortStaging removes tmp dir cleanly", () => {
    const finalDir = join(tmpRoot, "agent");
    const staging = createStaging(finalDir);
    writeFileSync(join(staging.tmpDir, "PARTIAL.md"), "x");
    abortStaging(staging);
    expect(existsSync(staging.tmpDir)).toBe(false);
  });

  it("cleanOldPrev retains the N most recent .prev dirs", () => {
    const finalDir = join(tmpRoot, "agent");
    mkdirSync(finalDir);
    const parent = dirname(finalDir);
    const stamps = ["2026-01-01T00-00-00", "2026-02-01T00-00-00", "2026-03-01T00-00-00", "2026-04-01T00-00-00"];
    for (const stamp of stamps) {
      mkdirSync(join(parent, `${basename(finalDir)}.prev.${stamp}`));
    }
    cleanOldPrev(finalDir, 2);
    const remaining = readdirSync(parent).filter((e) => e.includes(".prev."));
    expect(remaining).toHaveLength(2);
    expect(remaining.sort()).toEqual([
      `${basename(finalDir)}.prev.2026-03-01T00-00-00`,
      `${basename(finalDir)}.prev.2026-04-01T00-00-00`,
    ]);
  });
});
