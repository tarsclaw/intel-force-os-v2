// §8 — Pain signals. Fetch careers page; regex urgency phrases.
// Without LinkedIn director-post access, this is the main fresh-signal
// section in v0.

import { fetchFirstNLines } from "@ifos/web-scraper";
import type { OnlineFootprintData } from "./online-footprint.js";

const URGENCY_PATTERNS = [
  /rapid(?:ly)?\s+growing/gi,
  /scaling\s+(?:fast|rapidly|aggressively)/gi,
  /tripl(?:e|ing)\s+(?:our|the)\s+(?:team|headcount)/gi,
  /doubl(?:e|ing)\s+(?:our|the)\s+(?:team|headcount)/gi,
  /we['']?re\s+hiring/gi,
  /join\s+(?:a|the)\s+team\s+of/gi,
  /high[-\s]?growth/gi,
  /series\s+[abcde]/gi,
  /just\s+raised/gi,
  /backed\s+by/gi,
];

export interface PainSignalsData {
  careersPageUrl: string | null;
  careersPageStatus: number | null;
  matches: { pattern: string; quote: string }[];
}

export async function fetchPainSignals(
  firmName: string,
  footprint: OnlineFootprintData,
): Promise<PainSignalsData> {
  const empty: PainSignalsData = { careersPageUrl: null, careersPageStatus: null, matches: [] };

  if (!footprint.primarySite) return empty;

  const candidates = [
    `${footprint.primarySite.url.replace(/\/$/, "")}/careers`,
    `${footprint.primarySite.url.replace(/\/$/, "")}/jobs`,
    `${footprint.primarySite.url.replace(/\/$/, "")}/work-with-us`,
  ];

  for (const url of candidates) {
    const result = await fetchFirstNLines(url, 500);
    if (result && result.status >= 200 && result.status < 400 && result.lines.length > 0) {
      const text = result.lines.join("\n");
      const matches: PainSignalsData["matches"] = [];
      for (const pattern of URGENCY_PATTERNS) {
        const found = text.match(pattern);
        if (found) {
          for (const m of found) {
            matches.push({ pattern: pattern.source, quote: m });
          }
        }
      }
      // Dedup matches by quote
      const seen = new Set<string>();
      const deduped = matches.filter((m) => {
        const k = m.quote.toLowerCase();
        if (seen.has(k)) return false;
        seen.add(k);
        return true;
      });
      return { careersPageUrl: url, careersPageStatus: result.status, matches: deduped.slice(0, 5) };
    }
  }

  // No careers page found; check site root for urgency phrases as fallback
  const root = await fetchFirstNLines(footprint.primarySite.url, 300);
  if (root && root.status >= 200 && root.lines.length > 0) {
    const text = root.lines.join("\n");
    const matches: PainSignalsData["matches"] = [];
    for (const pattern of URGENCY_PATTERNS) {
      const found = text.match(pattern);
      if (found) for (const m of found) matches.push({ pattern: pattern.source, quote: m });
    }
    const seen = new Set<string>();
    const deduped = matches.filter((m) => {
      const k = m.quote.toLowerCase();
      if (seen.has(k)) return false;
      seen.add(k);
      return true;
    });
    return { careersPageUrl: footprint.primarySite.url, careersPageStatus: root.status, matches: deduped.slice(0, 5) };
  }

  // Avoid unused-param lint while keeping the public API simple.
  void firmName;
  return empty;
}

export function renderPainSignals(firmName: string, data: PainSignalsData): string {
  const lines: string[] = ["## Pain signals", ""];

  if (!data.careersPageUrl) {
    lines.push(
      `No careers page found at standard paths (/careers, /jobs, /work-with-us) for ${firmName}. No pain-signal regex pass possible at v0 without LinkedIn director-post access.`,
    );
    lines.push("");
    lines.push("Source: [searched site root](#) — no careers page reachable.");
    return lines.join("\n");
  }

  if (data.matches.length === 0) {
    lines.push(
      `Careers page reachable at [${data.careersPageUrl}](${data.careersPageUrl}) but no high-urgency phrases matched the v0 regex pass. Site may use measured language or hire offline.`,
    );
  } else {
    lines.push(
      `Careers page at [${data.careersPageUrl}](${data.careersPageUrl}) shows ${data.matches.length} pain-signal match${data.matches.length === 1 ? "" : "es"}:`,
    );
    lines.push("");
    for (const m of data.matches) {
      lines.push(`- _"${m.quote}"_ — pattern: \`${m.pattern}\``);
    }
    lines.push("");
    lines.push(
      "These phrases suggest active hiring pressure suitable for an outreach hook.",
    );
  }

  lines.push("");
  lines.push(`Source: [careers page](${data.careersPageUrl})`);
  return lines.join("\n");
}
