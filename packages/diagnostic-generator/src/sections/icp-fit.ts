// §6 — ICP fit. Composes firm-signal + sector hint against tenant's
// target_patch.json. v0: deterministic scoring on 2 dimensions
// (sector match + size-band proxy). Full multi-dimension scoring at W4.

import type { FirmSignalData } from "./firm-signal.js";

export interface TargetPatch {
  sectors?: string[];
  size_bands?: string[];
  geographies?: string[];
  deal_size_band_gbp?: { min?: number; max?: number };
}

export function renderIcpFit(
  firmSignal: FirmSignalData,
  firmName: string,
  sectorHint: string,
  targetPatch: TargetPatch | null,
): string {
  const lines: string[] = ["## ICP fit vs target_patch", ""];

  if (!targetPatch) {
    lines.push("No target_patch.json loaded for this tenant — cannot score ICP fit.");
    lines.push("");
    lines.push(
      `Source: [tenant config](vault://${firmSignal.companyNumber ? "target-patch" : "target-patch"})`,
    );
    return lines.join("\n");
  }

  let sectorScore: number | null = null;
  let sectorReason = "";
  if (targetPatch.sectors && targetPatch.sectors.length > 0) {
    if (sectorHint) {
      const matches = targetPatch.sectors.some((s) =>
        sectorHint.toLowerCase().includes(s.toLowerCase()),
      );
      sectorScore = matches ? 100 : 30;
      sectorReason = matches
        ? `sector hint \`${sectorHint}\` matches tenant target sectors (${targetPatch.sectors.join(", ")})`
        : `sector hint \`${sectorHint}\` does NOT match tenant target sectors (${targetPatch.sectors.join(", ")})`;
    } else {
      sectorScore = 50;
      sectorReason = "no operator sector hint provided; neutral score";
    }
  }

  let sizeScore: number | null = null;
  let sizeReason = "";
  const ageYears = firmSignal.incorporationDate
    ? Math.floor((Date.now() - Date.parse(firmSignal.incorporationDate)) / (365 * 24 * 60 * 60 * 1000))
    : null;
  if (ageYears !== null) {
    sizeScore = ageYears >= 5 && ageYears < 30 ? 80 : 40;
    sizeReason = `firm age ${ageYears} years — ${sizeScore === 80 ? "established mid-market band (good ICP fit signal)" : "outside typical mid-market band"}`;
  }

  const scoresPresent: number[] = [];
  if (sectorScore !== null) scoresPresent.push(sectorScore);
  if (sizeScore !== null) scoresPresent.push(sizeScore);

  const composite =
    scoresPresent.length > 0
      ? Math.round(scoresPresent.reduce((a, b) => a + b, 0) / scoresPresent.length)
      : null;

  lines.push(
    composite !== null
      ? `**Composite ICP fit score: ${composite}/100** (based on ${scoresPresent.length} dimension${scoresPresent.length === 1 ? "" : "s"} measurable at v0).`
      : "**ICP fit score not computable** — insufficient signals available.",
  );
  lines.push("");
  if (sectorScore !== null) lines.push(`- **Sector match (${sectorScore}):** ${sectorReason}`);
  if (sizeScore !== null) lines.push(`- **Size-band proxy (${sizeScore}):** ${sizeReason}`);
  lines.push("");
  lines.push(
    "**v0 limitation:** geography + deal_size_band scoring requires LinkedIn job-post data. Wire Proxycurl (W4 polish).",
  );
  lines.push("");

  const chUrl = firmSignal.companyNumber
    ? `https://find-and-update.company-information.service.gov.uk/company/${firmSignal.companyNumber}`
    : `https://find-and-update.company-information.service.gov.uk/search?q=${encodeURIComponent(firmName)}`;
  lines.push(`Source: [Companies House profile](${chUrl}) + tenant target_patch.json`);

  return lines.join("\n");
}
