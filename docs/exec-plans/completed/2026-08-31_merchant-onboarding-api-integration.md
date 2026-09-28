# Integrate Merchant Onboarding With The Accepted Backend API

**Plan version:** 2
**Task ID:** merchant-onboarding-api-integration
**Status:** completed
**Owner:** Dante
**Risk:** high
**Authority:** After the merchant-onboarding backend implementation and generated OpenAPI are reviewed and committed, sync that exact accepted contract into the mobile-owned snapshot and replace the production merchant-onboarding fake with a tested authenticated remote adapter while preserving the existing validated domain boundary and user flow; do not mutate the backend repository or publish changes.
**Allowed paths:** docs/exec-plans/queued/2026-08-31_merchant-onboarding-api-integration.md, docs/exec-plans/active/2026-08-31_merchant-onboarding-api-integration.md, docs/exec-plans/completed/2026-08-31_merchant-onboarding-api-integration.md, docs/contracts/openapi/backend.openapi.yaml, docs/contracts/openapi/backend.openapi.lock.json, lib/core/infra/network/endpoints/merchant_onboarding_endpoint.dart, lib/features/merchant_onboarding/data/, lib/features/merchant_onboarding/di/merchant_onboarding_module.dart, lib/features/merchant_onboarding/domain/entity/merchant_application_receipt.dart, lib/features/merchant_onboarding/domain/merchant_onboarding_failure.dart, lib/features/merchant_onboarding/presentation/cubit/merchant_onboarding/, lib/features/merchant_onboarding/presentation/localization/merchant_onboarding_error_localizer.dart, lib/features/merchant_onboarding/presentation/pages/merchant_onboarding_page.dart, lib/l10n/, test/features/merchant_onboarding/data/, test/features/merchant_onboarding/di/, test/features/merchant_onboarding/domain/, test/features/merchant_onboarding/presentation/, test/features/merchant_onboarding/support/, duplication/small_helper_duplication_allowlist.json, test/core/di/registrars/registrars_smoke_test.dart
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 6h
**Oracle IDs:** contract.openapi.snapshot, auth.integration, ui.human-review

Date: 2026-08-31
Related issue/PR: N/A

## Objective

Connect the completed four-step merchant-onboarding mobile demo to the accepted
`backend-core-kit` implementation without weakening its validation
architecture. The production DI graph must load server-owned reference data
and submit only a fully validated `MerchantOnboardingApplication`; transport
DTOs, response envelopes, idempotency headers, and RFC7807 failures remain
inside the data boundary.

This plan ends with a production-wired adapter that is completely testable
without a live backend. Live mobile-to-backend execution is deliberately owned
by the sequential `merchant-onboarding-live-e2e` plan.

## Entry Preconditions

- The current merchant-onboarding mobile demo is reviewed, committed, and the
  mobile working tree is suitable for a new task baseline.
- The backend implementation, migration, tests, and generated
  `docs/openapi/openapi.yaml` are reviewed and committed on its feature branch.
- The full 40-character accepted backend revision is available. A dirty backend
  working tree or a branch pointer without an accepted commit is not valid
  input to contract sync.
- A human has reviewed the backend OpenAPI delta and accepts copying that exact
  artifact into the mobile-owned snapshot. `--accept` must never be inferred
  from an arbitrary sibling checkout.

## Constraints

- Architecture constraints:
  - Keep `presentation -> input -> use case/final gate -> validated aggregate -> repository -> remote DTO` as the execution direction.
  - `MerchantOnboardingRepository.submitApplication` continues to accept a
    validated `MerchantOnboardingApplication`; raw form primitives and remote
    DTOs must not cross into the repository contract.
  - Hand-write mobile Freezed/JSON DTOs from the pinned snapshot. The repository
    explicitly uses zero OpenAPI client generation.
  - Use the existing `ApiHelper`, `ApiResponse`, `ApiFailure`, authentication
    interceptor, `ApiHost.core`, and `IdempotencyKeyUtils` conventions.
  - Keep endpoint constants small and feature-specific. Do not introduce a
    generic API SDK, mapper framework, validation framework, or catalog layer.
  - Preserve backend-provided catalog IDs and labels. IDs are domain identity;
    labels are display data and must never drive validation.
  - Generated Freezed/JSON and localization files must stay in sync through the
    repository's normal generators.
