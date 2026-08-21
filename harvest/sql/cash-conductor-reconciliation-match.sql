-- Cash Conductor — reconciliation 5-stage match (agent.md §3 Output 1 + §4 Step 5)
--
-- Single source of truth for the match algorithm. Consumed by:
--   1. cycle.sh Step 5 (live run)
--   2. scripts/run-reconciliation-recon-test.sh (deterministic fixture test)
--
-- CONTRACT: the CALLER opens the transaction and sets the tenant —
--   BEGIN; SET LOCAL app.current_tenant = '<slug>'; \i this-file; COMMIT;
-- This file contains NO transaction control and NO tenant literal; RLS
-- (current_setting('app.current_tenant')) scopes every read + write to the
-- caller's tenant. Re-runnable: only match_status='unmatched' rows are
-- (re-)evaluated, so matched/ambiguous rows are never re-touched.
--
-- Match stages (agent.md §3 Output 1 table). Per (transaction, invoice) pair the
-- LOWEST-numbered satisfied stage wins; per transaction the lowest stage across
-- candidate invoices wins; ties (>1 candidate at the winning stage) → ambiguous.
--   1  exact amount + invoice_number in memo/payee   → 0.98  → matched
--   2  exact amount + payee-name match               → 0.85  → matched
--   3  exact amount + within 90d of issue            → 0.70  → unmatched (review; suggestion attached)
--   4  fuzzy amount (±0.5%) + payee-name match        → 0.65  → ambiguous (ESC)
--   5  no candidate                                  → NULL  → unmatched
--   any stage with >1 candidate invoice             → ambiguous (ESC; multi-candidate per catalogue §2.10)
--
-- "exact amount": transaction.amount = invoice outstanding balance
-- (amount_total - amount_paid). Only incoming deposits (amount > 0) reconcile.
--
-- v1.0 conservative caveats (agent.md §9 gotcha 3 — avoid false-positive writes):
--   - invoice_number memo match is a case-insensitive substring; combined with
--     the exact-amount requirement + yellow-tier spot-check sampling + reversible
--     writes (autosend-policy irreversible:false), the false-positive surface is
--     acceptable for v1.0. Word-boundary hardening is a noted follow-up.
--   - payee match is normalised case-insensitive substring on the raw payee
--     string vs the invoice customer name (Xero raw.Contact.Name / QB
--     raw.CustomerRef.name). No fuzzy string distance at v1.0.
--
-- Returns one row: "s12|s3|s4|s5|ambiguous" stage-bucket counts for the
-- reconciliation_pass audit output (multi-candidate rows are counted in their
-- stage bucket AND in the ambiguous total).

WITH open_inv AS (
  SELECT
    invoice_id,
    invoice_number,
    issued_at,
    (amount_total - amount_paid) AS balance,
    lower(trim(coalesce(
      raw_payload -> 'Contact' ->> 'Name',
      raw_payload -> 'CustomerRef' ->> 'name',
      ''
    ))) AS cust_name
  FROM cash_conductor_invoices
  WHERE status IN ('open', 'partial', 'overdue')
),
eligible AS (
  SELECT
    id,
    amount,
    posted_at,
    lower(coalesce(payee_name_raw, '')) AS payee,
    coalesce(description, '') AS memo,
    coalesce(payee_name_raw, '') AS payee_raw
  FROM cash_conductor_transactions
  WHERE match_status = 'unmatched' AND amount > 0
),
pairs AS (
  SELECT
    e.id AS txn_id,
    i.invoice_id,
    CASE
      WHEN e.amount = i.balance
           AND i.invoice_number IS NOT NULL AND i.invoice_number <> ''
           AND (e.memo ILIKE '%' || i.invoice_number || '%'
                OR e.payee_raw ILIKE '%' || i.invoice_number || '%')
        THEN 1
      WHEN e.amount = i.balance
           AND i.cust_name <> '' AND e.payee LIKE '%' || i.cust_name || '%'
        THEN 2
      WHEN e.amount = i.balance
           AND e.posted_at BETWEEN i.issued_at AND i.issued_at + INTERVAL '90 days'
        THEN 3
      WHEN e.amount <> i.balance AND i.balance > 0
           AND abs(e.amount - i.balance) <= 0.005 * i.balance
           AND i.cust_name <> '' AND e.payee LIKE '%' || i.cust_name || '%'
        THEN 4
      ELSE NULL
    END AS stage
  FROM eligible e
  CROSS JOIN open_inv i
),
matched_pairs AS (
  SELECT txn_id, invoice_id, stage FROM pairs WHERE stage IS NOT NULL
),
ranked AS (
  SELECT
    txn_id,
    invoice_id,
    stage,
    min(stage) OVER (PARTITION BY txn_id) AS best_stage
  FROM matched_pairs
),
at_best AS (
  SELECT
    txn_id,
    best_stage,
    count(*) AS cand_count,
    (array_agg(invoice_id ORDER BY invoice_id))[1] AS one_invoice
  FROM ranked
  WHERE stage = best_stage
  GROUP BY txn_id, best_stage
),
decided AS (
  SELECT
    e.id AS txn_id,
    coalesce(ab.best_stage, 5) AS best_stage,
    coalesce(ab.cand_count, 0) AS cand_count,
    ab.one_invoice
  FROM eligible e
  LEFT JOIN at_best ab ON ab.txn_id = e.id
),
final AS (
  SELECT
    txn_id,
    best_stage,
    cand_count,
    CASE
      WHEN best_stage IN (1, 2) AND cand_count = 1 THEN 'matched'
      WHEN best_stage = 3 AND cand_count = 1 THEN 'unmatched'
      WHEN best_stage = 5 THEN 'unmatched'
      ELSE 'ambiguous'
    END AS new_status,
    CASE best_stage
      WHEN 1 THEN 0.98 WHEN 2 THEN 0.85 WHEN 3 THEN 0.70 WHEN 4 THEN 0.65
      ELSE NULL
    END AS conf,
    CASE WHEN cand_count = 1 THEN one_invoice ELSE NULL END AS matched_inv
  FROM decided
),
upd AS (
  UPDATE cash_conductor_transactions t
  SET
    match_status = f.new_status,
    match_confidence = f.conf,
    matched_invoice_id = f.matched_inv,
    match_dimensions = ARRAY[
      'stage:' || f.best_stage,
      'candidates:' || f.cand_count,
      'status:' || f.new_status
    ]
  FROM final f
  WHERE t.id = f.txn_id
  RETURNING f.best_stage AS best_stage, f.new_status AS new_status
)
SELECT
  count(*) FILTER (WHERE best_stage IN (1, 2))::text || '|' ||
  count(*) FILTER (WHERE best_stage = 3)::text || '|' ||
  count(*) FILTER (WHERE best_stage = 4)::text || '|' ||
  count(*) FILTER (WHERE best_stage = 5)::text || '|' ||
  count(*) FILTER (WHERE new_status = 'ambiguous')::text
FROM upd;
