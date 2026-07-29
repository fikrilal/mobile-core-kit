# Harden and Verify Mobilekit Template Initialization End to End

Date: 2026-08-01
Owner: Dante
Status: active
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

- [ ] Add the residual-default scanner to mobilekit doctor, including known
  template names, old package/import values, old IDs, old host, demo Firebase
  identity, placeholder environment values, and categorized severity.
- [ ] Connect init to dependency acquisition, localization generation,
  configuration generation, and code generation with clear skip/failure
  reporting.
- [ ] Add a fixture-copy integration test that runs the non-interactive flow,
  inspects managed outputs, checks idempotency, and verifies dry-run behavior.
- [ ] Add failure-injection coverage for transactional rollback and managed-file
  conflicts.
- [ ] Update the command reference, root README, template guides, and
  first-use checklist to describe bootstrap, customization, environment
  ownership, Firebase modes, and external steps.
- [ ] Verify CI remains pinned to the repository-local CLI command and does not
  depend on a globally activated executable.
- [ ] Run the full static/test/duplication verification set.
- [ ] Collect Android emulator/device evidence for the dev flavor.
- [ ] Collect iOS simulator/device and macOS build evidence.
- [ ] Record limitations or unresolved follow-ups in the plan and debt tracker.

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

Additional targeted checks:

~~~bash
dart run mobile_core_kit_cli:mobilekit init --config .mobilekit/project-input.yaml --dry-run
dart run mobile_core_kit_cli:mobilekit customize --dry-run
~~~

The worktree must remain unchanged after both dry-run commands.

## Runtime Evidence

Required.

- Device/emulator: Android emulator/device and iOS simulator/device on macOS
- Flavor: Android dev; iOS debug/dev configuration
- Executed target(s): Launch the customized app, verify package/bundle identity,
  display name, startup path, and one enabled deep-link scenario when enabled;
  verify no deep-link claim when disabled.
- Artifact path(s): Build outputs and the repository runtime evidence report
  location defined by mobilekit runtime evidence.
- Notes: Use test Firebase/environment configuration only. Do not commit
  credentials, native service files, or signing material.

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

Pending implementation.

## Follow-ups

- [ ] Add unresolved debt to docs/exec-plans/tech_debt_tracker.md.
