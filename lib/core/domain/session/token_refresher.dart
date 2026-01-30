import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/session/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';

/// Core abstraction for refreshing session tokens.
///
/// The auth feature provides the implementation via DI.
abstract class TokenRefresher {
  Future<Either<SessionFailure, AuthTokensEntity>> refresh(String refreshToken);
}