- Product/runtime constraints:
  - `GET /merchant-onboarding/reference-data` requires the authenticated core
    host and parses the standard `{data}` envelope.
  - `POST /merchant-onboarding/applications` requires authentication and one
    non-empty `Idempotency-Key` generated once per repository invocation. Dio's
    automatic retry of that request must reuse the same header.
  - A later manual Submit after an explicit failure is a new invocation and may
    use a new key. If the earlier result was ambiguous but accepted, the
    backend's one-application invariant is mapped to an already-submitted
    outcome rather than silently creating another application.
  - Decimal ownership percentages must be mapped losslessly to integer basis
    points. No `double` rounding is permitted in the wire mapper.
  - Account numbers preserve leading zeroes in requests and must never be
    logged or returned to presentation. Only the backend's redacted last-four
    response may be parsed.
  - Server field validation may be shown on existing fields only when its
    stable code/path maps to a known `MerchantValidationFailure`; raw server
    messages are never rendered.
- Out of scope:
  - Backend source, schema, migration, or OpenAPI mutation.
  - Editable server drafts, application status polling, review/approval,
    payouts, document upload, notifications, or admin capabilities.
  - Offline draft persistence, background submission, caching, and catalog
    administration.
  - Commit, push, draft PR, deployment, production credentials, or publication.
  - Live backend/device evidence, which belongs to the next plan.

## Impact Areas

- Auth/session: yes
- Navigation/deep links/startup: no
- API/contracts: yes
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: yes
- Harness/CI/release: no
- External systems: no

## Acceptance Scenarios

1. Given the accepted backend commit and its generated OpenAPI, when contract
   sync is performed, then the mobile snapshot and lock contain the exact bytes,
   SHA-256 digest, and full backend revision and pass contract verification.
2. Given an authenticated user opens merchant onboarding, when reference data
   loads, then the app requests the backend endpoint once and maps every catalog
   option, validation metadata flag, supported payout-schedule ID, and terms
   version into an immutable `MerchantReferenceData` snapshot.
3. Given the reference request returns `401`, a retryable network/server error,
   or malformed/unknown data, when the repository maps it, then presentation
   receives the corresponding safe domain failure and never a Dio exception or
   raw backend message.
4. Given a valid application containing percentage strings and an account
   number with leading zeroes, when it is mapped for submission, then ownership
   becomes exact integer basis points, normalized domain values are unwrapped,
   nullable fields follow the accepted schema, and the account number remains a
   JSON string with its leading zeroes.
5. Given submission starts, when the datasource sends the POST, then it uses
   authentication, the core API host, the standard envelope parser, and one
   non-empty idempotency key that remains attached to automatic retries of that
   request.
6. Given a successful `201` response, when it is mapped, then the domain receipt
   exposes the application ID needed by the existing success effect while full
   account data and unused transport details do not leak into presentation.
7. Given the backend returns `VALIDATION_FAILED` with recognized stable field
   paths/codes, when submission completes, then those errors appear on the
   correct wizard step/field and focus the first known invalid field.
8. Given the backend returns application-already-exists, registration conflict,
   stale references, stale terms, unauthenticated, idempotency-in-progress,
   generic conflict, timeout, or server failure, when it is mapped, then each
   documented case has deterministic safe behavior and localized user copy;
   unknown cases fall back to unexpected failure.
9. Given production DI is resolved, when `MerchantOnboardingCubit` is created,
   then it uses the real repository and remote datasource. Tests may still
   inject a fake through the existing repository interface without a second
   production abstraction.
10. Given the full mobile test suite and generators run, when verification
    finishes, then existing local final-gate validation, wizard behavior,
    navigation, and unrelated features remain green.

## Acceptance Criteria

1. The pinned mobile OpenAPI exposes the exact accepted merchant reference and
   submit operations, DTO schemas, authentication, idempotency header, response
   envelopes, and documented error codes.
2. Request, response, and reference-data models mirror only the accepted wire
   contract and have focused serialization fixture tests.
3. Pure mappers cover every catalog metadata field, exact basis-point
   conversion, optional owner references/percentages, leading-zero account
   numbers, and the redacted receipt.
4. The datasource has focused tests for method, path, host, authentication,
   request envelope, parser, and idempotency header behavior.
5. The repository implementation maps transport success and every documented
   error code/status into the feature's domain failure taxonomy without raw
   messages reaching UI.
