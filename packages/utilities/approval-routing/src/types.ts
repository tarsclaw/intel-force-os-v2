// @ifos/approval-routing — public types
//
// W1 slice of docs/features/approval-routing/PLAN.md (architectural decisions
// 1, 2, 8). Source of truth: docs/specs/approval-routing-architecture.md
// §4 (the ladder), §4.1/§4.2 (routing classes + gap rules), §6.3 (function-roles
// schema, implemented VERBATIM as schema_version 1), §6.4 (identity).

// ── Resolution input/output ────────────────────────────────────────────────

/** The acted-on cached Bullhorn record, when the action is record-bound. */
export interface RecordRef {
  /** entities.entity_type (vertical-schema.yaml): candidate | contractor | client | contact | brief | placement | ... */
  entity_type: string;
  /** entities.entity_id (tenant-scoped). */
  entity_id: string;
}

export interface ResolveInput {
  tenant_slug: string;
  /** autosend-policy.yaml action_type — the join key into action-class-registry.yaml. */
  action_type: string;
  record?: RecordRef;
}

/**
 * Which rung of the §4 ladder produced the approver.
 * "single_operator_fallback" is never returned by resolveApprover() itself —
 * it is reserved for the CALLER (W3 hook-helpers orange path) to record when
 * the resolver is absent/failed and routing fell back to
 * CTX_OPERATOR_TELEGRAM_CHAT_ID (PLAN.md decision 2 backwards-compat invariant).
 */
export type LadderStep =
  | "record_owner"
  | "function_role"
  | "firm_default"
  | "single_operator_fallback";

export type OnExpiry = "hold" | "auto_execute" | "safe_default";

export type TrustBucket = 1 | 2 | 3;

/** One hop of the escalation chain that sits on top of the resolved approver (spec §5). */
export interface EscalationHop {
  /** Canonical identity — M365/Entra object id (spec §6.4). */
  person_ref: string;
  display_name?: string;
  /**
   * Minutes of no-response after the PREVIOUS notification before this hop
   * fires (from action-class-registry escalation_after_minutes; same value
   * per hop in v1 — per-hop overrides are not in the spec).
   */
  after_minutes: number;
}

export interface ResolveResult {
  /** Canonical identity — M365/Entra object id (spec §6.4). */
  person_ref: string;
  display_name?: string;
  ladder_step: LadderStep;
  /** Set when ladder_step = "function_role" — which §6.3 function resolved. */
  function?: string;
  escalation_plan: EscalationHop[];
  /** null = holds indefinitely (Bucket 3 default). */
  ttl_minutes: number | null;
  on_expiry: OnExpiry;
  breaks_quiet_hours: boolean;
  trust_bucket: TrustBucket;
  /**
   * §4.2 gap rule: record-bound action whose record had no owner (or the
   * owner could not be mapped to an identity) — routed to firm default.
   * The CALLER emits the "N records have no assigned consultant"
   * Janitor-finding audit row; this flag is the signal.
   */
  unowned_record?: boolean;
  /** Human-readable resolution trace — ALWAYS set (auditability, spec §9 Phase A). */
  reason: string;
}

/**
 * Person-reference envelope recorded in approval rows' payload jsonb as
 * `decided_by` (PLAN.md decision 8 — no migration; column semantics unchanged).
 */
export interface PersonRef {
  /** M365/Entra object id. */
  person_ref: string;
  /** Transport the decision arrived on (e.g. "telegram", "teams"). */
  transport?: string;
  /** Transport-local user id (e.g. Telegram user id). */
  transport_user_id?: string;
}

// ── Identity map (spec §6.4; PLAN.md decision 8) ──────────────────────────

/** One row of /vault/{tenant}/routing/identity-map.yaml. */
export interface IdentityRow {
  /** Bullhorn user id (integer in Bullhorn; normalised to string for lookups). */
  bullhorn_user_id: number;
  /** Canonical identity — M365/Entra object id. */
  m365_object_id: string;
  email: string;
  telegram_user_id?: string;
  display_name: string;
  /** Provenance of the row, e.g. "manual" | "csv_import" | "graph_email_match". */
  source: string;
}

