# Engineering Proposal: Current-User Kernel in `core` + Full Vertical `account` Feature

**Companion TODO:** `_WIP/2026-03-06_current_user_kernel_account_feature_refactor_todo.md`

## Goal
Adopt a stricter architecture that separates:

1. the current-user kernel
2. account-management product workflows

The target architecture is:

- `lib/core/**` owns the current-user kernel
- `lib/features/account/**` owns account-management workflows
- `lib/features/account/subfeatures/*` are full vertical slices with their own `data`, `domain`, `presentation`, and `di`

This proposal treats that as the target architecture, not a migration-friendly compromise.

## Executive Summary
The current codebase is still carrying an overloaded `user` feature that acts as both:

- a shared identity/runtime foundation
- a product feature for profile, sessions, and account deletion

That is the wrong boundary.

The cleaner target state is:

- `core` defines and owns the signed-in identity kernel
- `account` is the business feature for account management
- each account workflow is isolated as a full vertical subfeature

So the system becomes:

```text
core = current-user kernel
account = account-management feature
profile / security / account_deletion = account subfeatures
```

## The Problem We Are Solving
Today the old `user` area bundles together concerns with different reasons to change:

- current-user fetch and cached-user persistence
- profile editing and profile completion
- profile image upload and avatar cache/download
- active sessions and revoke
- account deletion request/cancel
- runtime-facing adapters such as `CurrentUserFetcher` and `CachedUserStore`

This creates the wrong dependency shape:

- runtime identity support lives beside destructive account workflows
- one feature/module changes for unrelated business reasons
- a flat feature boundary hides real workflow ownership

The issue is not "too many files." The issue is "wrong architectural boundary."

## Why This Proposal Is Grounded in the Current Repo
The current-user kernel already partially exists in `core`:

- [`lib/core/domain/user/current_user_fetcher.dart`](/home/fikrilal/devs/core/mobile-core-kit/lib/core/domain/user/current_user_fetcher.dart)
- [`lib/core/domain/user/entity/user_entity.dart`](/home/fikrilal/devs/core/mobile-core-kit/lib/core/domain/user/entity/user_entity.dart)
- [`lib/core/domain/session/cached_user_store.dart`](/home/fikrilal/devs/core/mobile-core-kit/lib/core/domain/session/cached_user_store.dart)
- [`lib/core/runtime/user_context/user_context_service.dart`](/home/fikrilal/devs/core/mobile-core-kit/lib/core/runtime/user_context/user_context_service.dart)

So this is not inventing a new direction. It is finishing a split that has already started.

## Recommendation
Replace the current mental model:

- "`user` owns everything related to a signed-in person"

with this:

- `core` owns current-user identity kernel
- `account` owns account-management workflows
- `account` is decomposed into full vertical subfeatures

## Architectural Definitions

### Current-user kernel
The current-user kernel answers:

- who is the currently authenticated user?
- how does runtime fetch/cache that user?
- how do other app layers read that user safely?

It should be small, stable, and cross-cutting.

### Account feature
The account feature answers:

- how can the authenticated person manage their account?

That includes:

- profile management
- account security / active sessions
- account deletion
- settings/security composition screens

### Subfeature
Each workflow under `account` should be a full vertical slice:

- `data`
- `domain`
- `presentation`
- `di`

If a slice has separate endpoints, contracts, and UI flow, it should own the full stack.

## Target Architecture

