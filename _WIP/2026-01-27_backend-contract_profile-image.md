# Backend Contract — Profile Image (Current User)

Date: 2026-01-27  
Source of truth: `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`

## Endpoints

### 1) Create upload plan (presigned URL)

`POST /v1/me/profile-image/upload`

- Auth: access token required
- Request headers:
  - Optional `Idempotency-Key` (recommended)
- Request body:
  - `contentType`: `image/jpeg | image/png | image/webp`
  - `sizeBytes`: number, min 1, max 5,000,000
- Response: `200`
  - Envelope: `{ data: ProfileImageUploadPlanDto }`
  - `data.fileId`: string
  - `data.upload.method`: `"PUT"`
  - `data.upload.url`: presigned absolute URL
  - `data.upload.headers`: headers required by the presigned upload (e.g. `Content-Type`)
  - `data.expiresAt`: ISO date-time
- Error codes (x-error-codes):
  - `VALIDATION_FAILED`
  - `UNAUTHORIZED`
  - `RATE_LIMITED`
  - `IDEMPOTENCY_IN_PROGRESS`
  - `CONFLICT`
  - `USERS_OBJECT_STORAGE_NOT_CONFIGURED`
  - `INTERNAL`

### 2) Complete upload (attach to current user)

`POST /v1/me/profile-image/complete`

- Auth: access token required
- Request body:
  - `fileId`: string (from upload plan)
- Response: `204`
- Error codes:
  - `VALIDATION_FAILED`
  - `UNAUTHORIZED`
  - `NOT_FOUND`
  - `USERS_OBJECT_STORAGE_NOT_CONFIGURED`
  - `USERS_PROFILE_IMAGE_NOT_UPLOADED`
  - `USERS_PROFILE_IMAGE_SIZE_MISMATCH`
  - `USERS_PROFILE_IMAGE_CONTENT_TYPE_MISMATCH`
  - `INTERNAL`

### 3) Clear current profile image

`DELETE /v1/me/profile-image`

- Auth: access token required
- Response: `204`
- Error codes:
  - `UNAUTHORIZED`
  - `INTERNAL`

### 4) Get short-lived render URL for current profile image

`GET /v1/me/profile-image/url`

- Auth: access token required
- Response:
  - `200` → `{ data: { url, expiresAt } }`
  - `204` → no profile image set
- Error codes:
  - `UNAUTHORIZED`
  - `USERS_OBJECT_STORAGE_NOT_CONFIGURED`
  - `INTERNAL`

## Related fields in `/v1/me`

The current user profile includes:
- `profile.profileImageFileId` (nullable)

This file ID is the backend’s canonical “profile image pointer”. Clients should use:
- `GET /v1/me/profile-image/url` to render the image

## Client-side implications

### Presigned upload execution

- The client must upload the file bytes using the returned presigned URL and required headers.
- The client must NOT attach backend auth headers to the presigned upload request.
- The client should assume upload plans expire and handle retries by requesting a new plan.

### Handling 204 responses

`GET /v1/me/profile-image/url` can return `204`, which should be treated as:
- “no image” (not an error)

