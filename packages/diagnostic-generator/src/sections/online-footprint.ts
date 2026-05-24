// §2 — Online footprint. Web scraper for {firm}.com / {firm}.co.uk +
// LinkedIn company-page existence check (unauthenticated; bot-detection
// often returns 999 or login wall, but URL existence is meaningful).

import { headCheck } from "@ifos/web-scraper";
import { firmSlug } from "../firm-slug.js";

export interface OnlineFootprintData {
  primarySite: { url: string; status: number | null; lastModified: string | null } | null;
  linkedInUrl: string;
  linkedInReachable: boolean;
  linkedInStatus: number | null;
}

function stripCompanySuffixes(name: string): string {
  return name
    .replace(/\b(plc|ltd|limited|llp|inc|corp|corporation|holdings|group|partners)\b/gi, "")
    .replace(/\s+/g, " ")
    .trim();
}

export async function fetchOnlineFootprint(firmName: string): Promise<OnlineFootprintData> {
  const fullSlug = firmSlug(firmName);
  const baseSlug = firmSlug(stripCompanySuffixes(firmName));
  // Try the suffix-stripped slug first (closer to real domain) then full
  const slugCandidates = baseSlug && baseSlug !== fullSlug ? [baseSlug, fullSlug] : [fullSlug];
  const candidates: string[] = [];
  for (const s of slugCandidates) {
    candidates.push(`https://${s}.com`);
    candidates.push(`https://${s}.co.uk`);
    candidates.push(`https://www.${s}.com`);
    candidates.push(`https://www.${s}.co.uk`);
  }

  let primarySite: OnlineFootprintData["primarySite"] = null;
  for (const url of candidates) {
    const r = await headCheck(url);
    if (r && r.status >= 200 && r.status < 400) {
      primarySite = { url: r.finalUrl || url, status: r.status, lastModified: r.lastModified };
      break;
    }
  }

  // LinkedIn slug discovery: try base (suffix-stripped) first, then full.
  // Hays plc → linkedin.com/company/hays BEFORE /hays-plc/. Mirrors the
  // domain-discovery logic above for consistency.
  let linkedInUrl = `https://www.linkedin.com/company/${fullSlug}/`;
  let linkedInReachable = false;
  let linkedInStatus: number | null = null;
  for (const s of slugCandidates) {
    const candidateUrl = `https://www.linkedin.com/company/${s}/`;
    const li = await headCheck(candidateUrl);
    if (li) {
      // LinkedIn returns 999 for bots, 200 for real pages, 404 for non-existent.
      // Treat 200 + 999 as "page exists" (999 = bot block, page IS there).
      if (li.status === 200 || li.status === 999) {
        linkedInUrl = candidateUrl;
        linkedInStatus = li.status;
        linkedInReachable = true;
        break;
      }
      // Remember the LAST status seen for diagnostic reporting if nothing matches
      linkedInStatus = li.status;
    }
  }

  return { primarySite, linkedInUrl, linkedInReachable, linkedInStatus };
}

export function renderOnlineFootprint(firmName: string, data: OnlineFootprintData): string {
  const lines: string[] = ["## Online footprint", ""];

  if (data.primarySite) {
    lines.push(`Primary website: [${data.primarySite.url}](${data.primarySite.url}) (HTTP ${data.primarySite.status}).`);
    if (data.primarySite.lastModified) {
      lines.push(`Server-reported last-modified: ${data.primarySite.lastModified}.`);
    }
  } else {
    lines.push(
      `No primary website found at standard {firm}.com / {firm}.co.uk variants. ${firmName} may operate under a different domain — verify manually.`,
    );
  }

  lines.push("");
  if (data.linkedInReachable) {
    lines.push(
      `LinkedIn company page: [${data.linkedInUrl}](${data.linkedInUrl}) (page exists; LinkedIn bot-detection returned ${data.linkedInStatus}, full content needs authenticated fetch — Proxycurl integration v1.1).`,
    );
  } else {
    lines.push(
      `LinkedIn page at [${data.linkedInUrl}](${data.linkedInUrl}) not reachable (HTTP ${data.linkedInStatus ?? "n/a"}). Firm may use a different LinkedIn slug or have no company page.`,
    );
  }

  return lines.join("\n");
}
