-- ============================================================================
-- 0000_baseline.sql — recruitment vertical schema, v0.4 (LIVE PRODUCTION STATE)
-- ============================================================================
-- Generated: 2026-08-21, CortexOS -> new-estate harvest (HARVEST-MANIFEST A4).
-- Source:    pg_dump --schema-only --no-owner --no-privileges ifos_v2
--            on ifos-v2-prod-01 (178.105.87.24), PostgreSQL 16.14.
--            This is the AUTHORITATIVE live production schema, not a derivation.
--
-- WHY THIS FILE EXISTS. CortexOS has no base schema in source control: the
-- migration chain is incremental from v0.1-to-v0.2 onward, and
-- setup-local-dev-db.sh builds the dev database from a pg_dump of this server
-- rather than from git. The origin state existed ONLY on the VPS. This file is
-- the first complete, self-contained schema definition the project has held in
-- version control. The new repo must never regress to incremental-only.
--
-- VERSION. v0.4. Confirmed against live: the v0.5 columns
-- (reconciliation_written_at, accounting_payment_id) are ABSENT in production.
-- v0.5 follows as 0001_reconciliation_writeback.sql. Baselining at the deployed
-- state makes this file true by construction — see ESTATE-DECISIONS D4.
--
-- SUPERSEDES an earlier derived baseline (dev-DB dump rolled back through
-- v0.5-to-v0.4.sql). That derivation round-tripped cleanly but was INCOMPLETE:
-- it was missing public.voice_corpus_chunks and the pgvector extension,
-- because the local dev DB descends from an older VPS dump. Caught by this
-- diff. The derivation is discarded; nothing depends on it.
--
-- TABLES (12): cash_conductor_invoices, cash_conductor_transactions,
--   decision_log, entities, entity_links, recent_edit, tenant_adapters,
--   tenant_eval_sets, tenants, tone_rule, voice_corpus, voice_corpus_chunks
--
-- REQUIRES the `vector` extension (pgvector). voice_corpus_chunks carries
-- vector(1536) embeddings under an HNSW index (vector_cosine_ops, m=16,
-- ef_construction=64) and is RLS-isolated by tenant_slug like every other table.
-- ============================================================================

--
-- PostgreSQL database dump
--


