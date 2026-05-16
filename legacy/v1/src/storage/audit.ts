export interface AuditEntry {
  id: number;
  tenantId: string;
  conversationId: string;
  messageId: string | null;
  employeeAadId: string | null;
  originalQuery: string;
  draftReply: string | null;
  sensitivityScore: number;
  sensitivityCategory: string | null;
  confidence: number;
  escalationRecommended: boolean;
  status: AuditStatus;
  actorAadId: string | null;
  actionTimestamp: string | null;
  editedReply: string | null;
  createdAt: string;
  updatedAt: string | null;
}

export type AuditStatus =
  | 'pending_approval'
  | 'approved'
  | 'edited_and_approved'
  | 'rejected'
  | 'escalated'
  | 'acknowledged';

export interface WeeklyStats {
  total: number;
  approved: number;
  edited: number;
  rejected: number;
  escalated: number;
  avgConfidence: number;
  avgSensitivity: number;
}

export async function logMessage(
  db: D1Database,
  entry: {
    tenantId: string;
    conversationId: string;
    messageId?: string;
    employeeAadId?: string;
    originalQuery: string;
    draftReply: string | null;
    sensitivity: number;
    sensitivityCategory?: string;
    confidence: number;
    escalationRecommended: boolean;
    status: AuditStatus;
  },
): Promise<number> {
  const result = await db
    .prepare(
      `INSERT INTO audit_log (
        tenant_id, conversation_id, message_id,
        employee_aad_id, original_query, draft_reply,
        sensitivity_score, sensitivity_category, confidence,
        escalation_recommended, status
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    )
    .bind(
      entry.tenantId,
      entry.conversationId,
      entry.messageId ?? null,
      entry.employeeAadId ?? null,
      entry.originalQuery,
      entry.draftReply,
      entry.sensitivity,
      entry.sensitivityCategory ?? null,
      entry.confidence,
      entry.escalationRecommended ? 1 : 0,
      entry.status,
    )
    .run();

  return result.meta.last_row_id as number;
}

export async function logApproval(
  db: D1Database,
  auditId: number,
  newStatus: AuditStatus,
  actorAadId: string,
  editedReply?: string,
): Promise<void> {
  await db
    .prepare(
      `UPDATE audit_log
       SET status = ?, actor_aad_id = ?, action_timestamp = datetime('now'),
           edited_reply = COALESCE(?, edited_reply), updated_at = datetime('now')
       WHERE id = ?`,
    )
    .bind(newStatus, actorAadId, editedReply ?? null, auditId)
    .run();
}

export async function getAuditRecord(
  db: D1Database,
  auditId: number,
): Promise<AuditEntry | null> {
  const row = await db
    .prepare('SELECT * FROM audit_log WHERE id = ?')
    .bind(auditId)
    .first<Record<string, unknown>>();

  if (!row) return null;
  return rowToEntry(row);
}

export async function getPendingApprovals(
  db: D1Database,
  tenantId: string,
): Promise<AuditEntry[]> {
  const { results } = await db
    .prepare(
      `SELECT * FROM audit_log
       WHERE tenant_id = ? AND status = 'pending_approval'
       ORDER BY created_at DESC LIMIT 20`,
    )
    .bind(tenantId)
    .all<Record<string, unknown>>();

  return results.map(rowToEntry);
}

export async function getWeeklyStats(
  db: D1Database,
  tenantId: string,
  weekStart: Date,
): Promise<WeeklyStats> {
  const weekEnd = new Date(weekStart.getTime() + 7 * 86_400_000);

  const row = await db
    .prepare(
      `SELECT
        COUNT(*) as total,
        SUM(CASE WHEN status = 'approved' THEN 1 ELSE 0 END) as approved,
        SUM(CASE WHEN status = 'edited_and_approved' THEN 1 ELSE 0 END) as edited,
        SUM(CASE WHEN status = 'rejected' THEN 1 ELSE 0 END) as rejected,
        SUM(CASE WHEN status = 'escalated' THEN 1 ELSE 0 END) as escalated,
        AVG(confidence) as avg_confidence,
        AVG(sensitivity_score) as avg_sensitivity
       FROM audit_log
       WHERE tenant_id = ? AND created_at >= ? AND created_at < ?`,
    )
    .bind(tenantId, weekStart.toISOString(), weekEnd.toISOString())
    .first<Record<string, number | null>>();

  return {
    total: Number(row?.['total'] ?? 0),
    approved: Number(row?.['approved'] ?? 0),
    edited: Number(row?.['edited'] ?? 0),
    rejected: Number(row?.['rejected'] ?? 0),
    escalated: Number(row?.['escalated'] ?? 0),
    avgConfidence: Number(row?.['avg_confidence'] ?? 0),
    avgSensitivity: Number(row?.['avg_sensitivity'] ?? 0),
  };
}

export async function deleteEmployeeData(
  db: D1Database,
  tenantId: string,
  employeeAadId: string,
): Promise<number> {
  const result = await db
    .prepare(
      'DELETE FROM audit_log WHERE tenant_id = ? AND employee_aad_id = ?',
    )
    .bind(tenantId, employeeAadId)
    .run();

  return result.meta.changes as number;
}

export async function exportEmployeeData(
  db: D1Database,
  tenantId: string,
  employeeAadId: string,
): Promise<AuditEntry[]> {
  const { results } = await db
    .prepare(
      'SELECT * FROM audit_log WHERE tenant_id = ? AND employee_aad_id = ? ORDER BY created_at DESC',
    )
    .bind(tenantId, employeeAadId)
    .all<Record<string, unknown>>();

  return results.map(rowToEntry);
}

function rowToEntry(row: Record<string, unknown>): AuditEntry {
  return {
    id: Number(row['id']),
    tenantId: String(row['tenant_id'] ?? ''),
    conversationId: String(row['conversation_id'] ?? ''),
    messageId: row['message_id'] != null ? String(row['message_id']) : null,
    employeeAadId: row['employee_aad_id'] != null ? String(row['employee_aad_id']) : null,
    originalQuery: String(row['original_query'] ?? ''),
    draftReply: row['draft_reply'] != null ? String(row['draft_reply']) : null,
    sensitivityScore: Number(row['sensitivity_score'] ?? 0),
    sensitivityCategory: row['sensitivity_category'] != null ? String(row['sensitivity_category']) : null,
    confidence: Number(row['confidence'] ?? 0),
    escalationRecommended: Boolean(row['escalation_recommended']),
    status: String(row['status'] ?? 'pending_approval') as AuditStatus,
    actorAadId: row['actor_aad_id'] != null ? String(row['actor_aad_id']) : null,
    actionTimestamp: row['action_timestamp'] != null ? String(row['action_timestamp']) : null,
    editedReply: row['edited_reply'] != null ? String(row['edited_reply']) : null,
    createdAt: String(row['created_at'] ?? ''),
    updatedAt: row['updated_at'] != null ? String(row['updated_at']) : null,
  };
}
