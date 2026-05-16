// Optional Postgres write path — dual-writes audit events to ops.* tables
// when POSTGRES_HTTP_URL is set in Worker secrets.
//
// v1 approach: use Neon serverless driver (HTTP-compatible, works in Workers).
// For Hetzner Postgres: expose via Cloudflare Hyperdrive or a Neon proxy.
// When not set: Worker writes to D1 only (current behaviour).

export interface PostgresEnv {
  POSTGRES_HTTP_URL?: string;
}

interface PgInvocationRow {
  tenantId: string;
  agent: string;
  trigger: string;
  status: string;
  startedAt: string;
  durationMs: number | null;
  costGbp: number | null;
  model: string | null;
}

interface PgEscalationRow {
  tenantId: string;
  category: string;
  severity: string;
  originalMessage: string;
  employeeAadId: string | null;
  agentReasoning: string;
  correlationId: string | null;
}

interface PgAuditRow {
  tenantId: string;
  actorId: string | null;
  actorKind: string;
  actorLabel: string | null;
  action: string;
  targetKind: string | null;
  targetId: string | null;
  detail: string | null;
  severity: string;
  correlationId: string | null;
  ipAddress: string | null;
}

async function pgQuery(
  url: string,
  sql: string,
  params: unknown[],
): Promise<void> {
  const resp = await fetch(`${url}/query`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ query: sql, params }),
  });

  if (!resp.ok) {
    const body = await resp.text().catch(() => '');
    throw new Error(`Postgres HTTP error ${resp.status}: ${body}`);
  }
}

export async function pgWriteInvocation(
  env: PostgresEnv,
  row: PgInvocationRow,
): Promise<void> {
  if (!env.POSTGRES_HTTP_URL) return;
  try {
    await pgQuery(
      env.POSTGRES_HTTP_URL,
      `INSERT INTO ops.invocations
         (tenant_id, agent, trigger, status, started_at, duration_ms, cost_gbp, model)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
       ON CONFLICT DO NOTHING`,
      [
        row.tenantId,
        row.agent,
        row.trigger,
        row.status,
        row.startedAt,
        row.durationMs,
        row.costGbp,
        row.model,
      ],
    );
  } catch (err) {
    // Non-fatal — D1 is the source of truth in v1
    console.warn('pg_write_invocation_failed', {
      tenantId: row.tenantId,
      error: err instanceof Error ? err.message : 'unknown',
    });
  }
}

export async function pgWriteEscalation(
  env: PostgresEnv,
  row: PgEscalationRow,
): Promise<void> {
  if (!env.POSTGRES_HTTP_URL) return;
  try {
    await pgQuery(
      env.POSTGRES_HTTP_URL,
      `INSERT INTO ops.escalations
         (tenant_id, category, severity, original_message, employee_aad_id, agent_reasoning, correlation_id, status, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, 'OPEN', NOW())
       ON CONFLICT DO NOTHING`,
      [
        row.tenantId,
        row.category,
        row.severity,
        row.originalMessage,
        row.employeeAadId,
        row.agentReasoning,
        row.correlationId,
      ],
    );
  } catch (err) {
    console.warn('pg_write_escalation_failed', {
      tenantId: row.tenantId,
      error: err instanceof Error ? err.message : 'unknown',
    });
  }
}

export async function pgWriteAuditEvent(
  env: PostgresEnv,
  row: PgAuditRow,
): Promise<void> {
  if (!env.POSTGRES_HTTP_URL) return;
  try {
    await pgQuery(
      env.POSTGRES_HTTP_URL,
      `INSERT INTO ops.audit_log
         (tenant_id, actor_id, actor_kind, actor_label, action, target_kind, target_id, detail, severity, correlation_id, ip_address, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, NOW())`,
      [
        row.tenantId,
        row.actorId,
        row.actorKind,
        row.actorLabel,
        row.action,
        row.targetKind,
        row.targetId,
        row.detail,
        row.severity,
        row.correlationId,
        row.ipAddress,
      ],
    );
  } catch (err) {
    console.warn('pg_write_audit_failed', {
      tenantId: row.tenantId,
      action: row.action,
      error: err instanceof Error ? err.message : 'unknown',
    });
  }
}
