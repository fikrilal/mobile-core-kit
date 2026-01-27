# TODO — Profile Image Upload (Presigned URL)

Date: 2026-01-27  
Scope: mobile-core-kit  
Related docs:
- Proposal: `_WIP/2026-01-27_profile-image_upload_proposal.md`
- Backend contract: `_WIP/2026-01-27_backend-contract_profile-image.md`
- Backend source of truth: `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`

---

## Phase 0 — Contract & alignment (done)

- [x] Document backend contract (`/v1/me/profile-image/*`) in `_WIP/2026-01-27_backend-contract_profile-image.md`
- [x] Write implementation proposal in `_WIP/2026-01-27_profile-image_upload_proposal.md`

---

## Phase 1 — Core infra: direct/presigned upload client

Goal: Execute presigned uploads safely (no backend auth headers, no baseUrl rewriting, no interceptor retries/logging).

- [x] Add core upload module:
  - [x] `lib/core/network/upload/presigned_upload_request.dart`
  - [x] `lib/core/network/upload/presigned_upload_client.dart`
  - [x] `lib/core/network/upload/dio_presigned_upload_client.dart`
- [x] Implementation requirements:
  - [x] Accept absolute URL + required headers
  - [x] Ensure `Authorization` is NOT added
  - [x] No retries by default (upload is non-idempotent at HTTP layer)
  - [ ] Optional: progress + cancellation support
  - [x] Never log presigned URL (can contain temporary creds/signature)
- [x] Tests:
  - [x] “Sends PUT to absolute URL with headers”
  - [x] “Does not attach backend-only headers”
  - [x] “Surfacing non-2xx as failure (no retry)”

---

## Phase 2 — User feature: remote datasource + request/response models

Goal: Add typed backend calls for profile image endpoints (not the presigned upload itself).

- [x] Add endpoint constants:
  - [x] `UserEndpoint.meProfileImageUpload = '/me/profile-image/upload'`
  - [x] `UserEndpoint.meProfileImageComplete = '/me/profile-image/complete'`
  - [x] `UserEndpoint.meProfileImage = '/me/profile-image'`
  - [x] `UserEndpoint.meProfileImageUrl = '/me/profile-image/url'`
- [x] Add remote models:
  - [x] `lib/features/user/data/model/remote/create_profile_image_upload_request_model.dart`
  - [x] `lib/features/user/data/model/remote/profile_image_upload_plan_model.dart` (incl `PresignedUploadDto` shape)
  - [x] `lib/features/user/data/model/remote/complete_profile_image_upload_request_model.dart`
  - [x] `lib/features/user/data/model/remote/profile_image_url_model.dart`
- [x] Add remote datasource:
  - [x] `lib/features/user/data/datasource/remote/profile_image_remote_datasource.dart`
    - [x] `createUploadPlan(...) -> ApiResponse<ProfileImageUploadPlanModel>`
    - [x] `completeUpload(fileId) -> ApiResponse<ApiNoData>`
    - [x] `clearProfileImage() -> ApiResponse<ApiNoData>`
    - [x] `getProfileImageUrl() -> ApiResponse<ProfileImageUrlModel?>` (204 => null)
- [x] Ensure idempotency behavior:
  - [x] `upload` request uses `Idempotency-Key`
  - [x] `complete` does NOT auto-retry after refresh (no idempotency key in contract)
- [x] Tests:
  - [x] “Correct paths/hosts + envelope parsing”
  - [x] “204 from profile-image/url maps to null model”

---

## Phase 3 — Domain: entities + repository contract + use cases

Goal: Keep orchestration in user domain; isolate infra details behind abstractions.

- [x] Domain entities:
  - [x] `ProfileImageUploadPlanEntity` (fileId, upload method/url/headers, expiresAt)
  - [x] `ProfileImageUrlEntity` (url, expiresAt)
