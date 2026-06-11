// Loader for agents/_shared/action-class-registry.yaml — the action-class
// registry (spec §5.1, PLAN.md decision 4). Shipped, not configured.
//
// The seed file is authored by the sibling W2 slice in parallel; this loader
// codes against the agreed row shape, keyed by the SAME action_type keys as
// autosend-policy.yaml (the join key):
//
//   action_types:                       # autosend-policy.yaml idiom
//     gmail_outlook_send_to_candidate:
//       routing_rule: record_owner      # or function_role:<name>
//       trust_bucket: 2
//       escalation_after_minutes: 30    # null/absent = no escalation
//       ttl_minutes: 120                # null = holds indefinitely
//       on_expiry: safe_default         # hold | auto_execute | safe_default
//       breaks_quiet_hours: true
//       digest_eligible: false
//       dormant: true                   # optional; v1.1 agents seeded dormant
//
// Parallel-authoring hedge (documented in w1-summary): both the
// `action_types:`-keyed shape above AND a bare top-level map (rows directly
// under the root, schema_version sibling allowed) are accepted, so W1/W2
// cannot deadlock on an envelope choice neither could see. The validator is
// strict about ROW shape either way.

import { readFileSync } from "node:fs";

import { parseYaml, YamlParseError, type YamlValue } from "./yaml-lite.js";
import {
  FUNCTION_NAMES,
  RoutingConfigError,
  type ActionClassRow,
  type OnExpiry,
  type RoutingRule,
  type TrustBucket,
} from "./types.js";

export interface ActionClassRegistry {
  rows: Map<string, ActionClassRow>;
  /** Throws RoutingConfigError("action_type_unregistered") for unknown keys. */
  require(actionType: string): ActionClassRow;
  get(actionType: string): ActionClassRow | null;
}

function invalid(message: string): RoutingConfigError {
  return new RoutingConfigError(
    "registry_invalid",
    `action-class-registry.yaml: ${message}`,
  );
}

function isRecord(v: YamlValue): v is { [key: string]: YamlValue } {
  return v !== null && typeof v === "object" && !Array.isArray(v);
}

export function parseRoutingRule(raw: string, ctx: string): RoutingRule {
  if (raw === "record_owner") return { kind: "record_owner" };
  if (raw.startsWith("function_role:")) {
    const fn = raw.slice("function_role:".length);
    if (!(FUNCTION_NAMES as readonly string[]).includes(fn)) {
      throw invalid(
        `${ctx}.routing_rule function "${fn}" is not a §6.3 function (${FUNCTION_NAMES.join("|")})`,
      );
    }
    return { kind: "function_role", function: fn };
  }
  throw invalid(
    `${ctx}.routing_rule must be "record_owner" or "function_role:<name>" (got "${raw}")`,
  );
}

const ON_EXPIRY_VALUES: readonly string[] = ["hold", "auto_execute", "safe_default"];

function parseRow(actionType: string, v: YamlValue): ActionClassRow {
  const ctx = actionType;
  if (!isRecord(v)) throw invalid(`${ctx} must be a map`);

  const rule = v["routing_rule"];
  if (typeof rule !== "string") throw invalid(`${ctx}.routing_rule is required`);

  const bucket = v["trust_bucket"];
  if (bucket !== 1 && bucket !== 2 && bucket !== 3) {
    throw invalid(`${ctx}.trust_bucket must be 1, 2 or 3`);
  }

  const onExpiry = v["on_expiry"];
  if (typeof onExpiry !== "string" || !ON_EXPIRY_VALUES.includes(onExpiry)) {
    throw invalid(`${ctx}.on_expiry must be one of ${ON_EXPIRY_VALUES.join("|")}`);
  }

  const intOrNull = (key: string): number | null => {
    const n = v[key];
    if (n === undefined || n === null) return null;
    if (typeof n !== "number" || !Number.isInteger(n) || n <= 0) {
      throw invalid(`${ctx}.${key} must be a positive integer or null`);
    }
    return n;
  };

  const bool = (key: string, fallback: boolean): boolean => {
    const b = v[key];
    if (b === undefined || b === null) return fallback;
    if (typeof b !== "boolean") throw invalid(`${ctx}.${key} must be true or false`);
    return b;
  };

  const row: ActionClassRow = {
    action_type: actionType,
    routing_rule: parseRoutingRule(rule, ctx),
    trust_bucket: bucket as TrustBucket,
    escalation_after_minutes: intOrNull("escalation_after_minutes"),
    ttl_minutes: intOrNull("ttl_minutes"),
    ttl_minutes_explicit: "ttl_minutes" in v,
    on_expiry: onExpiry as OnExpiry,
    breaks_quiet_hours: bool("breaks_quiet_hours", false),
    breaks_quiet_hours_explicit: "breaks_quiet_hours" in v,
    digest_eligible: bool("digest_eligible", false),
  };
  if (v["dormant"] === true) row.dormant = true;
  return row;
}

/** Keys that are envelope metadata, not action-type rows, in the bare-map shape. */
const ENVELOPE_KEYS = new Set(["schema_version", "tenant_id", "comment", "description"]);

/** Validates an already-parsed YAML document into an ActionClassRegistry. */
export function validateRegistry(doc: YamlValue): ActionClassRegistry {
  if (!isRecord(doc)) throw invalid("document must be a map");

  let rowsSource: { [key: string]: YamlValue };
  if (isRecord(doc["action_types"])) {
    rowsSource = doc["action_types"];
  } else if ("action_types" in doc) {
    throw invalid("action_types must be a map of action_type → row");
  } else {
    rowsSource = Object.fromEntries(
      Object.entries(doc).filter(([k]) => !ENVELOPE_KEYS.has(k)),
    );
  }

  const rows = new Map<string, ActionClassRow>();
  for (const [actionType, raw] of Object.entries(rowsSource)) {
    rows.set(actionType, parseRow(actionType, raw));
  }
  if (rows.size === 0) throw invalid("registry contains no action-type rows");

  return {
    rows,
    get: (actionType) => rows.get(actionType) ?? null,
    require(actionType) {
      const row = rows.get(actionType);
      if (!row) {
        throw new RoutingConfigError(
          "action_type_unregistered",
          `action_type "${actionType}" is not in action-class-registry.yaml — caller falls back`,
        );
      }
      return row;
    },
  };
}

/**
 * Loads + validates the action-class registry from an explicit path
 * (production: agents/_shared/action-class-registry.yaml at the repo root —
 * the W3 shell layer passes the resolved path; tests pass fixtures).
 * Throws RoutingConfigError("registry_missing") when absent.
 */
export function loadRegistry(path: string): ActionClassRegistry {
  let raw: string;
  try {
    raw = readFileSync(path, "utf-8");
  } catch {
    throw new RoutingConfigError(
      "registry_missing",
      `action-class-registry not found at ${path}`,
    );
  }
  let doc: YamlValue;
  try {
    doc = parseYaml(raw);
  } catch (err) {
    if (err instanceof YamlParseError) throw invalid(`unparseable: ${err.message}`);
    throw err;
  }
  return validateRegistry(doc);
}
