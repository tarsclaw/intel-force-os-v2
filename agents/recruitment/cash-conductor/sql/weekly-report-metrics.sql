-- Cash Conductor — weekly cash-flow report metrics (agent.md §3 Output 3 + §4 Step 13)
--
-- Single source of truth for the weekly-report numbers. Consumed by:
--   1. cycle.sh Step 13 (assembles the 6-section Markdown report)
--   2. scripts/run-weekly-report-test.sh (deterministic metrics assertions)
--
-- CONTRACT: caller opens the transaction + sets the tenant —
--   BEGIN; SET LOCAL app.current_tenant='<slug>'; \i this-file; COMMIT;
-- READ-ONLY. Emits one "key|value" line per metric (numeric values; the assembler
-- computes DSO + formats the Markdown). The 7-day window is relative to now().

-- §1 Week summary + receipts
SELECT 'issued_7d|'   || count(*)::text FROM cash_conductor_invoices WHERE issued_at > now() - interval '7 days';
SELECT 'paid_count|'  || count(*)::text FROM cash_conductor_invoices WHERE status = 'paid';
SELECT 'open_count|'  || count(*)::text FROM cash_conductor_invoices WHERE status IN ('open','partial','overdue');
SELECT 'receipts_7d|' || coalesce(sum(amount),0)::text FROM cash_conductor_transactions WHERE amount > 0 AND posted_at > now() - interval '7 days';

-- §2 DSO inputs (AR outstanding + total credit extended)
SELECT 'ar_open|'      || coalesce(sum(amount_total - amount_paid),0)::text FROM cash_conductor_invoices WHERE status IN ('open','partial','overdue');
SELECT 'total_credit|' || coalesce(sum(amount_total),0)::text FROM cash_conductor_invoices;

-- §3 Aged debtors (outstanding by days overdue; open invoices)
SELECT 'bucket_0_30|'   || coalesce(sum(amount_total - amount_paid),0)::text FROM cash_conductor_invoices WHERE status IN ('open','partial','overdue') AND due_at >  now() - interval '30 days';
SELECT 'bucket_31_60|'  || coalesce(sum(amount_total - amount_paid),0)::text FROM cash_conductor_invoices WHERE status IN ('open','partial','overdue') AND due_at <= now() - interval '30 days' AND due_at > now() - interval '60 days';
SELECT 'bucket_61_90|'  || coalesce(sum(amount_total - amount_paid),0)::text FROM cash_conductor_invoices WHERE status IN ('open','partial','overdue') AND due_at <= now() - interval '60 days' AND due_at > now() - interval '90 days';
SELECT 'bucket_90_plus|'|| coalesce(sum(amount_total - amount_paid),0)::text FROM cash_conductor_invoices WHERE status IN ('open','partial','overdue') AND due_at <= now() - interval '90 days';

-- §4 Chase pipeline (by last sent position)
SELECT 'chase_pos1|' || count(*)::text FROM cash_conductor_invoices WHERE last_chase_position = 1;
SELECT 'chase_pos2|' || count(*)::text FROM cash_conductor_invoices WHERE last_chase_position = 2;
SELECT 'chase_pos3|' || count(*)::text FROM cash_conductor_invoices WHERE last_chase_position = 3;

-- §5 Cash-flow forecast (outstanding due within the next 4 weeks)
SELECT 'forecast_4w|' || coalesce(sum(amount_total - amount_paid),0)::text FROM cash_conductor_invoices WHERE status IN ('open','partial','overdue') AND due_at BETWEEN now() AND now() + interval '28 days';

-- §6 Exception list inputs
SELECT 'unmatched_count|' || count(*)::text FROM cash_conductor_transactions WHERE match_status = 'unmatched' AND amount > 0;
SELECT 'ambiguous_count|' || count(*)::text FROM cash_conductor_transactions WHERE match_status = 'ambiguous';
