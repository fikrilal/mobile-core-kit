# Customize iOS Identity and Packaging

Date: 2026-08-01
Owner: Dante
Status: active
Risk class: high
Related issue/PR: [template initialization and customization proposal](../../../_WIP/2026-08-01_mobilekit_template_initialization_customization_proposal.md)

## Objective

Add the iOS-specific transformation adapter to the shared customization engine.

The outcome must update the application bundle ID, derive a safe test bundle ID,
update the display name, and preserve the existing Xcode project/target names and
native structure.

## Constraints

- architectural constraints:
  - Use the shared planner, conflict detection, and transactional apply path.
  - Keep target-aware Xcode configuration handling inside the iOS transformation
    boundary.
  - Treat generated Firebase options and native configuration as external
    integration outputs.
- product/runtime constraints:
  - Update the application target and test target independently.
  - Preserve Runner project/target names in v1.
  - Do not configure signing, Firebase, or deep-link hosts in this plan.
  - Do not assume Linux can build iOS; use macOS CI or a macOS runtime host for
    native build evidence.
- out of scope:
  - Android changes.
  - Deep-link mode/host changes.
  - Firebase project configuration.
  - Xcode target/project renaming and signing setup.

## Acceptance Criteria

1. The requested iOS application bundle ID is applied to every relevant
   application build configuration.
2. The test target receives the documented derived test bundle ID and does not
   collide with the application bundle ID.
3. CFBundleDisplayName and CFBundleName reflect the product display name.
4. The transformation preserves Runner project/target names, build phases,
   signing settings, and unrelated Xcode configuration.
5. The transformation is dry-run safe, conflict-aware, transactional, and
   idempotent.
6. Fixture tests distinguish application and test target settings and prevent a
   blind replacement of every PRODUCT_BUNDLE_IDENTIFIER.
7. A macOS debug/no-code-sign build or equivalent CI validation succeeds after
   customization.

## Implementation Checklist

- [ ] Add target-aware parsing/anchoring for the Runner and RunnerTests build
  configurations.
- [ ] Define and validate the test bundle ID derivation policy.
- [ ] Update application and test PRODUCT_BUNDLE_IDENTIFIER settings without
  renaming Xcode targets.
- [ ] Update Info.plist display/name values through the branding input.
- [ ] Preserve entitlements, signing settings, build phases, and target names.
- [ ] Add fixture tests for multiple build configurations, conflict detection,
  rollback, and idempotency.
- [ ] Connect the adapter to the shared transformation registry.
- [ ] Add macOS build validation to the end-to-end evidence checklist.

## Decision Log

- 2026-08-01: Do not rename Runner in v1 -> bundle/display identity is
  sufficient for template customization, while target renaming is a separate
  native migration.
- 2026-08-01: Use a distinct test bundle ID -> replacing all Xcode identifiers
  with the application ID is unsafe for test packaging.
- 2026-08-01: Do not prompt for API/OIDC values or Firebase credentials -> iOS
  identity setup must remain independent from runtime service setup.

## Verification

Run after implementation:

~~~bash
(cd packages/mobile_core_kit_cli && dart test)
fvm flutter analyze
dart run custom_lint
~~~

On macOS:

~~~bash
fvm flutter build ios --debug --no-codesign -t lib/main_dev.dart --dart-define=ENV=dev
xcodebuild -list -project ios/Runner.xcodeproj
~~~

Expected outcome: application/test bundle IDs are target-correct and the
no-code-sign build succeeds on a macOS host.

Additional targeted checks:

~~~bash
dart run mobile_core_kit_cli:mobilekit verify --env dev --skip-tests
git diff --check
~~~

On Linux, record the macOS build as pending rather than claiming it passed.

## Runtime Evidence

Required because this changes iOS bundle identity and packaged output.

- Device/emulator: iOS simulator or test device on macOS
- Flavor: Debug/dev configuration
- Executed target(s): Install and launch the customized app; run the existing
  smoke path and confirm the generated bundle identity.
- Artifact path(s): No-code-sign build output and runtime evidence report.
- Notes: Confirm that the application launches, the test target remains
  installable, and Runner remains the native target name.

## Risks And Mitigations

- Risk: The test bundle ID is changed incorrectly and breaks XCTest packaging.
  Mitigation: test target-aware configuration parsing and validate app/test
  bundle uniqueness.
- Risk: Text anchoring corrupts project.pbxproj.
  Mitigation: constrain edits to known build-setting blocks, use fixture
  snapshots, and require macOS build validation.
- Risk: iOS evidence cannot be collected on the development host.
  Mitigation: make macOS CI/simulator evidence an explicit acceptance gate.

## Completion Notes

Pending implementation.

## Follow-ups

- [ ] Add unresolved debt to docs/exec-plans/tech_debt_tracker.md for any
  iOS project-format limitation.
