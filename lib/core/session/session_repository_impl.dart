import 'package:mobile_core_kit/core/services/startup_metrics/startup_metrics.dart';
import 'package:mobile_core_kit/core/session/session_repository.dart';
import 'package:mobile_core_kit/core/storage/secure/token_secure_storage.dart';
import 'package:mobile_core_kit/features/auth/data/datasource/local/auth_local_datasource.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_session_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/auth_tokens_entity.dart';
import 'package:mobile_core_kit/features/user/domain/entity/user_entity.dart';

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
      expiresAtMs: tokens.expiresAt?.millisecondsSinceEpoch,
    );
    final user = session.user;
    if (user != null) {
      await _local.cacheUserEntity(user);
    } else {
      // Prevent stale profile data if a tokens-only session is persisted.
      await _local.clearAll();
    }
  }

  @override
  Future<AuthSessionEntity?> loadSession() async {
    StartupMetrics.instance.mark(StartupMilestone.secureStorageReadStart);
    final tokens = await _secure.read();
    StartupMetrics.instance.mark(StartupMilestone.secureStorageReadComplete);
    if (tokens.access == null ||
        tokens.refresh == null ||
        tokens.expiresIn == null) {
      return null;
    }

    return AuthSessionEntity(
      tokens: AuthTokensEntity(
        accessToken: tokens.access!,
        refreshToken: tokens.refresh!,
        tokenType: 'Bearer',
        expiresIn: tokens.expiresIn!,
        expiresAt: tokens.expiresAtMs == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(tokens.expiresAtMs!),
      ),
    );
  }

  @override
  Future<UserEntity?> loadCachedUser() async {
    final model = await _local.getCachedUser();
    return model?.toEntity();
  }

  @override
  Future<void> clearSession() async {
    await _secure.clear();
    await _local.clearAll();
  }
}
