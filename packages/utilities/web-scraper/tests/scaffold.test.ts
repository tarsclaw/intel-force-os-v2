import { describe, it, expect } from "vitest";
import { VERSION } from "../src/index.js";

describe("@ifos/web-scraper — scaffold", () => {
  it("exports a version constant", () => {
    expect(VERSION).toBe("0.1.0");
  });
});
