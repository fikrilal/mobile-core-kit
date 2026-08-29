# Migrate Login Integration Fakes To Validated Credentials

**Plan version:** 2
**Task ID:** login-integration-credentials-migration
**Status:** completed
**Owner:** Codex
**Risk:** high
**Authority:** Finish the authorized login boundary refactor by migrating the two registered integration fakes to LoginCredentials and removing the temporary LoginRequestEntity compatibility alias.
**Allowed paths:** docs/exec-plans/active/2026-08-28_login-integration-credentials-migration.md, docs/exec-plans/completed/2026-08-28_login-integration-credentials-migration.md, integration_test/auth_happy_path_test.dart, integration_test/startup_deep_link_resume_test.dart, lib/features/auth/domain/entity/login_request_entity.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 2
**Task timeout:** 90m
**Oracle IDs:** auth.integration

Date: 2026-08-28
Related issue/PR: N/A

## Objective

Remove the last source references to `LoginRequestEntity` after production
login code moved to `LoginInput -> LoginCredentials -> LoginRequestModel`.

## Constraints

- Architecture constraints:
  - Integration fakes must match the repository's validated domain contract.
- Product/runtime constraints:
  - Do not change integration scenarios or fake behavior.
- Out of scope:
  - Any production flow beyond deleting the temporary compatibility alias.
  - Runtime harness behavior, including the Linux `--flavor` limitation.
  - Commit, push, or PR creation.

## Impact Areas

- Auth/session: yes
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: no
- External systems: no

## Acceptance Scenarios

1. Given either registered integration fake, when it implements `AuthRepository.login`, then its parameter type is `LoginCredentials` and behavior is unchanged.
2. Given the complete repository, when source references are searched, then `LoginRequestEntity` and its source file no longer exist.

## Acceptance Criteria

1. Both integration fakes compile against `AuthRepository.login(LoginCredentials)`.
2. The temporary compatibility alias is deleted.
3. Controlled full verification succeeds.

## Implementation Checklist

- [x] Update both registered integration fakes.
- [x] Delete the temporary compatibility alias.
- [x] Run controlled verification and record runtime availability.
- [x] Complete and archive this plan.

## Decision Log

- 2026-08-28: Use a separate narrow task -> the first task's immutable authority did not include registered integration sources.

## Verification

Executed:

```bash
dart run mobile_core_kit_cli:mobilekit task verify --task login-integration-credentials-migration --env dev
# Passed on attempt 2 with profile full.
```

## Runtime Evidence

No compatible Android/iOS device was connected. The only native target was
Linux, where the runtime harness currently always adds the unsupported
`--flavor dev` flag. The same limitation was recorded by the preceding task;
device runtime success is not claimed.

## Rollback

Restore the temporary alias and the two integration imports/signatures.

## Risks And Mitigations

- Risk: fake behavior changes during type migration.
- Mitigation: change only imports and parameter types; full tests compile the integration targets.

## Completion Notes

Both registered integration fakes now use `LoginCredentials`. The deprecated
alias and all `LoginRequestEntity` source references are removed.

## Follow-ups

- [x] Separately authorize a harness fix for Linux runtime evidence flavor handling; no product-code debt remains in this task.
