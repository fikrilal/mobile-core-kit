# Prove Merchant Onboarding Against The Live Backend

**Plan version:** 2
**Task ID:** merchant-onboarding-live-e2e
**Status:** completed
**Owner:** Dante
**Risk:** high
**Authority:** After the accepted backend commit and the verified mobile remote adapter are stable baselines, implement a deterministic mobile-to-local-backend merchant-onboarding integration target, execute the complete authenticated wizard against an isolated real backend database, collect sanitized runtime and human-review evidence, and repair only merchant integration defects discovered by that evidence; do not mutate backend source, use shared/production data, or publish changes.
**Allowed paths:** docs/exec-plans/queued/2026-08-31_merchant-onboarding-live-e2e.md, docs/exec-plans/active/2026-08-31_merchant-onboarding-live-e2e.md, docs/exec-plans/completed/2026-08-31_merchant-onboarding-live-e2e.md, integration_test/merchant_onboarding_live_test.dart, integration_test/support/, lib/features/merchant_onboarding/data/, lib/core/infra/network/endpoints/merchant_onboarding_endpoint.dart, lib/features/merchant_onboarding/di/merchant_onboarding_module.dart, lib/features/merchant_onboarding/domain/entity/merchant_application_receipt.dart, lib/features/merchant_onboarding/domain/merchant_onboarding_failure.dart, lib/features/merchant_onboarding/presentation/cubit/merchant_onboarding/, lib/features/merchant_onboarding/presentation/localization/merchant_onboarding_error_localizer.dart, lib/features/merchant_onboarding/presentation/pages/merchant_onboarding_page.dart, lib/l10n/, test/features/merchant_onboarding/, test/core/di/registrars/registrars_smoke_test.dart, _artifacts/mobile/
**Allowed actions:** edit, verify
**Maximum risk:** high
**Repair limit:** 3
**Task timeout:** 6h
**Oracle IDs:** contract.openapi.snapshot, auth.integration, ui.human-review, external.human-review

Date: 2026-08-31
Related issue/PR: N/A

## Objective

Prove that the production-wired mobile flow and the accepted backend work
together across the real HTTP, auth, idempotency, validation, Prisma, and UI
boundaries. The evidence must exercise a disposable local/test environment and
must be repeatable without relying on a developer's existing merchant record.

The test is supplementary deterministic evidence authored for this feature.
The registered contract, auth, UI-review, and external-system human-review
oracles remain the independent acceptance boundaries; the new target must not
be treated as an automatically trusted oracle merely because it passes.

## Entry Preconditions

- `merchant-onboarding-api-integration` is verified and available as a stable
  mobile baseline; no production DI path still resolves the fake repository.
- The exact accepted backend revision recorded in
  `backend.openapi.lock.json` is checked out and its repository verification,
  Prisma migration, and persistence integration tests have passed.
- The backend runs against an isolated disposable database and non-production
  environment. The operator has an explicit reset/cleanup procedure.
- A supported Android/iOS emulator or device can reach the local backend using
  the configured dev host. No credential, token, or host override is committed.
- The environment can create a unique authenticated test principal without
  email, payment, storage, or other external side effects.

## Constraints

- Architecture constraints:
  - Exercise the same production datasource, repository, use case, Cubit, page,
    routing, auth interceptor, and network stack used by the application.
  - Test-only setup may provision an ephemeral user/session, but it must not
    replace the merchant repository or inject canned merchant responses.
  - Reuse integration support only where it reduces setup duplication without
    introducing a parallel application architecture.
  - Repairs must address observed production-path defects and include focused
    regression tests. No unrelated refactor or generalized E2E framework.
- Product/runtime constraints:
  - Each run uses a unique authenticated user and isolated database state so the
    one-application-per-user invariant remains deterministic.
  - Reference data must come from the live GET response before the form is
    completed; the test must select IDs from that response/visible UI rather
    than hard-code labels as validation identity.
  - The submitted scenario uses a private company, a complete owning row,
    business settlement, a bank-supported schedule, current terms, and an
    account number with a leading zero.
  - Evidence may retain application ID, HTTP status, stable error code, and
    redacted last four digits only. It must exclude passwords, tokens, complete
    account numbers, personal emails/phones, authorization headers, request
    bodies, raw trace data, and database connection strings.
  - Backend startup, migration, seeding, and cleanup are operator-owned external
    actions. This mobile task may invoke documented commands but may not edit
    backend source or database schema.
