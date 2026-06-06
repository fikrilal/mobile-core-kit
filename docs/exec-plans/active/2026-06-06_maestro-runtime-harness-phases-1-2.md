# Maestro Runtime Harness Phases 1-2

Date: 2026-06-06
Owner: Codex
Status: active
Risk class: high
Related issue/PR: N/A
Decision: `ADR/records/0011-maestro-black-box-runtime-evidence.md`

## Objective

Implement the approved first two delivery phases of the Maestro runtime
harness: establish the Flutter semantics contract and one isolated Android
proof journey, then add deterministic local execution and evidence artifacts.

## Phase 0 Decisions

- Test ownership: Maestro owns critical compiled-app user journeys and does not
  replace lower-level or Flutter integration tests.
- Platform scope: Android first; iOS is explicitly deferred.
- Semantic identifier format:
  `<feature>_<screen>_<element>[_<action>]` in lowercase snake case.
- Initial Maestro CLI version: `2.6.0`.
- Reproducible baseline: Pixel 8 emulator, Android API 34, Google APIs, x86_64.
- Secondary validation device: Xiaomi `2312DRA50G`, Android 16/API 36,
  arm64-v8a.
- Initial CI direction: open Maestro CLI on a hosted Android emulator runner.
- Maestro Cloud: deferred to a separate decision.
- Pilot journey: clean startup/onboarding to sign-in, without backend fixtures.

## Constraints

- Architectural constraints:
  - Maestro remains outside `tool/verify.dart`.
  - `.maestro/flows/` contains top-level executable journeys only.
  - reusable setup belongs in `.maestro/subflows/`.
  - the runner reads the app ID from the built APK instead of duplicating
    package identifiers in scripts.
- Product/runtime constraints:
  - the pilot must run from cleared local app state;
  - selectors must be confirmed against the rendered accessibility tree;
  - accessibility labels must remain correct for screen-reader users;
  - no real backend account or shared mutable server state is allowed;
  - no destructive production execution is allowed.
- Tooling constraints:
  - use the repo-pinned Flutter SDK through FVM;
  - require Java 17 or 21;
  - require exact Maestro CLI version `2.6.0`;
  - retain local execution without Maestro Cloud.
- Out of scope:
  - CI workflow implementation;
  - `--lane` integration into `mobile_evidence_check.sh`;
  - backend fixture APIs;
  - authenticated journeys;
  - iOS support;
  - a required PR gate;
  - a semantics lint.

## Acceptance Criteria

1. The repository contains a minimal Maestro workspace with explicit flow
   discovery and no execution-order dependency.
2. Design-system primitives needed by the pilot expose stable semantic
   identifiers without replacing human-readable accessibility labels.
3. Widget tests verify the affected semantics labels and identifiers.
4. `startup_to_sign_in.yaml` runs from cleared state against the compiled dev
   APK and verifies the sign-in destination.
5. The pilot uses no coordinates, fixed sleeps, broad retries, or backend data.
6. `tool/agent/maestro_version.txt` pins Maestro CLI `2.6.0`.
7. `tool/agent/maestro_evidence_check.sh` validates prerequisites, builds or
   accepts a dev APK, reads its app ID, installs it, executes selected flows,
   and always stops log capture.
8. Evidence includes metadata, Markdown summary, JUnit, screenshots, command
   JSON, Maestro logs, runner logs, and device logs under `_artifacts/mobile/`.
9. Ten consecutive clean-state runs pass on the API 34 baseline.
10. One intentional assertion failure is executed during verification and
    produces actionable artifacts; the committed flow remains passing.
11. Missing CLI, wrong CLI version, missing device, invalid flavor, missing
    platform config, and missing-flow paths fail early with actionable output.
12. No secret or personal values are present in committed flows or captured
    verification artifacts.
13. Stable engineering docs describe how agents decide, author, inspect, run,
    and deliver Maestro journey evidence.

## Implementation Checklist

### Phase 1: semantics and proof flow

- [ ] Install Maestro CLI `2.6.0` in the local development environment.
- [ ] Create or verify the Pixel 8 / API 34 / Google APIs / x86_64 emulator.
- [ ] Inspect the startup, onboarding, and sign-in accessibility trees.
- [ ] Identify the minimum design-system semantic identifier API required.
- [ ] Add identifier support to only the required primitives.
- [ ] Add focused semantics widget tests.
- [ ] Add `.maestro/config.yaml`.
- [ ] Add `.maestro/subflows/launch_clean.yaml`.
- [ ] Add the minimum onboarding subflow only if it removes real duplication.
- [ ] Add `.maestro/flows/smoke/startup_to_sign_in.yaml`.
- [ ] Verify the flow from a clean dev app install.

### Phase 2: deterministic local evidence

- [ ] Add `tool/agent/maestro_version.txt` with `2.6.0`.
- [ ] Add `tool/agent/maestro_evidence_check.sh`.
- [ ] Validate Java, Maestro, FVM Flutter, ADB, device, flavor, env config,
  Firebase config, and selected flows before execution.
