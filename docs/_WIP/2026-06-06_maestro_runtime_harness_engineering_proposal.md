# Maestro Runtime Harness Engineering Proposal

Date: 2026-06-06
Status: Approved for Phases 0-2; durable decision recorded in ADR 0011
Risk class: High
Scope: Mobile runtime evidence, Flutter accessibility semantics, local tooling, and CI
Related: `docs/_WIP/openai_harness_gap_analysis.md`

## 1. Decision Summary

Adopt Maestro as the black-box UI automation lane of the mobile runtime harness.

Maestro should complement, not replace:

- Dart unit, Bloc/Cubit, repository, and mapper tests
- Flutter widget and golden tests
- Flutter `integration_test` coverage for in-process orchestration
- static checks in `tool/verify.dart`
- human review for medium/high-risk behavior

The recommended target is:

```text
tool/verify.dart
  -> static and deterministic code verification

integration_test/
  -> in-process application orchestration and test doubles

.maestro/
  -> compiled-app, accessibility-driven user journeys

tool/agent/mobile_evidence_check.sh
  -> one runtime evidence entry point and one artifact summary
```

Roll out Android first. Add iOS only after the Android lane is stable and the
iOS flavor/bundle identifier strategy is explicit.

Do not put Maestro in `tool/verify.dart`. Maestro requires a device, an
installed build, platform configuration, and possibly backend fixtures. It
belongs in the risk-based runtime evidence lane.

## 2. Why This Proposal Exists

The repository has strong static guardrails but limited black-box evidence of
what a user can do in the compiled application. Current Flutter integration
tests construct application slices with fakes inside the Dart process. They are
valuable, but they do not prove all of the following together:

- the built APK starts correctly
- Flutter exposes usable accessibility semantics to the operating system
- platform dialogs and deep links work outside the Flutter test process
- real navigation can be driven through visible controls
- failures produce screenshots and command-level artifacts for review

Maestro addresses that gap by operating through the platform accessibility
tree and device input APIs.

The installed Maestro MCP is documentation-only. Runtime execution will use the
Maestro CLI on a local or CI device.

## 3. Current Repository Assessment

### 3.1 Existing strengths

- `tool/verify.dart` is the canonical static and deterministic quality gate.
- `tool/agent/mobile_evidence_check.sh` already produces timestamped runtime
  evidence summaries and logs.
- `tool/agent/flutter_log_stream.sh` provides device log capture.
- `integration_test/auth_happy_path_test.dart` covers sign-in orchestration with
  in-process fakes.
- `integration_test/startup_deep_link_resume_test.dart` covers startup and
  pending deep-link orchestration with in-process fakes.
- Android has explicit `dev`, `staging`, and `prod` flavors.
- The design system already treats accessibility labels as a supported API.

### 3.2 Constraints discovered

- The Maestro CLI is not currently installed in the development environment.
- Java 17 is available and meets the documented Maestro requirement.
- An Android device is available through ADB.
- Android application IDs are:
  - dev: `dev.fikril.mobile.corekit.dev`
  - staging: `dev.fikril.mobile.corekit.staging`
  - prod: `dev.fikril.mobile.corekit`
- iOS currently uses `dev.fikril.mobile.corekit` without parallel environment
  bundle identifiers or shared flavor schemes.
- Flutter `Key` values are used extensively for widget tests but are invisible
  to Maestro.
- Existing semantics mostly expose human-readable labels. There is no stable
  `Semantics.identifier` convention for automation.
- Runtime tests may require Firebase configuration and environment YAML files.
- There is no deterministic backend fixture contract for black-box auth flows
  yet.

### 3.3 Consequence

The first Maestro work must not begin with a backend-dependent login test.
The first proof should validate a clean-start journey that can run without
shared mutable server state, such as startup/onboarding to sign-in.

## 4. Goals

1. Make critical user journeys executable against a compiled app.
2. Produce deterministic, reviewable runtime evidence.
3. Improve app legibility through stable, accessibility-correct semantics.
4. Keep every top-level flow independently runnable from a clean device state.
5. Preserve one runtime evidence entry point for agents and engineers.
6. Support local debugging before introducing a required CI gate.
7. Convert repeated runtime failures into tests, semantics, scripts, or docs.

## 5. Non-Goals

