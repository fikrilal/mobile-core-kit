# Validation Architecture — Bloc‑Driven, Layered, Predictable

A universal guide for input validation across features with Bloc/Cubit in presentation and Value Objects (VOs) in domain. This pairs with `docs/engineering/ui_state_architecture.md` and complements `docs/engineering/value_objects_validation.md`.

Goals:
- Single source of truth for rules in the domain layer (Value Objects).
- Great UX via real‑time feedback in Bloc/Cubit state.
- Final, enforceable guardrails in use cases (“final gate”) before calling repositories.
- Consistent error messaging and minimal duplication.

## 1) Principles

- Source of truth: domain Value Objects (VOs) encapsulate validation rules.
- Two gates: presentation (Bloc/Cubit) for real‑time feedback, and use case for the final validation before repositories.
- Clean boundaries: presentation depends on domain; repository contracts accept
  only validated domain types.
- User‑friendly errors: map failures to localized strings close to domain.

## 2) Folder Structure (recap)

Keep rules in domain, orchestration in presentation, and networking/storage in data.

```
lib/features/<feature>/
  domain/
    value/                 # Value Objects + helpers
    usecase/               # Submit-time validation (final gate) + business orchestration
    failure/               # Domain failures with UI-friendly mapping
  presentation/
    bloc/|cubit/           # Blocs/Cubits call VO.create() on field-change intents
    pages/                 # Widgets dispatch events; read errorText from state
  data/
    datasource/            # No client-side validation; decode only
    repository/            # Map server-side messages → domain failures
```

See also: `docs/engineering/project_architecture.md`.

## 3) Layers & Responsibilities

- Domain Value Objects
  - Define `create(String)` returning `Either<ValueFailure, VO>`.
  - Keep rules (regex/length/format) in one place.
  - Files: `lib/features/auth/domain/value/*.dart` (e.g., `email_address.dart`, `login_password.dart`, `password.dart`, `confirm_password.dart`, `display_name.dart`).

- Presentation (Bloc/Cubit, real‑time validation)
  - On each field‑change event, call `VO.create(value)` and store `errorText` in state.
  - On submit event, check state errors and required inputs; short‑circuit if any error exists.
  - UI binds `errorText` from state and dispatches events on `onChanged`.
  - Prefer storing `ValidationError` (field + code) rather than raw strings; localize in UI.

- Use Case (final gate)
  - Accept a raw application input type such as `LoginInput` or `RegisterInput`.
  - Validate it through an aggregate factory such as `LoginCredentials.create()`
    or `RegistrationCredentials.create()` before calling repositories.
  - On failure, return a domain validation failure; on success, pass the
    validated aggregate to the repository.

- Repository / Data Sources
  - Accept validated domain aggregates rather than raw form primitives.
  - Unwrap Value Objects into request-model primitives only in the data layer.
  - Do not repeat client-side validation.
  - Map server‑side validation payloads to domain failures to surface inline field errors when applicable.

## 4) Error Messages & Localization

- Domain failures (e.g., `ValueFailure`, feature‑specific failures) expose stable codes and/or typed variants.
- Localize in UI (or UI-adjacent helpers) via the template localizers.
- Files:
  - `lib/core/foundation/validation/value_failure.dart:1` → `ValueFailureX.code`
  - `lib/core/domain/auth/auth_failure.dart:1` → `AuthFailure` (typed variants)
  - `lib/core/presentation/localization/validation_error_localizer.dart:1` → `messageForValidationError(...)`

## 5) Real‑Time + Submit‑Time Flow

Typical flow for a form field:
- On change: Bloc/Cubit handles `FieldChanged` event → calls `VO.create(value)` → state carries `errorText` → UI shows inline error.
- On submit: Bloc/Cubit ensures no field errors and required inputs present, then invokes the use case.
- Use case (final gate): creates a validated aggregate from raw input → on
  failure returns a domain failure; on success calls the typed repository.
- Repository: receives only the validated aggregate, maps it to a request
  model, executes remote/local work, and maps server validation failures.

This gives fast feedback without compromising correctness if UI code is bypassed.

The template-level rationale and applicability boundary are recorded in
[ADR 0016](../../ADR/records/0016-validated-form-boundaries.md).

### Error Display: touched‑aware (recommended)

Real‑time validation does **not** mean “show every error immediately”.

To avoid noisy UX, follow a **touched‑aware** display rule:

- Validate on each change (so state is always consistent).
- Track whether the user has interacted with each field (e.g. `emailTouched`, `passwordTouched`).
- Only **display** a field error when that field is touched (or after an explicit submit attempt).

This matters most for **cross‑field validation**, where typing in one field may re‑compute errors in another field (e.g., `confirmPassword` mismatch, or `newPassword != currentPassword`). Without touched gating, the UI can incorrectly show “required/empty” for untouched fields.

