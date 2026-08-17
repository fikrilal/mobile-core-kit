# <Plan Title>

Date: YYYY-MM-DD  
Owner: <name>  
Status: active  
Risk class: low | medium | high  
Related issue/PR: <link or N/A>

## Objective

Describe the concrete outcome this task must deliver.

## Constraints

- architectural constraints:
- product/runtime constraints:
- out of scope:

## Acceptance Criteria

1.
2.
3.

## Implementation Checklist

- [ ] Step 1
- [ ] Step 2
- [ ] Step 3

## Decision Log

- YYYY-MM-DD: <decision> -> <reason>

## Verification

List exact commands and outcomes.

```bash
# example
dart run mobile_core_kit_cli:mobilekit verify --profile full --env dev
```

Additional targeted checks when relevant:

```bash
# examples
# dart run mobile_core_kit_cli:mobilekit lint
# fvm flutter test
# dart run mobile_core_kit_cli:mobilekit codegen verify
```

## Runtime Evidence

Required when the change is medium/high-risk and behavior cannot be proven sufficiently by static checks alone.

- Device/emulator:
- Flavor:
- Executed target(s):
- Artifact path(s):
- Notes:

## Risks And Mitigations

- Risk:
- Mitigation:

## Completion Notes

Summarize what shipped, what changed, and any important caveats.

## Follow-ups

- [ ] Add unresolved debt to `docs/exec-plans/tech_debt_tracker.md`
