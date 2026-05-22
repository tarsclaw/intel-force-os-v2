REJECTED

1. The runbook's purge pattern is incompatible with the current v0.2 schema. It says the cron NULLs `original_text` and `edited_text` (lines 48-55 and 63-70), but `recent_edit.original_text` is declared `TEXT NOT NULL` in `v0.1-to-v0.2.sql` lines 135-143, and the v0.3 migration does not drop that NOT NULL constraint.
   Proposed fix: update the forward migration to `ALTER TABLE recent_edit ALTER COLUMN original_text DROP NOT NULL;` before any purge cron can run, and update the schema supplement so post-purge rows are a first-class shape.

2. The runbook marks "v1.0 default: 90 days" as confirmed by D3 (line 30), but the founder decision briefing still treats D3 as unresolved and recommends advisor-coupled closure before first LOI (founder briefing lines 62-80).
   Proposed fix: either record a real D3 resolution, or change this runbook to "Proposed 90-day default pending D2/D3" throughout and make production cron deployment blocked.
