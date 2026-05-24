// Disk-backed cache with TTL for web-scraper. Stores responses at
// $IFOS_WEB_SCRAPER_CACHE_DIR (or ~/.ifos-cache/web-scraper/).

import { createHash } from "node:crypto";
import { promises as fs } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

export interface CacheEntry<T> {
  readonly cachedAt: number;
  readonly ttlMs: number;
  readonly value: T;
}

export class Cache {
  constructor(private readonly dir: string) {}

  static fromEnv(): Cache {
    const dir =
      process.env.IFOS_WEB_SCRAPER_CACHE_DIR ??
      join(homedir(), ".ifos-cache", "web-scraper");
    return new Cache(dir);
  }

  async get<T>(key: string): Promise<T | null> {
    const path = this.keyToPath(key);
    let raw: string;
    try {
      raw = await fs.readFile(path, "utf8");
    } catch {
      return null;
    }
    let entry: CacheEntry<T>;
    try {
      entry = JSON.parse(raw) as CacheEntry<T>;
    } catch {
      return null;
    }
    if (Date.now() - entry.cachedAt > entry.ttlMs) {
      return null;
    }
    return entry.value;
  }

  async set<T>(key: string, value: T, ttlMs: number): Promise<void> {
    const path = this.keyToPath(key);
    const entry: CacheEntry<T> = { cachedAt: Date.now(), ttlMs, value };
    await fs.mkdir(this.dir, { recursive: true });
    await fs.writeFile(path, JSON.stringify(entry), { mode: 0o600 });
  }

  private keyToPath(key: string): string {
    const hash = createHash("sha256").update(key).digest("hex");
    return join(this.dir, `${hash}.json`);
  }
}
