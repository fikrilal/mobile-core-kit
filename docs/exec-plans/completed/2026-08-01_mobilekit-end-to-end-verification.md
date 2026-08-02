# Harden and Verify Mobilekit Template Initialization End to End

Date: 2026-08-01
Owner: Dante
Status: completed
Risk class: high
Related issue/PR: [template initialization and customization proposal](../../../_WIP/2026-08-01_mobilekit_template_initialization_customization_proposal.md)

## Objective

Connect the completed customization adapters to the existing generation and
verification workflows, add residual-default diagnostics, document the supported
bootstrap, and prove the result on a representative customized copy.

This is the release gate for the full mobilekit init/customize lifecycle.

## Constraints

- architectural constraints:
  - Reuse existing mobilekit workflows for pub get, localization, config,
    code generation, lint, duplication, and verification.
  - Keep the manifest and transformation registry as the ownership boundary.
  - Do not add a second legacy shell/tool entry point.
- product/runtime constraints:
  - init must not claim production readiness while demo Firebase state,
    placeholder environment values, or unresolved package/platform defaults
    remain.
  - Do not prompt for API endpoints or OIDC client IDs.
  - Android and iOS runtime evidence must use a controlled fixture or a
    clearly documented test configuration, never real credentials in Git.
  - External setup steps must be visible and actionable.
- out of scope:
  - New application features.
  - Firebase project creation, signing setup, CI secret provisioning, or store
    submission.
  - Renaming the Xcode Runner target, Git remotes, directories, or hosting
    repositories.

## Acceptance Criteria

1. A clean copy of the template can be initialized through the documented
   bootstrap, before or after git init.
2. Interactive and non-interactive initialization produce equivalent normalized
   manifests and transformation plans.
3. A non-interactive fixture run updates package, branding, Android, iOS,
   deep-link, and selected documentation surfaces without stale blocking
   defaults.
4. A dry run leaves the fixture unchanged; a second apply is idempotent; a
   failure leaves no partially customized identity.
5. mobilekit doctor classifies remaining defaults as blocking, review-required,
   or intentionally historical.
6. Existing generation workflows run only when their inputs are valid, and
   generated outputs are refreshed through their owners.
7. The command reference, README/template setup guidance, and rename/rebrand
   documentation describe the new lifecycle and the external setup boundary.
8. The complete verification pipeline passes, including analyze, custom lints,
   tests, duplication checks, and mobilekit verify --env dev.
9. Android and iOS debug/dev runtime evidence confirms the customized package
   identities, display name, deep-link policy, and startup behavior.

## Implementation Checklist

- [x] Add the residual-default scanner to mobilekit doctor, including known
  template names, old package/import values, old IDs, old host, demo Firebase
  identity, placeholder environment values, and categorized severity.
- [x] Connect init to dependency acquisition, localization generation,
  configuration generation, and code generation with clear skip/failure
  reporting.
- [x] Add a fixture-copy integration test that runs the non-interactive flow,
  inspects managed outputs, checks idempotency, and verifies dry-run behavior.
- [x] Add failure-injection coverage for transactional rollback and managed-file
  conflicts.
- [x] Update the command reference, root README, template guides, and
  first-use checklist to describe bootstrap, customization, environment
  ownership, Firebase modes, and external steps.
- [x] Verify CI remains pinned to the repository-local CLI command and does not
  depend on a globally activated executable.
- [x] Run the full static/test/duplication verification set.
- [x] Collect Android emulator/device evidence for the dev flavor.
- [ ] Collect iOS simulator/device and macOS build evidence; deferred to a
  macOS host.
- [x] Record limitations or unresolved follow-ups in the plan and debt tracker.

## Decision Log

- 2026-08-01: Use mobilekit doctor for residual defaults -> a future copy needs
  one searchable diagnostic rather than a manual grep checklist.
- 2026-08-01: Keep CI pinned to dart run mobile_core_kit_cli:mobilekit -> global
  activation is a human convenience, not a reproducibility dependency.
- 2026-08-01: Treat runtime evidence as a release gate -> package IDs, native
  metadata, deep links, and Firebase startup behavior cannot be proven fully
  by static analysis.

## Verification

Run after implementation:

~~~bash
fvm flutter analyze
dart run custom_lint
fvm flutter test
dart run mobile_core_kit_cli:mobilekit duplication check --profile core
dart run mobile_core_kit_cli:mobilekit verify --env dev
dart run mobile_core_kit_cli:mobilekit doctor
git diff --check
~~~

