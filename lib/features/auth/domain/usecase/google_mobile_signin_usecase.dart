import 'package:fpdart/fpdart.dart';
import '../entity/user_entity.dart';
import '../failure/auth_failure.dart';
import '../repository/auth_repository.dart';

class GoogleMobileSignInUseCase {
  final AuthRepository _repository;
  GoogleMobileSignInUseCase(this._repository);

  Future<Either<AuthFailure, UserEntity>> call({required String idToken}) {
    return _repository.googleMobileSignIn(idToken: idToken);
  }
}
