/// App-wide domain events.
///
/// This file should only contain:
/// - The [AppEvent] base class
/// - Truly cross-cutting events that span multiple features
///   (e.g. session lifecycle, global settings changes)
///
/// Feature- or domain-specific events should live closer to their feature,
/// for example:
/// - `features/auth/events/auth_events.dart`
/// - `features/library/events/library_events.dart`
///
/// If you want a single "barrel" of all events, re-export those feature
/// event files from here instead of adding more concrete classes directly.

abstract class AppEvent {
  const AppEvent();
}

class SessionExpired extends AppEvent {
  final String? reason;

  const SessionExpired({this.reason});
}

/// Fired whenever a session is intentionally cleared (e.g. user logout).
///
/// Unlike [SessionExpired], this event represents an expected transition and
/// should not surface warning UI to the user.
class SessionCleared extends AppEvent {
  final String? reason;

  const SessionCleared({this.reason});
}

/// Fired when user reading goals (or daily reading intention) change.
///
/// Consumers like weekly recap should refresh their data when this is published.
class ReadingGoalsChanged extends AppEvent {
  const ReadingGoalsChanged();
}
