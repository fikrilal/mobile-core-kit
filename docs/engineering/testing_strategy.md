# Testing Strategy — mobile-core-kit

Battle-tested guardrails for the Clean Architecture Flutter template. The goal is to mirror enterprise patterns: domain rules are proven with unit tests, presentation logic is verified with bloc/cubit tests, repositories are validated via integration tests, and a thin layer of end‑to‑end coverage protects key flows.

---

## 1. Testing Pyramid & Ownership

| Layer         | Goal                                   | Typical Tools                            | Owner                  |
|---------------|----------------------------------------|------------------------------------------|------------------------|
| Unit (≈70%)   | Prove domain + presentation behavior   | `flutter_test`, `mocktail`, `bloc_test`  | Feature teams          |
| Integration (≈20%) | Verify data boundaries (API/DB)   | Real JSON fixtures, in‑memory DB         | Feature + infra        |
| E2E/UI (≈10%) | Guard golden flows                     | `integration_test`, device lab/CI        | QA/infra (product repo) |

Guidelines:
- Unit tests run fast (ideally <1s per file) and are expected for new/changed behavior.
- Integration tests focus on repository + datasource plumbing and critical mappings.
- E2E/UI suites cover only the most important user journeys (e.g., auth happy path) and can run nightly or on `main` in product repos built from this template.

---

## 2. Naming & Layout

- Mirror `lib/` paths under `test/`.  
  Example: `lib/features/auth/presentation/cubit/login` → `test/features/auth/presentation/cubit/login`.
- File names are `*_test.dart`. Multiple `group`s per file are fine if they target the same class or slice.
- Describe behavior, not implementation details:

```dart
group('LoginUserUseCase', () {
  test('returns validation failure when email invalid', () {
    // ...
  });
});
```

---

## 3. Domain Layer Tests

### Value Objects

Each VO (e.g. `EmailAddress`, `Password`, `ResetToken`) gets a suite covering:

- Happy path (returns `Right(value)` with normalized output).
- Every failure case (`Left(ValueFailure...)`) with the expected `userMessage`.

### Use Cases

- Stub repositories with `mocktail` or simple fakes.
- Assert:
  1. Validation failures short-circuit before the repository call (`verifyNever`).
  2. Successful inputs invoke the repository with normalized entities (trimmed email/token/password, etc.).
  3. Repository failures bubble up unchanged (e.g., `AuthFailure.network` remains intact).

Example:

```dart
test('rejects invalid email', () async {
  final repo = MockAuthRepository();
  final usecase = LoginUserUseCase(repo);

  final result = await usecase(
    LoginRequestEntity(email: 'bad', password: 'Secret1'),
  );

  expect(result.isLeft(), true);
  verifyNever(() => repo.login(any()));
});
```

---

## 4. Presentation (Bloc/Cubit) Tests

Use `bloc_test` to model intent → state sequences. The same pattern applies to both Bloc and Cubit.

1. **Field change events** – ensure state carries VO error strings:

```dart
blocTest<LoginCubit, LoginState>(
  'emits emailError when email invalid',
  build: () => LoginCubit(mockLoginUseCase, mockSessionManager, mockAnalytics),
  act: (cubit) => cubit.emailChanged('bad'),
  expect: () => [
    isA<LoginState>().having((s) => s.emailError, 'emailError', isNotNull),
  ],
);
```

2. **Submit success** – mock use case success, expect `submitting → success` transition and any derived fields set.
3. **Submit failure** – mock `AuthFailure.validation` (or network), verify failure state + any effects (e.g., error snackbars) if you surface them via side-effect streams.

Tips:
- Seed the bloc/cubit with specific state using `seed: () => initialState.copyWith(...)`.
- Use `verify` to ensure the expected use case was called with normalized data.

---

## 5. Integration Tests

Focus on data boundaries rather than UI:

### 5.1 Repositories ↔ Remote APIs

- Use a `FakeApiHelper` or `dio` interceptor to return recorded JSON fixtures stored under `test/fixtures/<feature>/`.
- Assert:
  - Mapping logic from JSON → models → entities.
  - Pagination metadata where applicable.
  - Error translation (`ApiFailure` → feature-specific failure).

### 5.2 Local Persistence

- Run sqflite in-memory (`sqflite_common_ffi`) or a temporary file DB.
- Verify DAOs read/write the same models used by repositories (e.g., `AuthLocalDataSource`, `SessionRepositoryImpl`, `UserDao`).

Keep integration tests deterministic: no real network calls, and no reliance on global state.

---

## 6. E2E/UI Tests (`integration_test/`)

This template includes a small E2E/UI suite under `integration_test/` (device/emulator required).

### Run on Android (recommended)

- List devices: `flutter devices`
- Run a single test (recommended):  
  `flutter test -d emulator-5554 --flavor dev integration_test/auth_happy_path_test.dart`

### WSL + Windows toolchain (recommended when developing in WSL)

Use the repo-pinned SDK to avoid CRLF shim issues:

`cmd.exe /C "cd /d C:\Development\_CORE\mobile-core-kit && .fvm\flutter_sdk\bin\flutter.bat test -d emulator-5554 --flavor dev integration_test/auth_happy_path_test.dart"`

Notes:
- `--flavor dev` is required because this project uses Android product flavors (`app-dev-debug.apk`, etc.).
- If installs fail with “insufficient storage”, wipe/create a larger emulator image or uninstall other apps from the emulator to free `/data` space.

## 6. Test Utilities & Fixtures

Create `test/support/` with:

