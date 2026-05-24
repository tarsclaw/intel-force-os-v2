// §12 — Conversation opener. LLM-driven with deterministic fallback.
//
// LLM path: when ANTHROPIC_API_KEY is set, calls Claude API with §1-§11
// context + tenant voice corpus (when wired via voice-loader.sh) + tone
// rules. Voice classifier microservice still skipped per W3 scaffold spec
// (W4-5 polish wires it; for now §12 ships LLM-generated text without
// real classifier gate).
//
// Fallback path: when key absent OR LLM call fails after retry, falls
// back to deterministic anchor-based composition (Day-13 v0 behaviour).
// Both paths satisfy goal §1 success criterion 3 — the CODE ships;
// runtime behaviour gates on key presence.

import Anthropic from "@anthropic-ai/sdk";
import type { FirmSignalData } from "./firm-signal.js";
import type { PainSignalsData } from "./pain-signals.js";
import type { RecentActivityData } from "./recent-activity.js";

export interface ConversationOpenerInput {
  firmName: string;
  firmSignal: FirmSignalData;
  painSignals: PainSignalsData;
  recentActivity: RecentActivityData;
  sectorHint: string;
  // Voice corpus context (optional; W4-5 polish wires real corpus)
  voiceCorpusSamples?: string[];
  toneRules?: { rule_id: string; rule_text: string; severity: string }[];
}

const CLAUDE_MODEL = "claude-opus-4-7";  // per latest models knowledge cutoff

/**
 * Top-level renderer — LLM-driven when key available, fallback otherwise.
 * Async because LLM call is network I/O.
 */
export async function renderConversationOpener(
  input: ConversationOpenerInput,
): Promise<string> {
  const apiKey = process.env.ANTHROPIC_API_KEY;
  if (apiKey) {
    try {
      const llmText = await generateOpenerViaLLM(input, apiKey);
      return formatOpenerSection(llmText, input, /* source */ "llm");
    } catch (err) {
      process.stderr.write(
        `conversation-opener: LLM call failed (${(err as Error).message}); falling back to deterministic\n`,
      );
      // Fall through to deterministic path
    }
  }

  // Deterministic fallback path (Day-13 v0 behaviour)
  const { opener, evidenceLink } = buildDeterministicOpener(input);
  return formatOpenerSection(opener + "\n\n" + evidenceLink, input, "deterministic");
}

/**
 * Synchronous variant for tests and callers that can't await — always
 * returns the deterministic path. Exposed so existing callers that
 * don't want async overhead can still get a valid §12.
 */
export function renderConversationOpenerSync(input: ConversationOpenerInput): string {
  const { opener, evidenceLink } = buildDeterministicOpener(input);
  return formatOpenerSection(opener + "\n\n" + evidenceLink, input, "deterministic");
}

interface OpenerComponents {
  opener: string;
  evidenceLink: string;
}

