// Disk cache for Companies House responses. 7-day TTL per tools.yaml.
// Pattern matches @ifos/web-scraper Cache; intentionally not shared to
// keep package boundaries clean.

import { createHash } from "node:crypto";
import { promises as fs } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

interface CacheEntry<T> {
  cachedAt: number;
  ttlMs: number;
  value: T;
}

export class CHCache {
  constructor(private readonly dir: string) {}

  static fromEnv(): CHCache {
    const dir =
      process.env.IFOS_CH_CACHE_DIR ??
      join(homedir(), ".ifos-cache", "companies-house");
    return new CHCache(dir);
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
    if (Date.now() - entry.cachedAt > entry.ttlMs) return null;
    return entry.value;
  }

  async set<T>(key: string, value: T, ttlMs: number): Promise<void> {
    const path = this.keyToPath(key);
    await fs.mkdir(this.dir, { recursive: true });
    await fs.writeFile(path, JSON.stringify({ cachedAt: Date.now(), ttlMs, value }), {
      mode: 0o600,
    });
  }

  private keyToPath(key: string): string {
    const hash = createHash("sha256").update(key).digest("hex");
    return join(this.dir, `${hash}.json`);
  }
}