Practical pattern:

- In state:
  - `String value`, `ValidationError? error`, `bool touched`
- In Cubit/Bloc:
  - On `...Changed(value)`: set `touched = true` and compute `error`
- In UI:
  - `errorText: touched ? messageForValidationError(error) : null`

## 6) Patterns You Can Reuse

- Bloc/Cubit‑driven validation (recommended)
  - Define `XChanged` events; in handlers call `VO.create()` and set `fieldError` on state.
  - Bind `errorText` from state; dispatch events on `onChanged`.
  - Do not duplicate regex/logic; always call `VO.create()`.

- Aggregate factory (final gate)
  - Compose field VOs in a privately constructed domain aggregate.
  - Return `Either<List<ValidationError>, Aggregate>` so multi-field forms can
    report all deterministic errors in one pass.
  - Invoke the factory from the use case; do not expose an unchecked constructor.

## 7) Conventions

- Naming
  - VO classes: `PascalCase` (e.g., `EmailAddress`, `Password`).
  - VO files: `snake_case.dart` (e.g., `email_address.dart`).
  - State error fields: `ValidationError? xxxError` on Bloc/Cubit state (use stable `code` and localize in UI via `messageForValidationError(...)`).

- What a VO should do
  - Enforce invariants (length, allowed chars, format).
  - Be immutable; once constructed, it is valid by definition.
  - Return `Either<ValueFailure, VO>` from factory methods.

- What a VO should not do
  - Perform network calls or side effects.
  - Depend on outer layers.

## 8) Adding a New Validated Field — Checklist

1) Create a Value Object in `domain/value/` with `create(String)`.
2) Add or reuse a `ValueFailure` variant and stable error-code mapping if needed.
3) In presentation (Bloc/Cubit):
   - Add `FieldChanged` event/handler; call `VO.create()`; store `ValidationError?` on state (stable `code`).
   - Wire `onChanged: (v) => context.read<FormBloc>().add(FieldChanged(v))` and `errorText: messageForValidationError(state.fieldError, l10n)` (touched‑aware) in the page.
4) Add or extend a validated aggregate with a private constructor and a factory
   that collects field VO failures.
5) In the use case (final gate), convert raw input into that aggregate and stop
   on validation failure.
6) Make the repository accept the validated aggregate; unwrap it only while
   building the data-layer request model.
7) Add unit tests:
   - VO tests for `create()` happy/sad paths.
   - Use case tests for validation branches (fail fast vs call repository).

## 9) Server vs Client Validation

- Client‑side (VOs in Bloc/Cubit + use cases): immediate UX; catches obvious errors early.
- Server‑side: still authoritative for domain/uniqueness rules; pass through readable messages when available.
- Interceptors/ApiHelper normalize error payloads where possible; repositories map HTTP status codes to domain failures.

## 10) References (code)

- Value Objects (examples)
  - `lib/features/auth/domain/value/email_address.dart:1`
  - `lib/features/auth/domain/value/login_password.dart:1`
  - `lib/features/auth/domain/value/password.dart:1`
  - `lib/features/auth/domain/value/confirm_password.dart:1`
  - `lib/features/auth/domain/value/display_name.dart:1`
  - `lib/features/auth/domain/value/login_credentials.dart:1`
  - `lib/features/auth/domain/value/registration_credentials.dart:1`

- Raw form inputs
  - `lib/features/auth/domain/input/login_input.dart:1`
  - `lib/features/auth/domain/input/register_input.dart:1`

- Use cases (final gate location)
  - `lib/features/auth/domain/usecase/login_user_usecase.dart:1`
  - `lib/features/auth/domain/usecase/register_user_usecase.dart:1`

- Failures and messages
  - `lib/core/foundation/validation/value_failure.dart:1`
  - `lib/core/domain/auth/auth_failure.dart:1`

- Bloc/Cubit patterns (real‑time validation)
  - `lib/features/auth/subfeatures/sign_in/presentation/cubit/login/login_cubit.dart:1`
  - `lib/features/auth/subfeatures/sign_in/presentation/pages/sign_in_page.dart:1`

- UI state guide (complementary)
  - `docs/engineering/ui_state_architecture.md:1`

- Portable examples (copy‑ready snippets)
  - `docs/engineering/validation_cookbook.md:1`

## 11) Anti‑Patterns to Avoid

- Duplicating regex or validation logic directly in widgets.
- Skipping the aggregate factory in the use case because the Bloc/Cubit already validated.
- Letting repository contracts accept raw `String` form fields.
- Returning raw backend messages directly without mapping to domain failures.
- Putting request/DTO logic into presentation or VOs.

---

For deeper VO details and examples, see `docs/engineering/value_objects_validation.md`.