6. Production DI no longer registers `FakeMerchantOnboardingRepository`.
7. Existing final-gate use cases and domain aggregates do not depend on Dio,
   JSON, remote models, or backend error types.
8. Code generation, localization generation, contract verification, targeted
   feature tests, architecture lint, duplication review, and full verification
   pass for the final candidate.

## Implementation Checklist

- [x] Confirm both entry baseline commits and record the accepted backend SHA in
  the task's narrative evidence without adding an absolute path to tracked files.
- [x] Activate this plan, run `mobilekit task begin` from the exact mobile task
  workspace, and inspect the immutable authority before editing.
- [x] Run contract-sync edit preflight, review the backend OpenAPI delta, then
  sync the accepted backend artifact with its full SHA and `--accept`.
- [x] Verify the pinned snapshot and inspect the merchant paths, schemas,
  envelopes, security declaration, idempotency header, and `x-error-codes`.
- [x] Add the two feature endpoint constants using the existing core-host base
  URL convention.
- [x] Add minimal Freezed/JSON reference, submit-request, submit-response, and
  envelope models plus generated files.
- [x] Add pure mapping from remote reference models to immutable domain
  reference data, rejecting malformed assumptions safely.
- [x] Add pure mapping from `MerchantOnboardingApplication` to the submit model;
  implement exact percentage-to-basis-points conversion without floating point.
- [x] Add the authenticated remote datasource for reference GET and idempotent
  application POST using `ApiHelper`.
- [x] Refine the feature failure taxonomy only where the accepted backend codes
  require distinct behavior: server field validation, existing application,
  registration conflict, stale reference, stale terms, unauthenticated,
  idempotency/retryable, and unexpected conflict/failure.
- [x] Implement one repository adapter that converts `ApiResponse`/`ApiFailure`
  into domain reference data, receipt, or safe feature failures.
- [x] Route recognized server field failures through the existing Cubit step,
  error, and focus behavior; localize repository-level outcomes without showing
  backend titles/details.
- [x] Replace the production fake registration with datasource + real repository
  registration and update DI smoke coverage.
- [x] Keep or relocate the deterministic fake only where tests explicitly need
  an injected repository fixture; remove production comments that claim the
  backend contract is pending.
- [x] Add focused model, mapper, datasource, repository, DI, Cubit, localization,
  and regression tests for the acceptance scenarios.
- [x] Run generators and the controlled full verification loop; repair only
  within declared scope and budget.
- [x] Perform the registered UI review for loading, server field failure,
  repository failure, and success copy using sanitized data.
- [x] Record truthful outcomes, move the verified plan to `completed/`, and hand
  off the clean logical boundary to `merchant-onboarding-live-e2e`.

## Decision Log

- 2026-08-31: Amend allowed paths with the test-support fake location and the
  small-helper duplication allowlist -> the fake moved to test support when
  production DI switched to the real adapter, and the merchant step-widget
  pairs were recorded as reviewed-acceptable duplication.
- 2026-08-31: Split live E2E from adapter implementation -> contract/data work
  is deterministic and unit-testable, while a real backend/database requires
  separate environment authority, cleanup, evidence, and rollback.
- 2026-08-31: Sync only an accepted backend commit -> the mobile lock must bind
  a reviewable immutable revision, never dirty sibling-checkout state.
- 2026-08-31: Keep zero OpenAPI code generation -> the repository contract says
  agents read the pinned spec and use normal Freezed/JSON models.
- 2026-08-31: Preserve the validated aggregate repository boundary -> backend
  integration transports validated domain values; it does not move final-gate
  validation into DTOs or presentation.
- 2026-08-31: Generate one idempotency key per repository invocation -> Dio
  automatic retries reuse the same request header, while a later explicit user
  attempt remains a new invocation and the server uniqueness invariant prevents
  duplicate persistence.
- 2026-08-31: Keep the domain receipt minimal unless UI needs more -> parse the
  accepted redacted response but expose only business data consumed by the flow.
- 2026-08-31: Distinguish actionable stable backend outcomes -> stale terms,
  stale catalogs, registration conflict, existing application, and known field
  validation require different recovery behavior; unknown server text does not.

## Verification

Record exact commands and outcomes. Replace placeholders only after the backend
revision is accepted.

