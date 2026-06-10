// CLI: record an operator approve/reject decision for a pending approval.
//
// This is the SINGLE WRITER of approval-decision rows. Callers:
//   - the future @ifos/telegram-surface /approve//reject command handler
//     (its reconciliation point — it shells this CLI per reply), and
//   - operators/tests doing manual decision recording while the Telegram
//     command handler is not yet built (honest-scope: getUpdates-driven
//     command handling is telegram-surface scope, NOT this package's).
//
// Usage:
//   node dist/bin/record-decision.js \
//     --approval-id <id> \
//     --tenant <slug> \
//     --outcome approved|rejected \
//     --decided-by <telegram-user-id>
//
// stdout: {"ok": true, "recorded": true|false}   (recorded:false = a decision
// for this approval_id already existed — first valid reply wins; the write is
// skipped, never overwritten.)
//
// env: IFOS_DB_URL — required. RLS-scoped (SET LOCAL app.current_tenant).

import {
  RECORD_DECISION_SQL,
  createPostgresDecisionSource,
  defaultRunPsql,
} from "../src/decisions-postgres.js";
import { emit, fail, parseArgs, requireArg } from "./cli-shared.js";

async function main(): Promise<void> {
  const args = parseArgs(process.argv.slice(2));
  const approvalId = requireArg(args, "approval-id");
  const tenant = requireArg(args, "tenant");
  const outcome = requireArg(args, "outcome");
  const decidedBy = requireArg(args, "decided-by");

  if (outcome !== "approved" && outcome !== "rejected") {
    fail(`--outcome must be approved|rejected (got "${outcome}")`);
  }

  const dbUrl = process.env.IFOS_DB_URL;
  if (!dbUrl) fail("IFOS_DB_URL unset");

  // First-valid-reply-wins: check for an existing decision before writing.
  const source = createPostgresDecisionSource({
    db_url: dbUrl as string,
    tenant_slug: tenant,
  });
  const existing = await source.fetchDecision(approvalId);
  if (existing) {
    emit({ ok: true, recorded: false, existing_outcome: existing.outcome });
    return;
  }

  await defaultRunPsql(
    [
      dbUrl as string,
      "-tAq",
      "-v",
      "ON_ERROR_STOP=1",
      "-v",
      `tenant=${tenant}`,
      "-v",
      `aid=${approvalId}`,
      "-v",
      `outcome=${outcome}`,
      "-v",
      `decider=${decidedBy}`,
    ],
    RECORD_DECISION_SQL,
  );

  emit({ ok: true, recorded: true });
}

main().catch((err: unknown) => {
  fail((err as Error)?.message ?? String(err));
});
