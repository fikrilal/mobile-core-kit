import '../../../../core/session/session_manager.dart';
import '../entity/logout_request_entity.dart';
import 'logout_remote_usecase.dart';

/// Orchestrates a full logout flow:
/// 1) best-effort remote session revocation (current session)
/// 2) always clear local session
class LogoutFlowUseCase {
  LogoutFlowUseCase({
    required LogoutRemoteUseCase logoutRemote,
    required SessionManager sessionManager,
  }) : _logoutRemote = logoutRemote,
       _sessionManager = sessionManager;

  final LogoutRemoteUseCase _logoutRemote;
  final SessionManager _sessionManager;

  static const Duration _remoteRevokeTimeout = Duration(seconds: 5);

  Future<void> call({String reason = 'manual_logout'}) async {
    final refreshToken = _sessionManager.session?.tokens.refreshToken;

    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _logoutRemote(
          LogoutRequestEntity(refreshToken: refreshToken),
        ).timeout(_remoteRevokeTimeout);
      } catch (_) {
        // Remote logout is best-effort; local session is always cleared.
      }
    }

    await _sessionManager.logout(reason: reason);
  }
}
