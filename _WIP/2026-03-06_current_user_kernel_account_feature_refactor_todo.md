# TODO — Current-User Kernel + `account` Feature Refactor

**Companion proposal:** `_WIP/2026-03-06_current_user_kernel_account_feature_engineering_proposal.md`

## Decisions (locked)

- [x] Target architecture is authoritative:
  - `lib/core/**` owns the current-user kernel
  - `lib/features/account/**` owns account-management workflows
  - `lib/features/account/subfeatures/*` are full vertical slices with `data`, `domain`, `presentation`, and `di`
- [x] `features/account` root stays thin:
  - kernel adapters
  - feature entry DI
  - composition pages
  - shared widgets reused across account subfeatures
- [x] `features/user/**` is transitional and must be removed at the end
- [x] `change_password` remains in `features/auth` for this refactor
- [x] No product behavior changes unless explicitly called out in a phase

## Definition of Done

- [x] `core` owns all current-user kernel contracts/runtime:
  - [x] `CurrentUserFetcher`
  - [x] `CachedUserStore`
  - [x] current-user entities
  - [x] `UserContextService`
- [x] `features/account` exists as the account-management feature boundary
- [x] `profile`, `security`, and `account_deletion` are full vertical subfeatures
- [x] `features/account` root contains no workflow-specific repository/usecase/datasource clutter
- [x] `features/user/**` is deleted
- [x] navigation and DI use `account` naming/ownership consistently
- [x] tests are updated for all moved paths
- [ ] `dart run tool/verify.dart --env dev` passes

## Phase 0 — Baseline, guardrails, and inventory

- [x] Re-run full verification baseline:
  - [x] `dart run tool/verify.dart --env dev`
- [x] Freeze current architectural rules in this document:
  - [x] kernel vs feature vs subfeature ownership
  - [x] thin `features/account` root rule
  - [x] no workflow code in `core`
- [x] Inventory current `features/user/**` into target buckets:
  - [x] current-user kernel support
  - [x] account root composition
  - [x] profile
  - [x] security
  - [x] account deletion
- [x] Inventory all route files and imports that reference `user`
- [x] Inventory all tests mirroring `features/user/**`
- [x] Inventory generated files (`*.freezed.dart`, `*.g.dart`) that must move with source files

### Phase 0 output — verification baseline (2026-03-07)

Command:

```bash
dart run tool/verify.dart --env dev
```

Result:

- Substantive verification steps passed:
  - `flutter pub get`
  - env schema validation
  - build config generation
  - `flutter gen-l10n`
  - untranslated message verification
  - AGENTS project map drift verification
  - `flutter analyze`
  - `dart run custom_lint`
  - modal entrypoint verification
  - hardcoded UI color verification
  - full `flutter test` suite
- Final status: non-zero exit at the last formatter check
- Existing files reformatted by the final step:
  - `lib/app.dart`
  - `lib/features/user/data/model/remote/request_account_deletion_request_model.dart`
  - `lib/features/user/domain/entity/request_account_deletion_request_entity.dart`
- Phase 0 decision:
  - leave those formatter-only changes untouched
  - do not include them in this refactor scope

### Phase 0 output — current `features/user` inventory

Current counts:

- `lib/features/user/**`: 125 files
- generated files under `lib/features/user/**`: 37 files
- `test/features/user/**`: 25 test files

Bucket summary:

- Current-user kernel support / feature-root support: 7 clearly-root files
  - `data/datasource/local/user_local_datasource.dart`
  - `data/datasource/remote/user_remote_datasource.dart`
  - `data/datasource/remote/me_push_token_remote_datasource.dart`
  - `data/model/local/user_local_model.dart`
  - `data/model/local/user_local_model.freezed.dart`
  - `data/services/user_avatar_cache_session_listener.dart`
  - `di/user_module.dart`
- Account root composition: 3 files
  - `presentation/pages/profile_page.dart`
  - `presentation/widgets/locale_setting_tile.dart`
  - `presentation/widgets/theme_mode_setting_tile.dart`
- Profile slice: 65 files
  - draft persistence
  - profile mutation
  - profile image upload/clear
  - avatar cache/download
  - complete-profile cubit/page
- Security slice: 24 files
  - active sessions remote/data/domain/presentation
  - `security_privacy_page.dart`
- Account deletion slice: 15 files
  - request/cancel deletion entities, models, use cases, cubit, page, localizer
