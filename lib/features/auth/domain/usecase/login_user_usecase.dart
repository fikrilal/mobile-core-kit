import 'package:fpdart/fpdart.dart';
import '../entity/login_request_entity.dart';
import '../entity/user_entity.dart';
import '../failure/auth_failure.dart';
import '../repository/auth_repository.dart';
import '../value/email_address.dart';
import '../value/login_password.dart';
import '../value/value_failure.dart';
import '../../../../core/network/api/api_response.dart';

class LoginUserUseCase {
  final AuthRepository _repository;

  LoginUserUseCase(this._repository);

  Future<Either<AuthFailure, UserEntity>> call(
    LoginRequestEntity request,
  ) async {
    // Final gate validation: email format + non-empty password
    final email = EmailAddress.create(request.email);
    final errors = <ValidationError>[];
    String normalizedEmail = request.email.trim();
    String normalizedPassword = request.password;

    email.fold(
      (f) => errors.add(
        ValidationError(
          field: 'email',
          message: f.userMessage,
          code: 'invalid_email',
        ),
      ),
      (_) {},
    );

    email.match((_) {}, (value) => normalizedEmail = value.value);

    final password = LoginPassword.create(request.password);
    password.fold(
      (f) => errors.add(
        ValidationError(
          field: 'password',
          message: f.userMessage,
          code: 'required',
        ),
      ),
      (value) => normalizedPassword = value.value,
    );

    if (errors.isNotEmpty) {
      return left<AuthFailure, UserEntity>(AuthFailure.validation(errors));
    }

    return _repository.login(
      LoginRequestEntity(email: normalizedEmail, password: normalizedPassword),
    );
  }
}
