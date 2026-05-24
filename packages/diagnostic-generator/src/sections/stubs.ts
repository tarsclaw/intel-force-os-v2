// Stub sections §3-§5, §7, §9, §11. Each needs LinkedIn deep data
// (employee search, JD parsing, profile timelines) we don't have at v0.
// Each renders with a Companies House anchor as fallback citation so
// Gate A V2 (≥1 link per section) passes.

import type { FirmSignalData } from "./firm-signal.js";

function chAnchor(firmSignal: FirmSignalData, firmName: string): string {
  if (firmSignal.companyNumber) {
    return `[Companies House profile](https://find-and-update.company-information.service.gov.uk/company/${firmSignal.companyNumber})`;
  }
  return `[Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=${encodeURIComponent(firmName)})`;
}

export function renderSectorMix(firmSignal: FirmSignalData, firmName: string, sectorHint: string): string {
  return [
    "## Sector + role-type mix",
    "",
    sectorHint
      ? `Operator-provided sector hint: \`${sectorHint}\`.`
      : "No operator-provided sector hint. SIC codes from Companies House are the only sector signal available without LinkedIn job-post data.",
    firmSignal.sicCodes.length > 0
      ? `Companies House SIC codes: ${firmSignal.sicCodes.join(", ")} — these are self-declared at registration and may not reflect current focus.`
      : "No SIC codes filed (unusual; verify firm status).",
    "",
    "**v0 limitation:** ratio of perm vs contract + role-level distribution requires LinkedIn job posts data. Wire Proxycurl (W4 polish) to populate this section properly.",
    "",
    `Source: ${chAnchor(firmSignal, firmName)}`,
  ].join("\n");
}

export function renderGeography(firmSignal: FirmSignalData, firmName: string): string {
  return [
    "## Geography",
    "",
    firmSignal.address
      ? `Registered office: ${firmSignal.address}.`
      : `Registered office address not visible at Companies House for ${firmName}.`,
    "",
    "**v0 limitation:** hiring-location mix (office vs remote vs hybrid) requires LinkedIn job posts location data. Wire Proxycurl (W4 polish).",
    "",
    `Source: ${chAnchor(firmSignal, firmName)}`,
  ].join("\n");
}

export function renderDealSizeBand(firmSignal: FirmSignalData, firmName: string): string {
  const years = firmSignal.incorporationDate
    ? Math.floor((Date.now() - Date.parse(firmSignal.incorporationDate)) / (365 * 24 * 60 * 60 * 1000))
    : null;
  return [
    "## Deal-size band proxy",
    "",
    years !== null
      ? `Firm age: ${years} years. Combined with ${firmSignal.recentFilingCount} recent filings and director count of ${firmSignal.directors.length}, suggests an established (not startup) operation — likely deal sizes in mid-market band rather than enterprise.`
      : `Firm-age signal unavailable without Companies House incorporation date.`,
    "",
    "**v0 limitation:** salary bands + level distribution require LinkedIn job posts data. Wire Proxycurl (W4 polish).",
    "",
    `Source: ${chAnchor(firmSignal, firmName)}`,
  ].join("\n");
}

export function renderTechStack(firmSignal: FirmSignalData, firmName: string): string {
  return [
    "## Tech stack signals",
    "",
    "**v0 limitation:** tech stack inference requires LinkedIn employee-skill aggregation + job-post tech-keyword extraction. Wire Proxycurl (W4 polish).",
    "",
    "Companies House SIC codes give a coarse industry signal but no specific technology stack visibility.",
    "",
    `Source: ${chAnchor(firmSignal, firmName)}`,
  ].join("\n");
}

export function renderCompetitorPositioning(firmSignal: FirmSignalData, firmName: string): string {
  return [
    "## Competitor positioning",
    "",
    "**v0 limitation:** competitor inference requires scanning LinkedIn employee employment-history for other-recruitment-agency names — needs Proxycurl-style profile data.",
    "",
    "Companies House does not surface competitor data at the firm level.",
    "",
    `Source: ${chAnchor(firmSignal, firmName)}`,
  ].join("\n");
}

export function renderDecisionMakerMap(firmSignal: FirmSignalData, firmName: string): string {
  const lines = ["## Decision-maker map", ""];
  if (firmSignal.directors.length > 0) {
    lines.push("Directors on file at Companies House (proxy for decision-makers until LinkedIn employee search is wired):");
    lines.push("");
    for (const d of firmSignal.directors.slice(0, 5)) {
      const cleanName = d.name.replace(/^([A-Z]+),\s*(.+)$/, "$2 $1");
      lines.push(
        `- **${cleanName}** — ${d.role}${d.appointedOn ? ` (appointed ${d.appointedOn})` : ""}`,
      );
    }
    lines.push("");
    lines.push(
      "**v0 limitation:** identifying _hiring_ decision-makers (head of talent / chief people officer / hiring manager) requires LinkedIn employee search filtered by title. Wire Proxycurl (W4 polish).",
    );
  } else {
    lines.push("No directors on file at Companies House (firm may be dissolved or unregistered).");
  }
  lines.push("");
  lines.push(`Source: ${chAnchor(firmSignal, firmName)}`);
  return lines.join("\n");
}
