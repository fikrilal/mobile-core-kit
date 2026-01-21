import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/session/session_failure.dart';

/// Core abstraction for refreshing session tokens.
///
/// The auth feature provides the implementation via DI.
abstract class TokenRefresher {
  Future<Either<SessionFailure, AuthTokensEntity>> refresh(String refreshToken);
}
