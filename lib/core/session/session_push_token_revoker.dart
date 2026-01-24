/// Abstraction for revoking the current session's push token on the backend.
///
/// This is modeled as a **session-level** concern so feature domain code
/// (e.g., auth logout flow) can request best-effort revocation without
/// importing infrastructure SDKs or HTTP wrappers.
abstract interface class SessionPushTokenRevoker {
  /// Best-effort revoke. Implementations must never throw.
  Future<void> revoke();
}
