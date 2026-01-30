import 'package:mobile_core_kit/core/foundation/utilities/log_utils.dart';
import 'package:mobile_core_kit/core/runtime/push/push_token_registrar.dart';
import 'package:mobile_core_kit/core/session/session_push_token_revoker.dart';

class SessionPushTokenRevokerImpl implements SessionPushTokenRevoker {
  SessionPushTokenRevokerImpl(this._registrar);

  final String _tag = 'SessionPushTokenRevokerImpl';
  final PushTokenRegistrar _registrar;

  @override
  Future<void> revoke() async {
    try {
      await _registrar.revoke();
    } catch (e, st) {
      // Revoke is best-effort and must never throw.
      Log.warning('Push token revoke failed: $e', name: _tag);
      Log.debug('Stack trace: $st', name: _tag);
    }
  }
}
