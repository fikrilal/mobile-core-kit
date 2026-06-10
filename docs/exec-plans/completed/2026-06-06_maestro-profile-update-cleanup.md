# Maestro: Profile Update With Cleanup

Date: 2026-06-06
Owner: Codex
Status: completed
Risk class: high
Related issue/PR: N/A

## Objective

Add one compiled-app journey that logs in with the resettable identity, updates
a deterministic profile field, proves the rendered result, and restores the
original backend profile even when the run fails.

## Dependencies

- `2026-06-06_maestro-login-logout-resettable-identity.md`.

## Constraints

- Prefer text profile fields; image upload is out of scope because it adds
  media storage and permission cleanup.
- Use a run-specific but non-sensitive value.
- Cleanup is mandatory and must be idempotent.
- Do not depend on eventual consistency without a backend-owned readiness
  signal.

## Required Backend Fixture Contract

- Reset the identity to known given/family-name values.
- Restore the baseline after success, assertion failure, or process interruption.
- Verify the final backend value without printing credentials or tokens.
- Define ownership and serialization if the identity is shared.

## Why Lower Layers Are Insufficient

Cubit/use-case/repository tests prove validation and mapping separately. They do
not prove real form population, backend mutation, refreshed user context, and
rendered profile state in the installed application.

## Acceptance Criteria

1. Preflight establishes the documented baseline profile.
2. The flow updates one profile field through the UI and proves the new value.
3. A reload or navigation round trip proves the value came from persisted state.
4. Cleanup restores the baseline and verifies restoration.
5. An intentional failure still executes cleanup.

## Implementation Checklist

- [x] Verify the backend reset/restore command and baseline values.
- [x] Add a normal authenticated profile-edit entry point.
- [x] Add minimal semantic identifiers and focused Cubit tests.
- [x] Add `.maestro/flows/account/profile_update.yaml` tagged
  `requires_backend` and `destructive`.
- [x] Integrate setup/cleanup outside the YAML flow with reliable traps.
- [x] Test passing and failed-run cleanup behavior.
- [x] Review artifacts for personal data and use only synthetic values.

## Verification

```bash
dart run tool/verify.dart --env dev
tool/agent/mobile_evidence_check.sh \
  --lane maestro \
  --device <api-34-device> \
  --flavor dev \
  --flow .maestro/flows/account/profile_update.yaml
```

## Risks And Mitigations

- Risk: failed cleanup contaminates later journeys.
- Mitigation: verify baseline in preflight and fail before launching the app.
- Risk: screenshots retain synthetic profile data.
- Mitigation: use explicitly non-personal fixture values and review artifacts.

## Evidence

- Passed: `_artifacts/mobile/mobtrace-profile-update-20260610_090004`
- Intentional failed runs restored the baseline before later runs:
  - `_artifacts/mobile/mobtrace-profile-update-20260610_081420`
  - `_artifacts/mobile/mobtrace-profile-update-20260610_081629`
- Baseline: `Maestro Fixture`
- Mutated value: `Runtime Fixture`

## Handoff Notes

Android camera and gallery use system-owned pickers and do not expose an
app-owned runtime permission denial/recovery journey. Notification permission
UX is not implemented, so a separate Android permission flow would currently
be synthetic rather than product evidence.
