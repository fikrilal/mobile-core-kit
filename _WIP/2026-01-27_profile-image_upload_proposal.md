# Profile Image Upload (Presigned URL) — Engineering Proposal

Date: 2026-01-27  
Status: Proposal (not implemented)

## Context

The backend supports profile image management for the current user via a **presigned upload** flow:

1) Request an upload plan (backend signs a presigned URL)  
2) Upload bytes directly to object storage (using the presigned URL)  
3) Finalize/attach the uploaded file to the user profile

This is high-ROI for a template because it demonstrates:

- A **non-trivial write flow** that combines API calls + raw HTTP upload (not JSON).
- Idempotency and safe retries (API calls) vs **non-retryable** upload calls.
- Error-code mapping for storage constraints/mismatches.
- A clean separation between **feature-owned orchestration** and **core infra utilities**.

See the backend contract details in:
- `_WIP/2026-01-27_backend-contract_profile-image.md`

## Goals

- Provide a template-grade implementation that is:
  - Scalable (reusable for future attachments/uploads)
  - Maintainable (clear ownership and responsibilities)
  - Safe (no accidental auth headers/logging on presigned requests)
  - Consistent with existing repo patterns (Clean Architecture + docs/engineering guides)
- Support:
  - Upload plan creation
  - Direct upload via presigned URL
  - Upload completion
  - Profile image URL fetch (200/204 semantics)
  - Profile image clear
- Ensure current user cache is updated after completion (so UI reflects `profileImageFileId`).

## Non-goals (initially)

- Image picking/cropping/compression UX
- Background uploads / resumable uploads
- Multi-image galleries or attachments
- Offline queueing

## Key design constraints (important)

### 1) The client must not “sign” anything

The backend signs and returns a presigned upload plan. The client must only execute the plan:

- HTTP method (likely `PUT`)
- Presigned URL (absolute URL)
- Exact headers required by the plan (e.g. `Content-Type`)

### 2) Presigned upload must bypass our API interceptors

Our API client has interceptors that are correct for backend calls but risky for presigned URLs:

- `AuthTokenInterceptor` could attach `Authorization` or do refresh/retry logic.
- `RequestIdInterceptor` could inject `X-Request-Id`.
- `LoggingInterceptor` could log presigned URLs.

Even if object storage accepts extra headers, signature validation can be strict depending on provider/signing strategy. The safest template approach is:

- Use a **dedicated** HTTP client for presigned uploads with **no interceptors**.

## Proposed architecture

### Ownership model

- `features/user` owns:
  - Backend API calls under `/v1/me/profile-image/*`
  - Repository + use cases + failure mapping
  - Orchestration (plan → upload → complete → refresh cached user)
- `core` provides:
  - A small “direct upload client” to execute presigned uploads
  - (Optional) shared helpers for content-type / file sizing / progress / cancellation

### System tree (proposed)

```
lib/
├─ core/
│  └─ network/
│     └─ upload/
│        ├─ presigned_upload_request.dart         # immutable request: method,url,headers
│        ├─ presigned_upload_client.dart          # interface
│        └─ dio_presigned_upload_client.dart      # implementation (no interceptors)
└─ features/
   └─ user/
      ├─ data/
      │  ├─ datasource/remote/
      │  │  └─ profile_image_remote_datasource.dart
      │  ├─ model/remote/
      │  │  ├─ create_profile_image_upload_request_model.dart
      │  │  ├─ profile_image_upload_plan_model.dart
      │  │  ├─ complete_profile_image_upload_request_model.dart
      │  │  └─ profile_image_url_model.dart
      │  └─ repository/
      │     └─ profile_image_repository_impl.dart
      ├─ domain/
      │  ├─ entity/
      │  │  ├─ profile_image_upload_plan_entity.dart
      │  │  └─ profile_image_url_entity.dart
      │  ├─ repository/
      │  │  └─ profile_image_repository.dart
      │  └─ usecase/
      │     ├─ upload_profile_image_usecase.dart
      │     ├─ clear_profile_image_usecase.dart
      │     └─ get_profile_image_url_usecase.dart
      └─ presentation/
         └─ cubit/
            └─ profile_image/
               ├─ profile_image_cubit.dart
               └─ profile_image_state.dart
```

