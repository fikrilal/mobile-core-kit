# Scaffold OpenAPI-Driven Data Layer

**Plan version:** 2
**Task ID:** scaffold-openapi-data-layer
**Status:** completed
**Owner:** Antigravity
**Risk:** high
**Authority:** Implement `mobilekit scaffold data` in `mobile_core_kit_cli` to parse OpenAPI endpoints, generate Freezed DTO request/response models, manage core endpoint constants, generate remote datasource methods, and trigger targeted build_runner codegen.
**Allowed paths:** docs/exec-plans/active/2026-09-24_scaffold-openapi-data-layer.md, docs/exec-plans/completed/2026-09-24_scaffold-openapi-data-layer.md, packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart, packages/mobile_core_kit_cli/lib/src/contracts/openapi_schema_resolver.dart, packages/mobile_core_kit_cli/lib/src/workflows/scaffold_data_workflow.dart, packages/mobile_core_kit_cli/test/scaffold_data_workflow_test.dart, lib/core/infra/network/endpoints/, lib/features/
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 60m
**Oracle IDs:** harness.full, contract.openapi.snapshot

Date: 2026-09-24
Related issue/PR: N/A

## Objective

Build `mobilekit scaffold data` subcommand in `mobile_core_kit_cli` that reads [`docs/contracts/openapi/backend.openapi.yaml`](file:///home/fikrilal/devs/core/mobile-core-kit/docs/contracts/openapi/backend.openapi.yaml) and scaffolds:
1. **Remote Request DTO**: `@freezed` model with `@JsonSerializable` in `lib/features/<feature>/data/model/remote/<operation>_request_model.dart`.
2. **Remote Response DTO**: `@freezed` model with `@JsonSerializable` in `lib/features/<feature>/data/model/remote/<operation>_response_model.dart`.
3. **Core Endpoint Constant**: In `lib/core/infra/network/endpoints/<feature>_endpoint.dart` with `/v1` prefix stripped.
4. **Remote DataSource Method**: `ApiHelper` call in `lib/features/<feature>/data/datasource/remote/<feature>_remote_datasource.dart`.
5. **Targeted Codegen**: Invokes `dart run build_runner build --build-filter="lib/features/<feature>/data/model/remote/**"` unless `--no-codegen` or `--dry-run` is passed.

## Constraints

- Architecture constraints:
  - Generation is strictly confined to the Data layer and Core endpoint classes.
  - Domain layer (`domain/**`) must never be modified or touched by this generator.
  - Local authority only: Reads local pinned OpenAPI snapshot; zero network requests.
  - Safe by default: Refuses to overwrite existing files unless `--force` is specified.
- Product/runtime constraints:
  - Models must conform to `flutter_lints` and `build_runner` code generation conventions.
  - String enums generate discrete Dart `enum`s with `@JsonValue`.
- Out of scope:
  - Auto-generating domain entities, value objects, use cases, or error mappers.
  - Complex polymorphism (`oneOf`, `anyOf`) or recursive schema hierarchies.

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

1. Given a valid `operationId` in `backend.openapi.yaml`, running `mobilekit scaffold data --feature <name> --operation <id>` generates request and response Freezed models, registers endpoint constant, and appends datasource method.
2. Given existing model files, running without `--force` halts with an error explaining files already exist.
3. Given an existing `<feature>_endpoint.dart` and `<feature>_remote_datasource.dart`, running scaffold appends the new constant and method without overwriting existing code.
4. Given `--dry-run`, the CLI reports planned file operations without writing to disk.
5. Given `--no-codegen`, file generation succeeds but skips executing `build_runner`.
6. Given standard execution, targeted `build_runner` runs and generates `*.freezed.dart` and `*.g.dart` without errors.

## Acceptance Criteria

1. `mobilekit scaffold data` parses `--feature`, `--operation`, `--dry-run`, `--force`, and `--no-codegen`.
2. OpenAPI schemas resolve direct and referenced (`#/components/schemas/*`) request bodies and 200/201 responses.
3. Core endpoint constants are generated/appended with `/v1` prefix stripped.
4. String enums produce type-safe Dart enums with `@JsonValue`.
5. Targeted `build_runner` generates compilable parts.
6. Automated unit tests in `packages/mobile_core_kit_cli/test/scaffold_data_workflow_test.dart` pass.
7. `dart run mobile_core_kit_cli:mobilekit verify --profile full --env dev` passes.

## Implementation Checklist

- [x] **Phase 1: OpenAPI Schema Resolver**
  - [x] Implement `packages/mobile_core_kit_cli/lib/src/contracts/openapi_schema_resolver.dart` to parse operation IDs, extract paths/methods, resolve `$ref` in `components.schemas`, and map types to Dart/Freezed representations.
- [x] **Phase 2: Scaffold Data Workflow**
  - [x] Implement `packages/mobile_core_kit_cli/lib/src/workflows/scaffold_data_workflow.dart`.
  - [x] Implement Request & Response Freezed DTO code generators.
  - [x] Implement Core Endpoint constant generator & file merger.
  - [x] Implement DataSource method generator & file merger.
  - [x] Implement targeted `build_runner` runner with `--build-filter`.
- [x] **Phase 3: CLI Registration**
  - [x] Wire `scaffold data` into `packages/mobile_core_kit_cli/lib/src/cli/mobilekit_cli.dart`.
  - [x] Update help text and command usage.
- [x] **Phase 4: Unit Test Coverage**
  - [x] Add tests in `packages/mobile_core_kit_cli/test/scaffold_data_workflow_test.dart` covering schema resolution, collision detection, dry-run, and code outputs.
- [x] **Phase 5: Verification & Dogfooding**
  - [x] Run automated tests: `dart test packages/mobile_core_kit_cli`.
  - [x] Run full repo verification: `dart run mobile_core_kit_cli:mobilekit verify --profile full --env dev`.

## Decision Log

- 2026-09-24: Confine generation strictly to Data layer DTOs and Core endpoint classes to protect Clean Architecture domain integrity.
- 2026-09-24: Use core endpoint classes in `lib/core/infra/network/endpoints/` and strip `/v1` prefix per repo convention.
- 2026-09-24: Run targeted `build_runner` using `--build-filter` by default for fast AST builds, providing `--no-codegen` for batching.

## Verification

```bash
dart test packages/mobile_core_kit_cli/test/scaffold_data_workflow_test.dart
dart test packages/mobile_core_kit_cli
dart run mobile_core_kit_cli:mobilekit lint
```

## Runtime Evidence

Runtime device evidence is not required because this change is developer tooling within `packages/mobile_core_kit_cli` and does not alter mobile runtime or platform lifecycle code. Code checks and automated tests provide complete verification.

## Rollback

Revert added workflow files and CLI routing changes with git. No shared state or database migrations are involved.

## Risks And Mitigations

- **Risk:** Complex schema unions (`oneOf`/`anyOf`) break model generation.
  - **Mitigation:** Fall back to `Map<String, dynamic>` for unsupported union schemas with a clear `TODO` note.
- **Risk:** Accidental overwrite of existing feature DTOs.
  - **Mitigation:** Default to fail-if-exists; require explicit `--force` flag.

## Completion Notes

Implemented `mobilekit scaffold data` subcommand in `mobile_core_kit_cli`. Resolves operation specs from `backend.openapi.yaml`, generates Freezed DTOs, updates core endpoint constants, creates remote datasource methods, and triggers targeted build_runner. Verified with 11 targeted unit tests and full package test suite (246 tests passing) and custom lint checks.

## Follow-ups

- None.
