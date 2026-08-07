# W1 implementation summary — `@ifos/approval-routing` (resolver core)

**Slice:** W1 of `docs/features/approval-routing/PLAN.md` (architectural decisions 1, 2, 8 + the §10.6 confirm-in-Diagnostic default).
**Spec sections implemented:** §0, §3, §4, §4.1, §4.2, §6.3 (verbatim, schema_version 1), §6.4, §7 (types only — read-filter lands W7), §11 guardrails.
**Status:** complete — typecheck green, 67/67 vitest, tsup build clean, full `scripts/build-gate.sh` PASS (2026-06-11).

## Deliverables

| Artefact | What it is |
|---|---|
| `packages/utilities/approval-routing/src/types.ts` | `ResolveInput` / `ResolveResult` (ladder_step, escalation_plan, ttl/on_expiry/quiet-hours/trust_bucket, `unowned_record`, mandatory `reason`), `PersonRef` envelope, `IdentitySource` (Graph populator drop-in point), typed `RoutingConfigError` |
| `src/yaml-lite.ts` | Zero-dep YAML-subset parser + emitter scoped to the routing artefacts (comments, quoted strings, nested list maps, `[]`; loud `YamlParseError` on anchors/tabs/flow/multiline — never a silent misparse) |
| `src/function-roles.ts` | Loader/validator for `/vault/{t}/routing/function-roles.yaml` — §6.3 verbatim as schema_version 1; firm_default_approver REQUIRED; closed six-function enum; holder.source enum; violations → typed error, caller falls back |
| `src/identity-map.ts` | Loader/validator/writer for `/vault/{t}/routing/identity-map.yaml`; bidirectional lookups (bullhorn_user_id → row, person_ref → row); validate-before-write |
| `src/registry.ts` | Loader for the action-class registry row shape (PLAN.md decision 4); `require()` throws typed `action_type_unregistered` |
| `src/owner-lookup.ts` | Injectable RunPsql, RLS-scoped (`SET LOCAL app.current_tenant`) reader of the record owner from `entities.data` (mapping verified below) |
| `src/resolve.ts` | `resolveApprover()` — the §4 ladder as a pure function over injected deps; ladder_step + reason on every result |
| `bin/resolve-approver.ts` | CLI: single-line JSON ResolveResult; exit 0 resolved / 3 config-absent (fallback) / 1 real error; `IFOS_ROUTING_FAKE` fixture mode |
| `bin/seed-identity-map.ts` | CSV/manual identity-map populator + `--render-confirmation` (§10.6 Diagnostic-style cited summary as a standalone CLI until the wizard exists) |
| `tests/` (7 files, 67 tests, all offline) | Ladder unit matrix, §6.3 accept+reject, identity round-trip + bidirectional lookup, CLI JSON contract + exit codes + fake mode, owner-lookup SQL shape vs fake RunPsql |

Package idioms mirror `autosend-bridge-telegram` exactly: zero npm runtime deps, tsup ESM `dist/bin/*.js`, injectable db/files, fixture-mode env var, errors as JSON on stderr.

## Verified entities owner-field mapping (honest)

The `entities` table is `(tenant_slug, entity_type, entity_id, data jsonb, …)`; owner data lives inside `data`. Per `docs/verticals/recruitment/vertical-schema.yaml`:

| entity_type | owner field in `data` | source | schema evidence |
|---|---|---|---|
| `candidate` | `owner_user_id` (integer) | `Bullhorn.Candidate.owner.id` | lines ~91–95 |
| `contractor` | `owner_user_id` | inherits the candidate base set ("candidate-overlap fields", ~163–165) | conceptual inherit |
| `client` | `account_owner_user_id` (integer) | `Bullhorn.ClientCorporation.owner.id` | lines ~262–265 |
| `brief` (JobOrder) | **none defined** in schema v0.x | — | full grep, no owner field |
| `placement` | **none defined** in schema v0.x | — | full grep, no owner field |
| `contact` | **none defined** | — | — |

**Critical finding:** owner data is **absent in all cached rows today**. The Bullhorn connector *fetches* `owner` (`packages/mcp-connectors/bullhorn/src/candidates.ts` DEFAULT_FIELDS), but the CLI normalisers that feed the entities upsert (`packages/mcp-connectors/bullhorn/src/cli.ts` `normCandidate`/`normContact`/`normClient`) **drop it** — no `owner_user_id`/`account_owner_user_id` ever reaches `data` jsonb, and a repo-wide grep shows no agent code or fixture seeds one. Consequence: ladder step 1 resolves not-found on live data and falls through per §4.2 — correct and honest, never invented. **Follow-up for W3 (or a small connector PR):** add `owner_user_id: c.owner?.id ?? null` to `normCandidate` (and the client equivalent) so step 1 lights up; the reader here is already coded to the schema field names. Spec §4 names JobOrder/Placement owners; schema v0.x doesn't model them — extending the vertical schema is a separate schema-before-code decision, not smuggled in here.

## Deviations / interpretation calls (numbered)