- Replacing unit, widget, golden, or Flutter integration tests.
- Covering every screen through end-to-end UI automation.
- Running Maestro from `tool/verify.dart`.
- Testing production with mutable or destructive flows.
- Adding Maestro Cloud before local CLI execution is stable.
- Creating a large page-object or selector abstraction framework.
- Adding identifiers to every widget preemptively.
- Hiding application instability with broad retries or excessive timeouts.

## 6. Test Ownership Model

| Layer | Owns | Does not own |
|---|---|---|
| Unit/domain | business rules, value objects, mapping, failure mapping | platform UI |
| Bloc/Cubit | state transitions and effects | compiled navigation |
| Widget/golden | component behavior and visual contracts | device/platform integration |
| Flutter `integration_test` | in-process orchestration with controlled dependencies | black-box compiled app proof |
| Maestro | user-visible cross-screen journeys, platform dialogs, deep links, accessibility reachability | internal state implementation |

A behavior should live at the lowest layer that proves it adequately. Maestro
coverage is reserved for high-value journeys where compiled-app evidence adds
meaningful confidence.

## 7. Proposed Repository Structure

```text
.maestro/
|-- config.yaml
|-- flows/
|   |-- smoke/
|   |   `-- startup_to_sign_in.yaml
|   `-- regression/
|       |-- deep_link_unauthenticated.yaml
|       `-- logout_returns_to_sign_in.yaml
|-- subflows/
|   |-- launch_clean.yaml
|   |-- complete_onboarding.yaml
|   `-- sign_in.yaml
`-- scripts/
    |-- seed_user.js
    `-- delete_test_data.js

tool/agent/
|-- maestro_evidence_check.sh
|-- mobile_evidence_check.sh
`-- maestro_version.txt

docs/engineering/
|-- mobile_runtime_harness.md
`-- maestro_testing.md
```

Rules:

- `flows/` contains executable top-level tests only.
- `subflows/` contains repeated user operations or setup steps and is excluded
  from top-level discovery.
- `scripts/` is allowed only for small data setup/cleanup operations that are
  clearer and faster outside the UI.
- Flow filenames use `snake_case.yaml` and describe an observable outcome.
- A top-level flow must not depend on another top-level flow having run first.

## 8. Workspace Configuration

The initial `.maestro/config.yaml` should be minimal:

```yaml
flows:
  - flows/**/*.yaml
```

Do not add `executionOrder` initially. A dependency between flows is a design
smell; required setup belongs in a subflow or fixture script.

Do not set a static `testOutputDir` in configuration. The evidence runner should
provide a timestamped output directory on every run.

Recommended tags:

- `smoke`: small critical suite intended to become a merge signal
- `regression`: broader runtime coverage
- `android` / `ios`: platform-specific behavior only
- `requires_backend`: needs controlled backend fixtures
- `destructive`: mutates or deletes persistent server data
- `wip`: incomplete and always excluded from official runs

Maestro tag filters use OR semantics within an include or exclude list. Runner
profiles must not assume that multiple include tags form an AND expression.

## 9. Flutter Semantics Contract

### 9.1 Selector policy

Use selectors in this order:

1. visible text when the exact user-facing wording is part of the behavior
2. stable semantic identifier for localized, duplicated, dynamic, or icon-only
   controls
3. relational selectors anchored to stable text or identifiers
4. index or coordinates only as a documented last resort

Do not use Flutter `Key` values as a Maestro contract. They are not exposed to
the operating-system accessibility tree.

### 9.2 Identifier naming

Use lowercase snake case:

```text
<feature>_<screen>_<element>[_<action>]
```

Examples:

```text
auth_sign_in_email_field
auth_sign_in_password_field
auth_sign_in_submit
onboarding_next
account_logout
```

Avoid dots and other regular-expression metacharacters because Maestro `id`
selectors are regular-expression based by default.

Identifiers are stable public test contracts. Rename them only when the user
interaction contract changes, not when a widget or class is refactored.

### 9.3 Design-system integration

Extend existing semantics-producing primitives only when required by a flow.
The first likely APIs are:

- `AppButton.semanticIdentifier`
- `AppTextField.semanticIdentifier`
- `AppTappable.semanticIdentifier`

The primitive should place the identifier on its existing `Semantics` node.
Avoid wrapping page widgets with competing nested semantics when the design
system already owns the accessibility node.

