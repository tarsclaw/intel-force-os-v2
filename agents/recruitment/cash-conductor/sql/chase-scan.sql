-- Cash Conductor — chase candidate scan (agent.md §4 Step 7 + §3.2 ladder)
--
-- Single source of truth for the overdue-invoice chase scan. Consumed by:
--   1. cycle.sh Step 7 (live run)
--   2. scripts/run-chase-scan-test.sh (deterministic ladder fixture test)
--
-- CONTRACT: the CALLER opens the transaction and sets the tenant —
--   BEGIN; SET LOCAL app.current_tenant='<slug>'; \i this-file; COMMIT;
-- No transaction control / tenant literal here; RLS scopes every read. READ-ONLY
-- (chase position is only advanced in Step 11 after a send, never here).
--
-- Selects invoices that are overdue >7d, still owing, and NOT reconciled
-- (no Stage-1/2 'matched' transaction points at them), then computes the NEXT
-- chase position to send per the §3.2 sequential ladder:
--   position 1 @ ≥7d overdue · 2 @ ≥14d · 3 @ ≥21d · 4 @ ≥30d
-- Ladder is SEQUENTIAL: next_pos = last_chase_position + 1, emitted only when the
-- age threshold for that position is reached (you never skip positions, even if
-- the invoice is much older). Position 4 = operator review (drafts STOP).
--
-- Returns one row per chase candidate (pipe-delimited):
--   invoice_id|invoice_number|amount_due|days_overdue|next_pos|client_contact_id|client_billing_email
-- next_pos 1-3 = draftable (Step 8); next_pos 4 = operator-review (no auto-draft).

WITH matched_inv AS (
  SELECT DISTINCT matched_invoice_id AS invoice_id
  FROM cash_conductor_transactions
  WHERE match_status = 'matched' AND matched_invoice_id IS NOT NULL
),
overdue AS (
  SELECT
    i.invoice_id,
    i.invoice_number,
    (i.amount_total - i.amount_paid) AS amount_due,
    floor(extract(epoch FROM (now() - i.due_at)) / 86400)::int AS days_overdue,
    i.last_chase_position,
    coalesce(i.client_contact_id, '') AS client_contact_id,
    coalesce(i.client_billing_email, '') AS client_billing_email
  FROM cash_conductor_invoices i
  WHERE i.status IN ('open', 'partial', 'overdue')
    AND i.due_at < now() - INTERVAL '7 days'
    AND (i.amount_total - i.amount_paid) > 0
    AND i.invoice_id NOT IN (SELECT invoice_id FROM matched_inv)
),
scored AS (
  SELECT
    overdue.*,
    CASE
      WHEN days_overdue >= 30 THEN 4
      WHEN days_overdue >= 21 THEN 3
      WHEN days_overdue >= 14 THEN 2
      WHEN days_overdue >= 7  THEN 1
      ELSE 0
    END AS age_pos,
    last_chase_position + 1 AS next_pos
  FROM overdue
)
SELECT
  invoice_id || '|' || coalesce(invoice_number, '') || '|' || amount_due::text || '|' ||
  days_overdue::text || '|' || next_pos::text || '|' || client_contact_id || '|' ||
  client_billing_email
FROM scored
WHERE last_chase_position < 4   -- position 4 already reached → operator handles, no further auto-processing
  AND next_pos <= 4
  AND age_pos >= next_pos        -- age threshold for the next ladder position reached
ORDER BY days_overdue DESC, invoice_id;
