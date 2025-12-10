# Validation Cookbook — Portable Patterns and Snippets

Portable, Bloc-first patterns for layered validation using Domain Value Objects (VOs) for rules, Bloc/Cubit for real-time feedback, and use cases as the final gate. Copy/paste the snippets and adapt names to your project.

Contents
- Domain primitives: ValueFailure and Value Objects
- Aggregated validation helper
- Use cases (submit-time validation) and repository contract
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

extension ValueFailureX on ValueFailure {
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

## 3) Domain — Aggregated Validation Helper

```dart
// domain/value/auth_validation_helper.dart (example for sign-in/sign-up)
import 'package:fpdart/fpdart.dart';
import 'display_name.dart';
import 'phone_number.dart';
import 'password.dart';
import 'strong_password.dart';
import 'confirm_password.dart';
import '../failure/value_failure.dart';

class AuthValidationHelper {
  static Either<List<ValueFailure>, (PhoneNumber, Password)> validateSignIn({
    required String phone,
    required String password,
  }) {
    final a = PhoneNumber.create(phone);
    final b = Password.create(password);
    final fails = <ValueFailure>[];
    a.fold(fails.add, (_) {});
    b.fold(fails.add, (_) {});
    return fails.isNotEmpty ? left(fails) : right((a.getRight().toNullable()!, b.getRight().toNullable()!));
  }

  static Either<List<ValueFailure>, (DisplayName, PhoneNumber, StrongPassword)> validateSignUp({
    required String fullname,
    required String phone,
    required String password,
  }) {
    final dn = DisplayName.create(fullname);
    final pn = PhoneNumber.create(phone);
    final sp = StrongPassword.create(password);
    final fails = <ValueFailure>[];
    dn.fold(fails.add, (_) {});
    pn.fold(fails.add, (_) {});
    sp.fold(fails.add, (_) {});
    return fails.isNotEmpty
        ? left(fails)
        : right((dn.getRight().toNullable()!, pn.getRight().toNullable()!, sp.getRight().toNullable()!));
  }

  static String firstError(List<ValueFailure> failures) => failures.isEmpty ? '' : failures.first.userMessage;
}
```

---

## 4) Domain — Repository Contract and Use Cases

```dart
// domain/repository/auth_repository.dart (minimal contract)
import 'package:fpdart/fpdart.dart';

class SignInRequest { final String phone; final String password; const SignInRequest(this.phone, this.password); }
class SignUpRequest { final String fullname; final String phone; final String password; final int coopId; const SignUpRequest(this.fullname, this.phone, this.password, this.coopId); }

class SignInData { const SignInData(); /* add fields as needed */ }

sealed class AuthFailure { const AuthFailure(); }
class NetworkFailure extends AuthFailure { const NetworkFailure(); }
class ValidationFailure extends AuthFailure { final String message; const ValidationFailure(this.message); }
class ServerFailure extends AuthFailure { final String? message; const ServerFailure([this.message]); }

abstract class AuthRepository {
  Future<Either<AuthFailure, SignInData>> signIn(SignInRequest request);
  Future<Either<AuthFailure, SignInData>> signUp(SignUpRequest request);
}
```

```dart
// domain/usecase/sign_in_usecase.dart
import 'package:fpdart/fpdart.dart';
import '../repository/auth_repository.dart';
import '../value/auth_validation_helper.dart';

class SignInUseCase {
  final AuthRepository _repo;
  SignInUseCase(this._repo);

  Future<Either<AuthFailure, SignInData>> call(String phone, String password) async {
    final v = AuthValidationHelper.validateSignIn(phone: phone, password: password);
    return v.fold(
      (fails) => left(ValidationFailure(AuthValidationHelper.firstError(fails))),
      (ok) => _repo.signIn(SignInRequest(ok.$1.value, ok.$2.value)),
    );
  }
}
```

```dart
// domain/usecase/sign_up_usecase.dart
import 'package:fpdart/fpdart.dart';
import '../repository/auth_repository.dart';
import '../value/auth_validation_helper.dart';

class SignUpUseCase {
  final AuthRepository _repo;
  SignUpUseCase(this._repo);

  Future<Either<AuthFailure, SignInData>> call({
    required String fullname,
    required String phone,
    required String password,
    required int coopId,
  }) async {
    final v = AuthValidationHelper.validateSignUp(fullname: fullname, phone: phone, password: password);
    return v.fold(
      (fails) => left(ValidationFailure(AuthValidationHelper.firstError(fails))),
      (ok) => _repo.signUp(SignUpRequest(ok.$1.value, ok.$2.value, ok.$3.value, coopId)),
    );
  }
}
```

---

## 5) Presentation — Bloc/Cubit Patterns (Real‑Time Validation)

Blocs/Cubits expose field values + error strings in state and validate on every change using VOs. On submit, they check errors and call the use case.

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

- Keep all validation logic in domain VOs; controllers should only call VO.create and display `userMessage`.
- Revalidate in use cases before building request entities; repositories should not do client-side validation.
- Consider adding tests for:
  - VO create() happy/sad paths
  - Use case early-return on invalid input
  - Controller mapping from VO failures to error strings

---

This cookbook is intentionally self-contained so you can reuse it across projects without referencing project-specific paths.