Each new identifier-capable primitive requires widget tests that inspect the
semantics tree. Human-readable labels remain accessibility content;
identifiers remain non-visible automation metadata.

### 9.4 Governance

Do not create a semantics lint in the first slice. First establish repeated,
validated conventions. Add a lint or verification rule only if identifier
omissions or naming drift recur at least twice, following the repository's
failure-to-harness policy.

## 10. Flow Design Rules

Every top-level flow must:

1. declare `appId: ${APP_ID}`
2. declare a descriptive `name`
3. declare relevant tags
4. establish its own initial state
5. assert the starting screen before acting
6. verify a user-visible outcome
7. avoid dependence on test execution order
8. avoid embedded credentials and environment URLs

Illustrative first flow:

```yaml
appId: ${APP_ID}
name: Startup reaches sign in after onboarding
tags:
  - smoke
---
- runFlow:
    file: ../../subflows/launch_clean.yaml
- assertVisible: "Welcome"
- runFlow:
    file: ../../subflows/complete_onboarding.yaml
- assertVisible: "Sign In"
- takeScreenshot: startup_to_sign_in
```

The exact copy and selectors must be derived from the rendered accessibility
tree in Maestro Studio or CLI hierarchy inspection, not guessed from Dart
source.

### 10.1 Synchronization

- Prefer `assertVisible` and `assertNotVisible`; they already poll.
- Use `extendedWaitUntil` only for known long operations.
- Use realistic timeouts so performance regressions remain visible.
- Use `waitForAnimationToEnd` only for moving UI that is already visible.
- Use `retryTapIfNoChange` only for a specific tap with a known transition.
- Never wrap a complete flow or large sequence in `retry`.
- Do not use fixed sleeps as routine synchronization.

### 10.2 State isolation

- Clean-state flows use `launchApp.clearState: true`.
- Permission tests set permissions explicitly rather than relying on device
  history.
- Authenticated flows establish authentication inside the flow or through an
  approved backend fixture mechanism.
- Server data uses unique run-scoped values where possible.
- Destructive data is cleaned in `onFlowComplete` or a dedicated cleanup
  script that also runs after a failed main flow.
- Cleanup must not make a passed behavior assertion fail silently; hook failures
  remain test failures.

## 11. Test Data And Backend Contract

Backend-dependent Maestro coverage must not rely on a manually maintained
shared account whose state drifts over time.

Preferred order:

1. dedicated non-production fixture API or script
2. immutable pre-provisioned account with reset capability
3. UI-created data only when creation itself is the behavior under test

The backend fixture contract should support:

- creating or resetting a test user
- choosing verified/unverified/profile-complete states
- revoking sessions
- expiring or invalidating tokens where session recovery is tested
- deleting run-scoped data
- idempotent cleanup

Until that contract exists, backend-dependent flows remain tagged
`requires_backend` and are excluded from the smoke gate.

Secrets must be passed by CI or shell environment. They must never be committed
to YAML, JavaScript, screenshots, summaries, or command logs. Use Maestro CLI
parameters or `MAESTRO_`-prefixed environment variables as appropriate.

## 12. CLI Version And Preflight Contract

Store one reviewed Maestro CLI version in:

```text
tool/agent/maestro_version.txt
```

The runner must fail before building the app when:

- `maestro` is missing
- `java` is missing or unsupported
- the installed Maestro version differs from the pinned version
- the requested device is not connected
- the requested flavor is invalid
- required environment or platform files are missing
- no selected top-level flows exist

The version update process is explicit:

1. update the pinned version in a focused PR
2. review Maestro release notes
3. run smoke flows repeatedly on the supported Android baseline
4. record any flow or selector migration
5. merge only after artifact behavior is verified

Do not download an unpinned latest CLI version inside normal test execution.

## 13. Runner Design

### 13.1 Dedicated Maestro runner

Add `tool/agent/maestro_evidence_check.sh` with a narrow responsibility:

```text
maestro_evidence_check.sh
  --device <id>
  --flavor <dev|staging|prod>
  [--include-tags <csv>]
  [--exclude-tags <csv>]
  [--flow <path>]
  [--app-file <apk-or-app>]
  [--skip-build]
  [--artifacts-dir <path>]
```

Default behavior:

