import 'package:mobile_core_kit/core/domain/session/entity/auth_session_entity.dart';

/// Domain-friendly abstraction over the current session.
///
/// Feature domain code must not depend on runtime orchestrators like
/// `SessionManager`, but it may need to:
/// - read the current session tokens (for best-effort remote revocation), and
/// - clear the local session.
abstract interface class SessionDriver {
  AuthSessionEntity? get session;

  Future<void> logout({String reason});
}
