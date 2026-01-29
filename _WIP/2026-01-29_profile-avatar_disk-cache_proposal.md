# Profile Avatar Disk Cache (TTL-based)

## Context

Today, the Profile tab loads the avatar by:

1. Calling `GET /v1/me/profile-image/url` to mint a short-lived **render URL** (presigned).
2. Rendering it via `Image.network(url)` in `AppAvatar`.

This causes a noticeable placeholder “blip” on first open after app restart because:

- `Image.network` only caches in memory (Flutter `ImageCache`), so a cold start has no cache.
- The render URL must be fetched before the image can be downloaded.

## Goal

Improve UX by showing the profile avatar immediately on Profile tab open:

- If a cached avatar exists and is within TTL, render from local disk instantly.
- Only call backend + download when cache is missing or TTL has expired.

## Non-goals

- Do not refresh on every Profile tab open.
- Do not persist presigned render URLs long-term.
- Do not introduce multi-account complexity (we still scope cache per user ID).

## Recommended cache strategy

Cache **image bytes on disk**, not presigned URLs.

Why:
- Presigned URLs expire and are capability tokens; persisting them is brittle and not great security hygiene.
- Disk-cached image bytes allow offline rendering and instant UI.
- The backend contract already supports generating short-lived render URLs, so we can always refresh when needed.

## High-level design (Clean Architecture aligned)

### Data layer

Add a local datasource responsible for storing/retrieving a cached avatar file + metadata:

- `lib/features/user/data/datasource/local/profile_avatar_cache_local_datasource.dart`

Responsibilities:
- Store avatar bytes as a file in app-internal storage.
- Persist metadata in `SharedPreferences`:
  - cached timestamp (for TTL),
  - optionally the `profileImageFileId` (cheap invalidation when `/me` changes).
- Clear cache safely on logout/session cleared.

Add a small download datasource (feature-owned) to fetch bytes from a presigned render URL:

- `lib/features/user/data/datasource/remote/profile_avatar_download_datasource.dart`

Responsibilities:
- `GET` bytes from a full URL (no auth headers, no ApiHelper).
- Must avoid logging the URL.

### Domain layer

Expose caching operations via use cases to keep presentation pure:

- `GetCachedProfileAvatarUseCase`
- `RefreshProfileAvatarCacheUseCase`
- `ClearProfileAvatarCacheUseCase`

### Presentation layer

Extend `ProfileImageCubit` (or introduce a small dedicated cubit if desired) to:

- Load cached avatar file path first.
- Refresh cache only when missing/expired.
- Update UI state immediately with `cachedFilePath` so `AppAvatar` can render using `FileImage`.

## Storage details

### Where to store the file

Use `path_provider` (already in repo) to store in internal app storage:

- Preferred: `getApplicationSupportDirectory()` (not user-visible, stable)
- Directory layout:

```
<app_support_dir>/
└─ user/
   └─ profile_avatar/
      └─ <userId>/
         └─ avatar.bin
```

Notes:
- File extension is not required for `FileImage`.
- We keep it per user ID to avoid cross-user bleed if logout + new login happens.

### Metadata keys

Use per-user keys similar to `ProfileDraftLocalDataSource`:

- `user_profile_avatar_cached_at:<userId>` → `int` (epoch ms)
- Optional (recommended): `user_profile_avatar_file_id:<userId>` → `String`
  - lets us invalidate local file when `/me.profile.profileImageFileId` changes without network calls.

### TTL

Configurable duration injected into the datasource for testing:

- Default proposal: `Duration(days: 7)` (tune later)
- Behavior:
  - If cache age < TTL: use cache, do not refresh.
  - If cache age >= TTL: still render stale cache immediately, then refresh in background.

## Runtime flow

### On Profile tab open

1) Determine current user ID and current `profileImageFileId` from `UserContextService`.
2) If `profileImageFileId` is null/empty:
   - Clear any cached file for the user (fail-safe).
   - Render initials/icon (no network calls).
3) Else try cached file:
   - If cached file exists and not expired:
     - Render file immediately.
     - Stop.
   - If cached file exists but expired:
     - Render file immediately.
     - Kick off background refresh (download new bytes).
   - If no cached file:
     - Call backend for render URL, download bytes, store file, render.

### On “Change photo” upload success

Avoid showing placeholder again by updating cache immediately:

- After successful upload + complete:
  - Save the *picked* bytes to cache as the new avatar file.
  - Optionally refresh from server later (not required).

### On “Remove photo” success

- Clear cache file + metadata.
- Clear cubit state so UI falls back to initials/icon.

### On logout/session cleared

Simplest + safest:

- Delete `user/profile_avatar/` directory entirely (clear all users).

Alternative:
- Clear only the last signed-in user if the session layer provides an ID.

## UI integration (minimal changes)

`AppAvatar` already supports `imageProvider`, so we can avoid introducing a new widget.

Add a field to `ProfileImageState`:

- `String? cachedFilePath`

Then in `ProfilePage`:

- Prefer `imageProvider: cachedFilePath != null ? FileImage(File(cachedFilePath)) : null`
- Only fall back to `imageUrl` when no cache exists and the refresh is in-flight.

## Failure behavior

- Cache read failures: ignore and behave as cache miss (best-effort).
- Download failures when cache exists: keep showing stale cached avatar.
- Download failures on cold miss: show initials/icon (existing fallback).
- `GET /v1/me/profile-image/url` returns `204`: treat as “no avatar”; clear cache if present.

## Testing strategy (must-have)

### Local datasource

- “Save then load returns path + cachedAt”
- “Expired returns isExpired=true but still returns path”
- “Missing file clears stale prefs”
- “Clear deletes file + prefs”

Implementation detail to keep tests clean:
- Inject `Directory Function()` baseDir provider (use temp dir in tests).
- Inject `DateTime Function()` now provider to test TTL deterministically.
- Use `SharedPreferences.setMockInitialValues({})` for prefs.

### Cubit (bloc_test)

- “Cache hit (not expired) emits cached path and never calls refresh”
- “Cache expired emits cached path then refreshes”
- “Cache miss refreshes and emits cached path”

## Rollout steps

1) Add local cache datasource + download datasource.
2) Add usecases + wire DI in `lib/features/user/di/user_module.dart`.
3) Update `ProfileImageCubit` to load cache first and refresh based on TTL.
4) Update `ProfilePage` to prefer `FileImage` via `imageProvider`.
5) Add session clear hook to wipe avatar cache directory.
6) Add tests + run verification (`tool/agent/dartw ... tool/verify.dart`).

## Open questions (to confirm before implementation)

1) TTL default: 1 day vs 7 days?
2) Do we also invalidate cache when `profileImageFileId` changes (recommended)?
3) Should we keep the existing `imageUrl` field, or switch fully to disk + remove URL state?

