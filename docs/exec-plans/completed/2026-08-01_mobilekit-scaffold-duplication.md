# Mobilekit Scaffolding And Duplication Harness

Date: 2026-08-01
Owner: Codex
Status: completed
Risk class: medium
Related issue/PR: N/A
Proposal: `_WIP/2026-08-01_mobilekit_cli_proposal.md`
Depends on: `docs/exec-plans/completed/2026-08-01_mobilekit-core-workflows.md`

## Objective

Expose feature scaffolding and duplication harness workflows through `mobilekit`.

This plan converts the public shell-based duplication command surface into Dart orchestration while keeping existing duplication policy files and allowlists repo-local.

## Constraints

- architectural constraints:
  - scaffolding behavior must follow existing feature architecture conventions
  - duplication config remains in `.jscpd*.json`
  - duplication allowlists remain in `duplication/*.json`
  - the internal duplication report filter remains package-owned and private
- product/runtime constraints:
  - no app runtime behavior should change
  - scaffolding must not overwrite existing files unless existing behavior explicitly allows it
  - duplication output should remain equivalent to the established profiles
- out of scope:
  - adding new duplication categories
  - changing duplication allowlist semantics
  - changing scaffolder architecture output
  - CI/docs cutover
  - deleting old shell wrappers

## Acceptance Criteria

1. `mobilekit scaffold feature <name>` preserves the established scaffolding behavior.
2. `mobilekit duplication check` runs the default core and small-helper profiles.
3. `mobilekit duplication check --profile core` preserves the core profile behavior.
4. `mobilekit duplication check --profile small-helpers` preserves the small-helper profile behavior.
5. `mobilekit duplication check --profile presentation` preserves the presentation profile behavior.
6. The CLI command surface remains available in pinned and installed modes.
7. Duplication policy/config data remains outside CLI code.

## Implementation Checklist

- [x] Implement `mobilekit scaffold feature`.
- [x] Implement duplication profile routing.
- [x] Implement Dart orchestration for the core duplication profile.
- [x] Implement Dart orchestration for the small-helper duplication profile.
- [x] Implement Dart orchestration for the presentation duplication profile.
- [x] Preserve current `npx --yes jscpd` invocation semantics.
- [x] Preserve the existing duplication report filtering behavior.
- [x] Keep the CLI command surface available as the supported workflow.
- [x] Add tests for argument parsing and profile-to-command mapping.
- [x] Add parity notes for duplication output equivalence.

## Decision Log

- 2026-08-01: Duplication rules/config stay repo-local -> the CLI executes policy; it does not own policy.
- 2026-08-01: Shell wrappers remain during this plan -> final deletion belongs to cutover after parity is proven.
- 2026-08-01: Default duplication check runs core and small-helpers only -> presentation remains an explicit profile as it is in the existing harness.

## Verification

Run exact commands and record outcomes before completing this plan.

```bash
dart run mobile_core_kit_cli:mobilekit duplication check --profile core
dart run mobile_core_kit_cli:mobilekit duplication check --profile small-helpers
dart run mobile_core_kit_cli:mobilekit duplication check --profile presentation
dart run mobile_core_kit_cli:mobilekit duplication check
dart run test packages/mobile_core_kit_cli
```

For scaffolding parity, use a disposable branch/worktree or temporary feature name and remove only files created by the test.

```bash
dart run mobile_core_kit_cli:mobilekit scaffold feature --help
```

If a real scaffold smoke test is performed, record the feature name and cleanup method.

Outcome: all listed profile commands and their shell-wrapper counterparts
passed. Core produced 21 raw clones with no actionable groups, small-helpers
produced 346 raw clones with no actionable groups, and presentation produced
28 raw clones with no actionable groups. The default profile ran core followed
by small-helpers. Scaffold dry-run output for `mobilekit_exec3_probe` with
slice `list` matched the established scaffolding behavior exactly and created
no files.
The package test suite, package analysis, and repository verification also
passed.

## Runtime Evidence

- Device/emulator: N/A
- Flavor: N/A
- Executed target(s): N/A
- Artifact path(s): N/A
- Notes: static/tooling verification is sufficient. This change does not alter app runtime behavior.

## Risks And Mitigations

- Risk: Dart duplication orchestration changes scan scope.
- Mitigation: compare CLI profile arguments directly against the established
  profiles and run focused profile checks.

- Risk: scaffolder smoke tests leave unwanted files.
- Mitigation: use a disposable branch/worktree or a clearly isolated temporary feature and clean up only generated files.

- Risk: `npx` behavior differs across platforms.
- Mitigation: keep invocation explicit and include failures in `mobilekit doctor` diagnostics if repeated setup issues appear.

## Completion Notes

Added `mobilekit scaffold feature <name>` as a positional wrapper around the
existing feature scaffolder, preserving `--slice` and `--dry-run` behavior.

Added Dart duplication orchestration for the core, small-helpers, and
presentation profiles. The CLI invokes the same `npx --yes jscpd` paths,
configs, reports, allowlists, and existing filter script as the shell wrappers.
The shell wrappers remain unchanged for compatibility, and no duplication
policy or allowlist data moved into the CLI package.

## Follow-ups

- [ ] Start `docs/exec-plans/active/2026-08-01_mobilekit-cutover-cleanup.md` after scaffolding and duplication parity is verified.