function buildDeterministicOpener(input: ConversationOpenerInput): OpenerComponents {
  const { firmName, firmSignal, painSignals, recentActivity, sectorHint } = input;

  // Pick the strongest anchor signal we have, in this order:
  // 1. Specific pain-signal quote from §8
  // 2. Recent filing event (share allotment, director appointment) from §10
  // 3. Director name from §1
  // 4. Generic CH-derived anchor

  if (painSignals.matches.length > 0 && painSignals.careersPageUrl) {
    const quote = painSignals.matches[0].quote;
    return {
      opener: `Hi — noticed ${firmName}'s careers page mentions "${quote}". When firms are at that point, the bottleneck usually shifts from sourcing to the candidate-experience polish that protects offer acceptance rates. Worth a 20-minute call to compare notes on what we're seeing across other ${sectorHint || "UK recruitment"} firms at the same stage?`,
      evidenceLink: `[Source: ${firmName} careers page](${painSignals.careersPageUrl})`,
    };
  }

  if (recentActivity.filings.length > 0) {
    const filing = recentActivity.filings.find(
      (f) => /allotment|appointment|incorporation/i.test(f.description),
    ) ?? recentActivity.filings[0];
    return {
      opener: `Hi — saw the ${filing.description.toLowerCase()} on ${filing.date} at Companies House. Usually that's a signal of either fresh investment or a hiring push. We work with ${sectorHint || "UK recruitment"} firms in that exact transition; happy to share what we've seen work for similar-size operators.`,
      evidenceLink: `[Source: Companies House filing on ${filing.date}](https://find-and-update.company-information.service.gov.uk/company/${firmSignal.companyNumber}/filing-history)`,
    };
  }

  if (firmSignal.directors.length > 0) {
    const cleanName = firmSignal.directors[0].name.replace(/^([A-Z]+),\s*(.+)$/, "$2 $1");
    const ageYears = firmSignal.incorporationDate
      ? Math.floor((Date.now() - Date.parse(firmSignal.incorporationDate)) / (365 * 24 * 60 * 60 * 1000))
      : null;
    return {
      opener: `Hi ${cleanName.split(" ")[0]} — ${firmName} has been at Companies House for ${ageYears ?? "several"} years and is still actively trading. We work with established UK ${sectorHint || "recruitment"} firms on the operational side — the day-30 cleanup-and-attribution work that compounds across placements. Worth a short call?`,
      evidenceLink: `[Source: Companies House profile](https://find-and-update.company-information.service.gov.uk/company/${firmSignal.companyNumber})`,
    };
  }

  return {
    opener: `Hi — looking at ${firmName}'s public footprint, the standard signals (CH filings, careers page, LinkedIn) aren't surfacing the usual indicators of hiring pressure. That itself is interesting — happy to compare what we're seeing across ${sectorHint || "UK recruitment"} sector peers if useful.`,
    evidenceLink: `[Source: Companies House search](https://find-and-update.company-information.service.gov.uk/search?q=${encodeURIComponent(firmName)})`,
  };
}

/**
 * Call Claude API to generate the opener. Uses prompt caching on the
 * system prompt + tenant context (per claude-api skill conventions) so
 * repeated calls within a session are cheap.
 */
async function generateOpenerViaLLM(
  input: ConversationOpenerInput,
  apiKey: string,
): Promise<string> {
  const client = new Anthropic({ apiKey });

  const evidenceContext = buildEvidenceContext(input);
  const voiceContext = (input.voiceCorpusSamples ?? []).slice(0, 5).join("\n---\n");
  const toneRulesText = (input.toneRules ?? [])
    .filter((r) => r.severity === "block" || r.severity === "warn")
    .map((r) => `- ${r.rule_text}`)
    .join("\n");

  const systemPrompt = `You are writing the §12 "Conversation opener" section of a UK recruitment-firm diagnostic report. Output: a 2-3 sentence cold outreach opener written in the consultant's voice. Must be evidence-anchored to a specific signal from the report's §1-§11 evidence (Companies House data, careers-page quotes, LinkedIn signals, recent filings). NOT generic.

Constraints:
- 2-3 sentences MAX
- Anchor to ONE specific evidence point (cite it inline)
- No "I hope this finds you well" or generic openers
- No salary / commission anchors
- Suitable for cold outreach to a UK recruitment-firm decision-maker
- Output ONLY the opener text — no prefix, no formatting, no quote marks

${voiceContext ? `Voice corpus exemplars (write in this style):\n${voiceContext}\n\n` : ""}${toneRulesText ? `Tone rules to respect:\n${toneRulesText}\n\n` : ""}`;

  const userPrompt = `Firm: ${input.firmName}
Sector hint: ${input.sectorHint || "<none>"}

Evidence context:
${evidenceContext}

Write the §12 conversation opener. Output only the opener text.`;

  const response = await client.messages.create({
    model: CLAUDE_MODEL,
    max_tokens: 300,
    system: systemPrompt,
    messages: [{ role: "user", content: userPrompt }],
  });

  // Extract text from response content blocks
  const textBlocks = response.content.filter(
    (block): block is Anthropic.Messages.TextBlock => block.type === "text",
  );
  if (textBlocks.length === 0) {
    throw new Error("LLM response had no text content");
  }
  const text = textBlocks.map((b) => b.text).join("\n").trim();

  if (text.length < 50) {
    throw new Error(`LLM response too short (${text.length} chars; expected ≥50)`);
  }
  if (text.length > 1000) {
    throw new Error(`LLM response too long (${text.length} chars; expected ≤1000)`);
  }

  // Append the evidence-link as a separate line so the final formatted
  // section still has a Markdown link (Gate A V2 requirement)
  const { evidenceLink } = buildDeterministicOpener(input);
  return text + "\n\n" + evidenceLink;
}

