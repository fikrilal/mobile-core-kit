# Customize Android Identity and Packaging

Date: 2026-08-01
Owner: Dante
Status: active
Risk class: high
Related issue/PR: [template initialization and customization proposal](../../../_WIP/2026-08-01_mobilekit_template_initialization_customization_proposal.md)

## Objective

Add the Android-specific transformation adapter to the shared customization
engine.

The outcome must update the Android namespace, application ID, flavor-derived
IDs, Kotlin package declaration/path, and product label while preserving the
existing flavor and signing behavior.

## Constraints

- architectural constraints:
  - Use the shared planner, conflict detection, and transactional apply path.
  - Keep Android-specific parsing and validation inside an Android transformation
    boundary.
  - The Android namespace and application ID are separate inputs.
- product/runtime constraints:
  - Preserve dev, staging, and prod flavor names and current suffix policy
    unless the user explicitly changes suffixes.
  - Do not change signing configuration, release behavior, Firebase project
    selection, or deep-link policy in this plan.
  - The source package directory move must match the Kotlin package declaration.
- out of scope:
  - iOS changes.
  - Deep-link host/mode changes.
  - Firebase configuration generation.
  - App icon generation or native target renaming.

## Acceptance Criteria

1. The requested Android namespace is written to Gradle and matches the moved
   Kotlin source package declaration and directory path.
2. The requested base application ID is valid and flavor IDs resolve to the
   expected .dev, .staging, and production values.
3. The Android application label is updated from the product display name.
4. The transformation does not alter release signing, flavor names, version
   suffix policy, or unrelated Gradle configuration.
5. The plan detects package-path collisions and refuses to overwrite an existing
   user-owned source file.
6. Android fixture tests prove apply, dry-run, conflict, rollback, and
   idempotency behavior.
7. A debug dev APK can be built from a customized fixture, and its package
   identity matches the manifest.

## Implementation Checklist

- [ ] Add Android namespace/application-ID validators and flavor derivation.
- [ ] Add target-aware Gradle transformations for namespace,
  defaultConfig.applicationId, and flavor suffixes.
- [ ] Move the Kotlin package path and update its package declaration
  transactionally.
- [ ] Update the Android manifest product label through the branding input.
- [ ] Preserve Firebase plugin declarations, signing configuration, and
  existing flavor behavior.
- [ ] Add fixture tests that inspect Gradle, manifest, and Kotlin outputs.
- [ ] Add a debug APK identity assertion using the Android build tooling.
- [ ] Connect the adapter to the shared transformation registry.

## Decision Log

- 2026-08-01: Ask for namespace and application ID separately -> the current
  repository already has different values, and conflating them causes invalid
  Android package structure.
- 2026-08-01: Preserve flavor suffixes by default -> environment identity is
  part of the existing build contract.
- 2026-08-01: Keep signing and Firebase setup outside this adapter -> those
  require external credentials or service state.

## Verification

Run after implementation:

~~~bash
(cd packages/mobile_core_kit_cli && dart test)
fvm flutter analyze
dart run custom_lint
fvm flutter build apk --debug --flavor dev -t lib/main_dev.dart --dart-define=ENV=dev
~~~

Expected outcome: the CLI/platform fixture tests pass and the customized dev APK
build completes with the requested namespace/application ID.

Additional targeted checks:

~~~bash
dart run mobile_core_kit_cli:mobilekit verify --env dev --skip-tests
git diff --check
~~~

If local environment values are unavailable, use a fixture project with valid
test inputs and record the missing environment setup as a blocker rather than
writing placeholder runtime values.

## Runtime Evidence

Required because this changes package identity and installable Android output.

- Device/emulator: Android emulator or test device
- Flavor: dev
- Executed target(s): Install and launch the customized debug APK; inspect the
  installed package and application label.
- Artifact path(s): Customized debug APK and any mobilekit evidence report.
- Notes: Confirm that the installed package uses the expected base ID plus
  .dev, and that the launchable activity resolves after the Kotlin path move.

## Risks And Mitigations

- Risk: Namespace and source path diverge, producing a compile failure.
  Mitigation: derive the path from the normalized namespace and assert the
  declaration/path relationship in tests.
- Risk: Application ID suffixes drift from CI flavor commands.
  Mitigation: preserve current suffix defaults and test all three resolved IDs.
- Risk: A broad Gradle rewrite changes signing or Firebase behavior.
  Mitigation: anchor changes to named settings and add snapshot assertions for
  unrelated sections.
- Risk: A source move overwrites a user-owned file.
  Mitigation: detect destination collisions before any write and require an
  explicit conflict resolution path.

## Completion Notes

Pending implementation.

## Follow-ups

- [ ] Add unresolved debt to docs/exec-plans/tech_debt_tracker.md for any
  Android-specific Gradle or package-path limitation.