/**
 * A producer of identity rows. The vault YAML seed (bin/seed-identity-map.ts)
 * is the v1 populator; a future M365 Graph email-match populator implements
 * this same interface and drops in with no schema change (spec §6.4).
 */
export interface IdentitySource {
  /** Returns the identity rows this source can vouch for. */
  listIdentities(): Promise<IdentityRow[]>;
}

// ── Action-class registry (spec §5.1; PLAN.md decision 4) ─────────────────

/** Parsed routing_rule: "record_owner" or "function_role:<name>". */
export type RoutingRule =
  | { kind: "record_owner" }
  | { kind: "function_role"; function: string };

/** One row of agents/_shared/action-class-registry.yaml, keyed by action_type. */
export interface ActionClassRow {
  action_type: string;
  routing_rule: RoutingRule;
  trust_bucket: TrustBucket;
  /** Minutes before the first escalation hop fires; null/absent = no escalation. */
  escalation_after_minutes: number | null;
  /** null = holds indefinitely. When the key is absent, function-roles ttl applies. */
  ttl_minutes: number | null;
  /** Whether the registry row carried an explicit ttl_minutes key (null counts as explicit). */
  ttl_minutes_explicit: boolean;
  on_expiry: OnExpiry;
  breaks_quiet_hours: boolean;
  /** Whether the registry row carried an explicit breaks_quiet_hours key. */
  breaks_quiet_hours_explicit: boolean;
  digest_eligible: boolean;
  /** v1.1 agents are seeded dormant: true (PLAN.md decision 4). */
  dormant?: boolean;
}

// ── Function-roles map (spec §6.3, schema_version 1) ───────────────────────

export const FUNCTION_NAMES = [
  "finance",
  "ops_data",
  "business_development",
  "candidate_comms_default",
  "client_comms_default",
  "admin",
] as const;

export type FunctionName = (typeof FUNCTION_NAMES)[number];

export type HolderSource = "graph_inferred" | "diagnostic_confirmed" | "manual";

export interface FunctionHolder {
  person_ref: string;
  display_name: string;
  source: HolderSource;
}

export interface FunctionEscalationEntry {
  person_ref: string;
  display_name: string;
}

export interface FunctionRoleEntry {
  function: FunctionName;
  holder: FunctionHolder;
  escalation: FunctionEscalationEntry[];
  /** null = holds indefinitely (Bucket 3). */
  ttl_minutes: number | null;
  breaks_quiet_hours: boolean;
}

export interface FirmDefaultApprover {
  person_ref: string;
  display_name: string;
}

export interface FunctionRolesMap {
  tenant_id: string;
  schema_version: 1;
  confirmed_at?: string;
  confirmed_by?: string;
  /** Ladder step 3 — must always be set (§6.3 "Must always be set"). */
  firm_default_approver: FirmDefaultApprover;
  functions: FunctionRoleEntry[];
}

// ── Owner lookup (entities cache; injectable) ──────────────────────────────

export interface OwnerLookupResult {
  /** Bullhorn user id of the record owner, as cached in entities.data. */
  owner_bullhorn_user_id: string;
}

/**
 * Resolves the owner of a cached Bullhorn record (entities table) for a
 * tenant. Returns null when the record is absent, the entity type carries no
 * owner field in the vertical schema, or the owner field is empty — the
 * ladder then falls through (§4.2). NEVER invents an owner.
 */
export type OwnerLookup = (
  tenant_slug: string,
  record: RecordRef,
) => Promise<OwnerLookupResult | null>;

// ── Typed errors (callers branch on `code`; CLI maps to exit 3) ────────────

export type RoutingConfigErrorCode =
  | "function_roles_missing"
  | "function_roles_invalid"
  | "identity_map_missing"
  | "identity_map_invalid"
  | "registry_missing"
  | "registry_invalid"
  | "action_type_unregistered";

/**
 * Routing configuration is absent or unusable. The W3 caller treats this as
 * "resolver unavailable" and falls back to the single-operator path
 * byte-for-byte (PLAN.md decision 2). CLI exit code 3.
 */
export class RoutingConfigError extends Error {
  readonly code: RoutingConfigErrorCode;
  constructor(code: RoutingConfigErrorCode, message: string) {
    super(message);
    this.name = "RoutingConfigError";
    this.code = code;
  }
}
