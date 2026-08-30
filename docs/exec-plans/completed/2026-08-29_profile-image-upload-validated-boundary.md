# Strengthen The Profile Image Upload Validation Boundary

**Plan version:** 2
**Task ID:** profile-image-upload-validated-boundary
**Status:** completed
**Owner:** Codex
**Risk:** medium
**Authority:** Refactor only profile-image upload from a raw UploadProfileImageRequestEntity plus primitive upload-plan request to ProfileImageUploadInput -> ValidatedProfileImageUpload -> CreateProfileImageUploadRequestModel, preserving file bytes, MIME normalization, size/type rules, idempotency, upload orchestration, cache refresh, and backend requests.
**Allowed paths:** docs/exec-plans/queued/2026-08-29_profile-image-upload-validated-boundary.md, docs/exec-plans/active/2026-08-29_profile-image-upload-validated-boundary.md, docs/exec-plans/completed/2026-08-29_profile-image-upload-validated-boundary.md, lib/features/account/subfeatures/profile/domain/entity/upload_profile_image_request_entity.dart, lib/features/account/subfeatures/profile/domain/entity/upload_profile_image_request_entity.freezed.dart, lib/features/account/subfeatures/profile/domain/entity/create_profile_image_upload_plan_request_entity.dart, lib/features/account/subfeatures/profile/domain/entity/create_profile_image_upload_plan_request_entity.freezed.dart, lib/features/account/subfeatures/profile/domain/input/profile_image_upload_input.dart, lib/features/account/subfeatures/profile/domain/value/validated_profile_image_upload.dart, lib/features/account/subfeatures/profile/domain/repository/profile_image_repository.dart, lib/features/account/subfeatures/profile/domain/usecase/upload_profile_image_usecase.dart, lib/features/account/subfeatures/profile/data/model/remote/create_profile_image_upload_request_model.dart, lib/features/account/subfeatures/profile/data/model/remote/create_profile_image_upload_request_model.freezed.dart, lib/features/account/subfeatures/profile/data/model/remote/create_profile_image_upload_request_model.g.dart, lib/features/account/subfeatures/profile/data/repository/profile_image_repository_impl.dart, lib/features/account/subfeatures/profile/presentation/cubit/profile_image/profile_image_cubit.dart, test/features/account/subfeatures/profile/domain/value/validated_profile_image_upload_test.dart, test/features/account/subfeatures/profile/domain/usecase/upload_profile_image_usecase_test.dart, test/features/account/subfeatures/profile/data/repository/profile_image_repository_impl_test.dart, test/features/account/subfeatures/profile/presentation/cubit/profile_image/profile_image_cubit_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** medium
**Repair limit:** 3
**Task timeout:** 120m
**Oracle IDs:** ui.human-review

Date: 2026-08-29
Related issue/PR: N/A

## Objective

Represent successful image type/size validation in the repository contract so
the upload-plan request cannot be created from arbitrary MIME/size primitives,
while leaving server-derived completion commands unchanged.

## Constraints

- Architecture constraints:
  - Raw selected bytes/content type/idempotency live in `ProfileImageUploadInput`.
  - `ValidatedProfileImageUpload.create()` owns MIME normalization, nonempty/max-size checks, and derived byte size.
  - `createUploadPlan` accepts the validated upload; the data request model unwraps only required metadata.
  - Keep server-derived `CompleteProfileImageUploadRequestEntity` and clear-image commands unchanged.
- Product/runtime constraints:
  - Preserve all bytes exactly, `image/jpg -> image/jpeg`, allowed types, 5 MB limit, idempotency key, presigned upload, completion, cache seeding, and current-user refresh.
- Out of scope:
  - Image compression/resizing, picker UX, upload retry policy, clear-image flow, cache architecture, or backend changes.
  - Commit, push, or PR creation.

## Impact Areas

- Auth/session: no
- Navigation/deep links/startup: no
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: yes
- Harness/CI/release: no
- External systems: no

## Acceptance Scenarios

1. Given empty, oversized, or unsupported image input, when upload starts, then deterministic errors are returned and no repository method is called.
2. Given `image/jpg`, when validated, then the upload plan receives `image/jpeg`, exact byte size, unchanged bytes, and unchanged idempotency key.
3. Given valid input, when upload completes, then create-plan, presigned upload, completion, cache/current-user refresh, and UI effects occur in the same order.
4. Given failure at any remote stage, when returned, then later stages remain uncalled as today.

## Acceptance Criteria

1. Raw upload input and validated upload are distinct types.
2. The validated upload has no public unchecked constructor and owns existing type/size rules.
3. `ProfileImageRepository.createUploadPlan` accepts only the validated upload.
4. The primitive upload-plan request entity and raw upload request entity are removed; server-derived completion types remain.
5. Request-model, repository orchestration, use-case failure ordering, byte preservation, and Cubit behavior are covered.

## Implementation Checklist

- [x] Add raw upload input and validated upload aggregate.
- [x] Migrate use case and create-plan repository/model boundary.
- [x] Migrate presentation input and remove obsolete request entities/generated sources.
- [x] Add aggregate tests and update mapper, repository, use-case, and Cubit tests.
- [x] Run controlled verification and collect upload runtime evidence.
- [x] Complete and archive this plan.

## Decision Log

- 2026-08-29: Validate the complete selected upload, not only plan metadata -> byte emptiness/size and MIME type form one invariant set.
- 2026-08-29: Retain completion request entities -> their values originate from a valid server plan, not raw form input.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task profile-image-upload-validated-boundary --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task profile-image-upload-validated-boundary --env dev
```

Run focused aggregate, use-case, repository, datasource/model, and Cubit tests
during the inner loop.

Result: `task verify` passed with profile full on attempt 1, including all
application tests, analyzer and custom lints, codegen freshness, knowledge
validation, and the duplication advisory.

## Runtime Evidence

Not collected. No mobile device or emulator is attached to this environment
(`flutter devices` reports only linux/chrome hosts), so the `ui.human-review`
runtime scenario could not be exercised. MIME normalization, byte/size rules,
stage-by-stage failure ordering, and Cubit effects remain covered by the
aggregate, use-case, repository, and Cubit tests updated in this change set.
Human review of the upload UI flow remains an open pre-merge expectation per
the plan's oracle.

## Rollback

Restore raw/upload-plan request entities and previous use-case/repository/model/
Cubit signatures. Remote objects and caches require no schema rollback.

## Risks And Mitigations

- Risk: bytes, MIME normalization, or idempotency changes during mapping.
- Mitigation: assert exact bytes/key and normalized MIME through every orchestration call.
- Risk: multi-stage failure ordering changes.
- Mitigation: retain stage-by-stage repository call-order and short-circuit tests.

## Completion Notes

`ProfileImageUploadInput` represents the raw selected upload and
`ValidatedProfileImageUpload.create()` owns MIME normalization
(`image/jpg` -> `image/jpeg`, trimmed/lowercased), the non-empty and 5 MB
checks, and the derived byte size, with no public unchecked constructor.
`ProfileImageRepository.createUploadPlan` accepts only the validated upload;
the repository passes the validated metadata to the datasource, whose request
model remains the sole JSON owner. The use case keeps the plan -> presigned
upload -> completion -> current-user refresh orchestration and its
stage-by-stage short-circuit ordering. The server-derived completion request
entity and clear-image commands are unchanged. Both primitive request
entities and their generated sources are removed; upload bytes are preserved
unchanged through every stage.

## Follow-ups

None. No unresolved debt recorded in `docs/exec-plans/tech_debt_tracker.md`.
