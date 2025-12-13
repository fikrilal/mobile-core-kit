import 'package:fpdart/fpdart.dart';
import '../entity/auth_session_entity.dart';
import '../failure/auth_failure.dart';
import '../repository/auth_repository.dart';

class GoogleMobileSignInUseCase {
  final AuthRepository _repository;
  GoogleMobileSignInUseCase(this._repository);

  Future<Either<AuthFailure, AuthSessionEntity>> call({required String idToken}) {
    return _repository.googleMobileSignIn(idToken: idToken);
  }
}
