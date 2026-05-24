// §1 — Firm signal. Companies House profile + officers + filing history.

import * as ch from "@ifos/companies-house";

export interface FirmSignalData {
  companyNumber: string | null;
  companyName: string | null;
  incorporationDate: string | null;
  status: string | null;
  address: string | null;
  sicCodes: string[];
  latestAccounts: string | null;
  recentFilingCount: number;
  directors: { name: string; role: string; appointedOn: string | null }[];
}

export async function fetchFirmSignal(firmName: string): Promise<FirmSignalData> {
  const empty: FirmSignalData = {
    companyNumber: null,
    companyName: null,
    incorporationDate: null,
    status: null,
    address: null,
    sicCodes: [],
    latestAccounts: null,
    recentFilingCount: 0,
    directors: [],
  };

  let matches;
  try {
    matches = await ch.search(firmName);
  } catch {
    return empty;
  }

  // Pick the first active match
  const best =
    matches.find((m) => m.company_status === "active") ?? matches[0] ?? null;
  if (!best) return empty;

  const [profile, officers, filings] = await Promise.all([
    ch.profile(best.company_number).catch(() => null),
    ch.officers(best.company_number).catch(() => null),
    ch.filingHistory(best.company_number, 90).catch(() => null),
  ]);

  return {
    companyNumber: best.company_number,
    companyName: profile?.company_name ?? best.title,
    incorporationDate: profile?.date_of_creation ?? null,
    status: profile?.company_status ?? best.company_status,
    address: profile
      ? [
          profile.registered_office_address.address_line_1,
          profile.registered_office_address.locality,
          profile.registered_office_address.postal_code,
          profile.registered_office_address.country,
        ]
          .filter(Boolean)
          .join(", ")
      : null,
    sicCodes: profile?.sic_codes ?? [],
    latestAccounts: profile?.accounts?.last_accounts?.made_up_to ?? null,
    recentFilingCount: filings?.items.length ?? 0,
    directors: (officers?.items ?? []).slice(0, 10).map((o) => ({
      name: o.name,
      role: o.officer_role,
      appointedOn: o.appointed_on ?? null,
    })),
  };
}

export function renderFirmSignal(firmName: string, data: FirmSignalData): string {
  const chUrl = data.companyNumber
    ? `https://find-and-update.company-information.service.gov.uk/company/${data.companyNumber}`
    : `https://find-and-update.company-information.service.gov.uk/search?q=${encodeURIComponent(firmName)}`;

  const lines: string[] = ["## Firm signal", ""];

  if (!data.companyNumber) {
    lines.push(
      `No active Companies House registration found for **${firmName}**. Diagnostic proceeded against publicly visible non-CH signals only.`,
    );
    lines.push("");
    lines.push(`Source: [Companies House search](${chUrl})`);
    return lines.join("\n");
  }

  lines.push(
    `**${data.companyName}** (CRN ${data.companyNumber}) is currently ${data.status === "active" ? "active" : `\`${data.status}\``} at Companies House.`,
  );
  if (data.incorporationDate) {
    const years = Math.floor(
      (Date.now() - Date.parse(data.incorporationDate)) / (365 * 24 * 60 * 60 * 1000),
    );
    lines.push(
      `Incorporated ${data.incorporationDate} (${years} years trading). Registered office: ${data.address ?? "address withheld"}.`,
    );
  }
  if (data.latestAccounts) {
    lines.push(`Latest accounts made up to ${data.latestAccounts}.`);
  }
  if (data.sicCodes.length > 0) {
    lines.push(`SIC codes: ${data.sicCodes.join(", ")}.`);
  }
  if (data.recentFilingCount > 0) {
    lines.push(
      `${data.recentFilingCount} filing${data.recentFilingCount === 1 ? "" : "s"} in last 90 days — covered in §10.`,
    );
  }
  if (data.directors.length > 0) {
    const names = data.directors
      .slice(0, 3)
      .map((d) => d.name.replace(/,\s*([A-Z][a-z]+)/, ", $1"))
      .join("; ");
    lines.push(`Directors on file (top 3): ${names}. Full mapping in §11.`);
  }

  lines.push("");
  lines.push(`Source: [Companies House profile](${chUrl})`);
  return lines.join("\n");
}
