import 'package:fpdart/fpdart.dart';
import 'package:mobile_core_kit/core/session/session_failure.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';

/// Core abstraction for fetching the current signed-in user ("me") remotely.
///
/// The user feature provides the implementation via DI.
abstract class CurrentUserFetcher {
  Future<Either<SessionFailure, UserEntity>> fetch();
}