Notes:
- This follows the same “vertical slice” feature layout.
- Entities remain in domain; models remain in data.
- The “direct upload” capability is template-level infra and reusable.

## Proposed flows

### Upload profile image (orchestrated use case)

```
UI (pick image)                      Domain (use case)                     Data/Infra
------------------                   ------------------                   --------------------------
select file + contentType
compute sizeBytes + bytes
        │
        ▼
UploadProfileImageUseCase(bytes, contentType, sizeBytes)
        │
        ├─ (1) create upload plan  ──────────────────────────────────────▶  POST /v1/me/profile-image/upload
        │                                                                       (Idempotency-Key ok)
        │
        ├─ (2) direct upload       ──────────────────────────────────────▶  PUT <presigned url>
        │                                                                       (no auth headers, no base URL)
        │
        ├─ (3) complete upload     ──────────────────────────────────────▶  POST /v1/me/profile-image/complete
        │
        └─ (4) refresh cached user ──────────────────────────────────────▶  GET /v1/me (via existing user flow)
```

Why “refresh cached user”?
- The canonical place to update `profile.profileImageFileId` should be the backend.
- Fetching `/v1/me` after completion makes the UI correct even if backend performs additional logic.

### Get profile image URL (render)

- `GET /v1/me/profile-image/url`
  - `200` returns presigned render URL
  - `204` indicates “no profile image”

Implementation note (important):
- Our `ApiHelper` returns `null as T` on `204`. For `204` endpoints, the datasource should use a **nullable generic**:
  - `getOne<ProfileImageUrlModel?>` (so `null` is a valid `T`)

### Clear profile image

- `DELETE /v1/me/profile-image` → `204`
- After clear, refresh cached user (or patch local cache) so `profileImageFileId` becomes null.

## Failure mapping proposal

We already use `AuthFailure` widely in auth + user flows. For this feature, we can:

### Option A (minimal churn; recommended for now)

Keep `AuthFailure` as the domain failure type for the profile image use cases:

- `UNAUTHORIZED` → `AuthFailure.unauthenticated()`
- `RATE_LIMITED` / `too many requests` → `AuthFailure.tooManyRequests()`
- `VALIDATION_FAILED` → `AuthFailure.validation([...])`
- `USERS_OBJECT_STORAGE_NOT_CONFIGURED` → `AuthFailure.serverError(<localized message key>)`
- `USERS_PROFILE_IMAGE_*` mismatches → `AuthFailure.serverError(<localized message key>)`
- Everything else → `AuthFailure.serverError()` or `AuthFailure.unexpected()`

This keeps the template consistent with current user feature error typing and avoids a user-wide refactor.

### Option B (more correct domain modeling; later)

Introduce `UserFailure` (user feature owns user-related failures) and migrate user repository + use cases.

This is architecturally cleaner long-term, but it’s a larger change than necessary to land profile images.

## Retry policy

- Step (1) `POST /profile-image/upload`:
  - Safe retries via `Idempotency-Key` (already supported)
- Step (2) `PUT presigned URL`:
  - **Do not auto-retry** (avoid double uploads / provider quirks)
  - Surface errors and allow user to retry manually (request a new plan if expired)
- Step (3) `POST /profile-image/complete`:
  - No idempotency key in the contract; do not auto-retry on auth refresh

## Logging + privacy

- Never log presigned URLs (they can contain temporary credentials/signature).
- Never log upload headers if they contain sensitive values.
- The presigned upload client should have:
  - Minimal logging, or none by default

## UX notes (for later UI work)

- Progress: provide optional `onSendProgress` for direct uploads.
- Cancellation: allow cancel token to abort the upload request.
- Errors: show user-friendly messages for “upload expired”, “unsupported image type”, and “size too large”.

## Suggested implementation phases

1) Add backend contract docs (this file + contract file) ✅ (this task)
2) Add core presigned upload client (unit tests with mocked Dio adapter)
3) Add user feature remote datasource + models (unit tests)
4) Add repository + use cases (unit tests)
5) Add presentation Cubit (bloc tests)
6) Add minimal UI integration on Profile page (widget tests only if needed)

