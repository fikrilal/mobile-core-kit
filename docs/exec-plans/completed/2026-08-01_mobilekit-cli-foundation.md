# Mobilekit CLI Foundation

Date: 2026-08-01
Owner: Codex
Status: completed
Risk class: medium
Related issue/PR: N/A
Proposal: `_WIP/2026-08-01_mobilekit_cli_proposal.md`

## Objective

Create the repo-local Dart CLI package foundation for `mobilekit` without changing existing tool behavior.

This plan establishes the package, executable, command routing, shared process runner, and read-only `doctor` command. Existing `tool/` commands must continue to work unchanged.

## Constraints

- architectural constraints:
  - CLI orchestration belongs in `packages/mobile_core_kit_cli/`
  - custom analyzer lints remain in `packages/mobile_core_kit_lints/`
  - repo policy/config remains in existing files such as `lint/architecture_lints.yaml`, `.jscpd*.json`, and `duplication/*.json`
  - do not hide architecture lint policy, duplication allowlists, or jscpd profile config inside CLI code
- product/runtime constraints:
  - no Flutter app runtime behavior should change
  - `mobilekit doctor` must be read-only by default
  - global installation is explicit through `dart pub global activate --source path packages/mobile_core_kit_cli`
- out of scope:
  - porting `verify`, `fix`, config generation, scaffolding, or duplication behavior
  - changing CI
  - deleting old `tool/` scripts
  - adding `mobilekit install`

## Acceptance Criteria

1. `packages/mobile_core_kit_cli/` exists as a private Dart package.
2. The package exposes the executable `mobilekit`.
3. The root package can run `dart run mobile_core_kit_cli:mobilekit --help`.
4. `dart run mobile_core_kit_cli:mobilekit doctor` reports local toolchain status without mutating the machine.
5. Local activation works: `dart pub global activate --source path packages/mobile_core_kit_cli`.
6. After activation, `mobilekit --help` and `mobilekit doctor` work.
7. Existing `tool/` commands remain untouched and usable.

## Implementation Checklist

- [x] Create `packages/mobile_core_kit_cli/pubspec.yaml`.
- [x] Add `bin/mobilekit.dart`.
- [x] Add command routing with `package:args`.
- [x] Add a shared process runner that preserves current FVM-aware Dart/Flutter resolution behavior.
- [x] Add repository-root discovery.
- [x] Add `mobilekit doctor` as a read-only diagnostics command.
- [x] Add root `pubspec.yaml` path dev dependency for `mobile_core_kit_cli`.
- [x] Add focused tests for command parsing, root discovery, process-runner resolution, and doctor result classification where feasible.
- [x] Validate local activation in both pinned and globally activated modes.

## Decision Log

- 2026-08-01: Executable name is `mobilekit` -> accepted as the stable public command name.
- 2026-08-01: `mobilekit doctor` is in v1 scope -> local diagnostics are useful enough to include, but must remain read-only by default.
- 2026-08-01: `mobilekit install` is not in v1 scope -> explicit `dart pub global activate --source path` is sufficient.

## Verification

Run exact commands and record outcomes before completing this plan.

```bash
dart pub get
dart run mobile_core_kit_cli:mobilekit --help
dart run mobile_core_kit_cli:mobilekit doctor
dart pub global activate --source path packages/mobile_core_kit_cli
mobilekit --help
mobilekit doctor
dart run test packages/mobile_core_kit_cli
dart run tool/verify.dart --env dev --skip-tests --skip-duplication
```

Outcome: all commands passed. The targeted repository gate also passed Flutter
analysis, custom lints, modal/color checks, and format verification. The
project-map step reported its existing skip because `AGENTS.md` does not define
the tree format that `tool/verify_project_map_drift.dart` parses.

If package-local tests require a different command, record the actual command used.

## Runtime Evidence

- Device/emulator: N/A
- Flavor: N/A
- Executed target(s): N/A
- Artifact path(s): N/A
- Notes: static/tooling verification is sufficient. This change does not alter app runtime behavior.

## Risks And Mitigations

- Risk: global activation masks stale local CLI behavior.
- Mitigation: keep CI on pinned `dart run mobile_core_kit_cli:mobilekit`; use `doctor` for diagnostics only.

- Risk: `doctor` grows into environment mutation.
- Mitigation: keep `doctor` read-only by default and print explicit remediation commands instead of running them.

- Risk: CLI package duplicates logic that later plans must refactor.
- Mitigation: keep foundation abstractions narrow: command routing, root discovery, process execution, diagnostics.

## Completion Notes

Added the private `mobile_core_kit_cli` package and root path dependency. The
`mobilekit` executable currently supports general help and the read-only
`doctor` command. The foundation includes repository-root discovery, FVM-aware
Dart/Flutter command resolution on POSIX and Windows, PATH executable probing,
and focused tests for the new boundaries.

Existing `tool/` commands and CI entrypoints were left unchanged for the later
workflow-port and cutover plans. The completed plan is retained as the
foundation record for those dependent phases.

## Follow-ups

- [ ] Start `docs/exec-plans/active/2026-08-01_mobilekit-core-workflows.md` after this foundation is verified.
