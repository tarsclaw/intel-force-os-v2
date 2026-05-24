// §10 — Recent activity. Companies House filings last 90 days +
// (v1.1) LinkedIn posts + Google news. v0 covers CH filings only.

import * as ch from "@ifos/companies-house";
import type { FirmSignalData } from "./firm-signal.js";

export interface RecentActivityData {
  filings: { date: string; description: string; category: string }[];
}

export async function fetchRecentActivity(
  firmSignal: FirmSignalData,
): Promise<RecentActivityData> {
  if (!firmSignal.companyNumber) return { filings: [] };
  let fh;
  try {
    fh = await ch.filingHistory(firmSignal.companyNumber, 90);
  } catch {
    return { filings: [] };
  }
  return {
    filings: (fh?.items ?? []).slice(0, 10).map((f: ch.CHFiling) => ({
      date: f.date,
      description: f.description,
      category: f.category,
    })),
  };
}

export function renderRecentActivity(
  firmSignal: FirmSignalData,
  firmName: string,
  data: RecentActivityData,
): string {
  const lines: string[] = ["## Recent activity", ""];
  const chUrl = firmSignal.companyNumber
    ? `https://find-and-update.company-information.service.gov.uk/company/${firmSignal.companyNumber}/filing-history`
    : `https://find-and-update.company-information.service.gov.uk/search?q=${encodeURIComponent(firmName)}`;

  if (data.filings.length === 0) {
    lines.push(
      "No filings at Companies House in the last 90 days. May indicate quiet period OR firm is between annual cycles.",
    );
  } else {
    lines.push(
      `${data.filings.length} filing${data.filings.length === 1 ? "" : "s"} in last 90 days (Companies House):`,
    );
    lines.push("");
    for (const f of data.filings) {
      lines.push(`- **${f.date}** — ${f.description} (${f.category})`);
    }
  }
  lines.push("");
  lines.push(
    "**v0 limitation:** LinkedIn company posts + Google news mentions require Proxycurl + SerpAPI. Wire at W4 polish.",
  );
  lines.push("");
  lines.push(`Source: [Companies House filing history](${chUrl})`);
  return lines.join("\n");
}
