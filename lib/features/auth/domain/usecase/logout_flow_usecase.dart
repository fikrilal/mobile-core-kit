import '../../../../core/session/session_manager.dart';
import 'revoke_sessions_usecase.dart';

/// Orchestrates a full logout flow:
/// 1) best-effort remote session revocation (logout all devices)
/// 2) always clear local session
class LogoutFlowUseCase {
  LogoutFlowUseCase({
    required RevokeSessionsUseCase revokeSessions,
    required SessionManager sessionManager,
  }) : _revokeSessions = revokeSessions,
       _sessionManager = sessionManager;

  final RevokeSessionsUseCase _revokeSessions;
  final SessionManager _sessionManager;

  static const Duration _remoteRevokeTimeout = Duration(seconds: 5);

  Future<void> call({String reason = 'manual_logout'}) async {
    final accessToken = _sessionManager.session?.tokens.accessToken;

    if (accessToken != null && accessToken.isNotEmpty) {
      try {
        await _revokeSessions().timeout(_remoteRevokeTimeout);
      } catch (_) {
        // Remote logout is best-effort; local session is always cleared.
      }
    }

    await _sessionManager.logout(reason: reason);
  }
}
