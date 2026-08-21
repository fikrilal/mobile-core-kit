# CI Runtime Firebase Build Fixture

**Plan version:** 2
**Task ID:** ci-runtime-firebase-fixture
**Status:** active
**Owner:** Codex
**Risk:** high
**Authority:** fix PR 38 CI Runtime Android assembly by adding and using a non-secret build-only Firebase fixture, verify, commit, and push; do not use real credentials, merge, deploy, or release
**Allowed paths:** .github/workflows/required.yml, harness/fixtures/google-services.ci.json, packages/mobile_core_kit_cli/test/ci_workflow_policy_test.dart, docs/exec-plans/active/2026-08-12_ci-runtime-firebase-fixture.md, docs/exec-plans/completed/2026-08-12_ci-runtime-firebase-fixture.md
**Allowed actions:** edit, verify, commit, push
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 3h
**Oracle IDs:** harness.full, runtime.mobile-evidence, external.human-review

Date: 2026-08-12
Related issue/PR: https://github.com/fikrilal/mobile-core-kit/pull/38

## Objective

Make the credential-free CI Runtime lane capable of assembling the dev Android
debug application without relying on a developer-local or production Firebase
configuration.

## Constraints

- Architecture constraints: keep Firebase application wiring unchanged; fix
  only CI build preparation and its regression policy.
- Product/runtime constraints: the fixture must be visibly synthetic,
  non-secret, package-matched, and used only by CI Runtime.
- Out of scope: real Firebase connectivity, production secrets, release builds,
  application behavior, deployment, merge, and release.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: yes
- UI/UX/accessibility: no
- Harness/CI/release: yes
- External systems: no

## Acceptance Scenarios

1. Given a clean credential-free checkout, when CI Runtime prepares the
   synthetic fixture and assembles dev debug, then the Google Services Gradle
   task finds a package-matched configuration and the APK build passes.
2. Given a future workflow edit removes or misroutes the fixture, when the
   workflow-policy test runs, then it fails before hosted runtime CI.

## Acceptance Criteria

1. A clearly named CI-only fixture contains no real Firebase project or key.
2. CI Runtime copies the fixture to the ignored Android configuration path
   before assembly.
3. Policy tests bind the source, destination, and dev package name.
4. A clean-checkout dev debug Android assembly passes.
5. Canonical full verification and hosted required CI pass.

## Implementation Checklist

- [ ] Add the non-secret package-matched Firebase build fixture.
- [ ] Prepare it only in CI Runtime.
- [ ] Add workflow-policy regression assertions.
- [ ] Run targeted, full, clean-build, and hosted verification.

## Decision Log

- 2026-08-12: Use a checked-in synthetic build fixture -> required PR CI stays
  credential-free and fork-safe without weakening Android plugin validation.

## Verification

Pending.

## Runtime Evidence

The required evidence is a clean-checkout dev debug APK assembly using the
synthetic fixture plus the hosted CI Runtime lane. No device interaction or
real Firebase call is authorized.

## Rollback

Revert the focused fixture/workflow commit.

## Risks And Mitigations

- Risk: a fixture is mistaken for deployable Firebase configuration.
- Mitigation: use reserved-looking synthetic identifiers, a CI-specific path,
  no credential-shaped API key, and copy it only inside CI Runtime.

## Completion Notes

Pending.

## Follow-ups

- [ ] State whether any follow-up debt remains.
