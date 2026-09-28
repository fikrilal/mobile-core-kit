# Scaffold All End-to-End Command

**Plan version:** 2
**Task ID:** scaffold-all-command
**Status:** completed
**Owner:** Antigravity
**Risk:** high
**Authority:** Implement `mobilekit scaffold all --feature <name> --operation <id> [options]` in `mobile_core_kit_cli` to unify feature skeleton scaffolding and OpenAPI data layer scaffolding into a single end-to-end command.
**Allowed paths:** docs/exec-plans/active/2026-09-24_scaffold-all-command.md, docs/exec-plans/completed/2026-09-24_scaffold-all-command.md, packages/mobile_core_kit_cli/lib/src/, packages/mobile_core_kit_cli/test/, lib/features/, lib/core/infra/network/endpoints/
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 60m
**Oracle IDs:** harness.full, contract.openapi.snapshot

Date: 2026-09-24
Related issue/PR: N/A

## Objective

Build `mobilekit scaffold all --feature <name> --operation <id> [options]` subcommand in `mobile_core_kit_cli` that:
1. Validates that `--feature` and `--operation` arguments are provided and valid.
2. Checks whether `lib/features/<feature>/` already exists. If not, runs `ScaffoldWorkflow` (`scaffold feature`) to generate the complete Clean Architecture feature skeleton (Presentation, Domain, Navigation, DI module, Data stubs).
3. Executes `ScaffoldDataWorkflow` (`scaffold data`) to parse the specified OpenAPI operation from `backend.openapi.yaml`, generate Freezed Request/Response DTOs, register core endpoint constants/methods, and generate remote datasource methods.
4. Triggers targeted `build_runner` codegen unless `--no-codegen` or `--dry-run` is passed.
5. Supports flags: `--slice <name>`, `--dry-run`, `--force`, `--no-codegen`.

## Constraints

- Architecture constraints:
  - Preserves Clean Architecture boundaries: Domain layer remains decoupled from backend DTOs.
  - Safe by default: If the feature already exists, `scaffold feature` is skipped and only `scaffold data` is run (or merged into existing files).
  - Works offline reading pinned local OpenAPI contract `docs/contracts/openapi/backend.openapi.yaml`.
- Product/runtime constraints:
  - Generates code complying with `flutter_lints` and repo architecture lints.
- Out of scope:
  - Altering mobile runtime or state machine implementations.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: yes
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: yes
- External systems: no

## Acceptance Scenarios

1. Given `--feature new_feature --operation users.me.get`, when `lib/features/new_feature/` does not exist, both feature skeleton and OpenAPI data layer are scaffolded.
2. Given `--feature existing_feature --operation auth.logout`, when the feature skeleton already exists, `scaffold feature` is gracefully skipped and `scaffold data` appends the new endpoint and datasource method.
3. Given `--dry-run`, previews both feature skeleton and data layer file operations without writing to disk.
4. Given missing required `--feature` or `--operation`, halts with exit code 2 and helpful usage.

## Acceptance Criteria

1. `mobilekit scaffold all --help` displays comprehensive usage and options.
2. `mobilekit scaffold all --feature <name> --operation <id>` performs end-to-end scaffolding.
3. Automated unit tests in `packages/mobile_core_kit_cli/test/scaffold_all_workflow_test.dart` pass.
4. `dart run mobile_core_kit_cli:mobilekit verify --profile full --env dev` passes.

## Implementation Checklist

- [x] **Phase 1: Workflow Implementation**
  - [x] Implement `packages/mobile_core_kit_cli/lib/src/workflows/scaffold_all_workflow.dart`.
  - [x] Coordinate `ScaffoldWorkflow` and `ScaffoldDataWorkflow`.
- [x] **Phase 2: CLI Routing & Help**
  - [x] Wire `scaffold all` in `packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart`.
  - [x] Update help text and command usage.
- [x] **Phase 3: Unit Test Suite**
  - [x] Create `packages/mobile_core_kit_cli/test/scaffold_all_workflow_test.dart`.
  - [x] Cover end-to-end generation, pre-existing feature handling, dry-run, and validation.
- [x] **Phase 4: Harness Verification**
  - [x] Run unit tests: `dart test packages/mobile_core_kit_cli/test/scaffold_all_workflow_test.dart`.
  - [x] Run full test suite: `dart test packages/mobile_core_kit_cli`.
  - [x] Run `mobilekit lint`.
  - [x] Run `mobilekit task verify --task scaffold-all-command --env dev`.

## Decision Log

- 2026-09-24: Implement dedicated `scaffold all` subcommand combining feature structure and OpenAPI data layer generation into a unified workflow.

## Verification

```bash
dart test packages/mobile_core_kit_cli/test/scaffold_all_workflow_test.dart
dart test packages/mobile_core_kit_cli
dart run mobile_core_kit_cli:mobilekit lint
dart run mobile_core_kit_cli:mobilekit task verify --task scaffold-all-command --env dev
```

## Runtime Evidence

Tooling only; verified via automated unit and package tests.

## Rollback

Revert added `scaffold_all_workflow.dart` and CLI routing changes with git.

## Risks And Mitigations

- **Risk:** Existing feature files overwritten unintentionally.
  - **Mitigation:** Check if feature directory exists; if present, do not re-scaffold skeleton, and enforce `--force` on data layer files.

## Completion Notes

Implemented `mobilekit scaffold all --feature <name> --operation <id> [options]` in `mobile_core_kit_cli`. Tested with unit and integration tests in `scaffold_all_workflow_test.dart` (7 tests). Successfully executed full verification (`mobilekit task verify --task scaffold-all-command --env dev`), passing all 672 test suite cases.

## Follow-ups

- None.
