enum SessionFailureType {
  network,
  unauthenticated,
  tooManyRequests,
  serverError,
  unexpected,
}

/// Core session-level failure type used for cross-cutting orchestration.
///
/// This intentionally models only the subset of failure semantics needed by
/// session orchestration (startup hydration, token refresh, logout decisions).
class SessionFailure {
  const SessionFailure._(this.type, {this.message});

  final SessionFailureType type;
  final String? message;

  const SessionFailure.network() : this._(SessionFailureType.network);

  const SessionFailure.unauthenticated()
    : this._(SessionFailureType.unauthenticated);

  const SessionFailure.tooManyRequests()
    : this._(SessionFailureType.tooManyRequests);

  const SessionFailure.serverError([String? message])
    : this._(SessionFailureType.serverError, message: message);

  const SessionFailure.unexpected([String? message])
    : this._(SessionFailureType.unexpected, message: message);

  bool get isUnauthenticated => type == SessionFailureType.unauthenticated;

  @override
  String toString() =>
      'SessionFailure(type: $type${message == null ? '' : ', message: $message'})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionFailure &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          message == other.message;

  @override
  int get hashCode => Object.hash(type, message);
}