- Common mocks (`MockAuthRepository`, `MockApiHelper`, `MockSessionRepository`, etc.) using `mocktail`.
- Entity factories (`TestUserFactory.make()`, `TestBookFactory.create()`, etc.).
- JSON fixture loader (e.g., `Future<Map<String, dynamic>> loadFixture(String path)`).
- Optional: `TestLogObserver` if you need to assert `Log.error` calls without hitting Crashlytics.

Store API responses under `test/fixtures/<feature>/<scenario>.json` and keep them minimal but representative.

---

## 7. CI Expectations

Recommended setup (product repos built from this template can tune thresholds):

- `flutter test --coverage` runs on every PR.
- Fail the pipeline if tests fail; consider enforcing minimum coverage (for example, ≥80% for domain + presentation).
- Add a PR checklist item: “✅ Tests added/updated for new or changed logic”.
- Optionally:
  - Gate merges on unit + integration tests.
  - Run E2E workflows on nightly or `main` instead of every PR.

---

## 8. Style Rules

- Deterministic: use `fake_async` for timers, avoid `Future.delayed` without overrides.
- One main behavior per test; multiple assertions are fine if they describe the same outcome.
- Never hit real services or file paths outside `test/fixtures`.
- Keep failure messages descriptive so it’s obvious what regressed.

---

## 9. Rollout Plan (When Adopting in a New Project)

1. **Scaffold support package** (`test/support/mocks.dart`, `test/support/factories.dart`).
2. **Pilot suite**: cover one vertical slice end-to-end (e.g., `LoginUserUseCase`, `LoginCubit`, and the auth repository).
3. Expand to other slices (library, profile, etc.) as they’re touched.
4. Add integration fixtures for one feature to validate the pattern before scaling.
5. Wire CI to enforce tests before merging.

By following this guide, we keep the “single source of truth” ethos from `docs/engineering/` intact in our tests: VOs are proven once, blocs/cubits reflect those rules, repositories ensure we don’t regress data mappings, and E2E smoke tests protect end-user flows.

---

## 10. Code Templates

> Copy/paste-ready snippets. Replace placeholder names with your slice.

### Value Object Test

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_core_kit/features/auth/domain/value/email_address.dart';

void main() {
  group('EmailAddress', () {
    test('accepts trimmed valid address', () {
      final result = EmailAddress.create(' user@example.com ');
      expect(result.isRight(), true);
      result.match(
        (_) => fail('Should not be left'),
        (value) => expect(value.value, 'user@example.com'),
      );
    });

    test('rejects invalid format', () {
      final result = EmailAddress.create('not-an-email');
      expect(result.isLeft(), true);
    });
  });
}
```

### Use Case Test

```dart
class MockReviewRepository extends Mock implements ReviewRepository {}

void main() {
  late MockReviewRepository repo;
  late CreateBookReviewUseCase usecase;

  setUp(() {
    repo = MockReviewRepository();
    usecase = CreateBookReviewUseCase(repo);
  });

  test('short-circuits when rating invalid', () async {
    final res = await usecase(
      CreateBookReviewRequestEntity(
        workId: 'w',
        editionId: 'e',
        rating: 0,
        reviewText: 'Nice',
        visibility: ReviewVisibility.public,
        isSpoiler: false,
      ),
    );

    expect(res.isLeft(), true);
    verifyNever(() => repo.createBookReview(any()));
  });
}
```

### Bloc/Cubit Test

```dart
blocTest<MyCubit, MyState>(
  'emits loading → success on happy path',
  build: () {
    when(() => mockUseCase(any())).thenAnswer((_) async => right(expectedData));
    return MyCubit(mockUseCase);
  },
  act: (cubit) => cubit.load(),
  expect: () => [
    const MyState(status: SliceStatus.loading),
    MyState(status: SliceStatus.success, items: expectedData),
  ],
);
```

### Repository Integration Test (HTTP fixture)

```dart
void main() {
  late FakeApiHelper api;
  late ReviewRemoteDataSource remote;

  setUp(() {
    api = FakeApiHelper();
    remote = ReviewRemoteDataSource(api);
  });

  test('maps success payload', () async {
    api.stubGet(
      '/reviews',
      fixture: 'test/fixtures/review/list_success.json',
    );

    final resp = await remote.getBookReviews(
      query: ReviewCommentsQuery(workId: 'w'),
    );

    expect(resp.isSuccess, true);
    expect(resp.data!.items, isNotEmpty);
  });
}
```

---

## 11. PR Checklist (Testing)

Developers should run through this list before submitting a PR:

- [ ] VO or entity changed → add/adjust VO tests.
- [ ] Use case logic changed → add/adjust use case tests (happy + failure).
- [ ] Bloc/Cubit logic changed → add/adjust `bloc_test` coverage.
- [ ] Repository/datasource logic changed → add/adjust integration tests or fixtures.
- [ ] Added new feature slice → ensure corresponding tests live under `test/features/<feature>/...`.
- [ ] `flutter test` and `flutter analyze` pass locally.
- [ ] Updated documentation if patterns changed (`AGENTS.md`, this file, or feature docs).

---

## 12. Support Package Map

Suggested contents for `test/support/`:

| File                        | Purpose                                      |
|-----------------------------|----------------------------------------------|
| `mocks.dart`                | Centralized `mocktail` mocks/fakes.          |
| `factories.dart`           | Builders for common entities/models.         |
| `fixtures.dart`            | JSON loader helper (`loadFixture('path')`).  |
| `log_observer.dart`        | Optional hook to assert logging behavior.    |

Add new helpers here as the suite grows so every feature reuses the same tooling.
