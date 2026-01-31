import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/domain/session/session_failure.dart';
import 'package:mobile_core_kit/core/domain/user/entity/user_entity.dart';

/// Core abstraction for fetching the current signed-in user ("me") remotely.
///
/// The user feature provides the implementation via DI.
abstract class CurrentUserFetcher {
  Future<Either<SessionFailure, UserEntity>> fetch();
}