```text
lib/core/
  domain/
    user/
      current_user_fetcher.dart
      entity/
        user_entity.dart
        user_profile_entity.dart
        account_deletion_entity.dart
    session/
      cached_user_store.dart
  runtime/
    user_context/
      user_context_service.dart
      current_user_state.dart
      user_data_slice.dart

lib/features/account/
  adapters/
    current_user_fetcher_adapter.dart
    cached_user_store_adapter.dart
  di/
    account_module.dart
    account_kernel_adapter_module.dart
  presentation/
    pages/
      account_home_page.dart
    widgets/
      ...
  subfeatures/
    profile/
      data/
        datasource/
          local/
            profile_draft_local_datasource.dart
            profile_avatar_cache_local_datasource.dart
          remote/
            profile_remote_datasource.dart
            profile_image_remote_datasource.dart
            profile_avatar_download_datasource.dart
        error/
          profile_failure_mapper.dart
          profile_image_failure_mapper.dart
        repository/
          profile_repository_impl.dart
          profile_image_repository_impl.dart
          profile_avatar_repository_impl.dart
      domain/
        entity/
        value/
        repository/
          profile_repository.dart
          profile_image_repository.dart
          profile_avatar_repository.dart
        usecase/
          patch_me_profile_usecase.dart
          get_profile_draft_usecase.dart
          save_profile_draft_usecase.dart
          clear_profile_draft_usecase.dart
          upload_profile_image_usecase.dart
          clear_profile_image_usecase.dart
          get_profile_image_url_usecase.dart
          get_cached_profile_avatar_usecase.dart
          refresh_profile_avatar_cache_usecase.dart
          save_profile_avatar_cache_usecase.dart
          clear_profile_avatar_cache_usecase.dart
          clear_all_profile_avatar_caches_usecase.dart
      presentation/
        cubit/
        pages/
        widgets/
      di/
        account_profile_module.dart
    security/
      data/
        datasource/
          remote/
            account_security_remote_datasource.dart
        repository/
          account_security_repository_impl.dart
      domain/
        entity/
        repository/
          account_security_repository.dart
        usecase/
          list_me_sessions_usecase.dart
          revoke_me_session_usecase.dart
      presentation/
        cubit/
        pages/
        widgets/
      di/
        account_security_module.dart
    account_deletion/
      data/
        datasource/
          remote/
            account_deletion_remote_datasource.dart
        error/
          account_deletion_failure_mapper.dart
        repository/
          account_deletion_repository_impl.dart
      domain/
        entity/
        repository/
          account_deletion_repository.dart
        usecase/
          request_account_deletion_usecase.dart
          cancel_account_deletion_usecase.dart
      presentation/
        cubit/
        pages/
        localization/
      di/
        account_deletion_module.dart
```

## Boundary Rules

### What belongs in `core`
`core` should own only the current-user kernel:

- current-user entities
- `CurrentUserFetcher`
- `CachedUserStore`
- user-context runtime state/service
- signed-in identity semantics needed by the whole app

`core` should not own:

- profile-editing workflow logic
- sessions page workflow logic
- account deletion workflow logic
- account settings UI composition

### What belongs in `features/account` root
The `account` root should stay thin.

It may contain:

- adapters that implement core ports
- top-level account composition pages
- feature entry DI
- shared widgets reused by multiple account subfeatures

It should not become another dumping ground for workflow-specific repositories/use cases/datasources.

### What belongs in `features/account/subfeatures/*`
Any workflow-specific concern should live in the owning subfeature.

Examples:

- profile-specific DTOs and repositories belong in `subfeatures/profile`
- sessions-specific entities and use cases belong in `subfeatures/security`
- deletion-specific failures and cubits belong in `subfeatures/account_deletion`

If only one workflow owns it, it should not sit at the feature root.

## Why Full Vertical Subfeatures Are the Correct Target
This is the key correction to the earlier draft.

The account subfeatures should not be presentation-only splits.

They should be full vertical slices because each of these workflows already has distinct:

1. endpoints and datasources
2. repositories
3. use cases
4. failure mapping
5. state management
6. product/security/compliance semantics

That means a presentation-only split would be cosmetic.  
A full vertical split is the architecturally correct end state.

## Concrete Ownership

### `core` current-user kernel
Owns:

- `UserEntity`
- `UserProfileEntity`
- `AccountDeletionEntity` only if it remains part of the canonical current-user shape returned by `/me`
- `CurrentUserFetcher`
- `CachedUserStore`
- `UserContextService`

### `features/account/adapters`
Owns the concrete implementations of kernel ports:

