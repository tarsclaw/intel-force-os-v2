// @ifos/cv-library CLI — thin bash↔TS bridge for the Sourcing Scout agent
// bundle (cycle.sh invokes `node dist/cli.js <command>`; mirrors the
// @ifos/xero + @ifos/quickbooks CLI pattern landed for Cash Conductor).
//
// Commands:
//   check-auth — validate env config presence (NO network call; CV-Library
//             uses a long-lived key, so "refresh" = config-presence check);
//             prints JSON {ok, auth_mode, account_id}
//   search-candidates [--keywords K] [--location L] [--salary-min N]
//             [--salary-max N] [--limit N]
//             — live candidate search normalised to the Sourcing Scout
//             unified candidate shape (cycle.sh Steps 3/5/6 consume the
//             same shape from every source — source-abstraction layer per
//             ULTRAPLAN A5 line 555 gotcha); prints JSON
//             {ok, total, candidates:[{ref,source,name,email,phone,
//              linkedin_url,headline,location}]}
//
// Config from env (caller sources _secrets.env; values never printed):
//   CVLIBRARY_AUTH_MODE     basic | bearer (default basic)
//   CVLIBRARY_API_KEY       required when auth_mode=basic
//   CVLIBRARY_ACCESS_TOKEN  required when auth_mode=bearer
//   CVLIBRARY_ACCOUNT_ID    rate-limit bucketing id (default "default")
//   CVLIBRARY_BASE_URL      optional base-URL override
//
// Errors → {ok:false, error:"auth"|"rate_limit"|<message>}, exit 1.

import { searchCandidates } from "./candidates.js";
import { CVLibraryClient } from "./client.js";
import { CVLibraryAuthError, CVLibraryRateLimitError } from "./errors.js";
import type { CVLibraryAuthMode, CVLibraryConfig } from "./types.js";

function fail(error: string): never {
  process.stdout.write(JSON.stringify({ ok: false, error }) + "\n");
  process.exit(1);
}

/** Minimal --flag <value> parser over argv[3..]. */
function parseFlags(argv: string[]): Record<string, string> {
  const flags: Record<string, string> = {};
  for (let i = 0; i < argv.length; i += 1) {
    const tok = argv[i];
    if (tok?.startsWith("--")) {
      flags[tok.slice(2)] = argv[i + 1] ?? "";
      i += 1;
    }
  }
  return flags;
}

function buildConfig(): CVLibraryConfig {
  const auth_mode = (process.env.CVLIBRARY_AUTH_MODE ?? "basic") as CVLibraryAuthMode;
  if (auth_mode !== "basic" && auth_mode !== "bearer") {
    fail(`CVLIBRARY_AUTH_MODE must be 'basic' or 'bearer' (got '${auth_mode}')`);
  }
  const api_key = process.env.CVLIBRARY_API_KEY;
  const access_token = process.env.CVLIBRARY_ACCESS_TOKEN;
  if (auth_mode === "basic" && !api_key) {
    fail("CVLIBRARY_API_KEY not in env (source _secrets.env)");
  }
  if (auth_mode === "bearer" && !access_token) {
    fail("CVLIBRARY_ACCESS_TOKEN not in env (source _secrets.env)");
  }
  return {
    account_id: process.env.CVLIBRARY_ACCOUNT_ID ?? "default",
    auth_mode,
    api_key,
    access_token,
    base_url: process.env.CVLIBRARY_BASE_URL,
  };
}

async function main(): Promise<void> {
  const command = process.argv[2];

  if (command === "check-auth") {
    const config = buildConfig();
    process.stdout.write(
      JSON.stringify({ ok: true, auth_mode: config.auth_mode, account_id: config.account_id }) + "\n",
    );
    return;
  }

  if (command === "search-candidates") {
    const config = buildConfig();
    const flags = parseFlags(process.argv.slice(3));
    const client = new CVLibraryClient({ config });
    const res = await searchCandidates(client, {
      keywords: flags.keywords || undefined,
      location: flags.location || undefined,
      salary_min: flags["salary-min"] ? Number(flags["salary-min"]) : undefined,
      salary_max: flags["salary-max"] ? Number(flags["salary-max"]) : undefined,
      limit: flags.limit ? Number(flags.limit) : 30,
      no_cache: true,
    });
    // Normalise to the Sourcing Scout unified candidate shape (cycle.sh
    // Step 7 aggregate + bin/fuzzy-match.sh consume this generically).
    const candidates = res.results.map((c) => ({
      ref: `cvlibrary:${c.candidate_id}`,
      source: "cvlibrary",
      name: c.full_name,
      email: c.email,
      phone: c.phone,
      linkedin_url: null,
      headline: c.current_title,
      location: c.location,
    }));
    process.stdout.write(
      JSON.stringify({ ok: true, total: res.total, candidates }) + "\n",
    );
    return;
  }

  fail(`unknown command '${command ?? ""}' (use: check-auth | search-candidates)`);
}

main().catch((e: unknown) => {
  if (e instanceof CVLibraryRateLimitError) fail("rate_limit");
  if (e instanceof CVLibraryAuthError) fail("auth");
  fail(e instanceof Error ? e.message : String(e));
});
