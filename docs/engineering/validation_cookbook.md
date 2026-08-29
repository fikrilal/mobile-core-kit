# Validation Cookbook — Portable Patterns and Snippets

Portable, Bloc-first patterns for layered validation using Domain Value Objects (VOs) for rules, Bloc/Cubit for real-time feedback, and use cases as the final gate. Copy/paste the snippets and adapt names to your project.

Contents
- Domain primitives: ValueFailure and Value Objects
- Choosing scalar, raw input, VO, command, or validated aggregate
- Use cases (submit-time final gate) and typed repository contracts
- Controller patterns (real-time validation) with confirm password VO
- UI wiring examples

Prereqs
- Uses `fpdart` for `Either`. Replace with your preferred result type as needed.
- Uses Dart sealed classes/extensions and Freezed for failures.

---

## 1) Domain — Failures and Messages

```dart
// domain/failure/value_failure.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'value_failure.freezed.dart';

@freezed
class ValueFailure with _$ValueFailure {
  const factory ValueFailure.empty(String failedValue) = Empty;
  const factory ValueFailure.invalidPhone(String failedValue) = InvalidPhone;
  const factory ValueFailure.invalidEmail(String failedValue) = InvalidEmail;
  const factory ValueFailure.shortPassword(String failedValue) = ShortPassword;
  const factory ValueFailure.weakPassword(String reason) = WeakPassword; // reason: min_length|uppercase|lowercase|digit|symbol
  const factory ValueFailure.passwordsDoNotMatch(String failedValue) = PasswordsDoNotMatch;
  const factory ValueFailure.shortName(String failedValue) = ShortName;
  const factory ValueFailure.longName(String failedValue) = LongName;
}

class ValidationError {
  const ValidationError({
    required this.field,
    required this.message,
    required this.code,
  });

  final String field;
  final String message;
  final String code;
}

extension ValueFailureX on ValueFailure {
  String get code => when(
    empty: (_) => 'required',
    invalidPhone: (_) => 'invalid_phone',
    invalidEmail: (_) => 'invalid_email',
    shortPassword: (_) => 'password_too_short',
    weakPassword: (reason) => 'weak_password_$reason',
    passwordsDoNotMatch: (_) => 'passwords_do_not_match',
    shortName: (_) => 'name_too_short',
    longName: (_) => 'name_too_long',
  );

  String get userMessage => when(
    empty: (_) => 'Field cannot be empty',
    invalidPhone: (_) => 'Enter a valid phone number',
    invalidEmail: (_) => 'Enter a valid email address',
    shortPassword: (_) => 'Password must be at least 6 characters',
    weakPassword: (reason) {
      switch (reason) {
        case 'min_length': return 'Password must be at least 8 characters';
        case 'uppercase':  return 'Password must contain an uppercase letter';
        case 'lowercase':  return 'Password must contain a lowercase letter';
        case 'digit':      return 'Password must contain a digit';
        case 'symbol':     return 'Password must contain a symbol';
        default:           return 'Password does not meet complexity requirements';
      }
    },
    passwordsDoNotMatch: (_) => 'Passwords do not match',
    shortName: (_) => 'Name must be at least 2 characters',
    longName: (_) => 'Name must not exceed 50 characters',
  );
}
```

---

## 2) Domain — Value Objects (VOs)

```dart
// domain/value/display_name.dart
import 'package:fpdart/fpdart.dart';
import '../failure/value_failure.dart';

class DisplayName {
  final String value;
  const DisplayName._(this.value);

  static Either<ValueFailure, DisplayName> create(String input) {
    final s = input.trim();
    if (s.isEmpty) return left(ValueFailure.empty(input));
    if (s.length < 2) return left(ValueFailure.shortName(input));
    if (s.length > 50) return left(ValueFailure.longName(input));
    return right(DisplayName._(s));
  }
}
```

