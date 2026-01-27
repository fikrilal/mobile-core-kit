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

- [ ] Add core upload module:
  - [ ] `lib/core/network/upload/presigned_upload_request.dart`
  - [ ] `lib/core/network/upload/presigned_upload_client.dart`
  - [ ] `lib/core/network/upload/dio_presigned_upload_client.dart`
- [ ] Implementation requirements:
  - [ ] Accept absolute URL + required headers
  - [ ] Ensure `Authorization` is NOT added
  - [ ] No retries by default (upload is non-idempotent at HTTP layer)
  - [ ] Optional: progress + cancellation support
  - [ ] Never log presigned URL (can contain temporary creds/signature)
- [ ] Tests:
  - [ ] “Sends PUT to absolute URL with headers”
  - [ ] “Does not attach backend-only headers”
  - [ ] “Surfacing non-2xx as failure (no retry)”

---

## Phase 2 — User feature: remote datasource + request/response models

Goal: Add typed backend calls for profile image endpoints (not the presigned upload itself).

- [ ] Add endpoint constants:
  - [ ] `UserEndpoint.meProfileImageUpload = '/me/profile-image/upload'`
  - [ ] `UserEndpoint.meProfileImageComplete = '/me/profile-image/complete'`
  - [ ] `UserEndpoint.meProfileImage = '/me/profile-image'`
  - [ ] `UserEndpoint.meProfileImageUrl = '/me/profile-image/url'`
- [ ] Add remote models:
  - [ ] `lib/features/user/data/model/remote/create_profile_image_upload_request_model.dart`
  - [ ] `lib/features/user/data/model/remote/profile_image_upload_plan_model.dart` (incl `PresignedUploadDto` shape)
  - [ ] `lib/features/user/data/model/remote/complete_profile_image_upload_request_model.dart`
  - [ ] `lib/features/user/data/model/remote/profile_image_url_model.dart`
- [ ] Add remote datasource:
  - [ ] `lib/features/user/data/datasource/remote/profile_image_remote_datasource.dart`
    - [ ] `createUploadPlan(...) -> ApiResponse<ProfileImageUploadPlanModel>`
    - [ ] `completeUpload(fileId) -> ApiResponse<ApiNoData>`
    - [ ] `clearProfileImage() -> ApiResponse<ApiNoData>`
    - [ ] `getProfileImageUrl() -> ApiResponse<ProfileImageUrlModel?>` (204 => null)
- [ ] Ensure idempotency behavior:
  - [ ] `upload` request uses `Idempotency-Key`
  - [ ] `complete` does NOT auto-retry after refresh (no idempotency key in contract)
- [ ] Tests:
  - [ ] “Correct paths/hosts + envelope parsing”
  - [ ] “204 from profile-image/url maps to null model”

---

## Phase 3 — Domain: entities + repository contract + use cases

Goal: Keep orchestration in user domain; isolate infra details behind abstractions.

- [ ] Domain entities:
  - [ ] `ProfileImageUploadPlanEntity` (fileId, upload method/url/headers, expiresAt)
  - [ ] `ProfileImageUrlEntity` (url, expiresAt)
- [ ] Repository contract:
  - [ ] `ProfileImageRepository` with:
    - [ ] `createUploadPlan(...)`
    - [ ] `uploadToPresignedUrl(...)` (or “execute plan”)
    - [ ] `completeUpload(fileId)`
    - [ ] `clearProfileImage()`
    - [ ] `getProfileImageUrl()`
- [ ] Use cases (suggested):
  - [ ] `UploadProfileImageUseCase` (plan → upload → complete → refresh cached user)
  - [ ] `ClearProfileImageUseCase` (clear → refresh cached user)
  - [ ] `GetProfileImageUrlUseCase`
- [ ] Validation:
  - [ ] Validate `contentType` is one of allowed enum values
  - [ ] Validate `sizeBytes <= 5_000_000`
  - [ ] Consider VOs if we want reusable constraints (optional for first pass)
- [ ] Tests:
  - [ ] “Invalid input fails early (repo not called)”
  - [ ] “Happy path orchestration calls steps in order”

---

## Phase 4 — Repository implementation + failure mapping

Goal: Map API failures and storage-related errors into domain failures consistently.

- [ ] Implement repository:
  - [ ] `lib/features/user/data/repository/profile_image_repository_impl.dart`
  - [ ] Uses:
    - [ ] `ProfileImageRemoteDataSource`
    - [ ] `PresignedUploadClient`
    - [ ] Existing `GetMeUseCase` / cache strategy to refresh `profileImageFileId`
- [ ] Failure mapping (initial approach: reuse `AuthFailure`):
  - [ ] `UNAUTHORIZED` → `AuthFailure.unauthenticated()`
  - [ ] `RATE_LIMITED` → `AuthFailure.tooManyRequests()`
  - [ ] `VALIDATION_FAILED` → `AuthFailure.validation([...])`
  - [ ] `USERS_OBJECT_STORAGE_NOT_CONFIGURED` → `AuthFailure.serverError(<localized>)`
  - [ ] `USERS_PROFILE_IMAGE_*` mismatches → `AuthFailure.serverError(<localized>)`
  - [ ] Upload (presigned URL) failures → `AuthFailure.network()` or `AuthFailure.serverError()` based on status
- [ ] Tests:
  - [ ] “Maps backend error codes correctly”
  - [ ] “Presigned upload failure does not call complete”

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

