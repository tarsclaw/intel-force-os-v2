import { afterEach, beforeEach, describe, expect, it } from "vitest";
import { Cache } from "../src/cache.js";
import { mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

let dir: string;
let cache: Cache;

beforeEach(() => {
  dir = mkdtempSync(join(tmpdir(), "ifos-cache-test-"));
  cache = new Cache(dir);
});

afterEach(() => {
  rmSync(dir, { recursive: true, force: true });
});

describe("Cache", () => {
  it("returns null on miss", async () => {
    expect(await cache.get("missing")).toBeNull();
  });

  it("returns value on hit", async () => {
    await cache.set("k", { foo: "bar" }, 60_000);
    expect(await cache.get<{ foo: string }>("k")).toEqual({ foo: "bar" });
  });

  it("returns null on TTL expiry", async () => {
    await cache.set("k", "v", -1); // already expired
    expect(await cache.get("k")).toBeNull();
  });
});
