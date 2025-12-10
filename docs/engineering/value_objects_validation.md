# Value Objects and Form Validation — Practical Guide

This guide explains how and why we use Value Objects (VOs) for validation in both the domain layer and the UI (forms) with Bloc/Cubit. It covers recommended patterns, trade‑offs, and how they are applied in this codebase.

## What Is a Value Object?

In Domain‑Driven Design, a Value Object is an immutable, validated wrapper around a primitive (e.g., `String` → `EmailAddress`). It encapsulates rules and ensures invalid values cannot exist once created.

Examples in this repo:

- `EmailAddress` — format check
- `Password` — rule (≥ 8 + lowercase + uppercase + digit)
- `ConfirmPassword` — matches original password
- `DisplayName` — name length bounds
- `Username` — length + format

All VOs return `Either<ValueFailure, VO>` from `create(...)`. `ValueFailure` maps to localized, user‑friendly messages.

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

- Use cases validate again before building request entities and calling repositories.
- Prevents bypasses (e.g., programmatic calls or stale UI state).
- Return meaningful failures (not just a generic “invalid credentials”).

This is compatible with Clean Architecture: outer layers (presentation) may depend on inner (domain), so UI using VOs is fine.

## Patterns

### Option A — Bloc/Cubit‑Driven Form Validation (used here)

- Blocs/Cubits expose per‑field error strings in state and `XChanged` events.
- On each `onChanged`, dispatch events; handlers call `VO.create()` and set error on state using `ValueFailure.userMessage`.
- On submit, re‑validate and short‑circuit if there are errors; otherwise call the use case.
- Use case still validates and returns specific messages.

Pros:

- Best UX (real‑time, field‑specific errors)
- Single ruleset shared by UI and domain

### Option B — Bubble Validation Failures from Use Case

- Use cases return a `validation` failure (e.g., `AuthFailure.validation(List<ValidationError>)`).
- Presentation maps failures → field errors.

Pros: reduces direct VO usage in presentation; Cons: extra mapping logic and tighter coupling of failure shapes.

## How This Repo Implements It

- Domain VOs: `lib/features/auth/domain/value/*`
- Localized messages: `ValueFailureX.userMessage`
- Real‑time validation with Bloc: login, register, username, forgot/reset password, update password Blocs.
- Submit‑time: use cases may serve as final gate (re‑validate with VOs) and repositories pass through server validation messages.

## Code Snippets

Field‑level validation in a Bloc handler (example):

```dart
void _onEmailChanged(EmailChanged e, Emitter<State> emit) {
  final res = EmailAddress.create(e.email);
  emit(state.copyWith(email: e.email, emailError: res.fold((f) => f.userMessage, (_) => null)));
}
```

Wiring to a TextField:

```dart
TextFieldComponent(
  controller: emailController,
  errorText: context.select((LoginBloc b) => b.state.emailError),
  onChanged: (v) => context.read<LoginBloc>().add(EmailChanged(v)),
)
```

Submit‑time in a use case (final gate):

```dart
final email = EmailAddress.create(input.email);
final password = Password.create(input.password);
final failures = <ValueFailure>[];
email.fold(failures.add, (_) {});
password.fold(failures.add, (_) {});
if (failures.isNotEmpty) {
  return left(AuthFailure.validation(failures.map((f) => ValidationError(field: 'email/password', message: f.userMessage)).toList()));
}
return _repository.login(LoginRequestEntity(email: email.getRight().toNullable()!.value, password: password.getRight().toNullable()!.value));
```

## Do & Don’t

Do

- Use VOs for both real‑time and submit‑time validation
- Localize messages in `ValueFailure.userMessage`
- Keep Blocs/Cubits thin; map VO results → `errorText` on state
- Return specific messages from use cases; avoid generic “invalid credentials” where possible

Don’t

- Duplicate regex/logic in the UI
- Trust UI only; keep the domain gate in use cases
- Leak DTOs into UI; prefer domain entities/VOs

## FAQ

Q: Why not validate only in use cases?

A: You can, but UX suffers (no real‑time, field‑specific errors). We still validate in use cases as a final guard, and we validate in Bloc/Cubit to improve usability.

Q: Does using VOs in presentation (Bloc/Cubit) break Clean Architecture?

A: No. Presentation depends on domain (outer → inner) which is allowed. VOs are domain primitives meant to be reused.

Q: What about input normalization?

A: Consider adding a normalization helper after VO creation if the backend expects a specific format.
