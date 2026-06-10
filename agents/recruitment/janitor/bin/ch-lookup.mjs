#!/usr/bin/env node
// Janitor — Companies House client-enrichment lookup (agent.md §4 Step 6).
//
// Thin node bridge over the @ifos/companies-house connector dist (Diagnostic
// precedent — the connector package owns auth/rate-limit/7d-cache; this
// helper only composes search → top-match → profile for ONE client name and
// prints a backfill-ready JSON row). Janitor does NOT modify the connector
// package — it consumes the built dist like diagnostic-generator does.
//
//   node ch-lookup.mjs --name "Acme Tech Ltd" [--conn-base <packages/mcp-connectors>]
//
// Output JSON (stdout, single line):
//   {ok:true,  crn, industry, source_confidence, matched_name}
//   {ok:false, error | not_found:true, source_confidence:0}
//
// source_confidence (deterministic v1.0 heuristic; feeds validate.sh G4
// ≥0.7 backfill-source gate):
//   0.9  — top search result title matches the client name case-insensitively
//   0.75 — top result present but inexact title match
//   0    — no result / 404 → backfill proposal is NOT generated (G4 honest)
//
// industry = first SIC code (raw 5-digit code string per CH profile
// sic_codes[]; human-readable SIC mapping is a documented enhancement).
// Requires COMPANIES_HOUSE_API_KEY in env (key SET in dev-sandbox; the one
// live-capable enrichment path this cycle per spec-001 §8).
// Rate-limit: connector enforces the shared 600/5min budget; a rate-limit
// error surfaces as {ok:false, error:"rate_limited"} → cycle.sh routes
// ESC_RATE_LIMIT_HIT.

import { pathToFileURL } from "node:url";
import { join } from "node:path";

function out(obj) {
  process.stdout.write(JSON.stringify(obj) + "\n");
}

const args = process.argv.slice(2);
const flags = {};
for (let i = 0; i < args.length; i += 1) {
  if (args[i]?.startsWith("--")) {
    flags[args[i].slice(2)] = args[i + 1] ?? "";
    i += 1;
  }
}

const name = (flags.name ?? "").trim();
if (!name) {
  out({ ok: false, error: "--name required", source_confidence: 0 });
  process.exit(1);
}

const connBase = flags["conn-base"] || join(process.cwd(), "packages", "mcp-connectors");
const distPath = join(connBase, "companies-house", "dist", "index.js");

let ch;
try {
  ch = await import(pathToFileURL(distPath).href);
} catch {
  out({ ok: false, error: `@ifos/companies-house dist not built at ${distPath} (pnpm --filter @ifos/companies-house build)`, source_confidence: 0 });
  process.exit(1);
}

try {
  const results = await ch.search(name);
  if (!results || results.length === 0) {
    out({ ok: false, not_found: true, source_confidence: 0 });
    process.exit(0);
  }
  const top = results[0];
  const exact = (top.title ?? "").trim().toLowerCase() === name.toLowerCase();
  const profile = await ch.profile(top.company_number);
  const industry =
    profile && Array.isArray(profile.sic_codes) && profile.sic_codes.length > 0
      ? profile.sic_codes[0]
      : null;
  out({
    ok: true,
    crn: top.company_number,
    industry,
    matched_name: top.title ?? "",
    source_confidence: exact ? 0.9 : 0.75,
  });
} catch (e) {
  const msg = e instanceof Error ? e.message : String(e);
  const rateLimited = e?.name === "CHRateLimitError" || /rate/i.test(msg);
  out({ ok: false, error: rateLimited ? "rate_limited" : msg, source_confidence: 0 });
  process.exit(1);
}
