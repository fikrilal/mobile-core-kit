# Value Objects and Form Validation — Practical Guide

This guide explains how and why we use Value Objects (VOs) for validation in both the domain layer and the UI (forms) with Bloc/Cubit. It covers recommended patterns, trade‑offs, and how they are applied in this codebase.

## What Is a Value Object?

In Domain‑Driven Design, a Value Object is an immutable, validated wrapper around a primitive (e.g., `String` → `EmailAddress`). It encapsulates rules and ensures invalid values cannot exist once created.

Examples in this repo:

- `EmailAddress` — format check
- `LoginPassword` — sign-in rule (non-empty)
- `Password` — sign-up rule (≥ 10 characters)
- `ConfirmPassword` — matches original password
- `DisplayName` — name length bounds

Field VOs return `Either<ValueFailure, VO>` from `create(...)`. Validated form
aggregates such as `LoginCredentials` and `RegistrationCredentials` compose
those results and return `Either<List<ValidationError>, Aggregate>`.
Presentation localizes the stable failure/error codes.

Password note: this template preserves the password string as entered (no trimming), but treats whitespace-only input as empty.

## Why Use VOs?

- Single source of truth for rules: no duplicated regex in UI and services.
- Safety at the boundary: repositories never receive invalid data.
- Better UX: the same rules drive real‑time form errors via Bloc/Cubit state.
- Testability: small, deterministic units to unit‑test.

## Where to Validate

We validate in two layers for both correctness and UX:

1) Field‑level (UI, real‑time via Bloc/Cubit)

- Blocs/Cubits call `VO.create(input)` on each field‑change event and store `errorText` in state.
- Pages read `errorText` from state and show messages with no duplication.

2) Submit‑level (Use Case, final gate)

- Use cases convert raw `XInput` into a privately constructed validated aggregate.
- Repository methods accept that aggregate, so their signatures cannot be
  called with unchecked form primitives.
- Prevents bypasses (e.g., programmatic calls or stale UI state).
- Returns all deterministic field failures before the repository is called.

This is compatible with Clean Architecture: outer layers (presentation) may depend on inner (domain), so UI using VOs is fine.

## Patterns

### Option A — Bloc/Cubit‑Driven Form Validation (used here)

- Blocs/Cubits expose per-field `ValidationError?` values in state and
  `XChanged` events.
- On each `onChanged`, handlers call `VO.create()` and retain the stable field
  and error code; presentation localizes it.
- On submit, re‑validate and short‑circuit if there are errors; otherwise call the use case.
- The use case still invokes the aggregate factory as the final gate.

Pros:

- Best UX (real‑time, field‑specific errors)
- Single ruleset shared by UI and domain

### Option B — Bubble Validation Failures from Use Case

- Use cases return a `validation` failure (e.g., `AuthFailure.validation(List<ValidationError>)`),
  where `ValidationError` is a neutral type from
  `lib/core/foundation/validation/validation_error.dart`.
- Presentation maps failures → field errors.

Pros: reduces direct VO usage in presentation; Cons: extra mapping logic and tighter coupling of failure shapes.

## How This Repo Implements It

- Domain VOs: `lib/features/auth/domain/value/*`
- Raw inputs: `lib/features/auth/domain/input/login_input.dart` and
  `lib/features/auth/domain/input/register_input.dart`
- Validated aggregates: `login_credentials.dart` and
  `registration_credentials.dart`
- Localized messages: `ValidationError` codes are mapped in presentation.
- Real-time validation:
  `lib/features/auth/subfeatures/sign_in/presentation/cubit/login/login_cubit.dart`
- Submit-time: use cases create validated aggregates as the final gate;
  repositories accept only those aggregates and map server validation failures.

## Code Snippets

Field‑level validation in a Cubit handler (example):

```dart
void emailChanged(String input) {
  final res = EmailAddress.create(input);
  emit(state.copyWith(
    email: input,
    emailError: res.fold(
      (f) => ValidationError(field: 'email', message: '', code: f.code),
      (_) => null,
    ),
  ));
}
```

Wiring to a TextField:

```dart
AppTextField(
  fieldType: FieldType.email,
  labelText: 'Email',
  errorText: context.select(
    (LoginCubit c) => messageForValidationError(c.state.emailError, l10n),
  ),
  onChanged: context.read<LoginCubit>().emailChanged,
)
```

Submit‑time in a use case (final gate):

```dart
final credentials = LoginCredentials.create(
  email: input.email,
  password: input.password,
);

return credentials.match(
  (errors) async => left(AuthFailure.validation(errors)),
  _repository.login,
);
```

## Do & Don’t

Do

- Use VOs for both real‑time and submit‑time validation
- Keep raw application input separate from validated domain aggregates
- Localize stable `ValidationError` codes in presentation
- Keep Blocs/Cubits thin; map VO results to field errors in state
- Make form repository contracts accept validated aggregates

Don’t

- Duplicate regex/logic in the UI
- Trust UI only; keep the domain gate in use cases
- Pass raw form primitives through repository contracts
- Leak DTOs into UI; prefer domain entities/VOs

## FAQ

Q: Why not validate only in use cases?

A: You can, but UX suffers (no real‑time, field‑specific errors). We still validate in use cases as a final guard, and we validate in Bloc/Cubit to improve usability.

Q: Does using VOs in presentation (Bloc/Cubit) break Clean Architecture?

A: No. Presentation depends on domain (outer → inner) which is allowed. VOs are domain primitives meant to be reused.

Q: Do all repository operations need a validated aggregate?

A: No. Use this pattern for user-controlled form values with deterministic
invariants. Parameterless operations, already-valid domain objects, and simple
pass-throughs should not gain aggregate types merely for ceremony.

Q: What about input normalization?

A: Normalization belongs in the field VO. The data layer unwraps the already
normalized value while building the request model; passwords and other
byte-sensitive values must remain unchanged when their VO policy requires it.

See [ADR 0016](../../ADR/records/0016-validated-form-boundaries.md) for the
decision boundary and trade-offs.
