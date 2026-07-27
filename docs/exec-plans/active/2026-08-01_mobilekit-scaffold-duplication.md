# Mobilekit Scaffolding And Duplication Harness

Date: 2026-08-01
Owner: Unassigned
Status: active
Risk class: medium
Related issue/PR: N/A
Proposal: `_WIP/2026-08-01_mobilekit_cli_proposal.md`
Depends on: `docs/exec-plans/active/2026-08-01_mobilekit-core-workflows.md`

## Objective

Expose feature scaffolding and duplication harness workflows through `mobilekit`.

This plan converts the public shell-based duplication command surface into Dart orchestration while keeping existing duplication policy files and allowlists repo-local.

## Constraints

- architectural constraints:
  - scaffolding behavior must follow existing feature architecture conventions
  - duplication config remains in `.jscpd*.json`
  - duplication allowlists remain in `tool/*allowlist.json`
  - `tool/filter_duplication_report.dart` may remain an internal helper or be moved only if ownership stays clear
- product/runtime constraints:
  - no app runtime behavior should change
  - scaffolding must not overwrite existing files unless existing behavior explicitly allows it
  - duplication output should remain equivalent to current shell scripts
- out of scope:
  - adding new duplication categories
  - changing duplication allowlist semantics
  - changing scaffolder architecture output
  - CI/docs cutover
  - deleting old shell wrappers

## Acceptance Criteria

1. `mobilekit scaffold feature <name>` matches current `tool/scaffold_feature.dart` behavior.
2. `mobilekit duplication check` runs the default core and small-helper profiles.
3. `mobilekit duplication check --profile core` matches `./tool/check_duplication.sh`.
4. `mobilekit duplication check --profile small-helpers` matches `./tool/check_small_helper_duplication.sh`.
5. `mobilekit duplication check --profile presentation` matches `./tool/check_presentation_duplication.sh`.
6. Existing shell wrappers continue to work during this plan.
7. Duplication policy/config data remains outside CLI code.

## Implementation Checklist

- [ ] Implement `mobilekit scaffold feature`.
- [ ] Implement duplication profile routing.
- [ ] Implement Dart orchestration for the core duplication profile.
- [ ] Implement Dart orchestration for the small-helper duplication profile.
- [ ] Implement Dart orchestration for the presentation duplication profile.
- [ ] Preserve current `npx --yes jscpd` invocation semantics.
- [ ] Preserve current `tool/filter_duplication_report.dart` filtering behavior.
- [ ] Keep current shell scripts working as compatibility wrappers.
- [ ] Add tests for argument parsing and profile-to-command mapping.
- [ ] Add parity notes for duplication output equivalence.

## Decision Log

- 2026-08-01: Duplication rules/config stay repo-local -> the CLI executes policy; it does not own policy.
- 2026-08-01: Shell wrappers remain during this plan -> final deletion belongs to cutover after parity is proven.

## Verification

Run exact commands and record outcomes before completing this plan.

```bash
dart run mobile_core_kit_cli:mobilekit duplication check --profile core
./tool/check_duplication.sh
dart run mobile_core_kit_cli:mobilekit duplication check --profile small-helpers
./tool/check_small_helper_duplication.sh
dart run mobile_core_kit_cli:mobilekit duplication check --profile presentation
./tool/check_presentation_duplication.sh
dart run mobile_core_kit_cli:mobilekit duplication check
dart run test packages/mobile_core_kit_cli
```

For scaffolding parity, use a disposable branch/worktree or temporary feature name and remove only files created by the test.

```bash
dart run tool/scaffold_feature.dart --help
dart run mobile_core_kit_cli:mobilekit scaffold feature --help
```

If a real scaffold smoke test is performed, record the feature name and cleanup method.

## Runtime Evidence

- Device/emulator: N/A
- Flavor: N/A
- Executed target(s): N/A
- Artifact path(s): N/A
- Notes: static/tooling verification is sufficient. This change does not alter app runtime behavior.

## Risks And Mitigations

- Risk: Dart duplication orchestration changes scan scope.
- Mitigation: compare commands/profile arguments directly against the old shell scripts and run old/new profile pairs.

- Risk: scaffolder smoke tests leave unwanted files.
- Mitigation: use a disposable branch/worktree or a clearly isolated temporary feature and clean up only generated files.

- Risk: `npx` behavior differs across platforms.
- Mitigation: keep invocation explicit and include failures in `mobilekit doctor` diagnostics if repeated setup issues appear.

## Completion Notes

Fill in after implementation.

## Follow-ups

- [ ] Start `docs/exec-plans/active/2026-08-01_mobilekit-cutover-cleanup.md` after scaffolding and duplication parity is verified.