- Ambiguous flat-root files still needing Phase 6 cleanup: 11 files
  - `data/datasource/local/dao/user_dao.dart`
  - `data/error/user_failure_mapper.dart`
  - `data/model/remote/me_push_token_upsert_request_model.*`
  - `data/model/remote/patch_me_request_model.*`
  - `data/repository/user_repository_impl.dart`
  - `domain/repository/user_repository.dart`
  - `domain/usecase/get_me_usecase.dart`

### Phase 0 output — route inventory

- Route files under current user namespace:
  - `lib/navigation/user/user_routes.dart`
  - `lib/navigation/user/user_routes_list.dart`
- Current navigation/test/doc references using `user` naming or paths: 31 hits across:
  - `lib/navigation/**`
  - `test/navigation/**`
  - `docs/core/**`
  - `docs/explainers/core/**`
  - `docs/explainers/features/**`
- Current `core -> features/user` direct import count:
  - 1 real import, in composition root only:
    - `lib/core/di/registrars/feature_modules_registrar.dart`

### Phase 0 output — test inventory

- `test/features/user/**`: 25 test files
- Covered areas:
  - local datasources
  - remote datasources
  - failure mappers
  - repositories
  - domain use cases
  - domain value objects
  - presentation cubits
  - user pages (`me_sessions`, `request_account_deletion`)

### Phase 0 output — generated file inventory

- Generated files to move with source files: 37
- Main generated hotspots:
  - request/response models under `data/model/remote/**`
  - local model under `data/model/local/**`
  - domain entities under `domain/entity/**`
  - Freezed presentation state files under `presentation/cubit/**`

## Phase 1 — Create `features/account` root and kernel adapter boundary

Goal: establish the new top-level boundary before moving workflows.

- [x] Create `lib/features/account/`
- [ ] Add thin feature root folders:
  - [x] `adapters/`
  - [x] `di/`
  - [ ] `presentation/pages/`
  - [ ] `presentation/widgets/`
- [x] Add `lib/features/account/di/account_module.dart`
- [x] Add `lib/features/account/di/account_kernel_adapter_module.dart`
- [x] Add explicit kernel adapter files:
  - [x] `lib/features/account/adapters/current_user_fetcher_adapter.dart`
  - [x] `lib/features/account/adapters/cached_user_store_adapter.dart`
- [x] Extract current `CurrentUserFetcher` implementation out of:
  - [x] `lib/features/user/di/user_module.dart`
- [x] Stop using a datasource itself as the kernel port implementation:
  - [x] `CachedUserStore` should be implemented by an explicit adapter, not directly by the account datasource
- [x] Register `CurrentUserFetcher` from `AccountKernelAdapterModule`
- [x] Register `CachedUserStore` from `AccountKernelAdapterModule`
- [x] Keep `core` depending only on:
  - [x] `CurrentUserFetcher`
  - [x] `CachedUserStore`
- [ ] Keep the app composition root wiring clean:
  - [x] update `lib/core/di/registrars/feature_modules_registrar.dart`

### Phase 1 output — adapter boundary extraction (2026-03-07)

- New account-root DI boundary:
  - `lib/features/account/di/account_module.dart`
  - `lib/features/account/di/account_kernel_adapter_module.dart`
- New explicit kernel adapters:
  - `lib/features/account/adapters/current_user_fetcher_adapter.dart`
  - `lib/features/account/adapters/cached_user_store_adapter.dart`
- `CurrentUserFetcher` no longer lives as a private class inside `UserModule`
- `CachedUserStore` is no longer implemented directly by `UserLocalDataSource`
- Core composition now imports `AccountModule` instead of `UserModule`
- Temporary architecture-lint exception added:
  - `features/account/{adapters,di}` may import transitional `features/user/**`
  - this exception must be removed once later phases move the workflow code

## Phase 2 — Move account root composition pages and shared widgets

Goal: move non-workflow root composition out of `features/user`.

- [x] Decide root account composition page naming:
  - [ ] `account_home_page.dart`
  - [x] or `account_page.dart`
- [x] Move/rename current composition page(s):
  - [x] `lib/features/user/presentation/pages/profile_page.dart`
  - [x] any account-root presentation that is not owned by a single subfeature
- [ ] Move shared root widgets if reused across multiple subfeatures:
  - [x] `locale_setting_tile.dart`
  - [x] `theme_mode_setting_tile.dart`
- [x] Keep root composition light:
  - [x] no workflow-specific use cases
  - [x] no workflow-specific repositories

### Phase 2 output — root account composition move (2026-03-07)

