// Shared arg-parsing + output helpers for the bin/ CLI entrypoints
// (idiom carried over from autosend-bridge-telegram/bin/cli-shared.ts).
//
// Shell contract (W3 hook-helpers orange path):
//   node dist/bin/resolve-approver.js --tenant ... --action-type ... → ResolveResult JSON
//   node dist/bin/seed-identity-map.js --tenant ... --csv ...        → {ok, ...}
//
// Exit codes (resolve-approver):
//   0 — resolution produced (any ladder step)
//   3 — routing config absent/unusable (RoutingConfigError) — caller treats
//       as "resolver unavailable" and falls back to the single-operator path
//   1 — real errors (bad args, psql failure, unexpected exceptions)
//
// Fixture mode: IFOS_ROUTING_FAKE='{"person_ref":...}' returns the injected
// ResolveResult verbatim (no vault reads, no DB) — the HH_AWAIT_TEST_MODE /
// IFOS_BRIDGE_FAKE idiom applied at the routing layer. Output carries
// "fake": true so fixture evidence is never mistaken for live resolution.

export const EXIT_OK = 0;
export const EXIT_ERROR = 1;
export const EXIT_CONFIG_ABSENT = 3;

export function parseArgs(argv: string[]): Map<string, string> {
  const out = new Map<string, string>();
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    if (a.startsWith("--")) {
      const key = a.slice(2);
      const next = argv[i + 1];
      if (next !== undefined && !next.startsWith("--")) {
        out.set(key, next);
        i++;
      } else {
        out.set(key, "true");
      }
    }
  }
  return out;
}

export function requireArg(args: Map<string, string>, name: string): string {
  const v = args.get(name);
  if (!v) {
    fail(`missing required --${name}`);
  }
  return v as string;
}

export function emit(obj: unknown): void {
  process.stdout.write(`${JSON.stringify(obj)}\n`);
}

export function fail(message: string, exitCode: number = EXIT_ERROR): never {
  // Errors go to stderr as JSON too, so shell callers can jq either stream.
  process.stderr.write(`${JSON.stringify({ ok: false, error: message })}\n`);
  process.exit(exitCode);
}

/** Parses IFOS_ROUTING_FAKE — a full ResolveResult JSON returned verbatim. */
export function routingFake(): Record<string, unknown> | null {
  const v = process.env.IFOS_ROUTING_FAKE;
  if (!v) return null;
  try {
    const parsed = JSON.parse(v) as unknown;
    if (parsed === null || typeof parsed !== "object" || Array.isArray(parsed)) {
      fail("IFOS_ROUTING_FAKE must be a JSON object (a ResolveResult)");
    }
    return parsed as Record<string, unknown>;
  } catch (err) {
    if (err instanceof SyntaxError) {
      fail(`IFOS_ROUTING_FAKE is not valid JSON: ${err.message}`);
    }
    throw err;
  }
}
