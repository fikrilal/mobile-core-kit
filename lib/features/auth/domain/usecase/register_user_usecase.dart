import 'package:fpdart/fpdart.dart';
import '../entity/register_request_entity.dart';
import '../entity/auth_session_entity.dart';
import '../repository/auth_repository.dart';
import '../failure/auth_failure.dart';
import '../value/email_address.dart';
import '../value/password.dart';
import '../value/display_name.dart';
import '../value/value_failure.dart';
import '../../../../core/network/api/api_response.dart';

class RegisterUserUseCase {
  final AuthRepository _repository;

  RegisterUserUseCase(this._repository);

  Future<Either<AuthFailure, AuthSessionEntity>> call(
    RegisterRequestEntity request,
  ) async {
    // Final gate validation: email format, strong password, display name
    final email = EmailAddress.create(request.email);
    final password = Password.create(request.password);
    final displayName = DisplayName.create(request.displayName);

    final errors = <ValidationError>[];
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
    password.fold(
      (f) => errors.add(
        ValidationError(
          field: 'password',
          message: f.userMessage,
          code: 'weak_password',
        ),
      ),
      (_) {},
    );
    displayName.fold(
      (f) => errors.add(
        ValidationError(
          field: 'display_name',
          message: f.userMessage,
          code: 'invalid_display_name',
        ),
      ),
      (_) {},
    );

    if (errors.isNotEmpty) {
      return left<AuthFailure, AuthSessionEntity>(AuthFailure.validation(errors));
    }

    return _repository.register(request);
  }
}
