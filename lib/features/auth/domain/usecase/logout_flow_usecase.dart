import '../../../../core/session/session_manager.dart';
import '../entity/refresh_request_entity.dart';
import 'logout_user_usecase.dart';

/// Orchestrates a full logout flow:
/// 1) best-effort remote logout (revoke refresh token)
/// 2) always clear local session
class LogoutFlowUseCase {
  LogoutFlowUseCase({
    required LogoutUserUseCase logoutUser,
    required SessionManager sessionManager,
  }) : _logoutUser = logoutUser,
       _sessionManager = sessionManager;

  final LogoutUserUseCase _logoutUser;
  final SessionManager _sessionManager;

  Future<void> call({String reason = 'manual_logout'}) async {
    final refreshToken = _sessionManager.session?.tokens.refreshToken;

    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _logoutUser(
          RefreshRequestEntity(refreshToken: refreshToken),
        );
      } catch (_) {
        // Remote logout is best-effort; local session is always cleared.
      }
    }

    await _sessionManager.logout(reason: reason);
  }
}

