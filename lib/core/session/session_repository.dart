import '../../features/auth/domain/entity/auth_session_entity.dart';

abstract class SessionRepository {
  Future<void> saveSession(AuthSessionEntity session);

  Future<AuthSessionEntity?> loadSession();

  Future<void> clearSession();
}