- [x] Repository contract:
  - [x] `ProfileImageRepository` with:
    - [x] `createUploadPlan(...)`
    - [x] `uploadToPresignedUrl(...)` (or “execute plan”)
    - [x] `completeUpload(fileId)`
    - [x] `clearProfileImage()`
    - [x] `getProfileImageUrl()`
- [x] Use cases (suggested):
  - [x] `UploadProfileImageUseCase` (plan → upload → complete → refresh cached user)
  - [x] `ClearProfileImageUseCase` (clear → refresh cached user)
  - [x] `GetProfileImageUrlUseCase`
- [x] Validation:
  - [x] Validate `contentType` is one of allowed enum values
  - [x] Validate `sizeBytes <= 5_000_000`
  - [ ] Consider VOs if we want reusable constraints (optional for first pass)
- [x] Tests:
  - [x] “Invalid input fails early (repo not called)”
  - [x] “Happy path orchestration calls steps in order”

---

## Phase 4 — Repository implementation + failure mapping

Goal: Map API failures and storage-related errors into domain failures consistently.

- [x] Implement repository:
  - [x] `lib/features/user/data/repository/profile_image_repository_impl.dart`
  - [x] Uses:
    - [x] `ProfileImageRemoteDataSource`
    - [x] `PresignedUploadClient`
    - [x] Use cases refresh `/me` after upload/clear (so UI can re-render using updated `profileImageFileId`)
- [x] Failure mapping (initial approach: reuse `AuthFailure`):
  - [x] `UNAUTHORIZED` → `AuthFailure.unauthenticated()`
  - [x] `RATE_LIMITED` → `AuthFailure.tooManyRequests()`
  - [x] `VALIDATION_FAILED` → `AuthFailure.validation([...])`
  - [x] `USERS_OBJECT_STORAGE_NOT_CONFIGURED` → `AuthFailure.serverError()`
  - [x] `USERS_PROFILE_IMAGE_*` mismatches → `AuthFailure.validation([...])` (best-effort mapping to file constraints)
  - [x] Upload (presigned URL) failures → `AuthFailure.network()` for offline/timeout, otherwise `AuthFailure.unexpected()`
- [x] Tests:
  - [x] “Maps backend error codes correctly”
  - [x] “Presigned upload failure does not call complete”

---

## Phase 5 — Presentation: Profile Image Cubit (no UI yet)

Goal: Provide a clean slice that UI can integrate without leaking infra details.

- [ ] Add `ProfileImageCubit` + state under `lib/features/user/presentation/cubit/profile_image/`
  - [ ] State includes:
    - [ ] `status` enum (idle/loading/success/failure)
    - [ ] touched-field validation strategy (if there are fields; otherwise simple)
    - [ ] one-shot effects for snackbars/navigation
- [ ] Tests:
  - [ ] `bloc_test` for success/failure states + effect emission

---

## Phase 6 — UI integration (minimal)

Goal: Wire to a profile screen without over-designing UX.

- [ ] Add “Change profile image” entry in profile page
- [ ] For first pass:
  - [ ] Pick image (source: gallery/camera) — decide approach/package
  - [ ] Call `UploadProfileImageUseCase` via cubit
  - [ ] Show progress + success/error snackbars
  - [ ] Re-render UI using updated cached `/me` (`profileImageFileId`)
- [ ] Optional follow-ups:
  - [ ] “View profile image” using `GET /v1/me/profile-image/url`
  - [ ] “Remove profile image” using `DELETE /v1/me/profile-image`

---

## Phase 7 — Docs & sample usage

- [ ] Add an engineering doc or explainer (under `docs/core/` or `docs/engineering/api/`) explaining:
  - [ ] Why presigned uploads must bypass API interceptors
  - [ ] How to model the plan + direct upload client
  - [ ] 204-as-null pattern for URL endpoint
- [ ] Add examples/snippets:
  - [ ] Example: “profile image upload in a feature slice”