1. **Unowned record → firm default directly (not via `candidate_comms_default`).** Spec §6.3 comments describe candidate/client_comms_default as "fallback when a candidate/client has no Bullhorn owner", but §4.2 (and the W1 slice brief verbatim) say unowned record → **firm default** + flag. Implemented §4.2. The comms-default functions remain fully loadable/validated and reachable via explicit `function_role:candidate_comms_default` registry rules; rewiring the unowned path through them is a ~5-line change in `resolve.ts` if W3 review prefers.
2. **Registry envelope hedge.** W2 authors the real seed in parallel and the envelope shape (top-level `action_types:` à la autosend-policy.yaml vs bare map) was not observable from this worktree. The loader accepts both; row-shape validation is strict either way. Collapse to one shape at W3 merge once the W2 file exists.
3. **TTL / quiet-hours precedence.** Both the registry (per action class, §5.1) and function-roles (per function, §6.3) carry `ttl_minutes`/`breaks_quiet_hours`. Implemented: explicit registry key wins (including explicit `null` = holds indefinitely, distinguished via `ttl_minutes_explicit`); the §6.3 per-function value applies when the registry row omits the key and resolution went through a function. Spec doesn't rank them; the action class is the shipped, more specific artefact.
4. **Record-owner escalation chain = firm default only.** §5 says "escalate to their backup, then the firm default", but v1 has no per-desk backup/desk-lead data (spec §3.2/§8 — split-desk modelling deferred). The chain after a record owner is therefore the firm default alone; function-role chains use the §6.3 escalation list, terminated at the firm default, consecutive duplicate hops deduped (boutique collapse).
5. **`record_owner` action invoked with no record → firm default** with an explanatory reason (no `unowned_record` flag — it's a caller misconfiguration, not a data gap). "Nothing falls through" (§4 step 3) preferred over a hard error.
6. **Record-bound CLI invocation with `IFOS_DB_URL` unset → exit 3** (config absent → single-operator fallback) rather than silently resolving without owner data — a DB-outage must not masquerade as "record has no owner" (that would emit false Janitor findings).
7. **Identity-map ABSENT is non-fatal in the CLI** (record-owner step just falls through; function-bound routing never needs it); identity-map INVALID is fatal (exit 3). Missing/invalid function-roles or registry are always exit 3.
8. **Zero-dep YAML.** `js-yaml` (used by agent-renderer) was not added; a scoped subset parser/emitter ships in-package per the bridge zero-dep precedent. Out-of-scope YAML fails loudly with a typed error — never a silent misparse.
9. **`IdentitySource`** is defined as a row *producer* (`listIdentities()`): the Graph email-match populator implements it later and writes through the same `saveIdentityMap()`; the resolver consumes the loaded `IdentityMap` lookups, so no schema change is needed when Graph arrives.

## Verification evidence

- `pnpm -s typecheck` — clean.
- `pnpm -s test` — 7 files, **67/67 passed**, fully offline (no DB, no network; CLI suite spawns the real entrypoints via tsx).
- `pnpm -s build` (tsup) — clean; `dist/bin/resolve-approver.js` + `dist/bin/seed-identity-map.js` + `dist/index.js` emitted.
- `bash scripts/build-gate.sh` — **PASS** (shellcheck clean, all connector suites green, all 18 DB-backed fixture suites green). This package is not yet in the gate's package loop — the orchestrator adds it at W3 merge per the slice brief.

## Queued for W3 / follow-ups

- Add owner fields to the Bullhorn CLI normalisers (see finding above).
- Wire `resolve-approver.js` into the `hh_decision_action` orange path + fallback invariant suite (W3 scope).
- Collapse the registry envelope hedge once the W2 seed lands.
- DB-backed owner-lookup fixture suite (W3 brings the registered-throwaway-tenant pattern).

## Review fix pass (post-W1-review, pre-merge)

The W1 review PASSED but probe-confirmed two `yaml-lite.ts` parser defects; both are required to close before merge because `/vault/{t}/routing/function-roles.yaml` is tenant-hand-edited. Both fixed:

1. **MAJOR — silent comment-swallow on apostrophes in unquoted scalars.** `stripComment` toggled `inSingle` on any apostrophe, so `display_name: Pat O'Brien # the desk lead` silently parsed to `"Pat O'Brien # the desk lead"`. Fix: a quote character now only opens quote state at a value-start position (line start after indentation, after `key: `, or after a `- ` sequence indicator); mid-scalar apostrophes are literal. The rewrite also handles `''` escapes in single-quoted and `\"`/`\\` escapes in double-quoted scalars during comment-stripping. After the fix: `Pat O'Brien # comment` → `"Pat O'Brien"`; quoted values containing `#`/`:` and escaped quotes remain protected.
2. **MINOR — block-scalar header variants silently parsed as plain strings.** Only bare `|`/`>` were rejected; `|-`, `|2`, `>-`, `>2` etc. yielded literal strings like `"|-"`. Fix: any scalar value starting with `|` or `>` now throws `YamlParseError` ("block scalars are not supported") — fail loudly, never misparse. Quoted values that merely look like headers (`"|-"`, `'>2'`) still parse as strings.

Verification: probe matrix re-run across all variants (apostrophe scalars, `|`/`>` header zoo, quoted `#`/`:`, escaped quotes, ISO timestamps, URLs) — every case either parses correctly or throws loudly; the package-header "never a silent misparse" claim is now accurate. `pnpm -s typecheck` clean; `pnpm -s test` **86/86** (was 67/67; +19 regression tests in `tests/yaml-lite.test.ts` covering both probe cases and the still-must-pass set, §6.3 fixture test unchanged and green); `bash scripts/build-gate.sh` **PASS**.
