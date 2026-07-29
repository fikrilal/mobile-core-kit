# Integrate Deep-Link, Environment, and Firebase Customization Policies

Date: 2026-08-01
Owner: Dante
Status: active
Risk class: high
Related issue/PR: [template initialization and customization proposal](../../../_WIP/2026-08-01_mobilekit_template_initialization_customization_proposal.md)

## Objective

Make deep-link policy and Firebase state explicit parts of initialization while
keeping runtime environment setup and external service configuration outside the
identity wizard.

The outcome must let a project choose enabled deep links with a real HTTPS host
or an explicit disabled mode, update all local policy surfaces consistently, and
report Firebase/external setup without inventing credentials or cloud state.

## Constraints

- architectural constraints:
  - Reuse the shared transformation engine and existing environment/configuration
    workflows.
  - Keep runtime environment files as user-owned source-of-truth inputs.
  - Keep external Firebase configuration delegated to FlutterFire.
- product/runtime constraints:
  - Do not prompt for API endpoints or OIDC client IDs.
  - Do not overwrite existing ignored .env/*.yaml,
    google-services.json, or GoogleService-Info.plist.
  - enabled deep links require a valid HTTPS host; disabled must not leave native
    claims or a required placeholder host.
  - Firebase configuration modes are configure, keep-demo, and disabled.
- out of scope:
  - Android namespace/application ID changes.
  - iOS bundle ID or target renaming.
  - Creating Firebase projects, registering apps, obtaining credentials,
    signing, CI secrets, or store metadata.
  - Generating icons or changing unrelated backend settings.

## Acceptance Criteria

1. The environment schema and generated configuration support an explicit
   deep-link disabled mode without requiring links.fikril.dev or another
   placeholder host.
2. An enabled deep-link configuration updates the runtime allowed-host input,
   Android intent filters, iOS entitlements, parser fixtures, and selected
   documentation consistently.
3. A disabled configuration removes or disables platform deep-link claims and
   updates tests/docs so no stale default host is treated as active.
4. Initialization updates only example environment values controlled by identity
   choices and reports missing runtime endpoints/OIDC IDs as follow-up work.
5. Existing ignored environment and native Firebase files are preserved unless
   the user explicitly invokes an external configuration step.
6. Firebase mode is persisted and reported; keep-demo is visible as a
   production-readiness blocker, and configure offers an explicit
   flutterfire configure handoff.
7. No API keys, credentials, or signing material are accepted in tracked input,
   manifest, logs, or generated reports.
8. Focused tests cover enabled/disabled deep links, Firebase mode reporting, and
   protection of ignored files.

## Implementation Checklist

- [ ] Extend the environment/deep-link validation contract to represent enabled
  and disabled explicitly.
- [ ] Add deep-link transformations for env examples, generated config inputs,
  Android manifest filters, iOS entitlements, parser fixtures, and selected
  current docs.
- [ ] Ensure disabled mode is handled by runtime parsing without requiring a
  non-empty placeholder host.
- [ ] Add Firebase state detection for the demo project/options and the three
  manifest modes.
- [ ] Add explicit FlutterFire handoff/reporting without collecting credentials
  or silently invoking a cloud operation.
- [ ] Add protected-file checks for ignored environment and native Firebase
  files.
- [ ] Add focused unit/fixture tests and connect the integration adapter to
  init/customize.
- [ ] Define the final external-setup report categories for endpoints, OIDC,
  Firebase, signing, domains, CI secrets, and store metadata.

## Decision Log

- 2026-08-01: Deep links are optional -> future apps may not use universal/app
  links, so a disabled mode is safer than a fake host.
- 2026-08-01: Do not prompt for API endpoints or OIDC IDs -> environment
  configuration has separate ownership and may vary by deployment.
- 2026-08-01: Do not configure Firebase automatically -> project creation,
  registration, and credentials are external state.
- 2026-08-01: Treat demo Firebase state as explicit -> the tracked
  firebase_options.dart currently identifies the template demo project.

## Verification

Run after implementation:

~~~bash
(cd packages/mobile_core_kit_cli && dart test)
fvm flutter test test/core/runtime/navigation/deep_link_parser_test.dart test/core/runtime/navigation/pending_deep_link_controller_test.dart
dart run custom_lint
dart run mobile_core_kit_cli:mobilekit doctor
~~~

Additional targeted checks:

~~~bash
dart run mobile_core_kit_cli:mobilekit env verify
dart run mobile_core_kit_cli:mobilekit config generate --env dev
git diff --check
~~~

If local environment inputs are not configured, use fixture inputs and record
the real-project environment verification as pending. Do not create values to
make the check pass.

## Runtime Evidence

Deep-link runtime evidence is collected in the final end-to-end plan after the
Android and iOS adapters are integrated.

- Device/emulator: Deferred to final end-to-end verification
- Flavor: dev
- Executed target(s): Enabled-host and disabled-mode launch/link scenarios
- Artifact path(s): Final runtime evidence report
- Notes: This plan must provide the configuration and test seams required by
  the final device checks.

## Risks And Mitigations

- Risk: Disabled mode conflicts with the current non-empty-host schema.
  Mitigation: change the schema/parser contract deliberately and add both modes
  to fixture tests.
- Risk: Native and Dart deep-link policy drifts.
  Mitigation: produce one normalized policy and assert every managed surface
  from that policy.
- Risk: Demo Firebase configuration is mistaken for a real app configuration.
  Mitigation: detect the demo project/options and make production readiness
  fail or require explicit resolution.
- Risk: Ignored files containing user values are overwritten.
  Mitigation: treat them as protected user-owned files and require an explicit
  external configuration command.

## Completion Notes

Pending implementation.

## Follow-ups

- [ ] Add unresolved debt to docs/exec-plans/tech_debt_tracker.md for any
  environment-schema or Firebase handoff limitation.
