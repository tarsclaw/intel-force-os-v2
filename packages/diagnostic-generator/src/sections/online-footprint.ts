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

export async function fetchOnlineFootprint(firmName: string): Promise<OnlineFootprintData> {
  const slug = firmSlug(firmName);
  const candidates = [
    `https://${slug}.com`,
    `https://${slug}.co.uk`,
    `https://www.${slug}.com`,
    `https://www.${slug}.co.uk`,
  ];

  let primarySite: OnlineFootprintData["primarySite"] = null;
  for (const url of candidates) {
    const r = await headCheck(url);
    if (r && r.status >= 200 && r.status < 400) {
      primarySite = { url: r.finalUrl || url, status: r.status, lastModified: r.lastModified };
      break;
    }
  }

  const linkedInUrl = `https://www.linkedin.com/company/${slug}/`;
  let linkedInReachable = false;
  let linkedInStatus: number | null = null;
  const li = await headCheck(linkedInUrl);
  if (li) {
    linkedInStatus = li.status;
    // LinkedIn returns 999 for bots, 200 for real pages, 404 for non-existent.
    // Treat 200 + 999 as "page exists" (999 = bot block, page IS there).
    linkedInReachable = li.status === 200 || li.status === 999;
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
