// CLI: block until the operator decides (or the absolute deadline passes).
//
// Usage:
//   node dist/bin/await.js \
//     --approval-id <id> \
//     --tenant <slug> \
//     [--expires-at <ISO>] \
//     [--poll-interval-seconds 30]
//
// stdout: {"outcome": "approved"|"rejected"|"timeout", "decided_by"?, "decided_at_iso"?}
// exit code is 0 for ALL THREE outcomes — the caller branches on .outcome
// (timeout is an expected business outcome, not a CLI failure).
//
// env:
//   IFOS_DB_URL       — required (production): the postgres approvals reader
//                       polls decision_log for the operator's decision row
//                       (written by record-decision.js / the future
//                       @ifos/telegram-surface command handler).
//   IFOS_BRIDGE_FAKE  — approve|reject|timeout: fixture mode; returns the
//                       forced outcome immediately, no DB, "fake": true.

import { awaitApprovalDecision } from "../src/bridge.js";
import { createPostgresDecisionSource } from "../src/decisions-postgres.js";
import { emit, fail, fakeMode, parseArgs, requireArg } from "./cli-shared.js";

async function main(): Promise<void> {
  const args = parseArgs(process.argv.slice(2));
  const approvalId = requireArg(args, "approval-id");
  const fake = fakeMode();

  if (fake) {
    if (fake === "timeout") {
      emit({ outcome: "timeout", fake: true });
      return;
    }
    emit({
      outcome: fake === "approve" ? "approved" : "rejected",
      decided_by: "fake-operator",
      decided_at_iso: new Date().toISOString(),
      fake: true,
    });
    return;
  }

  const tenant = requireArg(args, "tenant");
  const dbUrl = process.env.IFOS_DB_URL;
  if (!dbUrl) {
    fail("IFOS_DB_URL unset — the postgres approvals reader needs the dev/prod DB");
  }

  const decisions = createPostgresDecisionSource({
    db_url: dbUrl as string,
    tenant_slug: tenant,
  });

  const result = await awaitApprovalDecision(
    {
      approval_id: approvalId,
      expires_at_iso: args.get("expires-at"),
      poll_interval_seconds: args.has("poll-interval-seconds")
        ? Number(args.get("poll-interval-seconds"))
        : undefined,
    },
    { transport: { postMessage: async () => ({ message_id: "n/a" }) }, decisions },
  );

  emit(result);
}

main().catch((err: unknown) => {
  fail((err as Error)?.message ?? String(err));
});