1. resolve repository root
2. validate Java, Maestro version, FVM Flutter, ADB, device, and config
3. derive the entrypoint from the flavor
4. generate build config
5. validate Firebase/platform files
6. build a debug APK with the repo-pinned Flutter SDK
7. read the application ID from the built APK manifest
8. install the APK on the selected device
9. start device log capture
10. pass the discovered application ID to Maestro as `APP_ID`
11. run selected Maestro flows
12. stop log capture even when Maestro fails
13. emit JUnit, screenshots, command JSON, Maestro logs, and runner logs
14. write a machine-readable exit status and Markdown summary fragment

Flavor mapping:

| Flavor | Entrypoint | Android app ID |
|---|---|---|
| dev | `lib/main_dev.dart` | `dev.fikril.mobile.corekit.dev` |
| staging | `lib/main_staging.dart` | `dev.fikril.mobile.corekit.staging` |
| prod | `lib/main_prod.dart` | `dev.fikril.mobile.corekit` |

The IDs above document the current repository state. They must not become a
second hardcoded source of truth in the runner. Reading the built manifest keeps
the harness correct when this template is cloned and rebranded. The runner
should fail if it cannot inspect the application ID or if the installed package
does not match the inspected artifact.

`prod` execution must require an explicit opt-in flag and must exclude
`destructive` and `requires_backend` flows by default.

### 13.2 Unified mobile evidence entry point

After the standalone runner is stable, evolve
`tool/agent/mobile_evidence_check.sh` to support:

```text
--lane flutter|maestro|all
```

Backward compatibility:

- initial default remains `flutter`
- official medium/high-risk evidence uses `--lane all`
- changing the default to `all` requires a later explicit decision based on
  runtime cost and stability data

The unified summary should report each lane separately. One lane failing must
make the overall command fail after all requested evidence has been collected.

## 14. Artifact Contract

Use the existing runtime artifact root:

```text
_artifacts/mobile/<timestamp>/
|-- metadata.txt
|-- summary.md
|-- flutter/
|   `-- logs/
`-- maestro/
    |-- junit.xml
    |-- runner.log
    |-- maestro.log
    |-- commands-*.json
    |-- screenshots/
    `-- device.log
