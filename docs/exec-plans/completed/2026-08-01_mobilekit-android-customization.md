# Customize Android Identity and Packaging

Date: 2026-08-01
Owner: Dante
Status: completed
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

- [x] Add Android namespace/application-ID validators and flavor derivation.
- [x] Add target-aware Gradle transformations for namespace,
  defaultConfig.applicationId, and flavor suffixes.
- [x] Move the Kotlin package path and update its package declaration
  transactionally.
- [x] Update the Android manifest product label through the branding input.
- [x] Preserve Firebase plugin declarations, signing configuration, and
  existing flavor behavior.
- [x] Add fixture tests that inspect Gradle, manifest, and Kotlin outputs.
- [x] Add a debug APK identity assertion using the Android build tooling.
- [x] Connect the adapter to the shared transformation registry.

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
dart run mobile_core_kit_cli:mobilekit lint
dart run mobile_core_kit_cli:mobilekit verify --env dev --skip-tests
fvm flutter build apk --debug --flavor dev -t lib/main_dev.dart --dart-define=ENV=dev
~~~

Outcome: the CLI package suite passed 67 tests; the Android fixture suite
passed dry-run, apply, conflict, rollback, idempotency, package-path, label,
and flavor-ID assertions; Flutter analyze, custom lints, the CLI lint workflow,
and the repository verification gate passed. The customized dev APK built in an
isolated copy and its manifest application ID was `com.example.shopping.dev`.

The first isolated build attempt correctly stopped because the unchanged demo
`google-services.json` had no client for the new application ID. A temporary
matching Firebase client entry was used only in the isolated copy for the build
and was not added to the transformation or the repository.

Additional targeted checks:

~~~bash
dart run mobile_core_kit_cli:mobilekit verify --env dev --skip-tests
git diff --check
~~~

The Android fixture dry-run left its worktree unchanged. The repository diff
check passed. The customized APK was inspected with `apkanalyzer`, installed
on the `Medium_Phone` emulator, and launched successfully through
`com.example.shopping.MainActivity` under package `com.example.shopping.dev`.
No runtime credentials were written; Firebase reconfiguration remains an
external setup step.

## Runtime Evidence

Required because this changes package identity and installable Android output.

- Device/emulator: `Medium_Phone` emulator (`emulator-5554`)
- Flavor: dev
- Executed target(s): Installed and launched the customized debug APK; queried
  the installed package and resolved launch activity.
- Artifact path(s): `/tmp/tmp.lM4Qudjsip/build/app/outputs/flutter-apk/app-dev-debug.apk`
- Notes: Confirmed package `com.example.shopping.dev`, activity
  `com.example.shopping.MainActivity`, and version `1.0.0-dev` after the Kotlin
  path move.

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

Implemented the Android transformation boundary inside the shared transactional
engine. It updates only the named Gradle assignments, manifest label, and
Android source package paths; it preserves flavor names, version suffixes,
signing configuration, Firebase plugin declarations, and unrelated Gradle
content. File moves are represented as add/delete operations and use the same
fingerprint checks and rollback path as ordinary writes.

## Follow-ups

- [x] Firebase client registration and native service-file replacement remain
  explicit external setup; the adapter intentionally does not rewrite them.
