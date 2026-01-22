# TODO — Profile Draft (Complete Profile form)

## Objective

Persist unsent Complete Profile form inputs locally and restore them on reopen, so users can resume profile completion after closing the app mid-form.

## Phase 0 — Confirm scope

- [x] Confirm backend contract (source of truth):
  - [x] Backend accepts profile patch via `PATCH /v1/me` with payload:
    - `PatchMeRequestDto.profile` (required)
    - `PatchMeProfileDto.displayName|givenName|familyName` (all optional, all `nullable: true`)
    - Constraints: `minLength: 1`, `maxLength: 100` for each string field
    - OpenAPI: `/mnt/c/Development/_CORE/backend-core-kit/docs/openapi/openapi.yaml`
- [ ] Confirm which fields are part of Complete Profile *in this template*:
  - [ ] `givenName` (required for client gating; see `AppStartupController.needsProfileCompletion`)
  - [ ] `familyName` (optional)
  - [ ] `displayName` (supported by backend; currently not collected by UI)
- [ ] Confirm TTL policy (recommended default: 7 days).

## Phase 1 — Domain layer

- [x] Add `ProfileDraftEntity`:
  - [x] `lib/features/user/domain/entity/profile_draft_entity.dart`
- [x] Add repository contract:
  - [x] `lib/features/user/domain/repository/profile_draft_repository.dart`
- [x] Add use cases:
  - [x] `lib/features/user/domain/usecase/get_profile_draft_usecase.dart`
  - [x] `lib/features/user/domain/usecase/save_profile_draft_usecase.dart`
  - [x] `lib/features/user/domain/usecase/clear_profile_draft_usecase.dart`

## Phase 2 — Data layer (SharedPreferences)

- [x] Add local model (JSON + TTL helpers):
  - [x] `lib/features/user/data/model/local/profile_draft_local_model.dart`
- [x] Add local datasource (SharedPreferences + TTL):
  - [x] `lib/features/user/data/datasource/local/profile_draft_local_datasource.dart`
  - [x] Key format: `user_profile_draft:<userId>`
  - [x] Store JSON string (single key per user)
  - [x] Enforce TTL on read (expired/invalid drafts are cleared)
- [x] Add repository implementation:
  - [x] `lib/features/user/data/repository/profile_draft_repository_impl.dart`

## Phase 3 — DI wiring

- [ ] Register new components in `lib/features/user/di/user_module.dart`:
  - [ ] datasource
  - [ ] repository impl
  - [ ] use cases

## Phase 4 — Presentation wiring (CompleteProfile)

- [ ] Update `CompleteProfileCubit`:
  - [ ] Add `loadDraft()` (session-guarded)
  - [ ] Add debounced `saveDraft` on `givenNameChanged` / `familyNameChanged`
  - [ ] Clear draft on successful `PATCH /v1/me`
- [ ] Ensure draft load is triggered at provider creation (route builder), not in widget post-frame.

## Phase 5 — Tests

- [ ] Unit tests for datasource:
  - [ ] save → get roundtrip
  - [ ] clear removes
  - [ ] TTL expiry returns null
- [ ] (Optional) Cubit test:
  - [ ] loadDraft populates state + validation
  - [ ] debounce-save triggers repository

## Phase 6 — Verification

- [ ] `tool/agent/flutterw --no-stdin analyze`
- [ ] `tool/agent/dartw --no-stdin run custom_lint`
- [ ] `tool/agent/flutterw --no-stdin test`
- [ ] (If needed) `tool/agent/dartw --no-stdin run tool/verify.dart --env dev`

## Phase 7 — Optional cleanup

- [ ] Decide whether to clear drafts on logout/session cleared (cross-feature hook).
- [ ] Decide whether to support draft for other onboarding forms in the future (generic draft store vs per-form).
