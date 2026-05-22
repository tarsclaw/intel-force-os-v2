REJECTED

1. Status evidence conflicts with author metadata. Line 4 says founder review is pending, while lines 7 and 159 say the ADR is Accepted with founder decision logged. Fix the metadata so Accepted is backed by a recorded founder decision, or change Status to Proposed.

2. ADR-003 ratifies a CLI surface later shown to violate the submodule boundary. Lines 23 and 121 prescribe `cortextos-ifos render-agent`, which requires modifying or extending the upstream cortextOS CLI surface; ADR-004 later identifies this as a boundary violation. Fix ADR-003 with an erratum changing the command to the IFOS-owned standalone renderer binary.
