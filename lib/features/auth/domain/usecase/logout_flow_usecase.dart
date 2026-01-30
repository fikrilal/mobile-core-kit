import 'package:mobile_core_kit/core/domain/session/session_driver.dart';
import 'package:mobile_core_kit/core/domain/session/session_push_token_revoker.dart';
import 'package:mobile_core_kit/features/auth/domain/entity/logout_request_entity.dart';
import 'package:mobile_core_kit/features/auth/domain/usecase/logout_remote_usecase.dart';

/// Orchestrates a full logout flow:
/// 1) best-effort remote session revocation (current session)
/// 2) always clear local session
class LogoutFlowUseCase {
  LogoutFlowUseCase({
    required LogoutRemoteUseCase logoutRemote,
    required SessionPushTokenRevoker pushTokenRevoker,
    required SessionDriver session,
  }) : _logoutRemote = logoutRemote,
       _pushTokenRevoker = pushTokenRevoker,
       _session = session;

  final LogoutRemoteUseCase _logoutRemote;
  final SessionPushTokenRevoker _pushTokenRevoker;
  final SessionDriver _session;

  static const Duration _pushRevokeTimeout = Duration(seconds: 2);
  static const Duration _remoteRevokeTimeout = Duration(seconds: 5);

  Future<void> call({String reason = 'manual_logout'}) async {
    final refreshToken = _session.session?.tokens.refreshToken;

    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _pushTokenRevoker.revoke().timeout(_pushRevokeTimeout);
      } catch (_) {
        // Push token revoke is best-effort; local session is always cleared.
      }

      try {
        await _logoutRemote(
          LogoutRequestEntity(refreshToken: refreshToken),
        ).timeout(_remoteRevokeTimeout);
      } catch (_) {
        // Remote logout is best-effort; local session is always cleared.
      }
    }

    await _session.logout(reason: reason);
  }
}