- [ ] Build the flavor-specific debug APK when `--app-file` is not supplied.
- [ ] Inspect the application ID from the APK and verify the installed package.
- [ ] Integrate `tool/agent/flutter_log_stream.sh` with cleanup traps.
- [ ] Generate the complete artifact contract under `_artifacts/mobile/`.
- [ ] Add shell-level tests or a deterministic test harness for preflight and
  argument behavior where practical.
- [ ] Add `docs/engineering/maestro_testing.md`.
- [ ] Update `docs/engineering/mobile_runtime_harness.md`.
- [ ] Update `docs/engineering/testing_strategy.md`.
- [ ] Update `docs/README.md`.
- [ ] Run repeated success and intentional-failure verification.

## Agent Authoring Workflow

For a product feature that affects a critical journey:

1. During planning, state whether an existing Maestro journey changes or a new
   journey is justified.
2. Implement behavior and lower-level tests first.
3. Add only the semantic identifiers required for stable black-box selection.
4. Build and install the compiled app.
5. Inspect the actual accessibility tree; do not guess selectors from Dart.
6. Create or update the journey flow.
7. Run the targeted flow from clean state.
8. Run relevant smoke coverage and retain evidence artifacts.
9. Include exact artifact paths and outcomes in the PR.

Do not create one Maestro flow per feature. Create or update a flow only when
the feature changes a critical user-observable cross-screen journey that lower
test layers do not prove adequately.

## Decision Log

- 2026-06-06: Adopt Maestro as a complementary black-box lane -> closes the
  compiled-app evidence gap without replacing lower-level tests.
- 2026-06-06: Start with Android -> the repository has Android flavors and a
  connected device, while iOS environment schemes are not yet explicit.
- 2026-06-06: Use API 34 Pixel 8 Google APIs x86_64 as the baseline -> official
  Maestro guidance lists API 34 as supported; the available API 36 device is
  useful secondary evidence but not a stable sole baseline.
- 2026-06-06: Pin Maestro CLI `2.6.0` -> it is the latest stable official
  release as of 2026-06-06 and must be verified before use.
- 2026-06-06: Use local CLI and hosted emulator CI first -> preserves local
  reproducibility and defers cloud cost/security/vendor decisions.
- 2026-06-06: Pilot startup-to-sign-in -> avoids backend fixture dependency
  while proving launch, onboarding, navigation, semantics, and artifacts.
- 2026-06-06: Keep `mobile_evidence_check.sh` integration out of this plan ->
  the standalone lane must prove stability before changing the existing entry
  point.

## Verification

Documentation and configuration:

```bash
git diff --check
```

Flutter and semantics changes:

```bash
dart run tool/verify.dart --env dev
```

Harness scripts:

```bash
bash -n tool/agent/maestro_evidence_check.sh
bash -n tool/agent/flutter_log_stream.sh
```

Pilot flow:

```bash
tool/agent/maestro_evidence_check.sh \
  --device <api-34-device-id> \
  --flavor dev \
  --include-tags smoke
```

Additional required evidence:

- ten consecutive successful pilot runs;
- one intentional assertion failure with retained artifacts;
- targeted preflight failure checks;
- artifact review for secrets and personal data.

## Runtime Evidence

Required because this is high-risk runtime harness and accessibility work.

- Primary device/emulator: Pixel 8, Android API 34, Google APIs, x86_64
- Secondary device: Xiaomi `2312DRA50G`, Android API 36, arm64-v8a
- Flavor: dev
- Executed target: `.maestro/flows/smoke/startup_to_sign_in.yaml`
- Artifact paths: `_artifacts/mobile/<timestamp>/`
- Notes: record CLI, Java, Flutter, APK checksum, app ID, and device metadata.

## Risks And Mitigations

- Risk: semantic metadata is optimized for automation and harms accessibility.
- Mitigation: preserve human-readable labels, extend existing semantics nodes,
  and test both labels and identifiers.
- Risk: API 36 behavior differs from the supported reproducible baseline.
- Mitigation: gate repeatability on API 34 and treat API 36 as secondary proof.
- Risk: the runner becomes a second build system.
- Mitigation: invoke existing FVM Flutter and config generation paths; do not
  duplicate package IDs or build logic.
- Risk: retries hide application defects.
- Mitigation: prohibit broad retries and keep assertions as synchronization.
- Risk: artifacts leak credentials or personal data.
- Mitigation: use a backend-independent pilot, redact logs, review screenshots,
  and keep artifacts ignored with bounded CI retention later.
- Risk: scope expands into CI and authenticated flows before local stability.
- Mitigation: keep Phases 3-5 explicitly out of this execution plan.

## Completion Notes

Not complete. Phase 0 architecture and planning are accepted. Implementation
starts with Phase 1 after this plan is reviewed against the ADR.

## Follow-ups

- [ ] After Phases 1-2, decide whether to approve unified mobile evidence lane
  integration.
- [ ] After measured local reliability, decide whether to implement manual and
  scheduled CI.
- [ ] Before authenticated flows, define backend fixture ownership and contract.
- [ ] Before iOS flows, define environment bundle identifiers and schemes.
- [ ] Add unresolved implementation debt to
  `docs/exec-plans/tech_debt_tracker.md` before completing this plan.