- Root composition page renamed and moved:
  - from `lib/features/user/presentation/pages/profile_page.dart`
  - to `lib/features/account/presentation/pages/account_page.dart`
- Shared account-root widgets moved:
  - `lib/features/account/presentation/widgets/locale_setting_tile.dart`
  - `lib/features/account/presentation/widgets/theme_mode_setting_tile.dart`
- `app_router` now renders `AccountPage` for the shell profile tab
- Temporary architecture-lint exception added:
  - `features/account/presentation/**` may depend on transitional `features/user/**`
  - remove this once the profile-image flow moves into the account/profile subfeature

## Phase 3 — Profile subfeature full vertical split

Goal: `profile` becomes a complete vertical slice.

- [x] Create `lib/features/account/subfeatures/profile/`
- [x] Add:
  - [x] `data/`
  - [x] `domain/`
  - [x] `presentation/`
  - [x] `di/`

### Presentation
- [x] Move:
  - [x] `lib/features/user/presentation/cubit/complete_profile/**`
  - [x] `lib/features/user/presentation/cubit/profile_image/**`
  - [x] `lib/features/user/presentation/pages/complete_profile_page.dart`
- [x] Move any profile-owned widgets under:
  - [x] `subfeatures/profile/presentation/widgets/` (none required)

### Domain
- [x] Move profile-owned entities/value objects:
  - [x] `patch_me_profile_request_entity.dart`
  - [x] `profile_draft_entity.dart`
  - [x] `profile_image_*`
  - [x] `profile_avatar_cache_entry_entity.dart`
  - [x] `given_name.dart`
  - [x] `family_name.dart`
- [x] Move profile-owned repositories:
  - [x] `profile_draft_repository.dart`
  - [x] `profile_image_repository.dart`
  - [x] `profile_avatar_repository.dart`
  - [x] split patch profile into `profile_repository.dart`
- [x] Move profile-owned use cases:
  - [x] draft use cases
  - [x] patch profile use case
  - [x] profile image use cases
  - [x] avatar cache use cases

### Data
- [x] Move local datasources:
  - [x] `profile_draft_local_datasource.dart`
  - [x] `profile_avatar_cache_local_datasource.dart`
- [x] Move remote datasources:
  - [x] `profile_image_remote_datasource.dart`
  - [x] `profile_avatar_download_datasource.dart`
  - [x] split patch profile into `profile_remote_datasource.dart`
- [x] Move repositories:
  - [x] `profile_draft_repository_impl.dart`
  - [x] `profile_image_repository_impl.dart`
  - [x] `profile_avatar_repository_impl.dart`
  - [x] split patch profile into `profile_repository_impl.dart`
- [x] Move profile-related error mappers/codes
- [x] Move associated models and generated files

### DI
- [x] Add `lib/features/account/subfeatures/profile/di/account_profile_module.dart`
- [x] Register all profile datasources, repositories, use cases, cubits

### Phase 3 output — profile vertical split (2026-03-07)

- New full profile slice under `lib/features/account/subfeatures/profile/**`
- New DI boundary:
  - `lib/features/account/subfeatures/profile/di/account_profile_module.dart`
- `account_page.dart` and complete-profile routing now depend on account/profile presentation instead of legacy `features/user` presentation
- Patch-profile behavior is no longer owned by the flat `UserRepository`
  - new `ProfileRemoteDataSource`
  - new `ProfileRepository`
  - new `ProfileRepositoryImpl`
- Profile image refresh now depends on the core `CurrentUserFetcher` kernel port instead of `GetMeUseCase`
- Avatar session cleanup renamed to `ProfileAvatarCacheSessionListener`
- Legacy `features/user` kept only the remaining current-user, security, and account-deletion responsibilities
- Verification status:
  - `fvm flutter analyze` — passed
  - `dart run custom_lint` — passed
  - `fvm flutter test test/features/account/subfeatures/profile` — blocked by the existing local Flutter SDK / `dart:ui` mismatch, not by Phase 3 code

## Phase 4 — Security subfeature full vertical split

Goal: `security` becomes a complete vertical slice.

- [x] Create `lib/features/account/subfeatures/security/`
- [x] Add:
  - [x] `data/`
  - [x] `domain/`
  - [x] `presentation/`
  - [x] `di/`

### Presentation
- [x] Move:
  - [x] `lib/features/user/presentation/cubit/me_sessions/**`
  - [x] `lib/features/user/presentation/pages/me_sessions_page.dart`
  - [x] `lib/features/user/presentation/pages/security_privacy_page.dart`
  - [x] `lib/features/user/presentation/widgets/skeleton/me_sessions_skeleton.dart`

