// §12 — Conversation opener. v0: deterministic, evidence-anchored cold
// outreach pitch composed from §1, §6, §8, §10 signals. Voice classifier
// gate skipped at v0 per goal-option-c §6 (W3 build wires real classifier).

import type { FirmSignalData } from "./firm-signal.js";
import type { PainSignalsData } from "./pain-signals.js";
import type { RecentActivityData } from "./recent-activity.js";

export interface ConversationOpenerInput {
  firmName: string;
  firmSignal: FirmSignalData;
  painSignals: PainSignalsData;
  recentActivity: RecentActivityData;
  sectorHint: string;
}

export function renderConversationOpener(input: ConversationOpenerInput): string {
  const { firmName, firmSignal, painSignals, recentActivity, sectorHint } = input;

  const lines: string[] = ["## Conversation opener", ""];

  // Pick the strongest anchor signal we have, in this order:
  // 1. Specific pain-signal quote from §8
  // 2. Recent filing event (share allotment, director appointment) from §10
  // 3. Director name from §1
  // 4. Generic CH-derived anchor

  let opener: string;
  let evidenceLink: string;

  if (painSignals.matches.length > 0 && painSignals.careersPageUrl) {
    const quote = painSignals.matches[0].quote;
    opener = `Hi — noticed ${firmName}'s careers page mentions "${quote}". When firms are at that point, the bottleneck usually shifts from sourcing to the candidate-experience polish that protects offer acceptance rates. Worth a 20-minute call to compare notes on what we're seeing across other ${sectorHint || "UK recruitment"} firms at the same stage?`;
    evidenceLink = `[Source: ${firmName} careers page](${painSignals.careersPageUrl})`;
  } else if (recentActivity.filings.length > 0) {
    const filing = recentActivity.filings.find(
      (f) => /allotment|appointment|incorporation/i.test(f.description),
    ) ?? recentActivity.filings[0];
    opener = `Hi — saw the ${filing.description.toLowerCase()} on ${filing.date} at Companies House. Usually that's a signal of either fresh investment or a hiring push. We work with ${sectorHint || "UK recruitment"} firms in that exact transition; happy to share what we've seen work for similar-size operators.`;
    evidenceLink = `[Source: Companies House filing on ${filing.date}](https://find-and-update.company-information.service.gov.uk/company/${firmSignal.companyNumber}/filing-history)`;
  } else if (firmSignal.directors.length > 0) {
    const cleanName = firmSignal.directors[0].name.replace(/^([A-Z]+),\s*(.+)$/, "$2 $1");
    const ageYears = firmSignal.incorporationDate
      ? Math.floor((Date.now() - Date.parse(firmSignal.incorporationDate)) / (365 * 24 * 60 * 60 * 1000))
      : null;
    opener = `Hi ${cleanName.split(" ")[0]} — ${firmName} has been at Companies House for ${ageYears ?? "several"} years and is still actively trading. We work with established UK ${sectorHint || "recruitment"} firms on the operational side — the day-30 cleanup-and-attribution work that compounds across placements. Worth a short call?`;
    evidenceLink = `[Source: Companies House profile](https://find-and-update.company-information.service.gov.uk/company/${firmSignal.companyNumber})`;
  } else {
    opener = `Hi — looking at ${firmName}'s public footprint, the standard signals (CH filings, careers page, LinkedIn) aren't surfacing the usual indicators of hiring pressure. That itself is interesting — happy to compare what we're seeing across ${sectorHint || "UK recruitment"} sector peers if useful.`;
    evidenceLink = `[Source: Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=${encodeURIComponent(firmName)})`;
  }

  lines.push(`> ${opener}`);
  lines.push("");
  lines.push(evidenceLink);
  lines.push("");
  lines.push(
    "**v0 limitation:** voice classifier ≥ 0.75 gate (per agent.md §5 V3) skipped at v0; opener is deterministic anchor-based composition. Wire LLM + per-tenant voice classifier at W4 polish.",
  );

  return lines.join("\n");
}
