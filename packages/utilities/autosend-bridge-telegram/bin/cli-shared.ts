// Shared arg-parsing + output helpers for the bin/ CLI entrypoints.
//
// The CLIs are the shell-layer contract consumed by Concierge cycle.sh Step 11
// and Cash Conductor cycle.sh Step 10:
//   node dist/bin/propose.js --action ... --tenant ... → {approval_id, ...}
//   node dist/bin/await.js --approval-id ... --tenant ... → {outcome, ...}
//   node dist/bin/record-decision.js --approval-id ... --outcome ... → {ok}
//
// Fixture mode: IFOS_BRIDGE_FAKE=approve|reject|timeout short-circuits the
// network/DB so agent fixtures run deterministically without Telegram creds
// or operator interaction (the HH_AWAIT_TEST_MODE idiom from
// agents/_shared/hook-helpers.sh, applied at the bridge layer). Honest-scope:
// fixture mode is clearly marked in the output (`"fake": true`).

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

export function fail(message: string): never {
  // Errors go to stderr as JSON too, so shell callers can jq either stream.
  process.stderr.write(`${JSON.stringify({ ok: false, error: message })}\n`);
  process.exit(1);
}

export type BridgeFakeMode = "approve" | "reject" | "timeout";

export function fakeMode(): BridgeFakeMode | null {
  const v = process.env.IFOS_BRIDGE_FAKE;
  if (v === "approve" || v === "reject" || v === "timeout") return v;
  if (v) fail(`IFOS_BRIDGE_FAKE must be approve|reject|timeout (got "${v}")`);
  return null;
}
