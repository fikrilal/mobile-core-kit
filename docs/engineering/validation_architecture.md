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
- Clean boundaries: presentation depends on domain; repositories never receive invalid data.
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

- Use Case (final gate)
  - Re‑validate inputs using the same VOs (or a small helper) before calling repositories.
  - On success, build request entities and call repository; on failure, return a domain failure with friendly message.

- Repository / Data Sources
  - Do not perform client‑side validation; trust the use case.
  - Map server‑side validation payloads to domain failures to surface inline field errors when applicable.

## 4) Error Messages & Localization

- Domain failures (e.g., `ValueFailure`, feature‑specific failures) expose `userMessage` for UI‑friendly copy.
- Keep message mapping close to domain so both Bloc/Cubit and use cases reuse them.
- Files:
  - `lib/features/auth/domain/value/value_failure.dart:1` → `ValueFailureX.userMessage`
  - `lib/features/auth/domain/failure/auth_failure.dart:1` → `AuthFailureX.userMessage`

## 5) Real‑Time + Submit‑Time Flow

Typical flow for a form field:
- On change: Bloc/Cubit handles `FieldChanged` event → calls `VO.create(value)` → state carries `errorText` → UI shows inline error.
- On submit: Bloc/Cubit ensures no field errors and required inputs present, then invokes the use case.
- Use case (final gate): re‑validates with VOs (or helper) → on failure returns a domain failure; on success calls repository.
- Repository: executes remote/local; maps server validation messages to domain failures.

This gives fast feedback without compromising correctness if UI code is bypassed.

## 6) Patterns You Can Reuse

- Bloc/Cubit‑driven validation (recommended)
  - Define `XChanged` events; in handlers call `VO.create()` and set `fieldError` on state.
  - Bind `errorText` from state; dispatch events on `onChanged`.
  - Do not duplicate regex/logic; always call `VO.create()`.

- Use‑case aggregation (final gate)
  - Compose VO validations in a helper or inline in the use case.
  - Return a specific validation failure (or list) with UI‑friendly messages.

## 7) Conventions

- Naming
  - VO classes: `PascalCase` (e.g., `EmailAddress`, `Password`).
  - VO files: `snake_case.dart` (e.g., `email_address.dart`).
  - State error fields: `String? xxxError` on Bloc/Cubit state.

- What a VO should do
  - Enforce invariants (length, allowed chars, format).
  - Be immutable; once constructed, it is valid by definition.
  - Return `Either<ValueFailure, VO>` from factory methods.

- What a VO should not do
  - Perform network calls or side effects.
  - Depend on outer layers.

## 8) Adding a New Validated Field — Checklist

1) Create a Value Object in `domain/value/` with `create(String)`.
2) Add or reuse a `ValueFailure` variant and a `userMessage` mapping if needed.
3) In presentation (Bloc/Cubit):
   - Add `FieldChanged` event/handler; call `VO.create()`; store `fieldError` string in state.
   - Wire `onChanged: (v) => context.read<FormBloc>().add(FieldChanged(v))` and `errorText: state.fieldError` in the page.
4) In the use case (final gate):
   - Re‑validate with VOs; build request entities only if all inputs are valid.
5) In repository/data sources: no client‑side validation; map server responses only.
6) Add unit tests:
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

- Use cases (final gate location)
  - `lib/features/auth/domain/usecase/login_user_usecase.dart:1`
  - `lib/features/auth/domain/usecase/register_user_usecase.dart:1`

- Failures and messages
  - `lib/features/auth/domain/value/value_failure.dart:1`
  - `lib/features/auth/domain/failure/auth_failure.dart:1`

- Bloc/Cubit patterns (real‑time validation)
  - `lib/features/auth/presentation/cubit/login/login_cubit.dart:1`
  - `lib/features/auth/presentation/pages/sign_in_page.dart:1`

- UI state guide (complementary)
  - `docs/engineering/ui_state_architecture.md:1`

- Portable examples (copy‑ready snippets)
  - `docs/engineering/validation_cookbook.md:1`

## 11) Anti‑Patterns to Avoid

- Duplicating regex or validation logic directly in widgets.
- Skipping use‑case validation because the Bloc/Cubit already validated.
- Returning raw backend messages directly without mapping to domain failures.
- Putting request/DTO logic into presentation or VOs.

---

For deeper VO details and examples, see `docs/engineering/value_objects_validation.md`.
