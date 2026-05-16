-- Intel Force OS — Initial D1 schema
-- Apply: wrangler d1 execute intel-force-audit --file=migrations/0001_initial.sql

CREATE TABLE IF NOT EXISTS audit_log (
  id                    INTEGER PRIMARY KEY AUTOINCREMENT,
  tenant_id             TEXT    NOT NULL,
  conversation_id       TEXT    NOT NULL,
  message_id            TEXT,

  employee_aad_id       TEXT,

  original_query        TEXT    NOT NULL,
  draft_reply           TEXT,
  sensitivity_score     REAL    NOT NULL DEFAULT 0,
  sensitivity_category  TEXT,
  confidence            REAL    NOT NULL DEFAULT 0,
  escalation_recommended INTEGER NOT NULL DEFAULT 0,

  status                TEXT    NOT NULL DEFAULT 'pending_approval',
  -- pending_approval | approved | edited_and_approved | rejected | escalated | acknowledged

  actor_aad_id          TEXT,
  action_timestamp      TEXT,
  edited_reply          TEXT,

  created_at            TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at            TEXT,

  metadata              TEXT    -- JSON blob for future extensibility
);

CREATE INDEX IF NOT EXISTS idx_audit_tenant        ON audit_log(tenant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_audit_pending       ON audit_log(tenant_id, status)
  WHERE status = 'pending_approval';
CREATE INDEX IF NOT EXISTS idx_audit_escalations   ON audit_log(tenant_id, status)
  WHERE status = 'escalated';
CREATE INDEX IF NOT EXISTS idx_audit_employee      ON audit_log(tenant_id, employee_aad_id);

CREATE TABLE IF NOT EXISTS tenant_stats_daily (
  tenant_id         TEXT    NOT NULL,
  date              TEXT    NOT NULL,   -- YYYY-MM-DD
  messages_handled  INTEGER NOT NULL DEFAULT 0,
  approved_asis     INTEGER NOT NULL DEFAULT 0,
  edited            INTEGER NOT NULL DEFAULT 0,
  rejected          INTEGER NOT NULL DEFAULT 0,
  escalated         INTEGER NOT NULL DEFAULT 0,
  avg_confidence    REAL,
  avg_sensitivity   REAL,
  PRIMARY KEY (tenant_id, date)
);

CREATE INDEX IF NOT EXISTS idx_stats_tenant ON tenant_stats_daily(tenant_id, date DESC);