-- Dumped from database version 16.14 (Ubuntu 16.14-1.pgdg24.04+1)
-- Dumped by pg_dump version 16.14 (Ubuntu 16.14-1.pgdg24.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: vector; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA public;


--
-- Name: EXTENSION vector; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION vector IS 'vector data type and ivfflat and hnsw access methods';


--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;


--
-- Name: validate_entities_data_v0_3(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_entities_data_v0_3() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
  d JSONB := NEW.data;
  et TEXT := NEW.entity_type;
  arr_item JSONB;
BEGIN
  -- v0.2 voice-score keys (forwarded; preserves v0.2 [0.0, 1.0] range check)
  IF d ? 'voice_classifier_score' THEN
    IF jsonb_typeof(d->'voice_classifier_score') NOT IN ('number', 'null') THEN
      RAISE EXCEPTION 'voice_classifier_score must be number or null';
    END IF;
    IF d->'voice_classifier_score' != 'null'::jsonb THEN
      IF (d->>'voice_classifier_score')::numeric < 0.0
         OR (d->>'voice_classifier_score')::numeric > 1.0 THEN
        RAISE EXCEPTION 'voice_classifier_score out of [0.0, 1.0] range: %', d->>'voice_classifier_score';
      END IF;
    END IF;
  END IF;

  IF d ? 'voice_drift_at_close' THEN
    IF jsonb_typeof(d->'voice_drift_at_close') NOT IN ('number', 'null') THEN
      RAISE EXCEPTION 'voice_drift_at_close must be number or null';
    END IF;
    IF d->'voice_drift_at_close' != 'null'::jsonb THEN
      IF (d->>'voice_drift_at_close')::numeric < 0.0
         OR (d->>'voice_drift_at_close')::numeric > 1.0 THEN
        RAISE EXCEPTION 'voice_drift_at_close out of [0.0, 1.0] range: %', d->>'voice_drift_at_close';
      END IF;
    END IF;
  END IF;

  -- v0.3 candidate fields
  IF et = 'candidate' THEN
    IF d ? 'employment_type' THEN
      IF (d->>'employment_type') NOT IN (
        'perm', 'contract', 'contract_inside_ir35', 'contract_outside_ir35', 'day_rate', 'hybrid'
      ) THEN
        RAISE EXCEPTION 'employment_type invalid: %', d->>'employment_type';
      END IF;
    END IF;

    IF d ? 'key_skills' THEN
      IF jsonb_typeof(d->'key_skills') != 'array' THEN
        RAISE EXCEPTION 'key_skills must be array';
      END IF;
      IF jsonb_array_length(d->'key_skills') > 20 THEN
        RAISE EXCEPTION 'key_skills max length 20 (got %)', jsonb_array_length(d->'key_skills');
      END IF;
      -- Every element must be a string
      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'key_skills') LOOP
        IF jsonb_typeof(arr_item) != 'string' THEN
          RAISE EXCEPTION 'key_skills items must be strings; got %', jsonb_typeof(arr_item);
        END IF;
      END LOOP;
    END IF;

    IF d ? 'linkedin_url' THEN
      IF jsonb_typeof(d->'linkedin_url') NOT IN ('string', 'null') THEN
        RAISE EXCEPTION 'linkedin_url must be string or null';
      END IF;
      IF d->>'linkedin_url' IS NOT NULL
         AND d->>'linkedin_url' !~ '^https://([a-z]{2,3}\.)?linkedin\.com/in/[a-zA-Z0-9-]+/?$' THEN
        RAISE EXCEPTION 'linkedin_url does not match expected pattern: %', d->>'linkedin_url';
      END IF;
    END IF;
  END IF;

  -- v0.3 contact fields
  IF et = 'contact' THEN
    IF d ? 'preferred_channel' THEN
      IF (d->>'preferred_channel') NOT IN (
        'email', 'phone', 'sms', 'teams', 'slack', 'in_person', 'unknown'
      ) THEN
        RAISE EXCEPTION 'preferred_channel invalid: %', d->>'preferred_channel';
      END IF;
    END IF;

    IF d ? 'next_action_target_date' THEN
      IF jsonb_typeof(d->'next_action_target_date') NOT IN ('string', 'null') THEN
        RAISE EXCEPTION 'next_action_target_date must be ISO-8601 date string or null';
      END IF;
      -- Validate ISO-8601 date format (YYYY-MM-DD) by cast
      IF d->>'next_action_target_date' IS NOT NULL THEN
        BEGIN
          PERFORM (d->>'next_action_target_date')::date;
        EXCEPTION WHEN OTHERS THEN
          RAISE EXCEPTION 'next_action_target_date must parse as ISO-8601 date (YYYY-MM-DD); got: %', d->>'next_action_target_date';
        END;
      END IF;
    END IF;
  END IF;

  -- v0.3 brief fields
  IF et = 'brief' THEN
    IF d ? 'must_haves' THEN
      IF jsonb_typeof(d->'must_haves') != 'array' THEN
        RAISE EXCEPTION 'must_haves must be array';
      END IF;
      IF jsonb_array_length(d->'must_haves') > 15 THEN
        RAISE EXCEPTION 'must_haves max length 15';
      END IF;
      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'must_haves') LOOP
        IF jsonb_typeof(arr_item) != 'string' THEN
          RAISE EXCEPTION 'must_haves items must be strings';
        END IF;
      END LOOP;
    END IF;

    IF d ? 'nice_to_haves' THEN
      IF jsonb_typeof(d->'nice_to_haves') != 'array' THEN
        RAISE EXCEPTION 'nice_to_haves must be array';
      END IF;
      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'nice_to_haves') LOOP
        IF jsonb_typeof(arr_item) != 'string' THEN
          RAISE EXCEPTION 'nice_to_haves items must be strings';
        END IF;
      END LOOP;
    END IF;

    IF d ? 'deal_breakers' THEN
      IF jsonb_typeof(d->'deal_breakers') != 'array' THEN
        RAISE EXCEPTION 'deal_breakers must be array';
      END IF;
      FOR arr_item IN SELECT * FROM jsonb_array_elements(d->'deal_breakers') LOOP
        IF jsonb_typeof(arr_item) != 'string' THEN
          RAISE EXCEPTION 'deal_breakers items must be strings';
        END IF;
      END LOOP;
    END IF;
  END IF;

  -- v0.3 placement fields
  IF et = 'placement' THEN
    IF d ? 'placement_status' THEN
      IF (d->>'placement_status') NOT IN (
        'pending_start', 'active', 'completed', 'terminated_early', 'on_hold', 'cancelled'
      ) THEN
        RAISE EXCEPTION 'placement_status invalid: %', d->>'placement_status';
      END IF;
    END IF;

    IF d ? 'week_1_status_vault_path' THEN
      IF jsonb_typeof(d->'week_1_status_vault_path') NOT IN ('string', 'null') THEN
        RAISE EXCEPTION 'week_1_status_vault_path must be string or null';
      END IF;
      IF d->>'week_1_status_vault_path' IS NOT NULL
         AND d->>'week_1_status_vault_path' !~ '^/vault/[a-z0-9_-]+/scribe-notes/[a-zA-Z0-9_-]+\.md$' THEN
        RAISE EXCEPTION 'week_1_status_vault_path must match vault-path pattern (got %)', d->>'week_1_status_vault_path';
      END IF;
      IF d->>'week_1_status_vault_path' IS NOT NULL
         AND length(d->>'week_1_status_vault_path') > 200 THEN
        RAISE EXCEPTION 'week_1_status_vault_path exceeds 200 chars';
      END IF;
    END IF;

    IF d ? 'satisfaction_signal' THEN
      IF (d->>'satisfaction_signal') NOT IN ('positive', 'neutral', 'negative', 'unclear') THEN
        RAISE EXCEPTION 'satisfaction_signal invalid: %', d->>'satisfaction_signal';
      END IF;
    END IF;
  END IF;

  -- v0.3 opportunity fields
  IF et = 'opportunity' THEN
    IF d ? 'headcount_growth_signal_text' THEN
      IF jsonb_typeof(d->'headcount_growth_signal_text') NOT IN ('string', 'null') THEN
        RAISE EXCEPTION 'headcount_growth_signal_text must be string or null';
      END IF;
      IF d->>'headcount_growth_signal_text' IS NOT NULL
         AND length(d->>'headcount_growth_signal_text') > 280 THEN
        RAISE EXCEPTION 'headcount_growth_signal_text exceeds 280 chars';
      END IF;
    END IF;

    IF d ? 'hiring_velocity_band' THEN
      IF (d->>'hiring_velocity_band') NOT IN ('slow', 'moderate', 'fast', 'urgent', 'unknown') THEN
        RAISE EXCEPTION 'hiring_velocity_band invalid: %', d->>'hiring_velocity_band';
      END IF;
    END IF;

    IF d ? 'decision_window_text' THEN
      IF jsonb_typeof(d->'decision_window_text') NOT IN ('string', 'null') THEN
        RAISE EXCEPTION 'decision_window_text must be string or null';
      END IF;
      IF d->>'decision_window_text' IS NOT NULL
         AND length(d->>'decision_window_text') > 280 THEN
        RAISE EXCEPTION 'decision_window_text exceeds 280 chars';
      END IF;
    END IF;
  END IF;

  RETURN NEW;
