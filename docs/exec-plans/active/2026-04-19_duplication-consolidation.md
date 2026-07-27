# Consolidate High-Value Duplication In Account/Auth Bridges

Date: 2026-04-19  
Owner: Dante  
Status: active (implementation complete, awaiting review)  
Risk class: medium  
Related issue/PR: N/A

## Objective

Remove the highest-value duplication surfaced by the new duplication harness without broadening the refactor scope. The target is the three drift-prone cases already validated by review:

1. account-side `ApiFailure -> AuthFailure` mapping duplicated across account root + subfeatures
2. `AuthFailure -> SessionFailure` translation duplicated across account/auth bridge adapters
3. profile image mutation success-tail logic duplicated across upload/clear use cases

The outcome should reduce future drift, keep ownership explicit, and make the duplication report quieter on real maintainability debt.

## Constraints

- architectural constraints:
  - Keep `features/account` and `features/auth` as separate feature boundaries.
  - Shared account failure mapping should live in the account root error layer, not in `core/`.
  - `AuthFailure -> SessionFailure` translation is a cross-boundary bridge concern and should live at a shared core-boundary/helper location, not copied into each adapter.
  - The profile image mutation extraction should stay inside the profile subfeature; do not promote it to global/shared code.
- product/runtime constraints:
  - Behavior must remain identical for all mapped failure codes and status-code fallbacks.
  - Profile image upload/clear flows must still refresh current user after successful mutation.
- out of scope:
  - `AuthResponseModel` / `AuthResultModel` duplication
  - value-object parallelism such as `GivenName` / `FamilyName` / `DisplayName`
  - adding new lint rules or CI gates for duplication
  - unrelated refactors in auth/account modules

## Acceptance Criteria

1. Account feature uses one shared `ApiFailure -> AuthFailure` mapper for the current duplicated account cases, with all four previous call sites routed through it.
2. Account/auth adapters use one shared `AuthFailure -> SessionFailure` translation helper, with duplicate local `_toSessionFailure` methods removed.
3. Profile image upload and clear flows reuse one shared success-tail helper for `CurrentUserFetcher.fetch()` + `SessionFailure -> AuthFailure` translation.
4. Existing behavior is preserved with focused unit-test coverage for the consolidated mapping logic and profile success-tail logic.
5. The duplication harness no longer reports the three reviewed duplication groups as actionable debt.

## Implementation Checklist

- [x] Introduce an account-root mapper (or small shared mapper function) for `ApiFailure -> AuthFailure` and update:
  - `lib/features/account/data/repository/current_user_repository_impl.dart`
  - `lib/features/account/subfeatures/profile/data/repository/profile_repository_impl.dart`
  - `lib/features/account/subfeatures/profile/data/error/profile_image_failure_mapper.dart`
  - `lib/features/account/subfeatures/security/data/repository/me_session_repository_impl.dart`
  - `lib/features/account/subfeatures/account_deletion/data/repository/account_deletion_repository_impl.dart`
- [x] Add or move tests so the shared account mapper owns the mapping contract for:
  - `validationFailed`
  - `unauthorized`
  - `conflict`
  - `idempotencyInProgress`
  - `notFound`
  - `internal`
  - `rateLimited`
  - fallback status codes (`401`, `404`, `409`, `429`, `500`, `-1`, `-2`, default)
- [x] Extract a shared helper for `AuthFailure -> SessionFailure` translation and update:
  - `lib/features/account/adapters/current_user_fetcher_adapter.dart`
  - `lib/features/auth/adapters/auth_token_refresher_adapter.dart`
- [x] Add focused tests for the shared auth-to-session translation helper.
- [x] Extract a profile-subfeature helper/use case for the duplicated “refresh current user after successful mutation” tail and update:
  - `lib/features/account/subfeatures/profile/domain/usecase/clear_profile_image_usecase.dart`
  - `lib/features/account/subfeatures/profile/domain/usecase/upload_profile_image_usecase.dart`
- [x] Add or update tests to prove the shared profile helper preserves session-failure mapping and success behavior.
- [x] Run the duplication harness and verify the reviewed groups are removed from the actionable report.
- [x] Run analyze, custom lints, relevant tests, and full verify if the change set grows beyond focused unit-test coverage.

## Decision Log

- 2026-04-19: Scope only the three validated duplication groups -> avoids mixing proven consolidation work with lower-confidence duplication candidates.
- 2026-04-19: Keep account failure mapping shared inside `features/account` -> this duplication is feature-specific, not a core-wide contract.
- 2026-04-19: Treat `AuthFailure -> SessionFailure` translation as a bridge helper -> both adapters translate the same two core-domain vocabularies and should not own separate copies.
- 2026-04-19: Keep profile refresh-tail extraction local to the profile subfeature -> the duplicated logic is workflow-specific, not a general-purpose account capability.

## Verification

List exact commands and outcomes.

```bash
fvm flutter test test/core/domain/session/auth_to_session_failure_mapper_test.dart test/features/account/data/error/account_auth_failure_mapper_test.dart test/features/account/adapters/current_user_fetcher_adapter_test.dart test/features/account/subfeatures/profile/domain/usecase/refresh_current_user_after_profile_image_mutation_test.dart test/features/account/subfeatures/profile/domain/usecase/clear_profile_image_usecase_test.dart test/features/account/subfeatures/profile/domain/usecase/upload_profile_image_usecase_test.dart
# Passed

fvm flutter analyze
# Passed

dart run custom_lint
# Passed

dart run mobile_core_kit_cli:mobilekit duplication check --profile core
# Passed; actionable duplicate groups reduced from 6 to 1.
# Remaining group is the intentionally out-of-scope auth_response_model/auth_result_model pair.
```

Additional targeted checks when relevant:

```bash
rm -rf .dart_tool/hooks_runner && fvm flutter pub get
# Required once because flutter test initially hit a stale hooks_runner SDK-hash cache.
```

## Runtime Evidence

Required when the change is medium/high-risk and behavior cannot be proven sufficiently by static checks alone.

- Device/emulator: N/A if unit/integration coverage is sufficient
- Flavor: dev
- Executed target(s): Optional targeted manual spot-check of profile image upload/clear success path
- Artifact path(s): N/A unless manual runtime validation is needed
- Notes: Prefer proving this refactor with focused tests. Runtime evidence is only needed if the upload/clear success-tail refactor cannot be covered adequately by existing test seams.

## Risks And Mitigations

- Risk: Shared mapper extraction changes one failure branch silently.
- Mitigation: Consolidate existing behavior verbatim first, then add exhaustive mapper tests before any cleanup.

- Risk: Shared adapter helper is placed at the wrong boundary and introduces an awkward dependency.
- Mitigation: Keep the helper small and dependency-free; locate it where both adapters can import it without violating architecture lints.

- Risk: Profile helper extraction over-abstracts two use cases that still differ materially.
- Mitigation: Extract only the success-tail (`fetch current user` + session-failure mapping), not the upload/clear workflows themselves.

## Completion Notes

Implemented the three planned consolidations:
- one shared account-root `mapAccountAuthFailure(...)` helper now backs current-user, profile, security, and account-deletion mapping
- one shared core-domain `mapAuthFailureToSessionFailure(...)` helper now backs both bridge adapters
- one shared profile-local `refreshCurrentUserAfterProfileImageMutation(...)` helper now backs both profile image mutation flows

The duplication harness now no longer reports the reviewed mapper/adapter/profile-tail groups. The only remaining actionable group is the auth response/result model pair that was kept explicitly out of scope.

## Follow-ups

- [ ] Add unresolved debt to `docs/exec-plans/tech_debt_tracker.md`
