# TODO — Profile Avatar Disk Cache (TTL + fileId invalidation)

## Decisions (locked)

- TTL default: **7 days**
- Invalidate cache when `profileImageFileId` changes (from `/me`)
- UI uses **disk only** (no URL state in Cubit/UI); presigned URL is used only transiently to download bytes.

---

## Phase 0 — Baseline + verification setup

- [x] Confirm current entry points:
  - [x] Profile tab creates `ProfileImageCubit` in router (`..loadUrl()` today).
  - [x] Profile UI uses `AppAvatar(imageUrl: ...)`.
- [x] Ensure verification commands work:
  - [x] `flutter analyze`
  - [x] `dart run custom_lint`
  - [x] `flutter test`

---

## Phase 1 — Data layer: local cache + downloader

### 1.1 Local datasource (disk + metadata)

- [x] Create `lib/features/user/data/datasource/local/profile_avatar_cache_local_datasource.dart`
  - [x] TTL = `Duration(days: 7)` default (injectable for tests).
  - [x] Per-user keys:
    - [x] `user_profile_avatar_cached_at:<userId>` → epoch ms
    - [x] `user_profile_avatar_file_id:<userId>` → string
  - [x] File path (per user):
    - [x] `getApplicationSupportDirectory()/user/profile_avatar/<userId>/avatar.bin`
  - [x] Public API:
    - [x] `get({userId, profileImageFileId})`
    - [x] `save({userId, profileImageFileId, bytes})`
    - [x] `clear({userId})`
    - [x] `clearAll()`
  - [x] Ensure fail-safe cleanup:
    - [x] If file missing but prefs exist → clear prefs.
    - [x] If fileId mismatch → delete old file + clear prefs.

### 1.2 Download datasource (presigned render URL → bytes)

- [x] Create presigned download plumbing:
  - [x] `lib/core/network/download/presigned_download_client.dart`
  - [x] `lib/core/network/download/dio_presigned_download_client.dart`
- [x] Create feature wrapper `lib/features/user/data/datasource/remote/profile_avatar_download_datasource.dart`
  - [x] Never log the URL.
  - [x] Public API:
    - [x] `downloadBytes({required String url})`

---

## Phase 2 — Domain layer: usecases + small domain contract

### 2.1 Domain entity (small, stable)

- [x] Add `lib/features/user/domain/entity/profile_avatar_cache_entry_entity.dart`
  - [x] `String filePath`
  - [x] `DateTime cachedAt`
  - [x] `bool isExpired`

### 2.2 Repository contract

- [x] Add dedicated `ProfileAvatarRepository` (preferred)
  - [x] `getCachedAvatar({userId, profileImageFileId})`
  - [x] `refreshAvatar({userId, profileImageFileId})`
  - [x] `clearAvatar({userId})`
  - [x] `clearAllAvatars()`

### 2.3 Usecases

- [x] Create usecases:
  - [x] `GetCachedProfileAvatarUseCase`
  - [x] `RefreshProfileAvatarCacheUseCase`
  - [x] `ClearProfileAvatarCacheUseCase`
  - [x] `ClearAllProfileAvatarCachesUseCase`

---

## Phase 3 — Data layer: repository implementation

- [x] Implement repository:
  - [x] Wire `ProfileImageRemoteDataSource` (existing `getProfileImageUrl`) + download datasource + local cache datasource.
  - [x] Avoid `imageUrl` persistence (URL is used only to download bytes).
  - [x] Map API failures via `mapProfileImageFailure` and download failures to `AuthFailure`.

---

## Phase 4 — DI wiring

- [x] Register datasources + repository + usecases in DI:
  - [x] `lib/core/di/service_locator.dart` registers `PresignedDownloadClient`.
  - [x] `lib/features/user/di/user_module.dart` registers:
    - [x] `ProfileAvatarCacheLocalDataSource`
    - [x] `ProfileAvatarDownloadDataSource`
    - [x] `ProfileAvatarRepository`
    - [x] `GetCachedProfileAvatarUseCase`
    - [x] `RefreshProfileAvatarCacheUseCase`
    - [x] `ClearProfileAvatarCacheUseCase`
    - [x] `ClearAllProfileAvatarCachesUseCase`

---

## Phase 5 — Presentation: Cubit + state changes (remove URL state)

### 5.1 State changes

- [x] Update `lib/features/user/presentation/cubit/profile_image/profile_image_state.dart`
  - [x] Remove `imageUrl`
  - [x] Add `String? cachedFilePath`
  - [ ] Add `bool isStaleCacheShown` or derive from `cachedFilePath != null && isRefreshing` (optional)

### 5.2 Cubit changes

- [x] Update `ProfileImageCubit`:
  - [x] Replace `loadUrl()` with `loadAvatar()` (or `init()`)
    - [x] Read `userId` + `profileImageFileId` from `UserContextService` (inject or pass in call).
    - [x] Call `GetCachedProfileAvatarUseCase`
    - [x] If cache hit (not expired) → emit `cachedFilePath` and stop.
    - [x] If cache hit (expired) → emit `cachedFilePath` then refresh in background.
    - [x] If cache miss → refresh immediately.
  - [x] Upload flow:
    - [x] After successful upload: save picked bytes to cache immediately using `profileImageFileId` (may require pulling updated `/me` or returning it from upload completion).
  - [x] Clear flow:
    - [x] After successful clear: clear cache + clear `cachedFilePath`.
  - [x] Ensure no UI relies on URL string anymore.

### 5.3 Router initialization

- [x] Update `lib/navigation/app_router.dart`
  - [x] Replace `..loadUrl()` with `..loadAvatar()` (or equivalent)

---

## Phase 6 — UI integration (Profile page)

- [x] Update `lib/features/user/presentation/pages/profile_page.dart`
  - [x] Read `cachedFilePath` from cubit state
  - [x] Use `AppAvatar(imageProvider: FileImage(File(path)))`
  - [x] Remove `imageUrl` usage entirely
  - [x] Expected UX:
    - Cached file exists → instant avatar (no placeholder)
    - Missing cache → placeholder until download completes
    - Expired cache → show stale immediately, refresh silently

---

## Phase 7 — Session integration (cache cleanup)

- [x] Clear avatar cache on:
  - [x] `SessionCleared`
  - [x] `SessionExpired`
- [x] Prefer `clearAll()` (simpler, avoids needing userId during teardown).

---

## Phase 8 — Tests

### 8.1 Local datasource tests

- [x] Add tests under `test/features/user/data/datasource/local/`:
  - [x] save + get returns entry
  - [x] expired sets `isExpired=true` but still returns path
  - [x] file missing clears prefs
  - [x] fileId mismatch invalidates + deletes file
  - [x] clear removes file + prefs

### 8.2 Cubit tests (bloc_test)

- [x] Cache hit (not expired) → emits cached path, no refresh called
- [x] Cache expired → emits cached path, refresh invoked
- [x] Cache miss → refresh invoked, emits cached path

---

## Phase 9 — Verification + docs

- [x] Run:
  - [x] `flutter analyze`
  - [x] `dart run custom_lint`
  - [x] `flutter test`
- [x] Update explainer:
  - [x] `docs/explainers/features/user/profile_image_upload.md` add a “Caching” section summarizing TTL + fileId invalidation.