```dart
// domain/value/phone_number.dart
import 'package:fpdart/fpdart.dart';
import '../failure/value_failure.dart';

class PhoneNumber {
  final String value;
  const PhoneNumber._(this.value);

  static Either<ValueFailure, PhoneNumber> create(String input) {
    final s = input.trim();
    if (s.isEmpty) return left(ValueFailure.empty(input));
    final re = RegExp(r'^(0|62)[0-9]{8,12}$'); // adjust to your rules
    if (!re.hasMatch(s)) return left(ValueFailure.invalidPhone(input));
    return right(PhoneNumber._(s));
  }
}
```

```dart
// domain/value/password.dart (basic rule, e.g., for sign-in)
import 'package:fpdart/fpdart.dart';
import '../failure/value_failure.dart';

class Password {
  final String value;
  const Password._(this.value);

  static Either<ValueFailure, Password> create(String input) {
    if (input.isEmpty) return left(ValueFailure.empty(input));
    if (input.length < 6) return left(ValueFailure.shortPassword(input));
    return right(Password._(input));
  }
}
```

```dart
// domain/value/strong_password.dart (strong rule, e.g., for sign-up)
import 'package:fpdart/fpdart.dart';
import '../failure/value_failure.dart';

class StrongPassword {
  final String value;
  const StrongPassword._(this.value);

  static Either<ValueFailure, StrongPassword> create(String input) {
    if (input.length < 8) return left(const ValueFailure.weakPassword('min_length'));
    if (!RegExp(r'[A-Z]').hasMatch(input)) return left(const ValueFailure.weakPassword('uppercase'));
    if (!RegExp(r'[a-z]').hasMatch(input)) return left(const ValueFailure.weakPassword('lowercase'));
    if (!RegExp(r'[0-9]').hasMatch(input)) return left(const ValueFailure.weakPassword('digit'));
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>\-_/\\\[\]]').hasMatch(input)) return left(const ValueFailure.weakPassword('symbol'));
    return right(StrongPassword._(input));
  }
}
```

```dart
// domain/value/confirm_password.dart
import 'package:fpdart/fpdart.dart';
import '../failure/value_failure.dart';
import 'password.dart';

class ConfirmPassword {
  final String value;
  const ConfirmPassword._(this.value);

  static Either<ValueFailure, ConfirmPassword> create(String confirm, Password original) {
    if (confirm.isEmpty) return left(ValueFailure.empty(confirm));
    if (confirm != original.value) return left(ValueFailure.passwordsDoNotMatch(confirm));
    return right(ConfirmPassword._(confirm));
  }
}
```

Optional VO for email if needed:

```dart
// domain/value/email_address.dart
import 'package:fpdart/fpdart.dart';
import '../failure/value_failure.dart';

class EmailAddress {
  final String value;
  const EmailAddress._(this.value);

  static Either<ValueFailure, EmailAddress> create(String input) {
    final s = input.trim();
    if (s.isEmpty) return left(ValueFailure.empty(input));
    final re = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!re.hasMatch(s)) return left(ValueFailure.invalidEmail(input));
    return right(EmailAddress._(s));
  }
}
```

---

## 3) Domain — Choose The Boundary First

Grouping and validation are independent. Use the smallest shape that records
the operation's actual semantics.

| Input shape | Default |
| --- | --- |
| One value, no invariant | Scalar, enum, identifier, or existing domain type |
| One raw value with an invariant | Raw scalar -> field VO -> repository |
| Several cohesive values, no invariants | Named input/command; no aggregate or VOs required |
| Several cohesive values with invariants | Raw input -> private validated aggregate -> repository |
| Already-valid value | Pass its VO/entity directly |

For example, a single reset email does not need `PasswordResetInput` plus a
one-field aggregate:

```dart
Future<Either<AuthFailure, Unit>> call(String rawEmail) async {
  return EmailAddress.create(rawEmail).match(
    (failure) async => left(
      AuthFailure.validation([
        ValidationError(field: 'email', message: '', code: failure.code),
      ]),
    ),
    _repository.requestPasswordReset,
  );
}

abstract class AuthRepository {
  Future<Either<AuthFailure, Unit>> requestPasswordReset(EmailAddress email);
}
```

