# Fix Scaffold Feature Boilerplate Templates

**Plan version:** 2
**Task ID:** fix-scaffold-feature-templates
**Status:** completed
**Owner:** Antigravity
**Risk:** low
**Authority:** Update mobilekit scaffold templates and CLI instructions in packages/mobile_core_kit_cli to align with current design system barrels, DI registrars, and add verification test coverage asserting scaffolded code compiles cleanly.
**Allowed paths:** docs/exec-plans/active/2026-09-23_fix-scaffold-feature-templates.md, docs/exec-plans/completed/2026-09-23_fix-scaffold-feature-templates.md, packages/mobile_core_kit_cli/lib/src/workflows/scaffold_workflow.dart, packages/mobile_core_kit_cli/test/scaffold_duplication_test.dart, packages/mobile_core_kit_cli/test/scaffold_workflow_test.dart, lib/features/scaffold_test/, lib/navigation/scaffold_test/, test/features/scaffold_test/
**Allowed actions:** edit, verify
**Maximum risk:** low
**Repair limit:** 2
**Task timeout:** 60m
**Oracle IDs:** harness.full

Date: 2026-09-23
Related issue/PR: N/A

## Objective

Modernize `mobilekit scaffold feature` code generation so that newly scaffolded features compile cleanly without broken imports, respect existing design system barrels, provide correct DI registration instructions in `feature_modules_registrar.dart`, and are verified by mechanical tests.

## Constraints

- Architecture constraints:
  - Do not introduce cross-layer or disallowed imports in scaffolded templates.
  - Comply with `lint/architecture_lints.yaml` (especially `feature_di_only_composed_from_core_di`).
- Out of scope:
  - Rewriting existing features (`auth`, `account`, `merchant_onboarding`).
  - Introducing unnecessary dependencies or broad changes outside `packages/mobile_core_kit_cli`.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: no
- External systems: no

## Barrel Architecture Clarification

- **Subsystem barrels already available**:
  - `package:mobile_core_kit/core/design_system/adaptive/adaptive.dart` exports both `SurfaceKind` (`tokens/surface_tokens.dart`) and `AppPageContainer` (`widgets/app_page_container.dart`).
  - `package:mobile_core_kit/core/design_system/widgets/button/button.dart` exports `AppButton`.
  - `package:mobile_core_kit/core/design_system/widgets/loading/loading.dart` exports `AppDotWave`.
- **Barrel status**:
  - There is currently no umbrella `design_system.dart` barrel. Consolidating the page stub imports into the existing subsystem barrels (`adaptive/adaptive.dart`, `widgets/button/button.dart`, `widgets/loading/loading.dart`) reduces redundant subpath imports while honoring the repository's modular barrel conventions.
  - Localization (`l10n.dart`) resides under `package:mobile_core_kit/core/presentation/localization/l10n.dart` (Presentation layer, not design system).

## Acceptance Scenarios

1. Given a developer running `mobilekit scaffold feature <name>`, when the files are generated, then all import statements in the page, cubit, DI, repository, and routes point to valid existing files in the current repository.
2. Given a newly scaffolded feature, when `dart analyze` or `mobilekit lint` runs on the generated files, then zero compilation errors or architecture lint violations are reported.
3. Given the CLI guidance output after scaffolding, then next steps direct the developer to register the module in `lib/core/di/registrars/feature_modules_registrar.dart` instead of `lib/core/di/service_locator.dart`.

## Acceptance Criteria

1. `scaffold_workflow.dart` replaces all outdated `core/adaptive/`, `core/theme/`, `core/widgets/`, and `core/localization/` paths with the correct paths and subsystem barrels (`core/design_system/adaptive/adaptive.dart`, `core/design_system/widgets/button/button.dart`, `core/design_system/widgets/loading/loading.dart`, `core/design_system/theme/tokens/spacing.dart`, `core/design_system/theme/typography/components/text.dart`, `core/presentation/localization/l10n.dart`).
2. Post-scaffolding console output references `lib/core/di/registrars/feature_modules_registrar.dart`.
3. An automated test in `packages/mobile_core_kit_cli/test/` verifies that scaffolded files pass validation and do not produce unresolved imports.
4. `dart test packages/mobile_core_kit_cli` and `dart run mobile_core_kit_cli:mobilekit knowledge verify` pass.

## Implementation Checklist

- [x] Update `_pageStub` in `packages/mobile_core_kit_cli/lib/src/workflows/scaffold_workflow.dart` to use `core/design_system/adaptive/adaptive.dart`, `core/design_system/widgets/button/button.dart`, `core/design_system/widgets/loading/loading.dart`, and correct design system / presentation paths.
- [x] Update `scaffold_workflow.dart` next-steps output to instruct adding the module to `lib/core/di/registrars/feature_modules_registrar.dart`.
- [x] Add or update tests in `packages/mobile_core_kit_cli/test/` to assert that all imported URIs generated by `scaffold` exist in `lib/`.
- [x] Test scaffolding a temporary feature, run analyzer/lint, and verify clean status.
- [x] Run test suite and `mobilekit knowledge verify`.

## Decision Log

- 2026-09-23: Use existing subsystem barrels (`adaptive/adaptive.dart`, `widgets/button/button.dart`, `widgets/loading/loading.dart`) rather than introducing an umbrella barrel, maintaining consistency with repository layer rules.

## Verification

```bash
dart test packages/mobile_core_kit_cli/test/scaffold_duplication_test.dart
dart run mobile_core_kit_cli:mobilekit knowledge verify
```

## Runtime Evidence

Unnecessary: changes are strictly confined to CLI code generation templates and CLI unit tests. No mobile runtime behavior is altered.

## Rollback

Revert modifications to `packages/mobile_core_kit_cli/lib/src/workflows/scaffold_workflow.dart` and any test additions via `git checkout`.

## Risks And Mitigations

- Risk: Scaffolded template changes drift again in future refactors.
- Mitigation: Add a test in `packages/mobile_core_kit_cli/test/` that parses imports from scaffold stubs and asserts their presence in `lib/`.

## Completion Notes

All acceptance criteria met. Updated scaffolded templates in `packages/mobile_core_kit_cli/lib/src/workflows/scaffold_workflow.dart` to use modern design system subsystem barrels (`adaptive/adaptive.dart`, `widgets/button/button.dart`, `widgets/loading/loading.dart`), fixed `AppDotWave` required `color` parameter, converted route variable to lowerCamelCase, updated DI registration instructions to `feature_modules_registrar.dart`, and enhanced generated tests to use `bloc_test`. Added automated CLI unit tests in `scaffold_duplication_test.dart`.

## Follow-ups

- None.
