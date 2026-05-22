REJECTED

1. New entity fields are missing required `source` attributes. For example, `voice_corpus.tenant_slug` at lines 45-48, `tone_rule.rule_id` at lines 105-108, and `recent_edit.agent_name` at lines 161-165 have `type` and `required` but no `source`. Fix every canonical field to include `source: Bullhorn...` or `source: IFOS-derived (...)`.

2. The supplement conflicts with the schema layering invariant. Lines 16-18 say "Three new entity_types", while the migration creates three new tables at lines 46, 109, and 135 of `v0.1-to-v0.2.sql`. Fix the supplement to explicitly mark `voice_corpus`, `tone_rule`, and `recent_edit` as auxiliary v0.2 tables, not `entities.data` entity_types, or remodel them as JSONB-backed entity types without CREATE TABLEs.

3. Migration metadata does not cite both required companion files. Lines 312-317 cite the forward SQL and mention the rollback file only in prose. Fix the `migration:` block to name both `docs/verticals/recruitment/migrations/v0.1-to-v0.2.sql` and `docs/verticals/recruitment/migrations/v0.2-to-v0.1.sql`.

4. `recent_edit` stores raw PII-bearing text while claiming it is not external PII. Lines 179-188 store `original_text` and `edited_text` verbatim, and line 208 admits these can include names and salaries. This violates the autosend `payload_preview` PII discipline unless retention/redaction is enforced. Fix by adding redaction rules or making Q13's 90-day purge/legal review a pre-ratification blocker.