Several cohesive values with no deterministic invariant may still use a named
input/command to avoid a long signature. That type groups values; it does not
claim they are validated and does not require ceremonial VOs.

### Multi-field input with invariants

Raw application input is deliberately allowed to be invalid. A privately
constructed aggregate represents the successful transition to validated domain
values.

```dart
// domain/input/login_input.dart
class LoginInput {
  const LoginInput({required this.email, required this.password});

  final String email;
  final String password;
}
```

```dart
// domain/value/login_credentials.dart
class LoginCredentials {
  const LoginCredentials._({required this.email, required this.password});

  final EmailAddress email;
  final Password password;

  static Either<List<ValidationError>, LoginCredentials> create({
    required String email,
    required String password,
  }) {
    final emailResult = EmailAddress.create(email);
    final passwordResult = Password.create(password);
    final errors = <ValidationError>[];
    EmailAddress? validEmail;
    Password? validPassword;

    emailResult.fold(
      (failure) => errors.add(
        ValidationError(field: 'email', message: '', code: failure.code),
      ),
      (value) => validEmail = value,
    );
    passwordResult.fold(
      (failure) => errors.add(
        ValidationError(field: 'password', message: '', code: failure.code),
      ),
      (value) => validPassword = value,
    );

    if (errors.isNotEmpty) return left(errors);
    return right(
      LoginCredentials._(email: validEmail!, password: validPassword!),
    );
  }
}
```

For a larger form with deterministic invariants, add its cohesive fields and
field VOs to one flow-specific aggregate. Do not return positional records that
erase field meaning. If those fields have no deterministic invariants, a named
input/command alone is sufficient.

---

## 4) Domain — Repository Contract and Use Case

The use case owns the final deterministic gate. The repository accepts a field
VO for one invariant or a validated aggregate for several cohesive invariants.

```dart
abstract class AuthRepository {
  Future<Either<AuthFailure, AuthSessionEntity>> login(
    LoginCredentials credentials,
  );
}
```

```dart
class LoginUserUseCase {
  LoginUserUseCase(this._repository);

  final AuthRepository _repository;

  Future<Either<AuthFailure, AuthSessionEntity>> call(LoginInput input) async {
    final credentials = LoginCredentials.create(
      email: input.email,
      password: input.password,
    );

    return credentials.match(
      (errors) async => left(AuthFailure.validation(errors)),
      _repository.login,
    );
  }
}
```

The data layer then unwraps the validated type into a wire model:

```dart
factory LoginRequestModel.fromCredentials(LoginCredentials credentials) {
  return LoginRequestModel(
    email: credentials.email.value,
    password: credentials.password.value,
  );
}
```

---

## 5) Presentation — Bloc/Cubit Patterns (Real‑Time Validation)

Blocs/Cubits expose field values + error strings in state and validate on every change using VOs. On submit, they check errors and call the use case.

Tip: make error display **touched‑aware**.

- Keep validation real‑time (so state is always consistent).
- Track `...Touched` per field.
- Only display errors when the user has interacted with that specific field (or after a submit attempt).

This prevents “phantom errors” when cross‑field validation recomputes errors in fields the user has not interacted with yet (e.g., `confirmPassword` mismatch, `newPassword != currentPassword`).

