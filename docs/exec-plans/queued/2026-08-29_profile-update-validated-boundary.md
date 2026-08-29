# Strengthen The Profile Update Validation Boundary

**Plan version:** 2
**Task ID:** profile-update-validated-boundary
**Status:** queued
**Owner:** Codex
**Risk:** medium
**Authority:** Refactor only profile completion/update from a primitive PatchMeProfileRequestEntity to ProfileUpdateInput -> ProfileDetails -> PatchMeRequestModel, preserving current name rules, optional display-name normalization, draft behavior, current-user refresh, inline feedback, and payload shape.
**Allowed paths:** docs/exec-plans/queued/2026-08-29_profile-update-validated-boundary.md, docs/exec-plans/active/2026-08-29_profile-update-validated-boundary.md, docs/exec-plans/completed/2026-08-29_profile-update-validated-boundary.md, lib/features/account/subfeatures/profile/domain/entity/patch_me_profile_request_entity.dart, lib/features/account/subfeatures/profile/domain/entity/patch_me_profile_request_entity.freezed.dart, lib/features/account/subfeatures/profile/domain/input/profile_update_input.dart, lib/features/account/subfeatures/profile/domain/value/profile_details.dart, lib/features/account/subfeatures/profile/domain/repository/profile_repository.dart, lib/features/account/subfeatures/profile/domain/usecase/patch_me_profile_usecase.dart, lib/features/account/subfeatures/profile/data/model/remote/patch_me_request_model.dart, lib/features/account/subfeatures/profile/data/model/remote/patch_me_request_model.freezed.dart, lib/features/account/subfeatures/profile/data/model/remote/patch_me_request_model.g.dart, lib/features/account/subfeatures/profile/data/repository/profile_repository_impl.dart, lib/features/account/subfeatures/profile/presentation/cubit/complete_profile/complete_profile_cubit.dart, test/features/account/subfeatures/profile/domain/value/profile_details_test.dart, test/features/account/subfeatures/profile/domain/usecase/patch_me_profile_usecase_test.dart, test/features/account/subfeatures/profile/data/repository/profile_repository_impl_integration_test.dart, test/features/account/subfeatures/profile/presentation/cubit/complete_profile/complete_profile_cubit_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** medium
**Repair limit:** 3
**Task timeout:** 90m
**Oracle IDs:** ui.human-review

Date: 2026-08-29
Related issue/PR: N/A

## Objective

Make profile repository calls prove that given/family name validation and all
currently defined normalization have succeeded, without importing auth-owned
VOs into the account feature or silently adding display-name rules.

## Constraints

- Architecture constraints:
  - `ProfileUpdateInput` holds raw, possibly invalid form state.
  - `ProfileDetails.create()` uses account-owned `GivenName` and optional `FamilyName`.
  - Keep optional display name normalization explicit inside the aggregate; do not reuse auth's feature-local `DisplayName`.
  - Repository accepts `ProfileDetails`; the data model owns primitive mapping.
- Product/runtime constraints:
  - Preserve given/family name rules and error codes.
  - Preserve current behavior where blank display name becomes null and nonblank display name is trimmed without a new length rule.
  - Preserve draft persistence, current-user state update, payload shape, and inline errors.
- Out of scope:
  - New display-name policy, profile draft schema changes, avatar/image upload, or backend contract changes.
  - Commit, push, or PR creation.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: yes
- Harness/CI/release: no
- External systems: no

## Acceptance Scenarios

1. Given invalid given and family names, when submitted, then all deterministic errors are returned and the repository is not called.
2. Given valid names with whitespace and a blank display name, when submitted, then names are normalized and display name becomes null.
3. Given a nonblank display name, when submitted, then its current trim-only behavior is preserved without importing auth policy.
4. Given valid profile details, when saved, then payload, current-user update, draft clearing, and UI effects remain unchanged.

## Acceptance Criteria

1. `PatchMeProfileRequestEntity` and its generated file are removed from this flow.
2. Raw input and validated `ProfileDetails` are distinct types.
3. `ProfileDetails` has no public unchecked constructor and aggregates name failures.
4. Repository and request model require/map `ProfileDetails`.
5. Aggregate, use-case, repository integration, and Cubit tests preserve profile behavior.

## Implementation Checklist

- [ ] Add raw profile input and private validated aggregate.
- [ ] Migrate use case, repository contract/implementation, request model, and Cubit.
- [ ] Remove the old request entity and generated source.
- [ ] Add aggregate coverage and update focused/integration tests.
- [ ] Run controlled verification and collect UI/runtime evidence.
- [ ] Complete and archive this plan.

## Decision Log

- 2026-08-29: Keep a profile-owned aggregate -> cross-feature reuse of auth `DisplayName` would couple bounded contexts.
- 2026-08-29: Preserve display name's trim-only semantics -> validation architecture refactor must not introduce an unapproved product rule.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task profile-update-validated-boundary --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task profile-update-validated-boundary --env dev
```

Run focused aggregate, use-case, repository integration, and Cubit tests during
the inner loop.

## Runtime Evidence

Exercise invalid and successful profile completion/update on a supported target.
Confirm inline errors, normalized visible state, draft behavior, and refreshed
current-user data; retain sanitized evidence.

## Rollback

Restore the request entity and previous use-case/repository/model/Cubit
signatures. Draft and backend schemas are unchanged.

## Risks And Mitigations

- Risk: profile display-name behavior changes accidentally.
- Mitigation: encode and test the existing optional trim-only behavior explicitly.
- Risk: current-user or draft orchestration changes during type migration.
- Mitigation: retain repository integration and Cubit effect/state assertions.

## Completion Notes

Pending.

## Follow-ups

- [ ] Record unresolved debt in `docs/exec-plans/tech_debt_tracker.md`, or state none.
