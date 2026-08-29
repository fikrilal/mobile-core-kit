# Strengthen The Verify Email Token Boundary

**Plan version:** 2
**Task ID:** verify-email-token-boundary
**Status:** queued
**Owner:** Codex
**Risk:** high
**Authority:** Refactor only email verification so the use case accepts one raw token String, validates it into EmailVerificationToken, and the repository accepts that VO directly, preserving deep-link/navigation behavior, token normalization, backend payload, and failure handling.
**Allowed paths:** docs/exec-plans/queued/2026-08-29_verify-email-token-boundary.md, docs/exec-plans/active/2026-08-29_verify-email-token-boundary.md, docs/exec-plans/completed/2026-08-29_verify-email-token-boundary.md, integration_test/auth_happy_path_test.dart, integration_test/startup_deep_link_resume_test.dart, lib/features/auth/domain/entity/verify_email_request_entity.dart, lib/features/auth/domain/entity/verify_email_request_entity.freezed.dart, lib/features/auth/domain/repository/auth_repository.dart, lib/features/auth/domain/usecase/verify_email_usecase.dart, lib/features/auth/data/model/remote/verify_email_request_model.dart, lib/features/auth/data/model/remote/verify_email_request_model.freezed.dart, lib/features/auth/data/model/remote/verify_email_request_model.g.dart, lib/features/auth/data/repository/auth_repository_impl.dart, lib/features/auth/subfeatures/email_verification/presentation/cubit/email_verification/email_verification_cubit.dart, test/features/auth/domain/usecase/verify_email_usecase_test.dart, test/features/auth/data/model/remote/verify_email_request_model_test.dart, test/features/auth/subfeatures/email_verification/presentation/cubit/email_verification/email_verification_cubit_test.dart, test/navigation/app_redirect_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 75m
**Oracle IDs:** auth.integration, startup.integration

Date: 2026-08-29
Related issue/PR: N/A

## Objective

Prevent an arbitrary token string from reaching email verification without
creating a redundant one-field aggregate around `EmailVerificationToken`.

## Constraints

- Architecture constraints:
  - The use case accepts one raw token `String`; the repository accepts the validated VO.
  - The repository accepts `EmailVerificationToken` directly.
  - JSON conversion remains in `VerifyEmailRequestModel`.
- Product/runtime constraints:
  - Preserve trimming, deep-link ingestion, resend/verify UI behavior, payload, and backend failure mapping.
- Out of scope:
  - Verification-email resend, route redesign, or a generic token abstraction.
  - Commit, push, or PR creation.

## Impact Areas

- Auth/session: yes
- Navigation/deep links/startup: yes
- API/contracts: no
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: no
- Harness/CI/release: no
- External systems: no

## Acceptance Scenarios

1. Given an empty token, when verification is requested, then validation fails and the repository is not called.
2. Given a valid token with surrounding whitespace, when verified, then the repository receives the normalized VO.
3. Given a token delivered through a deep link, when serialized, then route behavior and `{token: ...}` payload remain unchanged.

## Acceptance Criteria

1. The primitive verification request entity and generated file are removed.
2. The use case accepts a raw token `String`; `EmailVerificationToken` represents validated input.
3. Repository and request-model signatures require/map `EmailVerificationToken`.
4. Use-case, mapper, Cubit, redirect, and integration tests preserve current behavior.

## Implementation Checklist

- [ ] Migrate presentation/use-case input to one raw token `String`.
- [ ] Migrate repository and request-model mappings to `EmailVerificationToken`.
- [ ] Remove the old request entity and generated source.
- [ ] Update focused, Cubit, redirect, and integration tests.
- [ ] Run controlled full verification and collect auth/startup runtime evidence where supported.
- [ ] Complete and archive this plan.

## Decision Log

- 2026-08-29: Use a raw `String` at the use-case boundary and the token VO at the repository boundary -> one-field `XInput` and aggregate wrappers add no semantics.

## Verification

```bash
dart run mobile_core_kit_cli:mobilekit task preflight --task verify-email-token-boundary --action verify
dart run mobile_core_kit_cli:mobilekit task verify --task verify-email-token-boundary --env dev
```

Run focused use-case, mapper, Cubit, redirect, and integration tests during the
inner loop.

## Runtime Evidence

Exercise a verification deep link and invalid token on a supported target.
Record sanitized auth/startup evidence or the exact environment limitation.

## Rollback

Restore `VerifyEmailRequestEntity` and prior Cubit/use-case/repository/model
signatures. No external contract rollback is required.

## Risks And Mitigations

- Risk: token normalization or route handoff changes.
- Mitigation: assert raw-to-VO normalization and retain deep-link/redirect coverage.

## Completion Notes

Pending.

## Follow-ups

- [ ] Record unresolved debt in `docs/exec-plans/tech_debt_tracker.md`, or state none.
