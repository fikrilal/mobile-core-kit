# Profile Image Upload (Presigned URL) — How it works

## Overview

This repo supports profile image management for the current signed-in user using a **presigned upload flow**:

1) Request an upload plan (backend signs a presigned URL)
2) Upload bytes directly to object storage (using the presigned URL)
3) Complete the upload (attach the file to the user profile)
4) Load a short-lived render URL to display the image

This is intentionally included in the template because it demonstrates a “real-world” non-JSON upload path:

- Backend calls (JSON, auth, retry-after-refresh rules)
- Object storage calls (absolute URL, signature validation, no backend auth headers)
- A clear ownership boundary: feature orchestration + core infra utilities

---

## Backend contract (reference only)

Source of truth:
- `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`

Endpoints:

- `POST /v1/me/profile-image/upload`
  - Request body: `{ contentType, sizeBytes }`
  - Response `200`: `{ data: { fileId, upload: { method, url, headers }, expiresAt } }`
  - Notes:
    - Supports `Idempotency-Key` (recommended)
- `PUT <presigned url>` (object storage, not backend)
  - Executes the upload plan using the exact `method`, `url`, and `headers`
- `POST /v1/me/profile-image/complete`
  - Request body: `{ fileId }`
  - Response `204`
  - Notes:
    - No idempotency contract → do not auto-retry after refresh
- `GET /v1/me/profile-image/url`
  - Response `200`: `{ data: { url, expiresAt } }`
  - Response `204`: no profile image set (not an error)
- `DELETE /v1/me/profile-image`
  - Response `204`

The `/v1/me` payload also includes:

- `profile.profileImageFileId` (nullable)

The file ID is the backend’s canonical pointer; clients should render via:

- `GET /v1/me/profile-image/url`

---

## Why this is not a normal API request

Presigned URLs must be treated as **authoritative and opaque**:

- The client must not “sign” anything.
- The client must not attach backend auth headers.
- The client must not rewrite base URLs.
- The client must not log the presigned URL (it may contain temporary credentials/signature).

This repo’s default API client includes interceptors that are correct for backend calls, but risky for object storage requests:

- `AuthTokenInterceptor` (Authorization + refresh + retry-after-refresh policy)
- `RequestIdInterceptor` (X-Request-Id injection)
- `BaseUrlInterceptor` (host rewriting)
- `LoggingInterceptor` (could leak presigned URLs)

Therefore presigned uploads are executed with a **dedicated Dio instance with no interceptors**.

---

## System tree (where the code lives)

Core infra (absolute URL upload execution):

```
lib/core/infra/network/upload/
├─ presigned_upload_request.dart        # validates absolute URL + captures method/headers
├─ presigned_upload_client.dart         # interface + stable failure type
└─ dio_presigned_upload_client.dart     # dedicated Dio (no interceptors)
```

User feature (API calls + orchestration):

```
lib/features/user/
├─ data/
│  ├─ datasource/remote/
│  │  └─ profile_image_remote_datasource.dart
│  ├─ error/
│  │  ├─ profile_image_error_codes.dart
│  │  └─ profile_image_failure_mapper.dart
│  ├─ model/remote/
│  │  ├─ create_profile_image_upload_request_model.dart
│  │  ├─ profile_image_upload_plan_model.dart
│  │  ├─ complete_profile_image_upload_request_model.dart
│  │  └─ profile_image_url_model.dart
│  └─ repository/
│     └─ profile_image_repository_impl.dart
├─ domain/
│  ├─ entity/
│  │  ├─ create_profile_image_upload_plan_request_entity.dart
│  │  ├─ complete_profile_image_upload_request_entity.dart
│  │  ├─ clear_profile_image_request_entity.dart
│  │  ├─ upload_profile_image_request_entity.dart
│  │  ├─ profile_image_upload_plan_entity.dart
│  │  └─ profile_image_url_entity.dart
│  ├─ repository/
│  │  └─ profile_image_repository.dart
│  └─ usecase/
│     ├─ upload_profile_image_usecase.dart
│     ├─ clear_profile_image_usecase.dart
│     └─ get_profile_image_url_usecase.dart
├─ presentation/
│  ├─ cubit/profile_image/
│  │  ├─ profile_image_cubit.dart
│  │  └─ profile_image_state.dart
│  └─ pages/
│     └─ profile_page.dart              # “Change profile photo” UI entry
└─ di/
   └─ user_module.dart                  # DI wiring
```

Media picking (gallery/camera + downscale/compress-to-fit):

```
lib/core/platform/media/
├─ image_picker_service.dart
├─ image_picker_service_impl.dart
├─ image_bytes_optimizer.dart
├─ media_pick_exception.dart
└─ picked_image.dart
```

Tests:

```
test/core/infra/network/upload/dio_presigned_upload_client_test.dart
test/features/user/
├─ data/datasource/remote/profile_image_remote_datasource_test.dart
├─ data/error/profile_image_failure_mapper_test.dart
├─ data/repository/profile_image_repository_impl_test.dart
├─ domain/usecase/upload_profile_image_usecase_test.dart
├─ domain/usecase/clear_profile_image_usecase_test.dart
├─ domain/usecase/get_profile_image_url_usecase_test.dart
└─ presentation/cubit/profile_image/profile_image_cubit_test.dart
```

