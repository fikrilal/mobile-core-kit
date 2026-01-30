# Profile Avatar Disk Cache (TTL + fileId invalidation) — How it works

## Overview

This repo renders the user’s profile avatar from a **disk-backed cache** to avoid the “placeholder blip” you get when rendering via a short-lived presigned render URL on cold start.

Core idea:

- Backend exposes a short-lived render URL (`GET /v1/me/profile-image/url`).
- The app **does not** persist that URL.
- Instead, it downloads the image bytes and stores them on disk with small metadata:
  - `cachedAt` (for TTL)
  - `profileImageFileId` (for invalidation when `/me` changes)

UX policy:

- Cache hit (fresh) → render instantly, no network.
- Cache hit (expired) → render instantly, refresh in background.
- Cache miss → download and then render.

---

## Backend contract (reference only)

Source of truth:
- `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`

Endpoints used:

- `GET /v1/me`
  - Contains `profile.profileImageFileId` (nullable)
- `GET /v1/me/profile-image/url`
  - `200` → `{ data: { url, expiresAt } }`
  - `204` → no profile image set (not an error)

Important: the render URL is a capability token; it can contain temporary credentials/signature. It must not be logged or persisted.

---

## Why disk cache (not URL cache)

Presigned URLs are the wrong cache primitive:

- They expire quickly → stale URLs create broken images.
- They are capability tokens → persisting them is poor security hygiene.
- They do not help offline UX.

Disk-caching bytes gives:

- instant render on profile tab open,
- stable rendering even when offline,
- clear invalidation semantics driven by `profileImageFileId`.

---

## System tree (where the code lives)

Core infra (absolute URL download, no backend interceptors):

```
lib/core/infra/network/download/
├─ presigned_download_client.dart          # interface
└─ dio_presigned_download_client.dart      # dedicated Dio (no interceptors)
```

User feature (cache + orchestration):

```
lib/features/user/
├─ data/
│  ├─ datasource/local/
│  │  └─ profile_avatar_cache_local_datasource.dart     # disk + SharedPreferences metadata + TTL
│  ├─ datasource/remote/
│  │  └─ profile_avatar_download_datasource.dart        # download bytes (never logs URL)
│  ├─ repository/
│  │  └─ profile_avatar_repository_impl.dart            # get URL → download bytes → save
│  └─ services/
│     └─ user_avatar_cache_session_listener.dart        # clears cache on session end
├─ domain/
│  ├─ entity/
│  │  └─ profile_avatar_cache_entry_entity.dart
│  ├─ repository/
│  │  └─ profile_avatar_repository.dart
│  └─ usecase/
│     ├─ get_cached_profile_avatar_usecase.dart
│     ├─ refresh_profile_avatar_cache_usecase.dart
│     ├─ save_profile_avatar_cache_usecase.dart
│     ├─ clear_profile_avatar_cache_usecase.dart
│     └─ clear_all_profile_avatar_caches_usecase.dart
└─ presentation/
   └─ cubit/profile_image/
      ├─ profile_image_cubit.dart                       # loadAvatar() disk-first
      └─ profile_image_state.dart                       # cachedFilePath (disk-only UI)
```

Tests:

```
test/features/user/
├─ data/datasource/local/profile_avatar_cache_local_datasource_test.dart
└─ presentation/cubit/profile_image/profile_image_cubit_test.dart
```

---

## Local data contract

### File storage

Stored under app-internal support directory (not user-visible):

```
<app_support_dir>/
└─ user/
   └─ profile_avatar/
      └─ <userId>/
         └─ avatar.bin
```

### Metadata keys

Per-user keys in `SharedPreferences`:

- `user_profile_avatar_cached_at:<userId>` → epoch ms
- `user_profile_avatar_file_id:<userId>` → string

### TTL

Defaults to **7 days**.

Semantics:

- `isExpired = now - cachedAt >= ttl`
- Expired entries are still returned so UI can show stale immediately.

### Fail-safes

On read:

- If `profileImageFileId` is null/empty → clear any cached file + metadata and return `null`.
- If metadata is missing/corrupt → clear and return `null`.
- If `storedFileId != current profileImageFileId` → clear and return `null`.
- If the file is missing but metadata exists → clear metadata and return `null`.

---

## Runtime behavior (step-by-step)

### 1) Load: profile tab entry

On profile tab entry, the router creates `ProfileImageCubit` and calls `loadAvatar()`:

1) Read `userId` + `profileImageFileId` from `UserContextService`.
2) `GetCachedProfileAvatarUseCase(userId, profileImageFileId)`
3) If cache hit:
   - emit `cachedFilePath` immediately
   - if expired → refresh in background
4) If cache miss and `profileImageFileId` exists:
   - `RefreshProfileAvatarCacheUseCase(userId, profileImageFileId)`:
     - call backend for render URL,
     - download bytes via `PresignedDownloadClient`,
     - save to disk via local datasource,
     - emit the new `cachedFilePath`

### 2) Upload: “Change photo”

After a successful upload flow, we seed the disk cache immediately:

- Use the picked bytes (already in memory) + the updated `/me.profileImageFileId`.
- Save bytes to disk and evict `FileImage` cache for that path, so UI updates instantly.

### 3) Clear: “Remove photo”

After a successful clear:

- Clear disk cache and metadata.
- UI falls back to the placeholder/initials state.

### 4) Session end hygiene

On `SessionCleared` and `SessionExpired` events:

- `UserAvatarCacheSessionListener` clears all avatar caches (safe default).

This prevents cross-user bleed when switching accounts and keeps guest mode clean.

---

## Troubleshooting (quick)

- “Avatar keeps showing placeholder”: confirm `profileImageFileId` is present in `/me` and `GET /v1/me/profile-image/url` returns `200` (not `204`).
- “Avatar never updates after upload”: `FileImage` caches by path; the implementation must evict the `FileImage` cache when overwriting the same file.
- “Wrong avatar after logout/login”: should not happen; cache is cleared on session end. If it happens, it’s a bug in session cleanup wiring.