```

The runner should pass both Maestro test-output and debug-output paths so visual
artifacts and diagnostic logs are retained. JUnit output is written explicitly
because it is not automatically placed inside those directories.

`summary.md` must include:

- git commit and dirty-worktree indicator
- device ID, model, Android API, and ABI
- flavor, app ID, app file checksum, and entrypoint
- Flutter, Java, and Maestro versions
- selected flows and tag filters
- start/end timestamps and duration
- pass/fail result per flow
- artifact paths
- relevant application log extracts such as startup metrics and trace IDs

The `_artifacts/` directory remains ignored by Git. CI uploads it on both pass
and failure with a bounded retention period.

## 15. Failure Classification

The summary should classify failures without changing Maestro's non-zero exit
status:

| Class | Examples | Owner |
|---|---|---|
| App regression | wrong screen, missing state, failed navigation | product code |
| Accessibility contract | element rendered but absent/misidentified in semantics | UI/design system |
| Flow defect | stale selector, invalid assumption, bad fixture setup | Maestro suite |
| Environment | missing config, unavailable device, unsupported Java | harness/platform |
| Backend fixture | seed/reset unavailable or inconsistent | backend contract |
| Infrastructure | emulator crash, disk exhaustion, runner outage | CI/platform |

Automatic reruns are allowed only for an explicitly detected infrastructure
failure. Assertion failures and selector failures are not retried at suite
level.

## 16. CI Rollout

### Phase A: local-only pilot

- no required CI job
- run one Android smoke flow manually
- collect at least ten consecutive clean runs across two fresh app installs
- validate failure screenshots and logs by intentionally breaking one assertion

### Phase B: manual CI job

- add `workflow_dispatch`
- build the dev debug APK
- start a pinned Android emulator image
- install the pinned Maestro CLI
- run only `smoke`, excluding `wip`, `requires_backend`, and `destructive`
- publish JUnit and `_artifacts/mobile/` on pass and failure
- keep the job non-blocking while reliability data is gathered

### Phase C: scheduled signal

- run Android smoke flows on a schedule
- track pass rate, median duration, and failure classification
- require at least 95 percent non-infrastructure pass rate over an agreed window
  before promotion

### Phase D: PR gate

- run on PRs that touch runtime-sensitive paths or through an explicit label
- make the smoke job required only after stability and runtime cost are accepted
- keep broader regression flows scheduled or pre-release

### Phase E: iOS evaluation

- define iOS environment bundle identifiers and schemes first
- verify simulator semantics and platform dialogs independently
- add iOS smoke flows only after Android conventions have proven durable

Maestro Cloud is an optional later execution backend. Adoption requires a
separate cost, security, retention, and vendor-dependency decision. The flow
workspace and artifact contract must remain runnable with the open CLI.

## 17. Security And Production Safety

- Default all official runs to `dev` or an isolated test environment.
- Never point destructive flows at production.
- Require explicit opt-in for production app IDs.
- Use least-privilege test accounts.
- Do not print secret values in shell tracing, YAML labels, JavaScript logs, or
  summaries.
- Review screenshots for personal or secret data before attaching them to PRs.
- Give CI artifacts bounded retention and repository-appropriate access.
- Fixture APIs must authenticate test infrastructure and reject production
  environments.
- `clearState` only clears local app state; it is not backend cleanup.

## 18. Documentation And Governance Changes

After the pilot is approved and implemented:

1. create an ADR under `ADR/records/` for adopting Maestro as the black-box
   runtime evidence tool
2. create a non-trivial execution plan under `docs/exec-plans/active/`
3. add `docs/engineering/maestro_testing.md` as the operational guide
4. update `docs/engineering/mobile_runtime_harness.md` with lane selection
5. update `docs/engineering/testing_strategy.md` with ownership boundaries
6. update `.github/pull_request_template.md` with Maestro evidence when relevant
7. update `docs/README.md` to index the stable Maestro guide

Keep this proposal in `_WIP` until the architectural decisions are accepted.
Do not treat it as an operational source of truth before implementation.

## 19. Phased Implementation Plan

### Phase 0: approve contracts

- approve test ownership boundaries
- approve Android-first scope
- approve semantics identifier convention
- choose and pin a Maestro CLI version
- decide local CI emulator versus Maestro Cloud for later CI execution
- define the first flow and supported Android API/device baseline

Exit criteria:

- ADR accepted
- active execution plan created
- no unresolved ownership decision blocks the pilot

### Phase 1: semantics and proof flow

- add identifier support only to primitives needed by the pilot
- add semantics widget tests
- add `.maestro/config.yaml`
- add clean-launch and onboarding subflows
- add `startup_to_sign_in.yaml`
- inspect selectors against the actual device accessibility tree

Exit criteria:

- proof flow passes from a clean install
- proof flow does not use coordinates, fixed sleeps, or broad retries
- accessibility labels remain correct for screen-reader users

### Phase 2: deterministic local evidence

- add the pinned version file
- implement `maestro_evidence_check.sh`
- collect JUnit, screenshots, command traces, Maestro logs, and device logs
- produce the documented metadata and summary
- test missing-tool, wrong-version, missing-device, assertion-failure, and
  successful-run paths

Exit criteria:

- ten consecutive successful local runs
- an intentional assertion failure produces actionable artifacts
- no secret values appear in artifacts

### Phase 3: unify runtime evidence

- add `--lane flutter|maestro|all` to `mobile_evidence_check.sh`
- preserve the current default
- merge both lane results into one summary
- update stable engineering docs

Exit criteria:

- `--lane flutter` preserves current behavior
- `--lane maestro` runs without Flutter integration tests
- `--lane all` collects both lanes and returns the correct aggregate status

### Phase 4: CI signal

- add manual Android CI execution
- then add scheduled smoke execution
- upload artifacts and JUnit unconditionally
- collect reliability and duration metrics

Exit criteria:

- CI reproduces local execution on the documented baseline
- infrastructure failures are distinguishable from app failures
- promotion criteria for a PR gate are supported by measured data

### Phase 5: expand critical journeys

Add flows only when prerequisites are deterministic:

1. unauthenticated deep-link routing
2. login and logout with resettable test identity
3. authenticated deep-link resume
4. profile update with cleanup
5. session expiry/refresh through backend fixtures
6. permission denial and recovery

Each added flow requires an explicit statement of why lower test layers are not
sufficient.

## 20. Verification Strategy For Implementation PRs

Docs-only proposal changes:

```bash
git diff --check
```

Semantics or Flutter code changes:

```bash
dart run tool/verify.dart --env dev
```

Harness shell changes:

```bash
bash -n tool/agent/maestro_evidence_check.sh
bash -n tool/agent/mobile_evidence_check.sh
```

Pilot runtime proof:

```bash
tool/agent/maestro_evidence_check.sh \
  --device <device-id> \
  --flavor dev \
  --include-tags smoke
