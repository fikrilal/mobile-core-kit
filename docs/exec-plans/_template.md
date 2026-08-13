# <Plan Title>

**Plan version:** 2
**Task ID:** <lowercase-kebab-case-id>
**Status:** active
**Owner:** <name or agent>
**Risk:** low | medium | high
**Authority:** <plain-language statement of the authority granted>
**Allowed paths:** <comma-separated repository-relative files/directories>
**Allowed actions:** edit, verify
**Maximum risk:** low | medium | high
**Repair limit:** <non-negative integer>
**Task timeout:** <positive duration, for example 90m or 6h>
**Oracle IDs:** <comma-separated IDs from harness/oracles.yaml; required for medium/high risk>

Date: YYYY-MM-DD
Related issue/PR: <link or N/A>

## Objective

Describe the concrete outcome this task must deliver.

## Constraints

- Architecture constraints:
- Product/runtime constraints:
- Out of scope:

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: no
- External systems: no

## Acceptance Scenarios

1. Given <starting condition>, when <action>, then <observable result>.

## Acceptance Criteria

1. <Measurable completion condition>.

## Implementation Checklist

- [ ] Step 1
- [ ] Step 2
- [ ] Step 3

## Decision Log

- YYYY-MM-DD: <decision> -> <reason>

## Verification

List exact commands and outcomes.

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task <task-id> --action verify
dart run mobile_core_kit_cli:mobilekit verify --profile full --env dev
```

## Runtime Evidence

State why runtime evidence is unnecessary, or record the device, flavor,
targets, artifacts, and observations required by the risk class.

## Rollback

Describe the smallest safe reversal and any state that must be restored.

## Risks And Mitigations

- Risk:
- Mitigation:

## Completion Notes

Pending.

## Follow-ups

- [ ] Record unresolved debt in `docs/exec-plans/tech_debt_tracker.md`, or state none.
