String taskPlanFixture({
  String taskId = 'test-task-authority',
  String status = 'active',
  String risk = 'medium',
  String maximumRisk = 'high',
  String allowedPaths = 'docs/exec-plans/active/test.md, lib/features/example/',
  String allowedActions = 'edit, verify',
  String oracleIds = 'ui.human-review',
  String impacts = validImpactFixture,
  String extra = '',
}) =>
    '''
# Test Task

**Plan version:** 2
**Task ID:** $taskId
**Status:** $status
**Owner:** Codex
**Risk:** $risk
**Authority:** implement and verify locally; no external mutation
**Allowed paths:** $allowedPaths
**Allowed actions:** $allowedActions
**Maximum risk:** $maximumRisk
**Repair limit:** 2
**Task timeout:** 90m
**Oracle IDs:** $oracleIds
$extra
Date: 2026-08-11
Related issue/PR: N/A

## Objective

Prove task authority.

## Constraints

- Keep scope narrow.

## Impact Areas

$impacts

## Acceptance Scenarios

1. Valid authority passes.

## Acceptance Criteria

1. The task is bounded.

## Implementation Checklist

- [ ] Implement.

## Decision Log

- 2026-08-11: Use explicit authority.

## Verification

Run tests.

## Runtime Evidence

Not required.

## Rollback

Remove local state.

## Risks And Mitigations

- Risk: broad scope. Mitigation: reject it.

## Completion Notes

Pending.

## Follow-ups

- [ ] None.
''';

const validImpactFixture = '''
- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: yes
- Harness/CI/release: no
- External systems: no
''';