```

Unified runtime proof:

```bash
tool/agent/mobile_evidence_check.sh \
  --device <device-id> \
  --flavor dev \
  --lane all
```

Relevant implementation PRs must include exact artifact paths and must not
claim runtime success without a real device run.

## 21. Risks And Mitigations

| Risk | Mitigation |
|---|---|
| Semantics added only for tests damages accessibility | extend existing semantics nodes; assert labels and identifiers in widget tests |
| Backend state creates flakes | exclude backend flows until resettable fixtures exist |
| Suite becomes slow | keep a small smoke tag; schedule broader regression coverage |
| Selectors break on localization | use semantic identifiers for localized or ambiguous controls |
| Retries hide regressions | prohibit suite-level retries for assertion/selector failures |
| Local and CI tools diverge | pin one CLI version and record versions in artifacts |
| Maestro duplicates integration tests | enforce the ownership table and require value justification |
| iOS behavior is assumed from Android | keep iOS out of initial scope and validate independently |
| Secrets leak through artifacts | environment injection, redaction, screenshot review, bounded retention |
| Harness becomes too abstract | use direct YAML and small subflows; no page-object framework initially |

## 22. Success Metrics

Pilot metrics:

- ten consecutive successful clean-state Android runs
- zero coordinate selectors
- zero fixed sleeps
- zero broad retry blocks
- actionable screenshot and log output for an intentional failure
- runtime evidence summary generated without manual editing

Operational metrics:

- smoke suite non-infrastructure pass rate at or above 95 percent
- median smoke duration within the agreed PR budget
- all failures assigned to one documented classification
- repeated flow failures promoted into code, semantics, fixtures, or harness
  improvements
- no committed credentials or sensitive artifact leakage

## 23. Decisions Required Before Implementation

1. Approve Android-first local CLI execution.
2. Approve the semantics identifier naming contract.
3. Select the first supported Android API/device baseline.
4. Select and pin the initial Maestro CLI version.
5. Confirm that the first flow is backend-independent
   `startup_to_sign_in`.
6. Choose the backend fixture owner and contract before auth flows are added.
7. Decide whether later CI uses a hosted emulator runner or Maestro Cloud.
8. Define the measured window and runtime budget for promotion to a PR gate.

## 24. Recommended Approval

Approved on 2026-06-06: Phases 0 through 2 only.

That scope establishes the semantics contract, proves one isolated journey, and
creates deterministic local artifacts without prematurely committing to CI,
cloud execution, backend fixtures, or broad flow coverage. Review measured
stability and maintenance cost before approving Phases 3 through 5.

Phase 0 decisions and the implementation system of record now live in:

- `ADR/records/0011-maestro-black-box-runtime-evidence.md`
- `docs/exec-plans/active/2026-06-06_maestro-runtime-harness-phases-1-2.md`

## 25. Official Maestro References

- Flutter support and semantics:
  https://docs.maestro.dev/get-started/supported-platform/flutter
- Selector strategy:
  https://docs.maestro.dev/maestro-flows/flow-control-and-logic/how-to-use-selectors
- Wait strategy:
  https://docs.maestro.dev/maestro-flows/flow-control-and-logic/wait-commands
- Test architecture:
  https://docs.maestro.dev/maestro-flows/workspace-management/design-your-test-architecture
- Project configuration:
  https://docs.maestro.dev/maestro-flows/workspace-management/project-configuration
- Nested flows:
  https://docs.maestro.dev/maestro-flows/flow-control-and-logic/nested-flows
- Hooks:
  https://docs.maestro.dev/maestro-flows/flow-control-and-logic/hooks
- Parameters and constants:
  https://docs.maestro.dev/maestro-flows/flow-control-and-logic/parameters-and-constants
- Reports and artifacts:
  https://docs.maestro.dev/maestro-flows/workspace-management/test-reports-and-artifacts
- CLI version pinning:
  https://docs.maestro.dev/maestro-cli/how-to-install-maestro-cli/update-the-maestro-cli
