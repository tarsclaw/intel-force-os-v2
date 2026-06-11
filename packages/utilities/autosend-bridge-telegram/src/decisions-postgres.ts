// Production DecisionSource — Postgres approvals reader over `decision_log`.
//
// W10-13 Concierge build slice (per spec-004 §8). Replaces the test-only
// in-memory DecisionSource for live runs.
//
// Storage decision (schema-before-code; spec-004 §2 "No new migration"):
// approval decisions are recorded as ordinary `decision_log` rows rather than
// a new `approvals` table —
//   agent_name = 'autosend-bridge'
//   phase      = 'action'
//   outcome    = 'approved' | 'rejected'
//   payload    = { approval_id, decided_by, decided_at_iso, action_type? }
// This keeps the D1-B audit chain inside the same append-only substrate the
// rest of autosend uses (the D1-B doc: "the Telegram interaction is the
// trigger, not the audit substrate") and needs zero schema change. The
// `bin/record-decision.js` CLI is the single writer; the future
// @ifos/telegram-surface /approve//reject command-handler calls the same CLI
// (its reconciliation point).
//
// RLS: every query runs inside BEGIN; SET LOCAL app.current_tenant = <tenant>;
// ... COMMIT — the reader is tenant-scoped by construction.
//
// Dependency posture: zero npm deps (the package ships dependency-free). The
// reader shells out to `psql` via execFile with psql -v variables (no SQL
// string interpolation of caller input). Injectable `runPsql` keeps unit
// tests offline.

import { execFile } from "node:child_process";

import type { DecisionSource, PendingDecision } from "./types.js";

export interface PostgresDecisionSourceConfig {
  /** Postgres connection string (IFOS_DB_URL). Never logged. */
  db_url: string;
  /** Tenant the approvals are scoped to (RLS SET LOCAL app.current_tenant). */
  tenant_slug: string;
  /** Injectable psql runner (tests). Defaults to execFile("psql", ...). */
  runPsql?: RunPsql;
}

/** Runs psql with the given args + stdin SQL; resolves stdout. Rejects on non-zero exit. */
export type RunPsql = (args: string[], stdinSql: string) => Promise<string>;

const defaultRunPsql: RunPsql = (args, stdinSql) =>
  new Promise((resolve, reject) => {
    const child = execFile("psql", args, { timeout: 30_000 }, (err, stdout, stderr) => {
      if (err) {
        reject(new Error(`psql failed: ${stderr.trim() || err.message}`));
        return;
      }
      resolve(stdout);
    });
    child.stdin?.write(stdinSql);
    child.stdin?.end();
  });

// The newest decision row for the approval_id wins (ORDER BY id DESC LIMIT 1)
// — "first valid reply wins" is enforced at the writer (record-decision skips
// when a decision already exists); the reader is just deterministic.
const FETCH_SQL = `BEGIN;
SET LOCAL app.current_tenant = :'tenant';
SELECT payload::text
FROM decision_log
WHERE tenant_slug = :'tenant'
  AND agent_name = 'autosend-bridge'
  AND phase = 'action'
  AND outcome IN ('approved', 'rejected')
  AND payload->>'approval_id' = :'aid'
ORDER BY id DESC
LIMIT 1;
COMMIT;
`;

export function createPostgresDecisionSource(
  config: PostgresDecisionSourceConfig,
): DecisionSource {
  if (!config.db_url) throw new Error("createPostgresDecisionSource: db_url is required");
  if (!config.tenant_slug) throw new Error("createPostgresDecisionSource: tenant_slug is required");
  const runPsql = config.runPsql ?? defaultRunPsql;

  return {
    async fetchDecision(approval_id: string): Promise<PendingDecision | null> {
      const stdout = await runPsql(
        [
          config.db_url,
          "-tAq",
          "-v",
          "ON_ERROR_STOP=1",
          "-v",
          `tenant=${config.tenant_slug}`,
          "-v",
          `aid=${approval_id}`,
        ],
        FETCH_SQL,
      );
      const line = stdout
        .split("\n")
        .map((l) => l.trim())
        .find((l) => l.startsWith("{"));
      if (!line) return null;

      let payload: {
        approval_id?: string;
        outcome?: string;
        decided_by?: string;
        decided_at_iso?: string;
      };
      try {
        payload = JSON.parse(line) as typeof payload;
      } catch {
        throw new Error(`decision row payload is not valid JSON for approval ${approval_id}`);
      }
      if (payload.outcome !== "approved" && payload.outcome !== "rejected") {
        // Defensive: outcome column matched but payload disagrees — treat as
        // still-pending rather than guessing (the writer stamps both).
        return null;
      }
      return {
        approval_id,
        outcome: payload.outcome,
        decided_by: payload.decided_by ?? "unknown",
        decided_at_iso: payload.decided_at_iso ?? new Date(0).toISOString(),
      };
    },
  };
}

// SQL used by bin/record-decision.ts (exported so the CLI + tests share one
// definition; also the documentation anchor for the telegram-surface handler).
export const RECORD_DECISION_SQL = `BEGIN;
SET LOCAL app.current_tenant = :'tenant';
INSERT INTO decision_log (tenant_slug, agent_name, phase, outcome, reason, payload)
SELECT :'tenant', 'autosend-bridge', 'action', :'outcome',
       'operator decision recorded via autosend-bridge record-decision CLI',
       jsonb_build_object(
         'approval_id', :'aid',
         'outcome', :'outcome',
         'decided_by', :'decider',
         'decided_at_iso', to_char(now() AT TIME ZONE 'utc', 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')
       )
WHERE NOT EXISTS (
  SELECT 1 FROM decision_log
  WHERE tenant_slug = :'tenant'
    AND agent_name = 'autosend-bridge'
    AND phase = 'action'
    AND outcome IN ('approved', 'rejected')
    AND payload->>'approval_id' = :'aid'
);
COMMIT;
`;

export { defaultRunPsql };