- `CurrentUserFetcher` adapter backed by `/me`
- `CachedUserStore` adapter backed by local account persistence

These are adapters because they serve the kernel, but they are implemented using account infrastructure.

### `subfeatures/profile`
Owns:

- complete profile
- patch profile
- profile draft
- profile image upload/clear
- avatar cache/download

### `subfeatures/security`
Owns:

- active sessions list
- revoke session
- security/privacy workflow screens

### `subfeatures/account_deletion`
Owns:

- request account deletion
- cancel account deletion
- deletion-specific error localization and state flow

## Repository Contract Split
The old flat `UserRepository` should not survive into the target architecture.

Do not keep a repository that mixes:

- current-user fetch
- profile mutation
- account deletion

Instead:

- account root adapter layer may have a `CurrentUserRepository` only if needed to back the `CurrentUserFetcher` adapter
- `subfeatures/profile` owns `ProfileRepository`
- `subfeatures/security` owns `AccountSecurityRepository`
- `subfeatures/account_deletion` owns `AccountDeletionRepository`

Each repository should map to one cohesive workflow area.

## DI Strategy
The account feature should compose like this:

```dart
class AccountModule {
  static void register(GetIt getIt) {
    AccountKernelAdapterModule.register(getIt);
    AccountProfileModule.register(getIt);
    AccountSecurityModule.register(getIt);
    AccountDeletionModule.register(getIt);
  }
}
```

This keeps:

- one entrypoint for feature registration
- one adapter module for kernel ports
- one DI module per full vertical subfeature

## Why This Is Better Than `user + subfeatures`
`user + subfeatures` is the lower-risk cleanup. It is not the cleaner architecture.

This proposal is better because it fixes three things at once:

1. semantic naming
   - `account` is the real product area
2. kernel ownership
   - current-user identity belongs to `core`, not a product feature
3. workflow ownership
   - profile/security/deletion become true vertical slices

So this is a stronger final architecture than keeping everything under `user`, even if better organized.

## Why This Is Better Than Splitting into Multiple Top-Level Features
Do not split into:

- `features/profile`
- `features/security`
- `features/account_deletion`

as separate top-level features.

That is too fragmented because these flows still share:

- authenticated account context
- account navigation/composition
- common owner/team boundary
- the same current-user kernel

`account` is the right business-area boundary.  
`profile`, `security`, and `account_deletion` are the right workflow slices beneath it.

## Risks

### 1. Rename churn
Renaming `user` to `account` touches:

- imports
- routes
- docs
- tests
- DI

That is real cost, but it is not a reason to keep the wrong architecture forever.

### 2. Overloading `core`
There is a risk of putting too much product logic into the kernel.

Mitigation:
- enforce a strict rule that `core` owns contracts/runtime only
- no account workflow state machines in `core`

### 3. Thin-root discipline
There is a risk that `features/account` root becomes the new dumping ground.

Mitigation:
- keep root limited to adapters, composition, and feature entry DI
- require workflow-specific code to live inside the owning subfeature

## Non-Goals
- redesigning session architecture
- changing backend contracts
- moving change-password ownership out of `auth` in the same effort
- package extraction

## Success Criteria
1. `core` owns all current-user identity kernel contracts and runtime orchestration.
2. `features/account` exists as the account-management product boundary.
3. `profile`, `security`, and `account_deletion` are full vertical subfeatures.
4. Workflow-specific data/domain code no longer sits at the feature root.
5. No product workflow code remains inside the current-user kernel.

## Migration Notes
Migration should still be incremental, but the target state above should remain authoritative.

Recommended sequence:

1. create `features/account`
2. move account workflow presentation into full subfeature folders
3. move workflow-owned data/domain contracts into the same subfeatures
4. add account adapter modules for `CurrentUserFetcher` and `CachedUserStore`
5. delete `features/user` after the account cutover is complete

The migration path may be gradual.  
The target architecture should not be diluted because of migration convenience.
