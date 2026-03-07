import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';
import 'package:mobile_core_kit/core/domain/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/entity/clear_profile_image_request_entity.dart';
import 'package:mobile_core_kit/features/account/subfeatures/profile/domain/repository/profile_image_repository.dart';

class ClearProfileImageUseCase {
  ClearProfileImageUseCase(
    this._profileImageRepository,
    this._currentUserFetcher,
  );

  final ProfileImageRepository _profileImageRepository;
  final CurrentUserFetcher _currentUserFetcher;

  Future<Either<AuthFailure, UserEntity>> call(
    ClearProfileImageRequestEntity request,
  ) async {
    final result = await _profileImageRepository.clearProfileImage(request);

    return result.match(
      (failure) => Future.value(left(failure)),
      (_) => _refreshCurrentUser(),
    );
  }

  Future<Either<AuthFailure, UserEntity>> _refreshCurrentUser() async {
    final result = await _currentUserFetcher.fetch();
    return result.mapLeft(_mapSessionFailure);
  }

  static AuthFailure _mapSessionFailure(SessionFailure failure) {
    return switch (failure.type) {
      SessionFailureType.network => const AuthFailure.network(),
      SessionFailureType.unauthenticated => const AuthFailure.unauthenticated(),
      SessionFailureType.tooManyRequests => const AuthFailure.tooManyRequests(),
      SessionFailureType.serverError => AuthFailure.serverError(
        failure.message,
      ),
      SessionFailureType.unexpected => AuthFailure.unexpected(
        message: failure.message,
      ),
    };
  }
}
