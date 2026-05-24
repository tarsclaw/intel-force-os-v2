// Top-level Diagnostic report generator. Composes the 12 sections,
// outputs Markdown. Called by cli.ts.

import { fetchFirmSignal, renderFirmSignal } from "./sections/firm-signal.js";
import {
  fetchOnlineFootprint,
  renderOnlineFootprint,
} from "./sections/online-footprint.js";
import {
  renderSectorMix,
  renderGeography,
  renderDealSizeBand,
  renderTechStack,
  renderCompetitorPositioning,
  renderDecisionMakerMap,
} from "./sections/stubs.js";
import { renderIcpFit, type TargetPatch } from "./sections/icp-fit.js";
import { fetchPainSignals, renderPainSignals } from "./sections/pain-signals.js";
import { fetchRecentActivity, renderRecentActivity } from "./sections/recent-activity.js";
import { renderConversationOpener } from "./sections/conversation-opener.js";

export interface GenerateInput {
  firmName: string;
  tenantSlug: string;
  sectorHint?: string;
  targetPatch?: TargetPatch | null;
  isoDate?: string;
}

export async function generateReport(input: GenerateInput): Promise<string> {
  const { firmName, tenantSlug, sectorHint = "", targetPatch = null } = input;
  const isoDate = input.isoDate ?? new Date().toISOString().slice(0, 10);

  // §1 — Firm signal (Companies House)
  const firmSignal = await fetchFirmSignal(firmName);
  // §2 — Online footprint (web scraper + LinkedIn HEAD check)
  const onlineFootprint = await fetchOnlineFootprint(firmName);
  // §8 — Pain signals (web scraper for careers page)
  const painSignals = await fetchPainSignals(firmName, onlineFootprint);
  // §10 — Recent activity (Companies House filings)
  const recentActivity = await fetchRecentActivity(firmSignal);

  const header = [
    `# Diagnostic report — ${firmName}`,
    "",
    `**Generated:** ${isoDate} by Intel Force OS Diagnostic agent (v0 — pre-W3 build).`,
    `**Tenant:** ${tenantSlug}`,
    `**Sector hint:** ${sectorHint || "_<none provided>_"}`,
    `**Status:** Real Companies House data; web scraper for online footprint; LinkedIn deep data deferred to W4 polish (Proxycurl).`,
    "",
  ].join("\n");

  // §12 is async (LLM call when key set; deterministic fallback otherwise)
  const conversationOpener = await renderConversationOpener({
    firmName,
    firmSignal,
    painSignals,
    recentActivity,
    sectorHint,
  });

  const sections: string[] = [
    renderFirmSignal(firmName, firmSignal),
    renderOnlineFootprint(firmName, onlineFootprint),
    renderSectorMix(firmSignal, firmName, sectorHint),
    renderGeography(firmSignal, firmName),
    renderDealSizeBand(firmSignal, firmName),
    renderIcpFit(firmSignal, firmName, sectorHint, targetPatch),
    renderTechStack(firmSignal, firmName),
    renderPainSignals(firmName, painSignals),
    renderCompetitorPositioning(firmSignal, firmName),
    renderRecentActivity(firmSignal, firmName, recentActivity),
    renderDecisionMakerMap(firmSignal, firmName),
    conversationOpener,
  ];

  return [header, ...sections].join("\n\n").trim() + "\n";
}
