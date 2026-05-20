import { existsSync, mkdirSync, renameSync, readdirSync, rmSync } from "node:fs";
import { dirname, basename, join } from "node:path";

export class AtomicWriteError extends Error {
  constructor(public reason: string, message: string) {
    super(message);
    this.name = "AtomicWriteError";
  }
}

export interface AtomicStaging {
  tmpDir: string;
  finalDir: string;
  prevDirIfAny: string | null;
}

export function createStaging(finalDir: string): AtomicStaging {
  const parent = dirname(finalDir);
  if (!existsSync(parent)) mkdirSync(parent, { recursive: true });
  const tmpDir = join(parent, `${basename(finalDir)}.tmp.${process.pid}`);
  if (existsSync(tmpDir)) rmSync(tmpDir, { recursive: true, force: true });
  mkdirSync(tmpDir, { recursive: true });
  return { tmpDir, finalDir, prevDirIfAny: null };
}

export function commitStaging(staging: AtomicStaging): AtomicStaging {
  const { tmpDir, finalDir } = staging;
  let prevDirIfAny: string | null = null;
  if (existsSync(finalDir)) {
    const ts = new Date().toISOString().replace(/[:.]/g, "-");
    prevDirIfAny = `${finalDir}.prev.${ts}`;
    try {
      renameSync(finalDir, prevDirIfAny);
    } catch (err) {
      throw new AtomicWriteError("atomic-rename-failed", `Failed to rename existing target to .prev: ${(err as Error).message}`);
    }
  }
  try {
    renameSync(tmpDir, finalDir);
  } catch (err) {
    if (prevDirIfAny && existsSync(prevDirIfAny)) {
      try {
        renameSync(prevDirIfAny, finalDir);
      } catch {
        // best-effort rollback; surface original error
      }
    }
    throw new AtomicWriteError("atomic-rename-failed", `Failed to rename tmp → target: ${(err as Error).message}`);
  }
  return { ...staging, prevDirIfAny };
}

export function abortStaging(staging: AtomicStaging): void {
  if (existsSync(staging.tmpDir)) {
    rmSync(staging.tmpDir, { recursive: true, force: true });
  }
}

export function cleanOldPrev(finalDir: string, keepCount: number = 2): void {
  const parent = dirname(finalDir);
  const prefix = `${basename(finalDir)}.prev.`;
  if (!existsSync(parent)) return;
  const prevs = readdirSync(parent)
    .filter((entry) => entry.startsWith(prefix))
    .sort()
    .reverse();
  for (const stale of prevs.slice(keepCount)) {
    rmSync(join(parent, stale), { recursive: true, force: true });
  }
}