### Domain
- [x] Move security-owned entities:
  - [x] `me_session_entity.dart`
  - [x] `list_me_sessions_request_entity.dart`
  - [x] `revoke_me_session_request_entity.dart`
- [x] Move security repository:
  - [x] `me_session_repository.dart`
    - [x] keep `MeSessionRepository`; the narrower name is still clear
- [x] Move security use cases:
  - [x] `list_me_sessions_usecase.dart`
  - [x] `revoke_me_session_usecase.dart`

### Data
- [x] Move remote datasource:
  - [x] `me_session_remote_datasource.dart`
- [x] Move repository implementation:
  - [x] `me_session_repository_impl.dart`
- [x] Move related request/response models and generated files
- [x] Add a security-local failure mapper to avoid a reverse dependency on `features/user/**`

### DI
- [x] Add `lib/features/account/subfeatures/security/di/account_security_module.dart`
- [x] Register all security datasources, repositories, use cases, cubits

### Verification notes
- `fvm flutter analyze` passes
- `dart run tool/verify_project_map_drift.dart` passes
- `dart run custom_lint` currently hangs in this environment; a bounded retry (`timeout 30s dart run custom_lint --no-fatal-infos`) timed out without diagnostics after stale lint daemons were cleared

## Phase 5 — Account deletion subfeature full vertical split

Goal: `account_deletion` becomes a complete vertical slice.

- [x] Create `lib/features/account/subfeatures/account_deletion/`
- [x] Add:
  - [x] `data/`
  - [x] `domain/`
  - [x] `presentation/`
  - [x] `di/`

### Presentation
- [x] Move:
  - [x] `lib/features/user/presentation/cubit/request_account_deletion/**`
  - [x] `lib/features/user/presentation/pages/request_account_deletion_page.dart`
  - [x] `lib/features/user/presentation/localization/account_deletion_failure_localizer.dart`

### Domain
- [x] Move deletion-owned repository:
  - [x] split current deletion operations away from flat `UserRepository`
- [x] Move deletion-owned request entities:
  - [x] `request_account_deletion_request_entity.dart`
  - [x] `cancel_account_deletion_request_entity.dart`
- [x] Move deletion use cases:
  - [x] `request_account_deletion_usecase.dart`
  - [x] `cancel_account_deletion_usecase.dart`
- [x] Keep `AccountDeletionEntity` in `core` if it remains part of canonical `/me` shape

### Data
- [x] Split deletion API behavior away from the flat user repository implementation
- [x] Move deletion-specific datasource/repository code
- [x] Move deletion-specific request models and generated files
- [x] Add a dedicated deletion failure mapper if the current generic mapper is too broad

### DI
- [x] Add `lib/features/account/subfeatures/account_deletion/di/account_deletion_module.dart`
- [x] Register all deletion datasources, repositories, use cases, cubits

### Verification notes
- `fvm flutter analyze` passes
- `dart run tool/verify_project_map_drift.dart` passes
- `dart run custom_lint` still hangs in this environment even after stale lint daemons were cleared; a bounded retry did not produce diagnostics
- `fvm flutter test test/features/account/subfeatures/account_deletion` is blocked by the existing local Flutter SDK / `dart:ui` mismatch, not by Phase 5 code

## Phase 6 — Current-user adapter support infrastructure

Goal: the `account` feature fully backs kernel ports without relying on `features/user`.

- [x] Move current-user remote fetch support out of `features/user`:
  - [x] `user_remote_datasource.dart`
  - [x] any flat user repository code used only for `/me`
- [x] Move cached-user local persistence support out of `features/user`:
  - [x] `user_local_datasource.dart`
  - [x] `data/datasource/local/dao/user_dao.dart`
  - [x] `data/model/local/user_local_model.dart`
- [x] Rename moved account-side current-user support code if it improves clarity:
  - [x] `me_remote_datasource.dart`
  - [x] `account_cached_user_local_datasource.dart`
- [x] Ensure this support code stays outside workflow subfeatures and outside `core`
- [x] Ensure only adapters expose these kernel-backed capabilities to `core`

Implementation notes:

- Current-user support now lives in `lib/features/account/data/**` and `lib/features/account/domain/**`.
- `AccountCurrentUserModule` now owns:
  - cached-user DB bootstrap
  - `/me` remote fetch support
  - `PushTokenRegistrar` binding
  - `CurrentUserRepository`
  - `GetCurrentUserUseCase`
