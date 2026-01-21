import 'package:mobile_core_kit/core/session/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/core/user/entity/user_entity.dart';

abstract class SessionRepository {
  Future<void> saveSession(AuthSessionEntity session);

  Future<AuthSessionEntity?> loadSession();

  Future<UserEntity?> loadCachedUser();

  Future<void> clearSession();
}
