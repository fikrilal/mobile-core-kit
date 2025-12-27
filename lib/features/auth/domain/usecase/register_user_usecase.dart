import 'package:fpdart/fpdart.dart';
import '../entity/register_request_entity.dart';
import '../entity/auth_session_entity.dart';
import '../repository/auth_repository.dart';
import '../failure/auth_failure.dart';
import '../value/email_address.dart';
import '../value/password.dart';
import '../value/value_failure.dart';
import '../../../../core/validation/validation_error.dart';
import '../value/person_name.dart';

class RegisterUserUseCase {
  final AuthRepository _repository;

  RegisterUserUseCase(this._repository);

  Future<Either<AuthFailure, AuthSessionEntity>> call(
    RegisterRequestEntity request,
  ) async {
    // Final gate validation: email format, password, required names.
    final email = EmailAddress.create(request.email);
    final password = Password.create(request.password);
    final firstName = PersonName.create(request.firstName);
    final lastName = PersonName.create(request.lastName);

    final errors = <ValidationError>[];
    String normalizedEmail = request.email.trim();
    String normalizedPassword = request.password;
    String normalizedFirstName = request.firstName.trim();
    String normalizedLastName = request.lastName.trim();

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

    password.fold(
      (f) => errors.add(
        ValidationError(
          field: 'password',
          message: f.userMessage,
          code: 'weak_password',
        ),
      ),
      (value) => normalizedPassword = value.value,
    );

    firstName.fold(
      (f) => errors.add(
        ValidationError(
          field: 'firstName',
          message: f.userMessage,
          code: 'invalid_first_name',
        ),
      ),
      (value) => normalizedFirstName = value.value,
    );

    lastName.fold(
      (f) => errors.add(
        ValidationError(
          field: 'lastName',
          message: f.userMessage,
          code: 'invalid_last_name',
        ),
      ),
      (value) => normalizedLastName = value.value,
    );

    if (errors.isNotEmpty) {
      return left<AuthFailure, AuthSessionEntity>(AuthFailure.validation(errors));
    }

    return _repository.register(
      RegisterRequestEntity(
        email: normalizedEmail,
        password: normalizedPassword,
        firstName: normalizedFirstName,
        lastName: normalizedLastName,
      ),
    );
  }
}
