---
status: accepted
date: 2026-06-06
decision-makers: Dante, Codex
consulted: OpenAI Harness Engineering guidance, official Maestro documentation
informed: future maintainers and downstream template adopters
scope: template
tags: [testing, runtime-evidence, maestro, accessibility, ci]
tracking: docs/exec-plans/active/2026-06-06_maestro-runtime-harness-phases-1-2.md
---

# Use Maestro for Black-Box Mobile Runtime Evidence

## Context and Problem Statement

The repository has strong static checks, lower-level tests, and Flutter
`integration_test` coverage, but it does not have a durable black-box lane that
proves critical user journeys against a compiled application through the
platform accessibility tree. We need device-level evidence without duplicating
all existing tests or making device availability part of the canonical static
verification gate.

## Decision Drivers

* Prove critical user journeys against the compiled mobile application.
* Produce reviewable screenshots, command traces, logs, and JUnit output.
* Preserve fast deterministic verification in `tool/verify.dart`.
* Use accessibility-correct Flutter semantics instead of widget internals.
* Keep local execution available without requiring a cloud vendor.
* Isolate flows from shared device and backend state.
* Roll out incrementally and measure reliability before creating a merge gate.

## Considered Options

* Keep only Flutter `integration_test` coverage.
* Adopt Maestro Cloud as the initial runtime execution path.
* Adopt the Maestro CLI as a complementary black-box runtime evidence lane.

## Decision Outcome

Chosen option: "Adopt the Maestro CLI as a complementary black-box runtime
evidence lane", because it closes the compiled-app and platform-interaction gap
while preserving the existing test pyramid and an open local execution path.

The decision includes these contracts:

* Maestro complements rather than replaces unit, Bloc/Cubit, widget, golden,
  repository, and Flutter integration tests.
* Maestro does not run from `tool/verify.dart`; it runs through the risk-based
  mobile runtime evidence workflow.
* Top-level Maestro flows represent critical user journeys, not individual
  features or screens.
* Every top-level flow establishes its own initial state and can run from a
  reset device without relying on a previous flow.
* Flutter selectors prefer visible text when wording is part of the behavior,
  then stable `Semantics.identifier` values for localized, duplicated,
  dynamic, or icon-only controls.
* Semantic identifiers use lowercase snake case in the form
  `<feature>_<screen>_<element>[_<action>]`.
* Coordinates, fixed sleeps, broad retries, and execution-order dependencies
  are prohibited in the initial suite.
* Backend-dependent flows remain outside the smoke gate until resettable,
  non-production fixture contracts exist.
* Android is implemented first. The reproducible baseline is a Pixel 8
  emulator using Android API 34, Google APIs, and x86_64.
* The available Android API 36 physical device is secondary exploratory
  evidence, not the sole compatibility baseline.
* The initial pinned Maestro CLI version is `2.6.0`. Version upgrades are
  focused changes that require release-note review and repeated smoke runs.
* Initial CI uses the open Maestro CLI on a hosted Android emulator runner.
  Maestro Cloud requires a separate cost, security, retention, and vendor
  decision.
* The first pilot journey is the backend-independent startup/onboarding path to
  sign-in.

### Consequences

* Good, because runtime-sensitive PRs can include machine-readable compiled-app
  evidence.
* Good, because accessibility reachability becomes an explicit application
  contract.
* Good, because local and CI execution can share one pinned CLI and workspace.
* Good, because the suite can grow by critical journey rather than by screen.
* Neutral, because some design-system APIs will gain semantic identifier
  parameters when a journey needs them.
* Neutral, because device tests remain slower and less deterministic than
  lower-level tests and therefore require a separate lane.
* Bad, because the repository gains another toolchain requiring Java, a device,
  version management, and artifact maintenance.
* Bad, because backend-dependent journeys cannot be reliable until fixture
  ownership is established.

### Confirmation

Confirm this decision through:

* an isolated `.maestro/` workspace with top-level flows and reusable subflows;
* semantics widget tests for each design-system primitive extended with an
  identifier;
* a pinned Maestro CLI version checked by the evidence runner;
* a clean-state startup-to-sign-in pilot with no coordinates, fixed sleeps, or
  broad retries;
* JUnit, screenshot, command, Maestro, and device-log artifacts under
  `_artifacts/mobile/`;
* ten consecutive successful local pilot runs plus one intentional assertion
  failure with actionable artifacts;
* measured CI reliability before making Maestro a required PR check.

## Pros and Cons of the Options

### Keep only Flutter `integration_test` coverage

Continue expanding in-process integration tests with controlled dependencies.

* Good, because the repository already has the dependency and patterns.
* Good, because tests can use deterministic fakes and direct Dart assertions.
* Bad, because this does not prove the installed compiled app through the
  operating-system accessibility tree.
* Bad, because platform dialogs and external deep-link entry are harder to
  validate as user journeys.

### Adopt Maestro Cloud as the initial runtime execution path

Build app artifacts and upload them with the flow workspace to Maestro Cloud.

* Good, because cloud devices and parallel execution reduce local device
  orchestration work.
* Good, because cloud dashboards can simplify result inspection.
* Bad, because it adds cost, secret management, retention, and vendor decisions
  before the suite has proved its value.
* Bad, because starting in the cloud makes local reproduction and harness
  ownership less direct.

### Adopt the Maestro CLI as a complementary black-box runtime evidence lane

Run versioned YAML flows against local or CI devices and retain standard
artifacts in the existing mobile evidence tree.

* Good, because it directly tests compiled application behavior.
* Good, because it is locally reproducible and cloud-optional.
* Good, because it integrates with the existing risk-based evidence model.
* Neutral, because agents must inspect the rendered accessibility tree after UI
  implementation before finalizing selectors.
* Bad, because emulator/device lifecycle and fixture reliability remain repo
  responsibilities.

## More Information

Implementation system of record:

* `docs/exec-plans/active/2026-06-06_maestro-runtime-harness-phases-1-2.md`

Approved engineering proposal:

* `docs/_WIP/2026-06-06_maestro_runtime_harness_engineering_proposal.md`

Official references reviewed on 2026-06-06:

* https://docs.maestro.dev/get-started/supported-platform/flutter
* https://docs.maestro.dev/maestro-flows/flow-control-and-logic/how-to-use-selectors
* https://docs.maestro.dev/maestro-flows/flow-control-and-logic/wait-commands
* https://docs.maestro.dev/maestro-flows/workspace-management/design-your-test-architecture
* https://docs.maestro.dev/maestro-flows/workspace-management/test-reports-and-artifacts
* https://github.com/mobile-dev-inc/maestro/releases/tag/cli-2.6.0