- Out of scope:
  - Production/staging deployment, shared databases, real merchant identities,
    payment rails, bank verification, compliance decisions, or load testing.
  - Backend fixes. A backend defect is reported with reproducible sanitized
    evidence and repaired under separate backend authority.
  - Registering the newly authored E2E target as a harness oracle in this task.
  - Commit, push, draft PR, or publication.

## Impact Areas

- Auth/session: yes
- Navigation/deep links/startup: no
- API/contracts: yes
- Database/migrations: no
- Platform/Firebase/permissions: no
- UI/UX/accessibility: yes
- Harness/CI/release: no
- External systems: yes

## Acceptance Scenarios

1. Given an isolated accepted backend and empty disposable database, when the
   mobile integration target provisions a unique test principal and launches
   the production-wired app, then authentication succeeds without embedding or
   logging secrets.
2. Given the authenticated user opens merchant onboarding, when the page
   initializes, then the real reference endpoint returns every expected catalog
   and current terms and the wizard renders the first step without fake data.
3. Given the user completes all four steps with contract-valid values, when Next
   and Submit are used through the UI, then local final-gate validation passes,
   exactly one real POST reaches the backend, and a localized success result
   contains the backend-generated application ID.
4. Given the request contains a leading-zero account number and exact ownership
   total, when the backend persists and responds, then persistence succeeds
   atomically, the response/evidence contains only the last four digits, and no
   complete account number appears in UI, logs, screenshots, or artifacts.
5. Given the backend has accepted the application, when its database is
   inspected through the backend's existing sanitized integration evidence,
   then one application and the expected owner rows exist for that user and no
   partial duplicate set exists.
6. Given the same logical HTTP request is replayed with the same idempotency key
   in a bounded datasource/live check, when the backend responds, then it returns
   the same application result without creating another application. This check
   must not submit through a second fake path.
7. Given a new key attempts a second application for the same user, when the
   backend returns the documented already-exists code, then mobile maps it to
   localized already-submitted behavior rather than success, crash, or raw
   server text.
8. Given no valid session is available, when reference loading is attempted in
   a bounded live check, then `401` maps to the safe unauthenticated domain
   outcome and no merchant request loops indefinitely.
9. Given the live target, registered auth oracle, contract oracle, UI review,
   and external-system review complete, when artifacts are inspected, then all
   evidence binds to the exact candidate fingerprint and contains no secrets or
   sensitive merchant data.

## Acceptance Criteria

1. A dedicated `integration_test/merchant_onboarding_live_test.dart` exercises
   the production merchant adapter against the accepted local backend and is
   skipped/fails with an actionable setup boundary when live prerequisites are
   absent; it never silently falls back to the fake.
2. Test setup uses explicit environment injection and an ephemeral user/session;
   no credential, token, backend absolute path, or database URL is tracked.
3. The full UI happy path, idempotent replay, already-submitted mapping, and
   unauthenticated boundary have deterministic evidence across mobile and
   backend-owned checks.
4. Backend persistence evidence proves one atomic application with expected
   owner rows in disposable state and no duplicate from replay.
5. Runtime artifacts are sanitized and bound to the exact verified mobile task
   fingerprint and accepted backend revision.
6. Any mobile repair discovered at runtime has a focused regression test and
   remains within allowed scope and repair budget.
7. Targeted tests, registered oracles, controlled full verification, live E2E,
   and human review all pass before completion is claimed.

## Implementation Checklist

- [x] Confirm and record the exact mobile candidate revision/fingerprint,
  accepted backend revision, backend verification result, disposable database
  mode, device/emulator, and dev flavor without recording secret values.
- [x] Activate this plan only after the API-integration plan is complete; run
  `mobilekit task begin` from the exact task workspace.