```bash
dart run mobile_core_kit_cli:mobilekit task begin \
  --plan docs/exec-plans/active/2026-08-31_merchant-onboarding-api-integration.md
dart run mobile_core_kit_cli:mobilekit task preflight \
  --task merchant-onboarding-api-integration --action edit
dart run mobile_core_kit_cli:mobilekit contract openapi sync \
  --source <reviewed-backend-openapi-path> \
  --source-revision <accepted-40-character-backend-sha> \
  --accept
dart run mobile_core_kit_cli:mobilekit contract openapi verify
dart run build_runner build
fvm flutter gen-l10n
fvm flutter test test/features/merchant_onboarding/data \
  test/features/merchant_onboarding/domain \
  test/features/merchant_onboarding/presentation \
  test/features/merchant_onboarding/di \
  test/core/di/registrars/registrars_smoke_test.dart
dart run mobile_core_kit_cli:mobilekit duplication check --profile core
dart run mobile_core_kit_cli:mobilekit duplication check --profile small-helpers
dart run mobile_core_kit_cli:mobilekit duplication check --profile presentation
dart run mobile_core_kit_cli:mobilekit task preflight \
  --task merchant-onboarding-api-integration --action verify
dart run mobile_core_kit_cli:mobilekit task verify \
  --task merchant-onboarding-api-integration --env dev
git diff --check
```

## Runtime Evidence

Live backend evidence is intentionally deferred to
`merchant-onboarding-live-e2e`. This plan still requires the registered UI
human review because remote failure mapping changes user-visible copy and field
routing. Record device/host, flavor, exact task fingerprint, sanitized
observations, and screenshots only when they contain no account number, token,
email, phone, authorization header, raw server body, or trace identifier.

## Rollback

Revert the integration commit as one logical unit: restore production DI to the
deterministic fake, remove the merchant remote models/datasource/repository and
endpoint constant, restore the previous feature failure/localization behavior,
and restore the prior OpenAPI snapshot and lock together. Never restore only
one of the two contract files. No backend or persisted data is changed by this
plan.

## Risks And Mitigations

- Risk: Mobile code is generated from a dirty or later-rewritten backend spec.
  Mitigation: Require an accepted full backend SHA and bind it in the lockfile.
- Risk: Transport DTOs duplicate or bypass domain validation.
  Mitigation: Map only from the validated aggregate at the repository edge and
  retain the use case as final gate.
- Risk: Percentage conversion silently rounds and breaks the 10,000-basis-point
  invariant.
  Mitigation: Convert normalized decimal text using integer arithmetic and test
  boundary values and multi-owner totals.
- Risk: A timeout causes an unsafe duplicate POST.
  Mitigation: Generate the key before the request, retain it on Dio retries, and
  rely on backend idempotency plus database uniqueness for ambiguous outcomes.
- Risk: Raw RFC7807 text or sensitive account data reaches logs/UI.
  Mitigation: Map stable codes/statuses only, use localized copy, and prohibit
  request-body logging and full account data in receipt/evidence.
- Risk: Server and mobile field paths differ for owner rows.
  Mitigation: Normalize accepted index/row-ID paths in one mapper and test focus
  routing for known rows; unknown paths become a safe form-level failure.

## Completion Notes

The merchant-onboarding flow is now wired to the accepted backend API. The
mobile-owned OpenAPI snapshot and lock were synced from the accepted backend
commit `b10a5bf905aa353df756cd03047dbcb3c6d649d7` (snapshot SHA
`6ae079adec93303ae3db3dee3ec13c2d1999f6b3367e800688469d4a780cff8c`) and pass
contract verification. Added the two feature endpoint constants, minimal
Freezed/JSON reference/submit/envelope DTOs, pure mappers (lossless integer
basis points, leading-zero account numbers), an authenticated remote datasource
(core host, standard envelope, one Idempotency-Key per invocation), and one
repository adapter mapping every documented backend error code into the
feature failure taxonomy. Production DI now registers the real datasource and
repository; the deterministic fake moved to test support. Server field
validation routes through the existing Cubit step/focus behavior with
localized repository-level copy. The merchant step-widget pairs were recorded
as reviewed-acceptable in the small-helper duplication allowlist. Controlled
verification passed with profile full on attempt 1.

## Follow-ups

- [x] Recorded as a follow-up (not executed): execute `merchant-onboarding-live-e2e` after this task is verified and its
  candidate is available as a stable baseline.
- [x] No other unresolved debt: `docs/exec-plans/tech_debt_tracker.md` unchanged (state none)
  `docs/exec-plans/tech_debt_tracker.md`, or state none.