- `AccountKernelAdapterModule` now depends only on account-side current-user support.
- App integration tests were decoupled from repository internals and now fake `CurrentUserFetcher` directly.

### Verification notes
- `fvm flutter analyze` passes
- `dart run tool/verify_project_map_drift.dart` passes
- `dart test test/features/account/adapters/current_user_fetcher_adapter_test.dart` passes
- `dart run custom_lint` still hangs in this environment; a bounded retry (`timeout 30s dart run custom_lint --no-fatal-infos`) timed out without diagnostics
- `fvm flutter test test/features/account/data/datasource/local/account_cached_user_local_datasource_test.dart` is still blocked by the existing local Flutter SDK / `dart:ui` mismatch, not by Phase 6 code

## Phase 7 — Repository and naming cleanup

Goal: remove historical flat contracts and align naming to the new architecture.

- [x] Delete the old flat `UserRepository` contract
- [x] Delete the old flat `UserRepositoryImpl`
- [x] Remove any remaining mixed-responsibility repository methods
- [x] Rename `navigation/user/**` to `navigation/account/**`
- [ ] Decide route path stability policy:
  - [x] keep existing `/user/...` paths temporarily if deep-link stability matters
  - [ ] or rename to `/account/...` if safe and intentional
- [x] Update imports across:
  - [x] app code
  - [x] tests
  - [x] docs

### Phase 7 output — navigation/account naming cleanup (2026-03-07)

- Route namespace moved:
  - from `lib/navigation/user/**`
  - to `lib/navigation/account/**`
- Route constant type renamed:
  - from `UserRoutes`
  - to `AccountRoutes`
- Route list renamed:
  - from `userRoutes`
  - to `accountRoutes`
- App code, navigation guards, tests, and affected docs now import the account namespace
- Route path strings intentionally remain stable as `/user/...` in this phase to avoid deep-link churn while the architectural cutover is still in progress

### Verification notes
- `fvm flutter analyze` passes
- `dart run tool/verify_project_map_drift.dart` passes
- `timeout 30s dart run custom_lint --no-fatal-infos` still times out in this environment without diagnostics
- `fvm flutter test test/navigation/app_redirect_test.dart` is still blocked by the existing local Flutter SDK / `dart:ui` mismatch, not by Phase 7 code

## Phase 8 — Remove `features/user` and finalize docs

Goal: complete the cutover.

- [x] Delete `lib/features/user/**`
- [x] Delete `UserModule`
- [x] Remove `features/user` references from:
  - [x] DI registrars
  - [x] routes
  - [x] docs
  - [x] `_WIP` documents where relevant
- [x] Update architecture docs if this refactor becomes the new canonical standard

### Phase 8 output — final account cutover cleanup (2026-03-07)

- `lib/features/user/**` is fully removed from tracked source
- `UserModule` is gone; `AccountModule` is the feature entrypoint
- Live feature explainers moved:
  - from `docs/explainers/features/user/**`
  - to `docs/explainers/features/account/**`
- Feature explainer index updated to the account namespace
- Historical `_WIP/examples/**` files intentionally retain old `features/user` references as archive material and are not part of runtime ownership

## Phase 9 — Verification and closeout

- [x] Run focused checks during each phase:
  - [x] `fvm flutter analyze`
  - [x] `dart run custom_lint`
  - [x] `fvm flutter test`
  - [x] `dart run tool/verify_project_map_drift.dart`
- [x] Run full verification at milestone boundaries:
  - [x] `dart run tool/verify.dart --env dev`
- [x] Confirm no stale `features/user` imports remain:
  - [x] `rg -n "features/user" lib test docs`
- [x] Confirm no stale `navigation/user` imports remain

### Phase 9 output — final verification and closeout (2026-03-07)

- Full verification passed:
  - `dart run tool/verify.dart --env dev`
- Verified clean source/doc cutover:
  - `rg -n "features/user|navigation/user" lib test integration_test docs`
- Canonical docs now describe the account/current-user ownership model:
  - `docs/template/current_user.md`
  - `docs/engineering/project_architecture.md`
  - `docs/core/session/components.md`
  - `docs/core/session/flows.md`

## Notes

- This TODO is intentionally phased for reversible implementation.
- The target architecture should remain strict even if some intermediate phases use transitional wiring.
- If a phase reveals a boundary mistake, update the proposal and this TODO before continuing further.