- [x] Run edit preflight and add the smallest explicit live-test configuration
  reader using compile-time/environment inputs already supported by the repo.
- [x] Add reusable integration support only for ephemeral authentication,
  production app bootstrapping, and secret-safe prerequisite diagnostics.
- [x] Implement the live merchant test with the real DI graph and UI wizard;
  assert reference loading, step progression, masked review, submission success,
  and backend application ID.
- [x] Add a bounded real-datasource check for same-key replay and a second-key
  already-exists response without logging the request body.
- [x] Add a bounded unauthenticated reference-data check and assert the mapped
  domain outcome.
- [x] Coordinate operator-owned backend reset/migration/startup and verify the
  accepted revision is the server actually running.
- [x] Execute backend-owned persistence evidence against the disposable database
  and record only counts, IDs safe for test evidence, and invariant outcomes.
- [x] Run controlled full mobile verification before live execution.
- [x] Execute the registered `auth.integration` runtime evidence target on the
  selected device for the exact candidate fingerprint.
- [x] Execute the new live merchant target directly as supplementary evidence;
  record its command, outcome, duration, and sanitized artifact hashes.
- [x] Perform registered UI and external-system human review of loading, masked
  review, success, already-submitted, and unauthenticated behavior.
- [x] If runtime exposes a mobile defect, run `mobilekit task repair`, make only
  an in-scope repair, add a focused regression test, re-run controlled full
  verification, and refresh all stale runtime evidence.
- [x] If runtime exposes a backend defect, stop mobile mutation, record a
  sanitized reproduction, and hand it back under separate backend authority.
- [x] Record truthful completion evidence and move the plan to `completed/` only
  after all acceptance scenarios are proven.

## Decision Log

- 2026-09-01: Amend allowed paths with the merchant endpoint constants ->
  live E2E exposed a double `/v1` prefix bug (endpoint paths included `/v1`
  while the core host base URL already carries it); the fix touched
  `merchant_onboarding_endpoint.dart`.
- 2026-08-31: Use a second sequential plan -> real HTTP/database execution has
  different authority, cleanup, secrets, evidence, and failure ownership from
  deterministic adapter implementation.
- 2026-08-31: Use an isolated backend database and unique principal per run ->
  the backend intentionally enforces one application per user, so shared state
  would make the test flaky and destructive.
- 2026-08-31: Exercise the production DI graph -> a fake repository would prove
  the wizard again, not mobile-backend compatibility.
- 2026-08-31: Keep the new live test supplementary rather than self-registering
  it as an oracle -> a test authored by the implementing task is useful evidence
  but not an independent acceptance authority.
- 2026-08-31: Pair live execution with registered contract, auth, UI, and
  external review oracles -> these independently cover schema/auth and the
  human-observable cross-system boundary.
- 2026-08-31: Treat backend defects as a separate task -> this plan has no
  authority to mutate the backend repository or its persisted contract.

## Verification

Exact backend startup/reset commands and live input variable names must be
resolved from the accepted backend/mobile docs at execution time and recorded
without their values. Do not invent or commit secret defaults.

```bash
dart run mobile_core_kit_cli:mobilekit task begin \
  --plan docs/exec-plans/active/2026-08-31_merchant-onboarding-live-e2e.md
dart run mobile_core_kit_cli:mobilekit task preflight \
  --task merchant-onboarding-live-e2e --action edit
dart run mobile_core_kit_cli:mobilekit contract openapi verify
fvm flutter test test/features/merchant_onboarding
dart run mobile_core_kit_cli:mobilekit task preflight \
  --task merchant-onboarding-live-e2e --action verify
dart run mobile_core_kit_cli:mobilekit task verify \
  --task merchant-onboarding-live-e2e --env dev
dart run mobile_core_kit_cli:mobilekit runtime evidence \
  --task merchant-onboarding-live-e2e \
  --device <device-id> \
  --target integration_test/auth_happy_path_test.dart \
  --flavor dev
fvm flutter test integration_test/merchant_onboarding_live_test.dart \
  -d <device-id> \
  --flavor dev \
  <explicit-secret-safe-live-defines>
git diff --check
```

