-- Janitor — day-30 report metrics (agent.md §4 Step 10 + §3 Output 1)
--
-- Single source of truth for the day-30 report aggregation over decision_log
-- (30-day window) + the entities cache + recent_edit. Consumed by:
--   1. cycle.sh Step 10 (report assembly)
--   2. scripts/run-janitor-report-test.sh (deterministic fixture assertions)
--
-- CONTRACT: the CALLER opens the transaction and sets the tenant —
--   BEGIN; SET LOCAL app.current_tenant='<slug>'; \i this-file; COMMIT;
-- No transaction control / tenant literal here; RLS scopes every read.
-- READ-ONLY.
--
-- Returns key|value rows (CC weekly-report-metrics.sql idiom).
--
-- Gate B inputs (v1.0 metric definitions — deterministic, decision_log-derived;
-- the day-0-baseline-relative measure lands once the pilot onboarding captures
-- a baseline — documented enhancement per spec-001 §8 / agent.md §9 Q6):
--   dedup_pct        = 100 · auto-merged pairs / (auto-merged + review-band pairs)
--   completeness_pct = 100 · backfills applied / (backfills + still-missing rows)

WITH dl AS (
  SELECT phase, outcome,
         payload->>'action_type' AS action_type,
         payload->>'output_type' AS output_type
  FROM decision_log
  WHERE agent_name = 'janitor'
    AND created_at > now() - interval '30 days'
),
missing_now AS (
  SELECT count(*) AS n
  FROM entities
  CROSS JOIN LATERAL (
    VALUES ('candidate', 'location'),
           ('client', 'industry'),
           ('client', 'size_employees'),
           ('client', 'companies_house_number'),
           ('contractor', 'day_rate_min'),
           ('contractor', 'day_rate_max'),
           ('brief', 'salary_min'),
           ('brief', 'salary_max')
  ) AS f(etype, field)
  WHERE entities.entity_type = f.etype
    AND (data->>f.field IS NULL OR data->>f.field = '')
)
SELECT 'count_candidate|'    || count(*) FILTER (WHERE entity_type = 'candidate')   FROM entities
UNION ALL
SELECT 'count_contractor|'   || count(*) FILTER (WHERE entity_type = 'contractor')  FROM entities
UNION ALL
SELECT 'count_client|'       || count(*) FILTER (WHERE entity_type = 'client')      FROM entities
UNION ALL
SELECT 'count_contact|'      || count(*) FILTER (WHERE entity_type = 'contact')     FROM entities
UNION ALL
SELECT 'count_placement|'    || count(*) FILTER (WHERE entity_type = 'placement')   FROM entities
UNION ALL
SELECT 'count_opportunity|'  || count(*) FILTER (WHERE entity_type = 'opportunity') FROM entities
UNION ALL
SELECT 'merges_30d|'    || count(*) FROM dl WHERE phase = 'action' AND action_type = 'bullhorn_candidate_dedupe'
UNION ALL
SELECT 'backfills_30d|' || count(*) FROM dl WHERE phase = 'action' AND action_type = 'bullhorn_field_backfill'
UNION ALL
SELECT 'notes_30d|'     || count(*) FROM dl WHERE phase = 'action' AND action_type = 'bullhorn_note_attach'
UNION ALL
SELECT 'review_band_30d|' || count(*) FROM dl WHERE phase = 'gating_failed' AND outcome = 'ESC_DUPLICATE_DETECTED'
UNION ALL
SELECT 'write_fails_30d|' || count(*) FROM dl WHERE phase = 'gating_failed' AND outcome = 'ESC_BULLHORN_WRITE_FAIL'
UNION ALL
SELECT 'rate_limit_30d|'  || count(*) FROM dl WHERE phase = 'gating_failed' AND outcome = 'ESC_RATE_LIMIT_HIT'
UNION ALL
SELECT 'gate_a_fails_30d|' || count(*) FROM dl WHERE phase = 'action' AND action_type = 'validate_gate_a_fail'
UNION ALL
SELECT 'missing_now|' || n FROM missing_now
UNION ALL
SELECT 'consultant_edits_30d|' || count(*) FROM recent_edit
WHERE resolved_at > now() - interval '30 days'
UNION ALL
SELECT 'approved_after_edit_30d|' || count(*) FROM recent_edit
WHERE resolution = 'approved_after_edit'
  AND resolved_at > now() - interval '30 days'
UNION ALL
SELECT 'harvest_runs_30d|' || count(*) FROM dl
WHERE phase = 'output' AND output_type = 'janitor_tacit_note_harvest';