Expected outcome: all applicable checks pass, or any environment/platform
limitation is recorded explicitly in the plan rather than presented as passed.

Completed on 2026-08-01:

- `dart test` in `packages/mobile_core_kit_cli` — 83 tests passed.
- `fvm flutter analyze` — no issues.
- `dart run custom_lint` — no issues.
- `fvm flutter test` — 554 tests passed.
- `dart run mobile_core_kit_cli:mobilekit verify --env dev` — passed the
  complete verification pipeline, including duplication checks and formatting.
- `dart run mobile_core_kit_cli:mobilekit doctor` — passed on the repository.
- `mobilekit init --dry-run` with interactive fixture input — exited successfully
  and reported `Dry run: no files were changed.`
- `git diff --check` — passed.
- CI invocation audit — executable workflow calls remain pinned to
  `dart run mobile_core_kit_cli:mobilekit`.

Additional Android runtime evidence completed on 2026-08-02:

- Android dev APK build and launch passed on `Medium_Phone` / `emulator-5554`.
- Both integration targets passed on the emulator.
- Package, activity, version, label, startup screens, and explicit deep-link
  dispatch were recorded under `_artifacts/mobile/2026-08-02_android-dev/`.

Additional targeted checks:

~~~bash
dart run mobile_core_kit_cli:mobilekit init --config .mobilekit/project-input.yaml --dry-run
dart run mobile_core_kit_cli:mobilekit customize --dry-run
~~~

The worktree must remain unchanged after both dry-run commands.

## Runtime Evidence

Required for the final platform release gate; Android collected, iOS deferred.

- Android device/emulator: `Medium_Phone` / `emulator-5554`, Android 15 (API
  35).
- Android flavor: `dev`.
- Android executed targets: `integration_test/auth_happy_path_test.dart` and
  `integration_test/startup_deep_link_resume_test.dart`, both passed through
  `mobilekit runtime evidence`.
- Android application launch: built the real `lib/main_dev.dart` entrypoint,
  installed `app-dev-debug.apk`, and launched
  `dev.fikril.mobile.corekit.dev/com.example.mobile_core_kit.MainActivity`.
  The app reached the onboarding `Welcome` screen, continued to `Sign In`,
  and rendered the expected UI hierarchy.
- Android identity: package `dev.fikril.mobile.corekit.dev`, version
  `1.0.0-dev`, label `Mobile Core Kit`.
- Android deep link: an explicit dispatch of
  `https://links.fikril.dev/profile` to the app returned `Status: ok` and
  reached the app. An implicit Android App Link dispatch selected Chrome
  because domain verification for the placeholder host is not configured;
  `assetlinks.json` and production domain verification remain external setup.
- Android artifact paths: `_artifacts/mobile/2026-08-02_android-dev/summary.md`,
  `android_main_dev_startup.png`, `android_main_dev_after_onboarding.png`,
  and `android_main_dev_deep_link.png`.
- iOS: no macOS, Xcode, or iOS simulator environment is available on this
  Linux host; iOS evidence remains tracked in DEBT-002.
- Notes: Test Firebase/environment configuration was used. No credentials,
  native service files, or signing material were committed.

## Risks And Mitigations

- Risk: Individual adapters pass focused tests but the complete init flow
  produces inconsistent derived files.
  Mitigation: use a copied-fixture integration test and inspect the final
  manifest, generated outputs, native metadata, and residual report together.
- Risk: Full verification is blocked by missing local services or macOS
  tooling.
  Mitigation: separate code failures from environment limitations and collect
  required platform evidence in CI or on the appropriate host.
- Risk: Documentation promises more automation than the CLI provides.
  Mitigation: review every command example against the final help output and
  explicitly list external follow-up steps.
- Risk: A future template change invalidates the known-default scanner.
  Mitigation: version the marker/manifest and keep the scanner default catalog
  close to the template contract.

## Completion Notes

The end-to-end initialization lifecycle is implemented and covered by fixture,
unit, static-analysis, duplication, and full verification checks. `mobilekit
doctor` now reports residual defaults by blocking, review-required, and
historical severity; successful initialization refreshes only valid generation
inputs and reports skipped or failed post-apply workflows clearly.

The Android portion of the platform runtime gate is complete with emulator
evidence and stored artifacts. The iOS/macOS portion remains deferred and is
tracked by DEBT-002; it is not represented as passed here.

## Follow-ups

- [x] Add the remaining iOS/macOS runtime limitation to
  `docs/exec-plans/tech_debt_tracker.md` (DEBT-002).