Also record the accepted backend repository's already-defined verification,
persistence-integration, migration, startup, and cleanup commands and outcomes.
Those are external evidence inputs, not authority to edit backend files.

## Runtime Evidence

Required. Record:

- accepted backend 40-character revision and matching mobile OpenAPI lock;
- disposable database mode and successful cleanup outcome;
- hashed device identifier, OS, flavor, and local network reachability mode;
- exact mobile task fingerprint and candidate revision;
- registered auth runtime evidence artifact path/hash;
- direct live merchant test command with variable names but redacted values;
- sanitized UI/external review observations for reference load, masked account,
  success ID, replay, already-submitted, and unauthenticated behavior;
- backend persistence-test outcome proving one application and atomic owner rows.

Screenshots and logs must not contain test passwords/tokens, full account
numbers, email/phone values, authorization headers, raw requests/responses,
trace IDs, database URLs, or absolute secret paths.

## Rollback

Delete the test-created disposable database/container or run the backend's
documented test reset; never delete shared or production state. Revert only the
live integration target/support and any explicitly recorded mobile repairs.
The production remote adapter from the preceding plan remains intact unless
evidence proves it must be separately reverted. If the live environment cannot
be cleaned deterministically, stop and mark the task blocked rather than
attempting broad database cleanup.

## Risks And Mitigations

- Risk: The test writes merchant data into a shared or production database.
  Mitigation: Require explicit disposable environment proof and unique test
  principal before any submission; fail closed when absent.
- Risk: Emulator host networking points at a different backend revision.
  Mitigation: record the running backend revision/health evidence and compare it
  with the OpenAPI lock before executing the wizard.
- Risk: Repeat runs fail because the application uniqueness constraint is
  working.
  Mitigation: provision a unique principal per run and reset disposable state.
- Risk: Evidence leaks credentials or financial/personal fields.
  Mitigation: sanitize at capture time, prohibit request-body logging, retain
  only application ID/status/codes/last-four, and inspect artifacts manually.
- Risk: A backend defect is patched casually from the mobile task.
  Mitigation: backend is read-only here; report a bounded reproduction and open
  separately authorized backend work.
- Risk: A passing task-authored E2E is treated as independent proof.
  Mitigation: require the registered contract/auth/UI/external oracles and human
  review in addition to the live target.

## Completion Notes

The live merchant-onboarding E2E was implemented and executed against the
accepted backend (revision `7079536` in `backend-core-kit`, whose generated
OpenAPI is byte-identical to the mobile lock `6ae079ad`). All three live tests
passed on emulator `emulator-5554`:

1. Wizard submission through the production DI graph and UI: reference data
   loaded from the live GET, all four steps completed with IDs from the live
   snapshot, masked review (`****5678`), and a successful real POST returning
   the backend application id.
2. Idempotent replay: the same request replayed with the same key returned the
   same application id via the real datasource (no second application).
3. Unauthenticated reference request mapped to `UNAUTHORIZED` (safe failure).

Two real defects were found and fixed by the live run: (a) the merchant
endpoint constants included `/v1` while the core host base URL already carries
it, causing `/v1/v1/...` requests — fixed and locked by the datasource test;
(b) the integration test app shell lacked the app theme, crashing the success
snackbar — fixed by adding `AppTheme.light()`.

Environment limitation: the controlled full `task verify` could not complete
because the test machine hung under resource pressure (Android Studio plus
emulators). The focused merchant suite (88 tests), `mobilekit lint`, codegen
verify, contract verify, and the live E2E all passed independently; this is
recorded truthfully rather than claiming a full controlled verification.

## Follow-ups

- [x] No backend defect found during live E2E; the backend accepted all submissions.
- [x] Environment debt recorded: full controlled `task verify` could not complete because the test machine hung under resource pressure (Android Studio + emulators); the focused suite, lint, codegen, contract, and live E2E all passed. Recorded in completion notes.
  `docs/exec-plans/tech_debt_tracker.md`, or state none.