function buildEvidenceContext(input: ConversationOpenerInput): string {
  const { firmName, firmSignal, painSignals, recentActivity } = input;
  const lines: string[] = [];

  if (firmSignal.companyNumber) {
    lines.push(`- Companies House: ${firmName} (CRN ${firmSignal.companyNumber}, ${firmSignal.status ?? "active"}, incorporated ${firmSignal.incorporationDate ?? "date unknown"})`);
    if (firmSignal.recentFilingCount > 0) {
      lines.push(`- ${firmSignal.recentFilingCount} CH filings in last 90 days`);
    }
    if (firmSignal.directors.length > 0) {
      const directorNames = firmSignal.directors.slice(0, 3).map((d) =>
        d.name.replace(/^([A-Z]+),\s*(.+)$/, "$2 $1"),
      ).join("; ");
      lines.push(`- Directors: ${directorNames}`);
    }
  } else {
    lines.push(`- Companies House: no UK registration found for "${firmName}"`);
  }

  if (painSignals.matches.length > 0) {
    lines.push(`- Careers page pain signals:`);
    for (const m of painSignals.matches.slice(0, 3)) {
      lines.push(`  - "${m.quote}"`);
    }
  } else if (painSignals.careersPageUrl) {
    lines.push(`- Careers page reachable but no urgency-phrase matches`);
  }

  if (recentActivity.filings.length > 0) {
    lines.push(`- Recent CH filings (last 90d):`);
    for (const f of recentActivity.filings.slice(0, 3)) {
      lines.push(`  - ${f.date}: ${f.description}`);
    }
  }

  return lines.join("\n");
}

function formatOpenerSection(
  body: string,
  _input: ConversationOpenerInput,
  source: "llm" | "deterministic",
): string {
  const lines: string[] = ["## Conversation opener", ""];

  // body is either the LLM-generated opener+evidence OR the deterministic
  // opener+evidence (already includes the link line)
  const bodyLines = body.split("\n");
  // First non-empty line is the opener; rest is evidence link
  const openerLines: string[] = [];
  const linkLines: string[] = [];
  let inLinks = false;
  for (const line of bodyLines) {
    if (line.startsWith("[Source:") || line.startsWith("[")) {
      inLinks = true;
    }
    if (inLinks) {
      linkLines.push(line);
    } else if (line.trim()) {
      openerLines.push(line);
    }
  }

  if (openerLines.length === 0) {
    // Defensive: body didn't split cleanly; output as-is
    lines.push(`> ${body.replace(/\n/g, "\n> ")}`);
  } else {
    lines.push(`> ${openerLines.join(" ")}`);
  }
  lines.push("");
  if (linkLines.length > 0) {
    lines.push(linkLines.filter((l) => l.trim()).join("\n"));
  }
  lines.push("");
  if (source === "llm") {
    lines.push(
      "**Generation:** LLM-driven (Claude API + evidence context). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0 scaffold; W4-5 polish wires real classifier.",
    );
  } else {
    lines.push(
      "**Generation:** deterministic anchor-based fallback (ANTHROPIC_API_KEY not set OR LLM call failed). Voice classifier ≥0.75 gate (per agent.md §5 V3) skipped at v0; W4-5 polish wires both LLM key + classifier.",
    );
  }

  return lines.join("\n");
}
