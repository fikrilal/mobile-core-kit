/// Motion duration tokens used across the app.
///
/// These are intentionally small, fixed values (design tokens) so animations
/// feel consistent and can be tuned in one place.
///
/// Prefer using these constants over inline `Duration(...)` literals.
class MotionDurations {
  MotionDurations._();

  /// Delay before showing the app startup gate overlay.
  ///
  /// Used by: `_AppStartupGate` in `lib/app.dart`.
  ///
  /// Why: avoids a "flash" on fast startups by only showing the overlay if
  /// startup is still not ready after this delay.
  static const Duration startupGateShowDelay = Duration(milliseconds: 200);

  /// Minimum time the startup gate overlay stays visible once shown.
  ///
  /// Used by: `_AppStartupGate` in `lib/app.dart`.
  ///
  /// Why: prevents a quick show/hide blink if startup becomes ready right after
  /// the overlay appears.
  static const Duration startupGateMinVisible = Duration(milliseconds: 250);

  /// Fade duration for the startup gate overlay.
  ///
  /// Used by: `_AppStartupGate` in `lib/app.dart`.
  ///
  /// Why: smooth transition to/from the overlay.
  static const Duration startupGateFadeDuration = Duration(milliseconds: 180);
}

