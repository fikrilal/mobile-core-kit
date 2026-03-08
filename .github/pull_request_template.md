## Summary

Describe what changed and why.

## Risk Class

- [ ] `low`
- [ ] `medium`
- [ ] `high`

Risk notes:
- Production impact areas touched (if any):
- Why this risk class was selected:

## Acceptance Criteria

1.
2.
3.

## Checks Run

List exact commands and outcomes.

```bash
dart run tool/verify.dart --env dev
```

Additional checks:

```bash
# examples:
# fvm flutter analyze
# dart run custom_lint
# fvm flutter test
# dart run tool/verify_codegen.dart
# dart run tool/verify_project_map_drift.dart
```

## Evidence

- [ ] Tests added/updated where behavior changed
- [ ] Screenshots/video attached (UI changes)
- [ ] Logs/error traces attached (runtime or failure-path changes)
- [ ] Mobile runtime evidence attached for medium/high UI/runtime PRs (see `docs/engineering/mobile_runtime_harness.md`)
- [ ] No speculative refactor mixed into this PR

Links/artifacts:
-

Runtime evidence details (if applicable):
- Device ID:
- Flavor:
- Integration targets:
- Evidence artifact paths:

## Safety And Rollback

- Potential failure mode:
- Rollback strategy:
- Follow-up required after merge (if any):

## Reviewer Focus

Point reviewers to the highest-risk files/decisions:
-