END;
$_$;


--
-- Name: validate_tenant_adapters_config_v0_4(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_tenant_adapters_config_v0_4() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
  c JSONB := NEW.config;
  k TEXT;
  elem JSONB;
  allowed_keys TEXT[] := ARRAY[
    -- v0.1 + v0.2 keys (forwarded; do not remove)
    'tier_overrides', 'blocked_recipients', 'janitor_dedup_threshold',
    'janitor_last_run',
    'pii_retention_days',  -- v0.2 PII purge runbook key
    -- autosend-safety-policy.md keys
    'approval_routing', 'approval_timeouts', 'sampling_rates',
    -- v0.3 additions
    'cash_conductor_last_run',
    'concierge_last_poll',
    'concierge_send_window',
    -- v0.4 additions (5 new keys)
    'operator_telegram_chat_id',  -- D1-B Path B; autosend-bridge consumer
    'email_channel',              -- Concierge MS Graph vs Gmail
    'workos_org_id',              -- per-tenant WorkOS org (master brief §5.3 line 401)
    'granola_workspace_id',       -- per-tenant Granola workspace (W6+ Scribe)
    'bullhorn_corporation_id'     -- per-tenant Bullhorn corporation
  ];
BEGIN
  IF c IS NULL THEN
    RETURN NEW;
  END IF;

  FOR k IN SELECT jsonb_object_keys(c) LOOP
    IF NOT (k = ANY(allowed_keys)) THEN
      RAISE EXCEPTION 'tenant_adapters.config unknown key: % (allowed: %)', k, allowed_keys;
    END IF;
  END LOOP;

  -- ────────────────────────────────────────────────────────────────────────
  -- v0.3 type validations (preserved verbatim)
  -- ────────────────────────────────────────────────────────────────────────

  IF c ? 'concierge_send_window' THEN
    IF jsonb_typeof(c->'concierge_send_window') != 'object' THEN
      RAISE EXCEPTION 'concierge_send_window must be object';
    END IF;
    IF NOT (c->'concierge_send_window' ? 'timezone') THEN
      RAISE EXCEPTION 'concierge_send_window must include timezone';
    END IF;
    IF NOT (c->'concierge_send_window' ? 'weekday_start') OR
       NOT (c->'concierge_send_window' ? 'weekday_end') THEN
      RAISE EXCEPTION 'concierge_send_window must include weekday_start + weekday_end';
    END IF;
    IF c->'concierge_send_window' ? 'weekend_send_enabled' AND
       jsonb_typeof(c->'concierge_send_window'->'weekend_send_enabled') != 'boolean' THEN
      RAISE EXCEPTION 'concierge_send_window.weekend_send_enabled must be boolean';
    END IF;
  END IF;

  IF c ? 'cash_conductor_last_run' THEN
    IF jsonb_typeof(c->'cash_conductor_last_run') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'cash_conductor_last_run must be ISO-8601 timestamp string or null';
    END IF;
  END IF;

  IF c ? 'concierge_last_poll' THEN
    IF jsonb_typeof(c->'concierge_last_poll') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'concierge_last_poll must be ISO-8601 timestamp string or null';
    END IF;
  END IF;

  IF c ? 'janitor_dedup_threshold' THEN
    IF jsonb_typeof(c->'janitor_dedup_threshold') != 'number' THEN
      RAISE EXCEPTION 'janitor_dedup_threshold must be number';
    END IF;
    IF (c->>'janitor_dedup_threshold')::numeric < 0.75
       OR (c->>'janitor_dedup_threshold')::numeric > 0.95 THEN
      RAISE EXCEPTION 'janitor_dedup_threshold out of [0.75, 0.95] range: %', c->>'janitor_dedup_threshold';
    END IF;
  END IF;

  IF c ? 'janitor_last_run' THEN
    IF jsonb_typeof(c->'janitor_last_run') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'janitor_last_run must be ISO-8601 timestamp string or null';
    END IF;
  END IF;

  IF c ? 'blocked_recipients' THEN
    IF jsonb_typeof(c->'blocked_recipients') != 'array' THEN
      RAISE EXCEPTION 'blocked_recipients must be array';
    END IF;
    FOR elem IN SELECT * FROM jsonb_array_elements(c->'blocked_recipients') LOOP
      IF jsonb_typeof(elem) != 'string' THEN
        RAISE EXCEPTION 'blocked_recipients items must be strings; got %', jsonb_typeof(elem);
      END IF;
    END LOOP;
  END IF;

  -- ────────────────────────────────────────────────────────────────────────
  -- v0.4 type validations (5 new keys)
  -- ────────────────────────────────────────────────────────────────────────

  -- operator_telegram_chat_id: string matching signed integer pattern
  IF c ? 'operator_telegram_chat_id' THEN
    IF jsonb_typeof(c->'operator_telegram_chat_id') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'operator_telegram_chat_id must be string or null';
    END IF;
    IF c->>'operator_telegram_chat_id' IS NOT NULL
       AND c->>'operator_telegram_chat_id' !~ '^-?[0-9]+$' THEN
      RAISE EXCEPTION 'operator_telegram_chat_id must match ^-?[0-9]+$ (Telegram chat ID format); got: %', c->>'operator_telegram_chat_id';
    END IF;
  END IF;

  -- email_channel: enum
  IF c ? 'email_channel' THEN
    IF jsonb_typeof(c->'email_channel') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'email_channel must be string or null';
    END IF;
    IF c->>'email_channel' IS NOT NULL
       AND (c->>'email_channel') NOT IN ('microsoft-graph', 'gmail') THEN
      RAISE EXCEPTION 'email_channel must be one of (microsoft-graph, gmail); got: %', c->>'email_channel';
    END IF;
  END IF;

  -- workos_org_id: string matching WorkOS org pattern
  IF c ? 'workos_org_id' THEN
    IF jsonb_typeof(c->'workos_org_id') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'workos_org_id must be string or null';
    END IF;
    IF c->>'workos_org_id' IS NOT NULL
       AND c->>'workos_org_id' !~ '^org_[A-Z0-9]+$' THEN
      RAISE EXCEPTION 'workos_org_id must match ^org_[A-Z0-9]+$ (WorkOS org ID format); got: %', c->>'workos_org_id';
    END IF;
  END IF;

  -- granola_workspace_id: opaque string (no format constraint)
  IF c ? 'granola_workspace_id' THEN
    IF jsonb_typeof(c->'granola_workspace_id') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'granola_workspace_id must be string or null';
    END IF;
  END IF;

  -- bullhorn_corporation_id: string matching integer pattern
  IF c ? 'bullhorn_corporation_id' THEN
    IF jsonb_typeof(c->'bullhorn_corporation_id') NOT IN ('string', 'null') THEN
      RAISE EXCEPTION 'bullhorn_corporation_id must be string or null';
    END IF;
    IF c->>'bullhorn_corporation_id' IS NOT NULL
       AND c->>'bullhorn_corporation_id' !~ '^[0-9]+$' THEN
      RAISE EXCEPTION 'bullhorn_corporation_id must match ^[0-9]+$ (Bullhorn corporation ID format); got: %', c->>'bullhorn_corporation_id';
    END IF;
  END IF;

  RETURN NEW;
END;
$_$;


--
-- Name: validate_voice_score_fields(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validate_voice_score_fields() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  score_keys TEXT[] := ARRAY['voice_classifier_score', 'voice_drift_at_close'];
  k TEXT;
  v JSONB;
BEGIN
  FOREACH k IN ARRAY score_keys LOOP
    v := NEW.data -> k;
    IF v IS NOT NULL AND jsonb_typeof(v) != 'null' THEN
      IF jsonb_typeof(v) != 'number' THEN
        RAISE EXCEPTION 'entities.data.% must be number; got %', k, jsonb_typeof(v);
      END IF;
      IF (v::TEXT)::NUMERIC < 0.0 OR (v::TEXT)::NUMERIC > 1.0 THEN
        RAISE EXCEPTION 'entities.data.% out of range [0.0, 1.0]: %', k, v::TEXT;
      END IF;
    END IF;
  END LOOP;
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: cash_conductor_invoices; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cash_conductor_invoices (
    id bigint NOT NULL,
    tenant_slug text NOT NULL,
    invoice_id text NOT NULL,
    accounting_provider text NOT NULL,
    invoice_number text,
    issued_at timestamp with time zone NOT NULL,
    due_at timestamp with time zone NOT NULL,
    amount_total numeric(15,2) NOT NULL,
    amount_paid numeric(15,2) DEFAULT 0 NOT NULL,
    currency text DEFAULT 'GBP'::text NOT NULL,
    status text DEFAULT 'open'::text NOT NULL,
    client_contact_id text,
    client_billing_email text,
    last_chase_position integer DEFAULT 0 NOT NULL,
    last_chase_sent_at timestamp with time zone,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    raw_payload jsonb,
    CONSTRAINT cci_amount_paid_non_negative CHECK (((amount_paid >= (0)::numeric) AND (amount_paid <= amount_total))),
    CONSTRAINT cci_chase_position_range CHECK (((last_chase_position >= 0) AND (last_chase_position <= 4))),
    CONSTRAINT cci_provider_valid CHECK ((accounting_provider = ANY (ARRAY['xero'::text, 'quickbooks'::text, 'sage'::text]))),
    CONSTRAINT cci_status_valid CHECK ((status = ANY (ARRAY['open'::text, 'partial'::text, 'paid'::text, 'overdue'::text, 'cancelled'::text, 'voided'::text])))
);

ALTER TABLE ONLY public.cash_conductor_invoices FORCE ROW LEVEL SECURITY;


--
-- Name: cash_conductor_invoices_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cash_conductor_invoices_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cash_conductor_invoices_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cash_conductor_invoices_id_seq OWNED BY public.cash_conductor_invoices.id;


--
-- Name: cash_conductor_transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cash_conductor_transactions (
    id bigint NOT NULL,
    tenant_slug text NOT NULL,
    transaction_id text NOT NULL,
    posted_at timestamp with time zone NOT NULL,
    amount numeric(15,2) NOT NULL,
    currency text DEFAULT 'GBP'::text NOT NULL,
    payee_name_raw text,
    description text,
    bank_provider text NOT NULL,
    match_status text DEFAULT 'unmatched'::text NOT NULL,
    matched_invoice_id text,
    match_confidence numeric(3,2),
    match_dimensions text[],
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    raw_payload jsonb,
    CONSTRAINT cct_bank_provider_valid CHECK ((bank_provider = ANY (ARRAY['truelayer'::text, 'plaid_uk'::text, 'open_banking_direct'::text]))),
    CONSTRAINT cct_match_confidence_range CHECK (((match_confidence IS NULL) OR ((match_confidence >= 0.00) AND (match_confidence <= 1.00)))),
    CONSTRAINT cct_match_status_valid CHECK ((match_status = ANY (ARRAY['unmatched'::text, 'matched'::text, 'ambiguous'::text])))
);

ALTER TABLE ONLY public.cash_conductor_transactions FORCE ROW LEVEL SECURITY;


--
-- Name: cash_conductor_transactions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cash_conductor_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cash_conductor_transactions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cash_conductor_transactions_id_seq OWNED BY public.cash_conductor_transactions.id;


--
-- Name: decision_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.decision_log (
    id bigint NOT NULL,
    tenant_slug text NOT NULL,
    agent_name text NOT NULL,
    phase text NOT NULL,
    outcome text,
    reason text,
    payload jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT decision_log_phase_check CHECK ((phase = ANY (ARRAY['trigger'::text, 'output'::text, 'action'::text, 'gating_failed'::text, 'agent_handoff'::text, 'render'::text])))
);

ALTER TABLE ONLY public.decision_log FORCE ROW LEVEL SECURITY;


--
-- Name: decision_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.decision_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: decision_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.decision_log_id_seq OWNED BY public.decision_log.id;


--
-- Name: entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entities (
    id bigint NOT NULL,
    tenant_slug text NOT NULL,
    entity_type text NOT NULL,
    entity_id text NOT NULL,
    data jsonb NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.entities FORCE ROW LEVEL SECURITY;


--
-- Name: entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entities_id_seq OWNED BY public.entities.id;


--
-- Name: entity_links; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entity_links (
    id bigint NOT NULL,
    tenant_slug text NOT NULL,
    source_entity_type text NOT NULL,
    source_entity_id text NOT NULL,
    target_entity_type text NOT NULL,
    target_entity_id text NOT NULL,
    link_type text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.entity_links FORCE ROW LEVEL SECURITY;


--
-- Name: entity_links_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.entity_links_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entity_links_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entity_links_id_seq OWNED BY public.entity_links.id;


--
-- Name: recent_edit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recent_edit (
    id bigint NOT NULL,
    tenant_slug text NOT NULL,
    agent_name text NOT NULL,
    action_type text NOT NULL,
    target_entity_type text,
    target_entity_id text,
    original_text text NOT NULL,
    edited_text text,
    edit_distance integer,
    resolution text NOT NULL,
    resolved_at timestamp with time zone NOT NULL,
    tone_rules_triggered text[] DEFAULT '{}'::text[] NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT recent_edit_edit_distance_check CHECK (((edit_distance IS NULL) OR (edit_distance >= 0))),
    CONSTRAINT recent_edit_resolution_check CHECK ((resolution = ANY (ARRAY['approved_verbatim'::text, 'approved_after_edit'::text, 'rejected'::text, 'deferred'::text])))
);

ALTER TABLE ONLY public.recent_edit FORCE ROW LEVEL SECURITY;


--
-- Name: recent_edit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recent_edit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recent_edit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recent_edit_id_seq OWNED BY public.recent_edit.id;


--
-- Name: tenant_adapters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_adapters (
    id bigint NOT NULL,
    tenant_slug text NOT NULL,
    adapter_name text NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.tenant_adapters FORCE ROW LEVEL SECURITY;


--
-- Name: tenant_adapters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tenant_adapters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenant_adapters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tenant_adapters_id_seq OWNED BY public.tenant_adapters.id;


--
-- Name: tenant_eval_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenant_eval_sets (
    id bigint NOT NULL,
    tenant_slug text NOT NULL,
    agent_name text NOT NULL,
    eval_set_path text NOT NULL,
    last_run_at timestamp with time zone,
    last_run_passed boolean,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.tenant_eval_sets FORCE ROW LEVEL SECURITY;


--
-- Name: tenant_eval_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tenant_eval_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tenant_eval_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tenant_eval_sets_id_seq OWNED BY public.tenant_eval_sets.id;


--
-- Name: tenants; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tenants (
    tenant_slug text NOT NULL,
    tenant_name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb
);


--
-- Name: tone_rule; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tone_rule (
    id bigint NOT NULL,
    tenant_slug text NOT NULL,
    rule_id text NOT NULL,
    rule_text text NOT NULL,
    severity text NOT NULL,
    applies_to_agents text[] DEFAULT '{}'::text[] NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    created_by text NOT NULL,
    examples_positive text[],
    examples_negative text[],
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT tone_rule_created_by_check CHECK ((created_by = ANY (ARRAY['founder'::text, 'tenant-admin'::text, 'ifos-csm'::text]))),
    CONSTRAINT tone_rule_severity_check CHECK ((severity = ANY (ARRAY['info'::text, 'warn'::text, 'block'::text])))
);

ALTER TABLE ONLY public.tone_rule FORCE ROW LEVEL SECURITY;


--
-- Name: tone_rule_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tone_rule_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tone_rule_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tone_rule_id_seq OWNED BY public.tone_rule.id;


--
-- Name: voice_corpus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.voice_corpus (
    id bigint NOT NULL,
    tenant_slug text NOT NULL,
    version text NOT NULL,
    source_doc_count integer NOT NULL,
    source_doc_origin text[] DEFAULT '{}'::text[] NOT NULL,
    chunk_count integer NOT NULL,
    chunking_strategy text NOT NULL,
    embedding_model text NOT NULL,
    last_indexed_at timestamp with time zone NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    ingest_completion_ms integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT voice_corpus_chunk_count_check CHECK ((chunk_count >= 0)),
    CONSTRAINT voice_corpus_chunking_strategy_check CHECK ((chunking_strategy = ANY (ARRAY['paragraph'::text, 'sentence-window-5'::text, 'semantic-segment-v1'::text]))),
    CONSTRAINT voice_corpus_source_doc_count_check CHECK ((source_doc_count >= 0))
);

ALTER TABLE ONLY public.voice_corpus FORCE ROW LEVEL SECURITY;


--
-- Name: voice_corpus_chunks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.voice_corpus_chunks (
    id bigint NOT NULL,
    tenant_slug text NOT NULL,
    voice_corpus_id bigint NOT NULL,
    chunk_index integer NOT NULL,
    text_chunk text NOT NULL,
    source_doc_ref text,
    embedding public.vector(1536),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.voice_corpus_chunks FORCE ROW LEVEL SECURITY;


--
-- Name: voice_corpus_chunks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.voice_corpus_chunks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: voice_corpus_chunks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.voice_corpus_chunks_id_seq OWNED BY public.voice_corpus_chunks.id;


--
-- Name: voice_corpus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.voice_corpus_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: voice_corpus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.voice_corpus_id_seq OWNED BY public.voice_corpus.id;


--
-- Name: cash_conductor_invoices id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cash_conductor_invoices ALTER COLUMN id SET DEFAULT nextval('public.cash_conductor_invoices_id_seq'::regclass);


--
-- Name: cash_conductor_transactions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cash_conductor_transactions ALTER COLUMN id SET DEFAULT nextval('public.cash_conductor_transactions_id_seq'::regclass);


--
-- Name: decision_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_log ALTER COLUMN id SET DEFAULT nextval('public.decision_log_id_seq'::regclass);


--
-- Name: entities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities ALTER COLUMN id SET DEFAULT nextval('public.entities_id_seq'::regclass);


--
-- Name: entity_links id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_links ALTER COLUMN id SET DEFAULT nextval('public.entity_links_id_seq'::regclass);


--
-- Name: recent_edit id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recent_edit ALTER COLUMN id SET DEFAULT nextval('public.recent_edit_id_seq'::regclass);


--
-- Name: tenant_adapters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_adapters ALTER COLUMN id SET DEFAULT nextval('public.tenant_adapters_id_seq'::regclass);


--
-- Name: tenant_eval_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_eval_sets ALTER COLUMN id SET DEFAULT nextval('public.tenant_eval_sets_id_seq'::regclass);


--
-- Name: tone_rule id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tone_rule ALTER COLUMN id SET DEFAULT nextval('public.tone_rule_id_seq'::regclass);


--
-- Name: voice_corpus id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.voice_corpus ALTER COLUMN id SET DEFAULT nextval('public.voice_corpus_id_seq'::regclass);


--
-- Name: voice_corpus_chunks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.voice_corpus_chunks ALTER COLUMN id SET DEFAULT nextval('public.voice_corpus_chunks_id_seq'::regclass);


--
-- Name: cash_conductor_invoices cash_conductor_invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cash_conductor_invoices
    ADD CONSTRAINT cash_conductor_invoices_pkey PRIMARY KEY (id);


--
-- Name: cash_conductor_transactions cash_conductor_transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cash_conductor_transactions
    ADD CONSTRAINT cash_conductor_transactions_pkey PRIMARY KEY (id);


--
-- Name: cash_conductor_invoices cci_tenant_provider_invoice_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cash_conductor_invoices
    ADD CONSTRAINT cci_tenant_provider_invoice_unique UNIQUE (tenant_slug, accounting_provider, invoice_id);


--
-- Name: cash_conductor_transactions cct_tenant_transaction_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cash_conductor_transactions
    ADD CONSTRAINT cct_tenant_transaction_unique UNIQUE (tenant_slug, bank_provider, transaction_id);


--
-- Name: decision_log decision_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_log
    ADD CONSTRAINT decision_log_pkey PRIMARY KEY (id);


--
-- Name: entities entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities
    ADD CONSTRAINT entities_pkey PRIMARY KEY (id);


--
-- Name: entities entities_tenant_slug_entity_type_entity_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities
    ADD CONSTRAINT entities_tenant_slug_entity_type_entity_id_key UNIQUE (tenant_slug, entity_type, entity_id);


--
-- Name: entity_links entity_links_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_links
    ADD CONSTRAINT entity_links_pkey PRIMARY KEY (id);


--
-- Name: entity_links entity_links_tenant_slug_source_entity_type_source_entity_i_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_links
    ADD CONSTRAINT entity_links_tenant_slug_source_entity_type_source_entity_i_key UNIQUE (tenant_slug, source_entity_type, source_entity_id, target_entity_type, target_entity_id, link_type);


--
-- Name: recent_edit recent_edit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recent_edit
    ADD CONSTRAINT recent_edit_pkey PRIMARY KEY (id);


--
-- Name: tenant_adapters tenant_adapters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_adapters
    ADD CONSTRAINT tenant_adapters_pkey PRIMARY KEY (id);


--
-- Name: tenant_adapters tenant_adapters_tenant_slug_adapter_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_adapters
    ADD CONSTRAINT tenant_adapters_tenant_slug_adapter_name_key UNIQUE (tenant_slug, adapter_name);


--
-- Name: tenant_eval_sets tenant_eval_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_eval_sets
    ADD CONSTRAINT tenant_eval_sets_pkey PRIMARY KEY (id);


--
-- Name: tenant_eval_sets tenant_eval_sets_tenant_slug_agent_name_eval_set_path_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_eval_sets
    ADD CONSTRAINT tenant_eval_sets_tenant_slug_agent_name_eval_set_path_key UNIQUE (tenant_slug, agent_name, eval_set_path);


--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (tenant_slug);


--
-- Name: tone_rule tone_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tone_rule
    ADD CONSTRAINT tone_rule_pkey PRIMARY KEY (id);


--
-- Name: tone_rule tone_rule_tenant_rule_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tone_rule
    ADD CONSTRAINT tone_rule_tenant_rule_id_unique UNIQUE (tenant_slug, rule_id);


--
-- Name: voice_corpus_chunks voice_corpus_chunks_corpus_chunk_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.voice_corpus_chunks
    ADD CONSTRAINT voice_corpus_chunks_corpus_chunk_unique UNIQUE (voice_corpus_id, chunk_index);


--
-- Name: voice_corpus_chunks voice_corpus_chunks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.voice_corpus_chunks
    ADD CONSTRAINT voice_corpus_chunks_pkey PRIMARY KEY (id);


--
-- Name: voice_corpus voice_corpus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.voice_corpus
    ADD CONSTRAINT voice_corpus_pkey PRIMARY KEY (id);


--
-- Name: voice_corpus voice_corpus_tenant_version_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.voice_corpus
    ADD CONSTRAINT voice_corpus_tenant_version_unique UNIQUE (tenant_slug, version);


--
-- Name: decision_log_tenant_agent_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX decision_log_tenant_agent_idx ON public.decision_log USING btree (tenant_slug, agent_name, created_at DESC);


--
-- Name: entities_data_gin_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entities_data_gin_idx ON public.entities USING gin (data jsonb_path_ops);


--
-- Name: entities_tenant_type_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entities_tenant_type_idx ON public.entities USING btree (tenant_slug, entity_type);


--
-- Name: entity_links_tenant_source_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entity_links_tenant_source_idx ON public.entity_links USING btree (tenant_slug, source_entity_type, source_entity_id);


--
-- Name: entity_links_tenant_target_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entity_links_tenant_target_idx ON public.entity_links USING btree (tenant_slug, target_entity_type, target_entity_id);


--
-- Name: idx_cci_tenant_chase; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cci_tenant_chase ON public.cash_conductor_invoices USING btree (tenant_slug, last_chase_position, due_at) WHERE ((last_chase_position >= 1) AND (last_chase_position <= 3));


--
-- Name: idx_cci_tenant_due; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cci_tenant_due ON public.cash_conductor_invoices USING btree (tenant_slug, due_at);


--
-- Name: idx_cci_tenant_overdue; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cci_tenant_overdue ON public.cash_conductor_invoices USING btree (tenant_slug, status, due_at) WHERE (status = ANY (ARRAY['open'::text, 'partial'::text, 'overdue'::text]));


--
-- Name: idx_cct_tenant_posted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cct_tenant_posted ON public.cash_conductor_transactions USING btree (tenant_slug, posted_at DESC);


--
-- Name: idx_cct_tenant_unmatched; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cct_tenant_unmatched ON public.cash_conductor_transactions USING btree (tenant_slug, match_status, posted_at DESC) WHERE (match_status = ANY (ARRAY['unmatched'::text, 'ambiguous'::text]));


--
-- Name: recent_edit_lookback_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX recent_edit_lookback_idx ON public.recent_edit USING btree (tenant_slug, resolved_at DESC);


--
-- Name: recent_edit_tenant_action_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX recent_edit_tenant_action_idx ON public.recent_edit USING btree (tenant_slug, action_type, resolved_at DESC);


--
-- Name: recent_edit_tenant_agent_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX recent_edit_tenant_agent_idx ON public.recent_edit USING btree (tenant_slug, agent_name, resolved_at DESC);


--
-- Name: tone_rule_tenant_enabled_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX tone_rule_tenant_enabled_idx ON public.tone_rule USING btree (tenant_slug, enabled);


--
-- Name: voice_corpus_chunks_corpus_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX voice_corpus_chunks_corpus_idx ON public.voice_corpus_chunks USING btree (voice_corpus_id);


--
-- Name: voice_corpus_chunks_tenant_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX voice_corpus_chunks_tenant_idx ON public.voice_corpus_chunks USING btree (tenant_slug);


--
-- Name: voice_corpus_one_active_per_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX voice_corpus_one_active_per_tenant ON public.voice_corpus USING btree (tenant_slug) WHERE (is_active = true);


--
-- Name: voice_corpus_tenant_slug_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX voice_corpus_tenant_slug_idx ON public.voice_corpus USING btree (tenant_slug);


--
-- Name: voice_samples_embedded; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX voice_samples_embedded ON public.voice_corpus_chunks USING hnsw (embedding public.vector_cosine_ops) WITH (m='16', ef_construction='64');


--
-- Name: cash_conductor_invoices set_updated_at_cci; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_cci BEFORE UPDATE ON public.cash_conductor_invoices FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: cash_conductor_transactions set_updated_at_cct; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER set_updated_at_cct BEFORE UPDATE ON public.cash_conductor_transactions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: entities validate_entities_data_v0_3; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER validate_entities_data_v0_3 BEFORE INSERT OR UPDATE ON public.entities FOR EACH ROW WHEN ((new.entity_type = ANY (ARRAY['candidate'::text, 'contact'::text, 'brief'::text, 'placement'::text, 'opportunity'::text]))) EXECUTE FUNCTION public.validate_entities_data_v0_3();


--
-- Name: tenant_adapters validate_tenant_adapters_config_v0_4; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER validate_tenant_adapters_config_v0_4 BEFORE INSERT OR UPDATE ON public.tenant_adapters FOR EACH ROW EXECUTE FUNCTION public.validate_tenant_adapters_config_v0_4();


--
-- Name: decision_log decision_log_tenant_slug_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decision_log
    ADD CONSTRAINT decision_log_tenant_slug_fkey FOREIGN KEY (tenant_slug) REFERENCES public.tenants(tenant_slug) ON DELETE CASCADE;


--
-- Name: entities entities_tenant_slug_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities
    ADD CONSTRAINT entities_tenant_slug_fkey FOREIGN KEY (tenant_slug) REFERENCES public.tenants(tenant_slug) ON DELETE CASCADE;


--
-- Name: entity_links entity_links_tenant_slug_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entity_links
    ADD CONSTRAINT entity_links_tenant_slug_fkey FOREIGN KEY (tenant_slug) REFERENCES public.tenants(tenant_slug) ON DELETE CASCADE;


--
-- Name: tenant_adapters tenant_adapters_tenant_slug_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_adapters
    ADD CONSTRAINT tenant_adapters_tenant_slug_fkey FOREIGN KEY (tenant_slug) REFERENCES public.tenants(tenant_slug) ON DELETE CASCADE;


--
-- Name: tenant_eval_sets tenant_eval_sets_tenant_slug_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tenant_eval_sets
    ADD CONSTRAINT tenant_eval_sets_tenant_slug_fkey FOREIGN KEY (tenant_slug) REFERENCES public.tenants(tenant_slug) ON DELETE CASCADE;


--
-- Name: voice_corpus_chunks voice_corpus_chunks_voice_corpus_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.voice_corpus_chunks
    ADD CONSTRAINT voice_corpus_chunks_voice_corpus_id_fkey FOREIGN KEY (voice_corpus_id) REFERENCES public.voice_corpus(id) ON DELETE CASCADE;


--
-- Name: cash_conductor_invoices; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.cash_conductor_invoices ENABLE ROW LEVEL SECURITY;

--
-- Name: cash_conductor_transactions; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.cash_conductor_transactions ENABLE ROW LEVEL SECURITY;

--
-- Name: cash_conductor_invoices cci_tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY cci_tenant_isolation ON public.cash_conductor_invoices TO ifos_app USING ((tenant_slug = current_setting('app.current_tenant'::text, true)));


--
-- Name: cash_conductor_transactions cct_tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY cct_tenant_isolation ON public.cash_conductor_transactions TO ifos_app USING ((tenant_slug = current_setting('app.current_tenant'::text, true)));


--
-- Name: decision_log; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.decision_log ENABLE ROW LEVEL SECURITY;

--
-- Name: entities; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.entities ENABLE ROW LEVEL SECURITY;

--
-- Name: entity_links; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.entity_links ENABLE ROW LEVEL SECURITY;

--
-- Name: recent_edit; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.recent_edit ENABLE ROW LEVEL SECURITY;

--
-- Name: recent_edit recent_edit_tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY recent_edit_tenant_isolation ON public.recent_edit USING ((tenant_slug = current_setting('app.current_tenant'::text, true)));


--
-- Name: tenant_adapters; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_adapters ENABLE ROW LEVEL SECURITY;

--
-- Name: tenant_eval_sets; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tenant_eval_sets ENABLE ROW LEVEL SECURITY;

--
-- Name: decision_log tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.decision_log TO ifos_app USING ((tenant_slug = current_setting('app.current_tenant'::text, true))) WITH CHECK ((tenant_slug = current_setting('app.current_tenant'::text, true)));


--
-- Name: entities tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.entities TO ifos_app USING ((tenant_slug = current_setting('app.current_tenant'::text, true))) WITH CHECK ((tenant_slug = current_setting('app.current_tenant'::text, true)));


--
-- Name: entity_links tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.entity_links TO ifos_app USING ((tenant_slug = current_setting('app.current_tenant'::text, true))) WITH CHECK ((tenant_slug = current_setting('app.current_tenant'::text, true)));


--
-- Name: tenant_adapters tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.tenant_adapters TO ifos_app USING ((tenant_slug = current_setting('app.current_tenant'::text, true))) WITH CHECK ((tenant_slug = current_setting('app.current_tenant'::text, true)));


--
-- Name: tenant_eval_sets tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.tenant_eval_sets TO ifos_app USING ((tenant_slug = current_setting('app.current_tenant'::text, true))) WITH CHECK ((tenant_slug = current_setting('app.current_tenant'::text, true)));


--
-- Name: tone_rule; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.tone_rule ENABLE ROW LEVEL SECURITY;

--
-- Name: tone_rule tone_rule_tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tone_rule_tenant_isolation ON public.tone_rule USING ((tenant_slug = current_setting('app.current_tenant'::text, true)));


--
-- Name: voice_corpus; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.voice_corpus ENABLE ROW LEVEL SECURITY;

--
-- Name: voice_corpus_chunks; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.voice_corpus_chunks ENABLE ROW LEVEL SECURITY;

--
-- Name: voice_corpus_chunks voice_corpus_chunks_tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY voice_corpus_chunks_tenant_isolation ON public.voice_corpus_chunks USING ((tenant_slug = current_setting('app.current_tenant'::text, true)));


--
-- Name: voice_corpus voice_corpus_tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY voice_corpus_tenant_isolation ON public.voice_corpus USING ((tenant_slug = current_setting('app.current_tenant'::text, true)));


--
-- PostgreSQL database dump complete
--


