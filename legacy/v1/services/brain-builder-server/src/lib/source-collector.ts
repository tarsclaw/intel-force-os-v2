import { readdir, readFile, stat } from 'node:fs/promises';
import { createHash } from 'node:crypto';
import path from 'node:path';

export interface SourceFile {
  name: string;
  fullPath: string;
  sha256: string;
  size: number;
  ingestedAt: string;
}

const SUPPORTED_EXT = new Set(['.md', '.txt', '.pdf', '.html', '.docx']);

/**
 * Recursively collect all supported source files from a directory.
 *
 * For PDFs/DOCX, the markitdown service is used to convert them to markdown
 * before graphify processes them. This module just enumerates and hashes —
 * conversion happens in graphify-runner.
 */
export async function collectSourceFiles(dir: string): Promise<SourceFile[]> {
  const out: SourceFile[] = [];
  await walk(dir, out);
  return out;
}

async function walk(dir: string, out: SourceFile[]): Promise<void> {
  let entries: import('node:fs').Dirent[];
  try {
    entries = await readdir(dir, { withFileTypes: true });
  } catch {
    return;
  }

  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      await walk(full, out);
      continue;
    }
    if (!entry.isFile()) continue;
    const ext = path.extname(entry.name).toLowerCase();
    if (!SUPPORTED_EXT.has(ext)) continue;

    const buf = await readFile(full);
    const stats = await stat(full);
    out.push({
      name: entry.name,
      fullPath: full,
      sha256: createHash('sha256').update(buf).digest('hex'),
      size: stats.size,
      ingestedAt: new Date().toISOString(),
    });
  }
}
