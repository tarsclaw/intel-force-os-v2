-- Janitor — field-completeness audit (agent.md §4 Step 5; spec-001 §4)
--
-- Single source of truth for the canonical missing-field scan over the
-- Postgres `entities` Bullhorn cache. Consumed by:
--   1. cycle.sh Step 5 (live run; feeds Step 6 CH enrichment + Step 9 backfill)
--   2. scripts/run-janitor-report-test.sh (deterministic fixture assertions)
--
-- CONTRACT: the CALLER opens the transaction and sets the tenant —
--   BEGIN; SET LOCAL app.current_tenant='<slug>'; \i this-file; COMMIT;
-- No transaction control / tenant literal here; RLS scopes every read.
-- READ-ONLY.
--
-- Canonical critical fields per vertical-schema.yaml (agent.md §4 Step 5):
--   candidate.location              (line 124)
--   client.industry                 (line 238)
--   client.size_employees           (line 243)
--   client.companies_house_number   (line 252)
--   contractor.day_rate_min/max     (lines 193-197)
--   brief.salary_min/max            (lines 371-376)
--
-- Returns pipe-delimited rows in two shapes:
--   summary|<entity_type>|<field>|<missing_count>
--   client_queue|<entity_id>|<client_name>|<missing_fields_csv>
-- client_queue rows are the Step 6 Companies House enrichment input: clients
-- with a name but missing industry OR companies_house_number.

WITH missing AS (
  SELECT entity_type, entity_id, f.field,
         coalesce(data->>'name', '') AS client_name
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
SELECT 'summary' || '|' || entity_type || '|' || field || '|' || count(*)::text
FROM missing
GROUP BY entity_type, field

UNION ALL

SELECT 'client_queue' || '|' || entity_id || '|' || max(client_name) || '|' ||
       string_agg(field, ',' ORDER BY field)
FROM missing
WHERE entity_type = 'client'
  AND client_name <> ''
  AND field IN ('industry', 'companies_house_number')
GROUP BY entity_id
ORDER BY 1;