---

## Runtime behavior (step-by-step)

### 1) Render (disk-first avatar)

On profile tab entry, we create `ProfileImageCubit` and call `loadAvatar()`:

1) Look up the signed-in user + `profile.profileImageFileId` via `UserContextService`
2) Try disk cache (fast path)
3) If missing/expired and `profileImageFileId` exists → request a short-lived render URL and download bytes to disk

The backend render URL is still produced by:

- `GET /v1/me/profile-image/url` (`200` → `{ url, expiresAt }`, `204` → no avatar set)

### 2) Upload (change photo)

High-level sequence:

```
ProfilePage
  -> ImagePickerService.pickFromGallery|pickFromCamera (bytes + contentType)
  -> ProfileImageCubit.upload(bytes, contentType, idempotencyKey)
     -> UploadProfileImageUseCase
        -> ProfileImageRepository.createUploadPlan(...)           (POST /me/profile-image/upload + Idempotency-Key)
        -> ProfileImageRepository.uploadToPresignedUrl(plan, ...) (PUT <presigned url> via DioPresignedUploadClient)
        -> ProfileImageRepository.completeUpload(fileId)          (POST /me/profile-image/complete)
        -> GetMeUseCase                                          (GET /v1/me)
```

Then the UI:

- shows a loading overlay while upload is in-flight
- shows a success/error snackbar
- calls `ProfileImageCubit.loadAvatar()` so the avatar re-renders from disk

### 3) Clear (remove photo)

High-level sequence:

```
ProfilePage -> ProfileImageCubit.clear(idempotencyKey)
  -> ClearProfileImageUseCase
     -> ProfileImageRepository.clearProfileImage(...) (DELETE /v1/me/profile-image)
     -> GetMeUseCase                                 (GET /v1/me)
```

Then the UI re-loads the avatar, which becomes `null` (placeholder) when there is no profile image.

---

## Caching (disk + TTL)

The avatar is rendered from a **disk cache**, not from the presigned URL directly.

See also:
- `docs/explainers/features/user/profile_avatar_disk_cache.md`

Policy:

- TTL default: **7 days**
- Cache key: `(userId, profileImageFileId)`
- Invalidation:
  - If `profileImageFileId` changes, the old cache is deleted and treated as a miss.
  - If the cache file is missing/corrupt, metadata is cleared (fail-safe).
- UX:
  - Cache hit (fresh) → show instantly (no network).
  - Cache hit (expired) → show stale immediately, refresh in background.
  - Cache miss → download and then render.

Implementation:

- Local cache: `ProfileAvatarCacheLocalDataSource` (disk + SharedPreferences metadata)
- Orchestration: `ProfileAvatarRepository` (get URL → download bytes → save to disk)
- Session safety: cache is cleared on `SessionCleared` and `SessionExpired`.

---

## Retry policy (auth refresh + idempotency)

Backend calls go through the normal API client (Dio + interceptors).

This repo’s `AuthTokenInterceptor` retry policy is:

- Reads (`GET`/`HEAD`) may be retried after token refresh.
- Writes (`POST`/`PUT`/`PATCH`/`DELETE`) may be retried after refresh **only if** an `Idempotency-Key` header is present.

Applied to profile image endpoints:

- `POST /me/profile-image/upload`
  - includes `Idempotency-Key` → retry-after-refresh is allowed
- `POST /me/profile-image/complete`
  - no idempotency key → retry-after-refresh is not allowed
- `DELETE /me/profile-image`
  - we include `Idempotency-Key` (best-effort; even if backend ignores it) → retry-after-refresh is allowed

Presigned uploads:

- are **not** retried automatically
- are executed through a dedicated client that has no refresh logic

---

## Failure mapping

For now, profile image failures map into `AuthFailure` for consistency with existing user flows:

- backend error codes are mapped in `profile_image_failure_mapper.dart`
- presigned upload failures (`PresignedUploadFailure`) map to:
  - `AuthFailure.network()` (offline/timeouts)
  - `AuthFailure.unexpected()` (everything else)

UI uses the existing localizer:

- `features/auth/presentation/localization/auth_failure_localizer.dart`

---

## Logging & privacy

Rules:

- Do not log presigned URLs.
- Do not log presigned headers (may include sensitive values).

Enforcement:

- `ProfileImageRepositoryImpl` logs only status codes for presigned failures.
- Presigned uploads do not share the normal `ApiClient` Dio instance (no interceptors/logging).

---

## Troubleshooting (quick)

- “Avatar doesn’t update after upload”:
  - confirm `loadUrl()` runs after success (profile page listener does this)
  - confirm backend returns `200` for `/profile-image/url` (not `204`)
- “Remove photo option not shown”:
  - remove option is only shown when backend state indicates a photo exists (fileId/url)
- “Upload fails randomly”:
  - presigned URLs expire; retry by requesting a new upload plan
- “Works on Wi‑Fi, fails on mobile data”:
  - likely connectivity or MTU/proxy issues; treat as `AuthFailure.network()`

---

## Optional follow-ups

- Add progress + cancellation plumbing to `PresignedUploadClient.uploadBytes(...)` and surface it in UI.
- Add a dedicated “view profile image” action using the render URL endpoint.
