REJECTED

1. The status value is invalid. Line 4 says `Design specification (not a decision record)`, which is not one of the allowed values. Fix by changing it to `Status: Reference` and keeping the "recommendations become binding via ADR-003" sentence as explanatory text.

2. The design adds an unsupported `decision_log.phase` value. Lines 636 and 706 require `phase='render'`, but the supported CHECK set is `trigger | output | action | gating_failed | agent_handoff`. Fix by using an existing phase such as `gating_failed`/`action` with `agent_name='_renderer'`, or update the Day-4 schema and all references to include `render`.

3. The CLI surface conflicts with the submodule boundary. Lines 611-618 and 790-792 prescribe `cortextos-ifos render-agent`, which implies extending the upstream cortextOS CLI. ADR-004 later corrects this to `ifos-render-agent`. Fix the design and master-brief edit text to use the standalone IFOS-owned binary.
