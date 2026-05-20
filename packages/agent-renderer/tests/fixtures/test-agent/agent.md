# test-agent — output contract + workflow

## Output contract

Test-agent emits one structured `decision_log` row per invocation with phase
`output`. Payload shape: `{ "ok": true, "echoed_input": <string> }`. No external
side effects. Used exclusively by renderer unit tests.

## Workflow

1. `hh_decision_trigger` at session start
2. Read `${CTX_TENANT_SLUG}` from env
3. Echo input + emit `hh_decision_output`
4. Wait for human resolve; emit `hh_decision_action`

## Gates

Gate A: `validate.sh` enforces tenant_slug matches CTX env var.

## Escalation

Single ESC code in scope: `ESC_SCHEMA_VIOLATION` on malformed input. Routes per
`common-notifications.json`.
