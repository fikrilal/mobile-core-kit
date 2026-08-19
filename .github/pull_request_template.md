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
dart run mobile_core_kit_cli:mobilekit verify --profile full --env dev
```

Additional checks:

```bash
# examples:
# dart run mobile_core_kit_cli:mobilekit lint
# fvm flutter test
# dart run mobile_core_kit_cli:mobilekit codegen verify
# dart run mobile_core_kit_cli:mobilekit project-map verify
```

Hosted checks:
- [ ] `CI Risk` passed
- [ ] `CI Full` passed
- [ ] `CI Runtime` passed or was intentionally skipped by classification
- [ ] `CI Governance` passed
- [ ] Stable `CI Required` aggregate passed

## Evidence

- [ ] Tests added/updated where behavior changed
- [ ] Screenshots/video attached (UI changes)
- [ ] Logs/error traces attached (runtime or failure-path changes)
- [ ] Mobile runtime evidence attached for medium/high UI/runtime PRs (see `docs/engineering/mobile_runtime_harness.md`)
- [ ] Runtime evidence fingerprint matches the final reviewed candidate
- [ ] No speculative refactor mixed into this PR
- [ ] Handoff used fresh action-specific evidence and explicit publication authority
- [ ] No force push, merge, deployment, signing, migration, or release was performed by the harness

Links/artifacts:
-

Runtime evidence details (if applicable):
- Task fingerprint:
- Device identifier hash:
- Flavor:
- Registered oracle results:
- Evidence artifact paths:

## Safety And Rollback

- Potential failure mode:
- Rollback strategy:
- Follow-up required after merge (if any):

## Reviewer Focus

Point reviewers to the highest-risk files/decisions:
-
