import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/auth/auth_failure.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';
import 'package:mobile_core_kit/core/domain/user/current_user_fetcher.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';

Future<Either<AuthFailure, UserEntity>>
refreshCurrentUserAfterProfileImageMutation(
  CurrentUserFetcher currentUserFetcher,
) async {
  final result = await currentUserFetcher.fetch();
  return result.mapLeft(_mapSessionFailureToAuthFailure);
}

AuthFailure _mapSessionFailureToAuthFailure(SessionFailure failure) {
  return switch (failure.type) {
    SessionFailureType.network => const AuthFailure.network(),
    SessionFailureType.unauthenticated => const AuthFailure.unauthenticated(),
    SessionFailureType.tooManyRequests => const AuthFailure.tooManyRequests(),
    SessionFailureType.serverError => AuthFailure.serverError(failure.message),
    SessionFailureType.unexpected => AuthFailure.unexpected(
      message: failure.message,
    ),
  };
}