```dart
// presentation/bloc/sign_up_bloc.dart (sketch)
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecase/sign_up_usecase.dart';
import '../../domain/value/display_name.dart';
import '../../domain/value/email_address.dart';
import '../../domain/value/password.dart';
import '../../domain/value/confirm_password.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  SignUpBloc(this._signUp) : super(const SignUpState()) {
    on<FullnameChanged>(_onFullname);
    on<EmailChanged>(_onEmail);
    on<PasswordChanged>(_onPassword);
    on<ConfirmChanged>(_onConfirm);
    on<SignUpSubmitted>(_onSubmitted);
  }

  final SignUpUseCase _signUp;

  void _onFullname(FullnameChanged e, Emitter<SignUpState> emit) {
    final r = DisplayName.create(e.fullname);
    emit(state.copyWith(fullname: e.fullname, fullnameError: r.fold((f) => f.userMessage, (_) => null)));
  }
  void _onEmail(EmailChanged e, Emitter<SignUpState> emit) {
    final r = EmailAddress.create(e.email);
    emit(state.copyWith(email: e.email, emailError: r.fold((f) => f.userMessage, (_) => null)));
  }
  void _onPassword(PasswordChanged e, Emitter<SignUpState> emit) {
    final r = Password.create(e.password);
    emit(state.copyWith(password: e.password, passwordError: r.fold((f) => f.userMessage, (_) => null)));
    if (state.confirm.isNotEmpty) {
      final c = ConfirmPassword.create(e.password, state.confirm);
      emit(state.copyWith(confirmError: c.fold((f) => f.userMessage, (_) => null)));
    }
  }
  void _onConfirm(ConfirmChanged e, Emitter<SignUpState> emit) {
    final r = ConfirmPassword.create(state.password, e.confirm);
    emit(state.copyWith(confirm: e.confirm, confirmError: r.fold((f) => f.userMessage, (_) => null)));
  }

  Future<void> _onSubmitted(SignUpSubmitted e, Emitter<SignUpState> emit) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(submitting: true, message: null));
    final res = await _signUp(fullname: state.fullname, email: state.email, password: state.password);
    res.match(
      (failure) => emit(state.copyWith(submitting: false, message: failure.toString())),
      (_) => emit(state.copyWith(submitting: false, success: true)),
    );
  }
}
```

### Touched‑aware UI wiring (example)

```dart
TextField(
  onChanged: (v) => context.read<SignUpBloc>().add(EmailChanged(v)),
  decoration: InputDecoration(
    labelText: 'Email',
    // Only show once the user touched the field.
    errorText: context.select((SignUpBloc b) {
      final s = b.state;
      return s.emailTouched ? s.emailError : null;
    }),
  ),
)
```

---

## 6) UI Wiring (Framework Examples)

Flutter example (widget wiring):

```dart
// Example field wiring
TextField(
  onChanged: (v) => context.read<SignUpBloc>().add(EmailChanged(v)),
  decoration: InputDecoration(
    labelText: 'Email',
    errorText: context.select((SignUpBloc b) => b.state.emailError),
  ),
)

TextField(
  obscureText: true,
  onChanged: (v) => context.read<SignUpBloc>().add(PasswordChanged(v)),
  decoration: InputDecoration(
    labelText: 'Password',
    errorText: context.select((SignUpBloc b) => b.state.passwordError),
  ),
)

TextField(
  obscureText: true,
  onChanged: (v) => context.read<SignUpBloc>().add(ConfirmChanged(v)),
  decoration: InputDecoration(
    labelText: 'Confirm Password',
    errorText: context.select((SignUpBloc b) => b.state.confirmError),
  ),
)
```

---

## 7) Integration Tips

- Keep validation rules in domain field VOs; controllers call `VO.create()` and
  store stable field errors for presentation to localize.
- Invoke the field VO or aggregate factory in the use case even when presentation
  already performed pre-flight validation.
- Make repository contracts accept a VO for one validated field or an aggregate
  for several cohesive invariants. Use a scalar/input/command when no invariant
  needs proof.
- Consider adding tests for:
  - VO create() happy/sad paths
  - aggregate error collection and normalization when several invariants exist
  - use case early-return on invalid raw input
  - request-model mapping from the aggregate
  - Controller mapping from VO failures to field errors

---

This cookbook is intentionally self-contained so you can reuse it across projects without referencing project-specific paths.

See [ADR 0017](../../ADR/records/0017-input-cardinality-and-validation-boundaries.md)
for the cardinality, cohesion, and invariant decision policy.
