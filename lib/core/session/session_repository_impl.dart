import '../../features/auth/data/datasource/local/auth_local_datasource.dart';
import '../../features/auth/domain/entity/user_entity.dart';
import '../storage/secure/token_secure_storage.dart';
import 'session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final AuthLocalDataSource _local;
  final TokenSecureStorage _secure;

  SessionRepositoryImpl({
    required AuthLocalDataSource local,
    TokenSecureStorage? secure,
  }) : _local = local,
       _secure = secure ?? const TokenSecureStorage();

  @override
  Future<void> saveSession(UserEntity user) async {
    // save auth tokens only
    if (user.accessToken != null &&
        user.refreshToken != null &&
        user.expiresIn != null) {
      await _secure.save(
        access: user.accessToken!,
        refresh: user.refreshToken!,
        expiresIn: user.expiresIn!,
      );
    }
  }

  @override
  Future<UserEntity?> loadSession() async {
    final tokens = await _secure.read();
    final model = await _local.getCachedUser();
    if (model == null) return null;
    if (tokens.access == null ||
        tokens.refresh == null ||
        tokens.expiresIn == null) {
      return null;
    }
    final user = model.toEntity();
    return _attachTokens(
      user,
      tokens.access!,
      tokens.refresh!,
      tokens.expiresIn!,
    );
  }

  @override
  Future<void> clearSession() async {
    await _secure.clear();
    await _local.clearAll();
  }

  UserEntity _attachTokens(
    UserEntity u,
    String access,
    String refresh,
    int expires,
  ) => UserEntity(
    id: u.id,
    email: u.email,
    displayName: u.displayName,
    emailVerified: u.emailVerified,
    createdAt: u.createdAt,
    avatarUrl: u.avatarUrl,
    accessToken: access,
    refreshToken: refresh,
    expiresIn: expires,
  );
}
