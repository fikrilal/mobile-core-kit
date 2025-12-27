import '../../features/auth/data/datasource/local/auth_local_datasource.dart';
import '../../features/auth/domain/entity/auth_session_entity.dart';
import '../../features/auth/domain/entity/auth_tokens_entity.dart';
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
  Future<void> saveSession(AuthSessionEntity session) async {
    final tokens = session.tokens;
    await _secure.save(
      access: tokens.accessToken,
      refresh: tokens.refreshToken,
      expiresIn: tokens.expiresIn,
    );
    final user = session.user;
    if (user != null) {
      await _local.cacheUserEntity(user);
    }
  }

  @override
  Future<AuthSessionEntity?> loadSession() async {
    final tokens = await _secure.read();
    if (tokens.access == null || tokens.refresh == null || tokens.expiresIn == null) {
      return null;
    }

    final model = await _local.getCachedUser();
    final user = model?.toEntity();

    return AuthSessionEntity(
      tokens: AuthTokensEntity(
        accessToken: tokens.access!,
        refreshToken: tokens.refresh!,
        tokenType: 'Bearer',
        expiresIn: tokens.expiresIn!,
      ),
      user: user,
    );
  }

  @override
  Future<void> clearSession() async {
    await _secure.clear();
    await _local.clearAll();
  }
}
