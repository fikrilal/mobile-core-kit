import '../../features/auth/domain/entity/user_entity.dart';

abstract class SessionRepository {
  Future<void> saveSession(UserEntity user);

  Future<UserEntity?> loadSession();

  Future<void> clearSession();
}
